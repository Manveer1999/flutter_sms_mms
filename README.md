# sms_mms

[![pub package](https://img.shields.io/pub/v/sms_mms.svg)](https://pub.dev/packages/sms_mms)
[![CI](https://github.com/Manveer1999/flutter_sms_mms/actions/workflows/ci.yml/badge.svg)](https://github.com/Manveer1999/flutter_sms_mms/actions/workflows/ci.yml)

Opens the native messaging app with recipients, a message and attachments filled in.
The user reviews the message and taps send.

- **Android** opens the default SMS app directly, without the app chooser.
- **iOS** presents the system compose sheet (`MFMessageComposeViewController`) and
  tells you whether the user sent or cancelled.

The plugin never sends a message by itself. See [Sending without the user](#sending-without-the-user).

| iOS | Android |
|---|---|
| [demo video](https://user-images.githubusercontent.com/64741771/205976966-82406d92-fd50-4b10-a4bd-d2f121bd13aa.mov) | [demo video](https://user-images.githubusercontent.com/64741771/205976824-2483f3b1-d946-430c-9b3e-dbf1054ee5b8.mov) |

## Usage

```dart
import 'package:sms_mms/sms_mms.dart';

final result = await SmsMms.send(
  recipients: ['+4915112345678'],
  message: 'Here is the invoice',
  filePaths: [invoicePdf.path, photo.path], // optional
);
```

| Parameter | |
|---|---|
| `recipients` | Phone numbers. Use international format (`+49…`); otherwise the messaging app may add its own country prefix. |
| `message` | The message body. |
| `filePath` | One attachment. Kept for compatibility with 0.0.x. |
| `filePaths` | Any number of attachments. Combined with `filePath`, which goes first. |

No setup is needed in your app: the plugin brings its own `FileProvider` and manifest entries.

## What `send` returns

| Platform | Result |
|---|---|
| iOS | `SmsMmsResult.sent`, `.cancelled` or `.failed`, when the user closes the sheet. |
| Android | `SmsMmsResult.unknown`, as soon as the messaging app opens. |

Android messaging apps do not report whether the user sent the message, so the plugin
does not guess. To run code when the user comes back to your app, listen for the app
resuming:

```dart
final result = await SmsMms.send(recipients: numbers, message: text);
if (result == SmsMmsResult.unknown) {
  // Android: wait for AppLifecycleState.resumed, e.g. with AppLifecycleListener.
}
```

## Errors

`send` throws a `PlatformException` with one of these codes:

| Code | Platform | Meaning |
|---|---|---|
| `no_sms_app` | Android | No installed app can send messages or accept the attachment type. |
| `file_not_found` | both | An attachment is missing or unreadable (iOS: or of a type Messages rejects). |
| `device_not_capable` | iOS | The device cannot send messages, or cannot send attachments. |
| `message_not_sent` | iOS | Running on the simulator, which cannot send messages. |
| `already_open` | iOS | A compose sheet from an earlier call is still open. |
| `no_view_controller` | iOS | No view controller was available to present the sheet. |

## How attachments work on Android

Each file is copied into the app's cache directory (`cache/sms_mms/`) and shared through
a content URI, so the plugin can attach files from any path your app can read without
exposing the rest of its storage. Copies older than a day are cleared on the next send.

## Sending without the user

Not supported, on purpose. iOS has no API for it. On Android it needs the `SEND_SMS`
permission, which Google Play only allows for apps that are the default SMS handler.

## Platform support

Android (API 21+) and iOS (13+). Earlier versions listed web and desktop, but they had
no implementation and were removed in 0.1.0.
