package com.example.sms_mms;

import static android.content.Intent.EXTRA_STREAM;
import static android.content.Intent.FLAG_ACTIVITY_NEW_TASK;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.provider.Telephony;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.FileProvider;

import java.io.File;
import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * SmsMmsPlugin
 */
public class SmsMmsPlugin implements FlutterPlugin, MethodCallHandler {

    @Nullable
    private Context context;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        /// The MethodChannel that will the communication between Flutter and native Android
        ///
        /// This local reference serves to register the plugin with the Flutter Engine and unregister it
        /// when the Flutter Engine is detached from the Activity
        MethodChannel channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "sms_mms");
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

            try {
                sendSMS(filePath, addressString.toString(), message);
            } catch (Exception e) {
                Toast.makeText(context, e.getMessage(), Toast.LENGTH_SHORT).show();
            }

        } else {
            result.notImplemented();
        }
    }

    protected void sendSMS(@Nullable String filePath, String address, String message) throws Exception {

        @Nullable Uri fileUri = null;
        String DEFAULT_MESSAGE_PACKAGE_NAME = "";


        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
            String packageName = Telephony.Sms.getDefaultSmsPackage(context);
            if(packageName != null) {
                DEFAULT_MESSAGE_PACKAGE_NAME = packageName;
            }
            if(packageName == null) {
                throw new Exception("Default sms app not found");
            }
        }

        if (filePath != null) {
            File file = new File(filePath);
            assert context != null;
            String providerAuthority = context.getPackageName() + ".flutter.mms";
            fileUri = FileProvider.getUriForFile(context, providerAuthority, file);
        }

        String action = filePath != null ? Intent.ACTION_SEND : Intent.ACTION_VIEW;


        Intent shareIntent = new Intent(action);
        shareIntent.addFlags(FLAG_ACTIVITY_NEW_TASK);
        shareIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK);
        shareIntent.putExtra("sms_body", message);

        if(filePath != null) {
            shareIntent.setData(fileUri);
            Uri returnUri = shareIntent.getData();
            String mimeType = context.getContentResolver().getType(returnUri);
            shareIntent.setType(mimeType);
            shareIntent.putExtra(EXTRA_STREAM, fileUri);
            shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            if (context != null) {
                context.grantUriPermission(DEFAULT_MESSAGE_PACKAGE_NAME, fileUri, Intent.FLAG_GRANT_WRITE_URI_PERMISSION | Intent.FLAG_GRANT_READ_URI_PERMISSION);
            }
            shareIntent.putExtra("address", address);
        } else {
            shareIntent.setData(Uri.fromParts("sms", address, null));
        }

        shareIntent.setPackage(DEFAULT_MESSAGE_PACKAGE_NAME);

        try {
            if (context != null) {
                context.startActivity(shareIntent);
            }
        } catch (Exception e) {
            if(filePath != null) {
                throw new Exception("File format not supported by Messages");
            } else {
                throw new Exception("Unable to launch Messages");
            }
        }
    }
}
