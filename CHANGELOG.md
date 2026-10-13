## 0.1.0

**Breaking changes**

* `SmsMms.send` now returns `Future<SmsMmsResult>`. Code that awaited the old `Future<void>` still compiles.
* Android errors are now thrown as `PlatformException` instead of being shown as a Toast.
* The Android package moved from `com.example.sms_mms` to `io.github.manveer1999.sms_mms`. This only matters if you referenced the plugin's classes directly.
* Requires Dart 3, Flutter 3.10 and iOS 13.
* Removed the web, macOS, Linux and Windows entries. They had no implementation.

**Fixes**

* Android: `send` never completed, so code after `await` did not run ([#8](https://github.com/Manveer1999/flutter_sms_mms/issues/8), [#10](https://github.com/Manveer1999/flutter_sms_mms/issues/10)).
* Android: when no default SMS app was set, `send` failed with "Default sms app not found". It now falls back to any app that can handle the message ([#3](https://github.com/Manveer1999/flutter_sms_mms/issues/3)).
* Android: if the default SMS app rejects the attachment type, any other app that accepts it is offered.
* iOS: every attachment was sent as `attachment.jpeg` with type `public.image`, so PDFs and other files arrived as broken images. The real file name and type are now used ([#1](https://github.com/Manveer1999/flutter_sms_mms/issues/1)).
* iOS: text-only messages failed on devices that cannot send attachments.
* iOS: the compose sheet failed to open when another screen was presented. It now uses the top view controller.

**Features**

* Multiple attachments with `filePaths` ([#5](https://github.com/Manveer1999/flutter_sms_mms/issues/5), [#9](https://github.com/Manveer1999/flutter_sms_mms/issues/9)).
* On iOS, `send` reports whether the message was sent, cancelled or failed.

**Housekeeping**

* Android: removed the unused `READ_EXTERNAL_STORAGE` permission and an incorrect `<activity>` entry pointing at the plugin class.
* Android: the `FileProvider` now exposes only the plugin's cache folder, not `/storage/`.
* iOS: Swift Package Manager support, alongside CocoaPods, and a privacy manifest.
* Unit tests and a GitHub Actions workflow that builds the example on Android and iOS.

## 0.0.2+1

* Fixed Messaging app not opens message page, if already in recent tasks

## 0.0.2

* Fixed Attachment Issue for Devices using customized Messaging App (eg. Samsung, Mi)
* Improved android side implementation
* Added error messages as a Toast

## 0.0.1

* Added support for opening native messaging app 
