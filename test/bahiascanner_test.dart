import 'package:flutter_test/flutter_test.dart';
import 'package:bahiascanner/bahiascanner.dart';
import 'package:bahiascanner/bahiascanner_platform_interface.dart';
import 'package:bahiascanner/bahiascanner_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBahiascannerPlatform
    with MockPlatformInterfaceMixin
    implements BahiascannerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BahiascannerPlatform initialPlatform = BahiascannerPlatform.instance;

  test('$MethodChannelBahiascanner is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBahiascanner>());
  });

  test('getPlatformVersion', () async {
    Bahiascanner bahiascannerPlugin = Bahiascanner();
    MockBahiascannerPlatform fakePlatform = MockBahiascannerPlatform();
    BahiascannerPlatform.instance = fakePlatform;

    expect(await bahiascannerPlugin.getPlatformVersion(), '42');
  });
}
