import 'sms_mms_platform_interface.dart';

class SmsMms {

  static Future<void> send({
    required List<String> recipients,
    String? filePath,
    required String message,
  }) async {
    return SmsMmsPlatform.instance.sendMms(
      phones: recipients,
      text: message,
      filePath: filePath,
    );
  }
}
