import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'sms_mms_method_channel.dart';

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

  Future<void> sendMms({required List<String> phones, String? filePath, required String text}) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
