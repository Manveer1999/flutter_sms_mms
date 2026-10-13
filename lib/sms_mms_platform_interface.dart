import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'sms_mms_method_channel.dart';

/// What happened to the message after the messaging app was opened.
enum SmsMmsResult {
  /// The user sent the message. iOS only.
  sent,

  /// The user closed the compose sheet without sending. iOS only.
  cancelled,

  /// The system failed to send the message. iOS only.
  failed,

  /// The messaging app opened, and the platform does not report what the
  /// user did next. Always the result on Android.
  unknown,
}

abstract class SmsMmsPlatform extends PlatformInterface {
  /// Constructs a SmsMmsPlatform.
  SmsMmsPlatform() : super(token: _token);

  static final Object _token = Object();

  static SmsMmsPlatform _instance = MethodChannelSmsMms();

  /// The default instance of [SmsMmsPlatform] to use.
  ///
  /// Defaults to [MethodChannelSmsMms].
  static SmsMmsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SmsMmsPlatform] when
  /// they register themselves.
  static set instance(SmsMmsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<SmsMmsResult> sendMms({
    required List<String> phones,
    required String text,
    List<String> filePaths = const [],
  }) {
    throw UnimplementedError('sendMms() has not been implemented.');
  }
}
