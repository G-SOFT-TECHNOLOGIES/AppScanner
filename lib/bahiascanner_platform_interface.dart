import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'bahiascanner_method_channel.dart';

abstract class BahiascannerPlatform extends PlatformInterface {
  /// Constructs a BahiascannerPlatform.
  BahiascannerPlatform() : super(token: _token);

  static final Object _token = Object();

  static BahiascannerPlatform _instance = MethodChannelBahiascanner();

  /// The default instance of [BahiascannerPlatform] to use.
  ///
  /// Defaults to [MethodChannelBahiascanner].
  static BahiascannerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BahiascannerPlatform] when
  /// they register themselves.
  static set instance(BahiascannerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
