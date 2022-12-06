package com.example.sms_mms;

import static android.content.Intent.CATEGORY_APP_MESSAGING;
import static android.content.Intent.CATEGORY_DEFAULT;
import static android.content.Intent.FLAG_ACTIVITY_NEW_TASK;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.os.Environment;
import android.provider.Telephony;
import android.telephony.SmsManager;
import android.util.Base64;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.FileProvider;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Objects;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * SmsMmsPlugin
 */
public class SmsMmsPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;

    String DEFAULT_MESSAGE_PACKAGE_NAME = "com.google.android.apps.messaging";

    @Nullable
    private Context context;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "sms_mms");
        context = flutterPluginBinding.getApplicationContext();
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {

    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("sendMms")) {

            @Nullable String filePath = call.argument("path");
            List<String> address = call.argument("recipientNumbers");
            String message = call.argument("message");

            StringBuilder addressString = new StringBuilder();

            for (int i = 0; i < (address != null ? address.size() : 0); i++) {
                addressString.append(address.get(i)).append(";");
            }

            sendSMS(filePath, addressString.toString(), message);

        } else {
            result.notImplemented();
        }
    }

    protected void sendSMS(@Nullable String filePath, String address, String message) {

        @Nullable Uri fileUri = null;

        if (filePath != null) {
            File file = new File(filePath);
            assert context != null;
            String providerAuthority = context.getPackageName() + ".flutter.mms";
            fileUri = FileProvider.getUriForFile(context, providerAuthority, file);
        }

        Intent smsIntent = new Intent(Intent.ACTION_VIEW);

        smsIntent.addFlags(FLAG_ACTIVITY_NEW_TASK);
        smsIntent.setData(Uri.parse("mmsto:"));
        smsIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        smsIntent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
        smsIntent.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY);
        smsIntent.putExtra("address", address);
        smsIntent.putExtra("sms_body", message);

        try {
            if (filePath != null) {
                smsIntent.putExtra(Intent.EXTRA_STREAM, fileUri);
                context.grantUriPermission(DEFAULT_MESSAGE_PACKAGE_NAME, fileUri, Intent.FLAG_GRANT_WRITE_URI_PERMISSION | Intent.FLAG_GRANT_READ_URI_PERMISSION);
            }
            context.startActivity(smsIntent);
        } catch (android.content.ActivityNotFoundException ex) {
            Log.e("ERROR", Objects.requireNonNull(ex.getMessage()));
            Toast.makeText(context,
                    "SMS failed, please try again later.", Toast.LENGTH_SHORT).show();
        }
    }
}
