
import 'bahiascanner_platform_interface.dart';

class Bahiascanner {
  Future<String?> getPlatformVersion() {
    return BahiascannerPlatform.instance.getPlatformVersion();
  }
}
