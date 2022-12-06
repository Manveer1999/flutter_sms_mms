import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'sms_mms_platform_interface.dart';

/// An implementation of [SmsMmsPlatform] that uses method channels.
class MethodChannelSmsMms extends SmsMmsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('sms_mms');

  @override
  Future<void> sendMms(
      {required List<String> phones, String? filePath, required String text}) async {
    await methodChannel.invokeMethod('sendMms', {
      'path' : filePath,
      'recipientNumbers' : phones,
      'message' : text
    });
  }
}
