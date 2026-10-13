import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sms_mms/sms_mms.dart';
import 'package:sms_mms/sms_mms_method_channel.dart';
import 'package:sms_mms/sms_mms_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('sms_mms');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late List<MethodCall> calls;
  Object? reply;

  setUp(() {
    calls = [];
    reply = 'unknown';
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (reply is PlatformException) throw reply!;
      return reply;
    });
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('the method channel is the default platform', () {
    expect(SmsMmsPlatform.instance, isA<MethodChannelSmsMms>());
  });

  test('sends recipients, message and no attachments', () async {
    await SmsMms.send(recipients: ['+491511', '+491512'], message: 'Hallo');

    expect(calls.single.method, 'sendMms');
    expect(calls.single.arguments, {
      'recipientNumbers': ['+491511', '+491512'],
      'message': 'Hallo',
      'paths': <String>[],
    });
  });

  test('puts filePath before filePaths', () async {
    await SmsMms.send(
      recipients: ['1'],
      message: '',
      filePath: '/a.jpg',
      filePaths: ['/b.pdf', '/c.png'],
    );

    expect(calls.single.arguments['paths'], ['/a.jpg', '/b.pdf', '/c.png']);
  });

  for (final result in SmsMmsResult.values) {
    test('maps "${result.name}" to $result', () async {
      reply = result.name;
      expect(await SmsMms.send(recipients: ['1'], message: ''), result);
    });
  }

  test('treats a null or unrecognised reply as unknown', () async {
    reply = null;
    expect(await SmsMms.send(recipients: ['1'], message: ''),
        SmsMmsResult.unknown);
    reply = 'something_new';
    expect(await SmsMms.send(recipients: ['1'], message: ''),
        SmsMmsResult.unknown);
  });

  test('passes platform errors through', () async {
    reply = PlatformException(code: 'no_sms_app');
    expect(
      SmsMms.send(recipients: ['1'], message: ''),
      throwsA(
          isA<PlatformException>().having((e) => e.code, 'code', 'no_sms_app')),
    );
  });
}
