import 'sms_mms_platform_interface.dart';

export 'sms_mms_platform_interface.dart' show SmsMmsResult;

/// Opens the platform's native messaging app with recipients, a message and
/// optional attachments filled in. The user reviews and sends the message.
class SmsMms {
  /// Opens the native messaging app.
  ///
  /// [recipients] are phone numbers. Pass them in international format
  /// (`+4915112345678`); the messaging app may otherwise apply its own
  /// country prefix.
  ///
  /// [filePath] attaches one file. [filePaths] attaches several. Both may be
  /// given; the files are sent in order, [filePath] first.
  ///
  /// On iOS the future completes when the user closes the compose sheet, with
  /// [SmsMmsResult.sent], [SmsMmsResult.cancelled] or [SmsMmsResult.failed].
  ///
  /// On Android the future completes with [SmsMmsResult.unknown] as soon as
  /// the messaging app opens. Android messaging apps do not report back
  /// whether the user sent the message.
  ///
  /// Throws a `PlatformException` if no messaging app can be opened or an
  /// attachment cannot be read. See the README for the error codes.
  static Future<SmsMmsResult> send({
    required List<String> recipients,
    required String message,
    String? filePath,
    List<String>? filePaths,
  }) {
    return SmsMmsPlatform.instance.sendMms(
      phones: recipients,
      text: message,
      filePaths: [if (filePath != null) filePath, ...?filePaths],
    );
  }
}
