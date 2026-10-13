import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'sms_mms_platform_interface.dart';

/// An implementation of [SmsMmsPlatform] that uses method channels.
class MethodChannelSmsMms extends SmsMmsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('sms_mms');

  @override
  Future<SmsMmsResult> sendMms({
    required List<String> phones,
    required String text,
    List<String> filePaths = const [],
  }) async {
    final status = await methodChannel.invokeMethod<String>('sendMms', {
      'recipientNumbers': phones,
      'message': text,
      'paths': filePaths,
    });
    return SmsMmsResult.values.firstWhere(
      (r) => r.name == status,
      orElse: () => SmsMmsResult.unknown,
    );
  }
}
