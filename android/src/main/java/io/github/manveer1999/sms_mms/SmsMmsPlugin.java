package io.github.manveer1999.sms_mms;

import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.provider.Telephony;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.FileProvider;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** SmsMmsPlugin */
public class SmsMmsPlugin implements FlutterPlugin, MethodCallHandler {

    /** Cache subdirectory shared through {@link MmsProvider}, see res/xml/file_paths.xml. */
    private static final String ATTACHMENT_DIR = "sms_mms";

    /** Copies older than this are deleted on the next send. */
    private static final long ATTACHMENT_MAX_AGE_MS = 24L * 60 * 60 * 1000;

    /** Android does not report whether the user sent the message. */
    private static final String RESULT_UNKNOWN = "unknown";

    @Nullable private MethodChannel channel;
    @Nullable private Context context;
    private final ExecutorService executor = Executors.newSingleThreadExecutor();
    private final Handler mainHandler = new Handler(Looper.getMainLooper());

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        context = binding.getApplicationContext();
        channel = new MethodChannel(binding.getBinaryMessenger(), "sms_mms");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        if (channel != null) {
            channel.setMethodCallHandler(null);
            channel = null;
        }
        context = null;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (!call.method.equals("sendMms")) {
            result.notImplemented();
            return;
        }
        final Context ctx = context;
        if (ctx == null) {
            result.error("not_attached", "Plugin is not attached to an engine", null);
            return;
        }

        List<String> recipients = call.argument("recipientNumbers");
        final String message = call.argument("message");
        final List<String> paths = call.argument("paths");
        final String address = recipients == null ? "" : TextUtils.join(";", recipients);

        // Copying attachments touches the disk, so it runs off the main thread.
        executor.execute(() -> {
            final ArrayList<Uri> uris;
            try {
                uris = copyAttachments(ctx, paths);
            } catch (IOException e) {
                mainHandler.post(() -> result.error("file_not_found", e.getMessage(), null));
                return;
            }
            mainHandler.post(() -> launch(ctx, address, message, uris, result));
        });
    }

    private void launch(Context ctx, String address, @Nullable String message,
                        ArrayList<Uri> uris, Result result) {
        Intent intent = buildIntent(ctx, address, message, uris);

        // Prefer the default SMS app so the user is not shown a chooser. Some devices,
        // tablets without telephony for example, have none; let the system pick then.
        String smsPackage = Telephony.Sms.getDefaultSmsPackage(ctx);
        if (smsPackage != null) {
            intent.setPackage(smsPackage);
            for (Uri uri : uris) {
                ctx.grantUriPermission(smsPackage, uri, Intent.FLAG_GRANT_READ_URI_PERMISSION);
            }
        }

        try {
            ctx.startActivity(intent);
            result.success(RESULT_UNKNOWN);
        } catch (ActivityNotFoundException e) {
            if (smsPackage == null) {
                result.error("no_sms_app", "No app on this device can send messages", null);
                return;
            }
            // The default SMS app rejected the attachment type; offer every app that accepts it.
            intent.setPackage(null);
            try {
                ctx.startActivity(intent);
                result.success(RESULT_UNKNOWN);
            } catch (ActivityNotFoundException e2) {
                result.error("no_sms_app", "No messaging app accepts this attachment type", null);
            }
        }
    }

    private static Intent buildIntent(Context ctx, String address, @Nullable String message,
                                      ArrayList<Uri> uris) {
        Intent intent;
        if (uris.isEmpty()) {
            intent = new Intent(Intent.ACTION_VIEW, Uri.fromParts("sms", address, null));
        } else {
            if (uris.size() == 1) {
                intent = new Intent(Intent.ACTION_SEND);
                intent.putExtra(Intent.EXTRA_STREAM, uris.get(0));
            } else {
                intent = new Intent(Intent.ACTION_SEND_MULTIPLE);
                intent.putParcelableArrayListExtra(Intent.EXTRA_STREAM, uris);
            }
            intent.setType(mimeTypeFor(ctx, uris));
            intent.putExtra("address", address);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        }
        intent.putExtra("sms_body", message);
        // Without these the messaging app can resume an old conversation from recents
        // instead of opening a new message (fixed in 0.0.2+1).
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        return intent;
    }

    /** One shared type for all attachments, widened to a wildcard when they differ. */
    private static String mimeTypeFor(Context ctx, List<Uri> uris) {
        String common = null;
        for (Uri uri : uris) {
            String type = ctx.getContentResolver().getType(uri);
            if (type == null) return "*/*";
            if (common == null) {
                common = type;
            } else if (!common.equals(type)) {
                String major = type.substring(0, type.indexOf('/'));
                common = common.startsWith(major + "/") ? major + "/*" : "*/*";
            }
        }
        return common == null ? "*/*" : common;
    }

    /**
     * Copies each attachment into the plugin's cache directory and returns content URIs for
     * the copies. The FileProvider then only needs to expose that one directory, whatever
     * path the caller passed in.
     */
    private static ArrayList<Uri> copyAttachments(Context ctx, @Nullable List<String> paths)
            throws IOException {
        ArrayList<Uri> uris = new ArrayList<>();
        if (paths == null || paths.isEmpty()) return uris;

        File dir = new File(ctx.getCacheDir(), ATTACHMENT_DIR);
        if (!dir.isDirectory() && !dir.mkdirs()) {
            throw new IOException("Cannot create " + dir);
        }
        deleteStaleCopies(dir);

        String authority = ctx.getPackageName() + ".flutter.mms";
        for (int i = 0; i < paths.size(); i++) {
            File source = new File(paths.get(i));
            if (!source.isFile()) {
                throw new IOException("Attachment not found: " + source.getPath());
            }
            // A per-send subdirectory keeps the original file name, which some messaging
            // apps show to the recipient, without clashing with earlier sends.
            File sendDir = new File(dir, System.currentTimeMillis() + "_" + i);
            if (!sendDir.mkdirs()) {
                throw new IOException("Cannot create " + sendDir);
            }
            File copy = new File(sendDir, source.getName());
            copy(source, copy);
            uris.add(FileProvider.getUriForFile(ctx, authority, copy));
        }
        return uris;
    }

    private static void copy(File from, File to) throws IOException {
        try (InputStream in = new FileInputStream(from); OutputStream out = new FileOutputStream(to)) {
            byte[] buffer = new byte[64 * 1024];
            int n;
            while ((n = in.read(buffer)) != -1) {
                out.write(buffer, 0, n);
            }
        }
    }

    private static void deleteStaleCopies(File dir) {
        File[] entries = dir.listFiles();
        if (entries == null) return;
        long cutoff = System.currentTimeMillis() - ATTACHMENT_MAX_AGE_MS;
        for (File entry : entries) {
            if (entry.lastModified() < cutoff) deleteRecursively(entry);
        }
    }

    private static void deleteRecursively(File file) {
        File[] children = file.listFiles();
        if (children != null) {
            for (File child : children) deleteRecursively(child);
        }
        //noinspection ResultOfMethodCallIgnored
        file.delete();
    }
}
