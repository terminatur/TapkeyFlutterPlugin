import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapkey_flutter_plugin2/tapkey_flutter_plugin2.dart';

void main() {
  const MethodChannel channel = MethodChannel('tapkey_flutter_plugin2');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await TapkeyFlutterPlugin2.platformVersion, '42');
  });
}
