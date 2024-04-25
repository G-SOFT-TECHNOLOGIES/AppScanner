import 'package:flutter/services.dart';

import 'bahiascanner_platform_interface.dart';

/// An implementation of [BahiascannerPlatform] that uses method channels.
class MethodChannelBahiascanner extends BahiascannerPlatform {
  /// The method channel used to interact with the native platform.
  // @visibleForTesting
  // final methodChannel = const MethodChannel('bahiascanner');
  static const MethodChannel _channel = MethodChannel('bahiascanner');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await _channel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
   static Future<void> invokeVenta({
    required double monto,
    String cedula = "",
    bool soloTD = false,
    bool soloTC = false,
    bool montoEditable = false, 
    required Null Function(dynamic response) onSuccess,
  }) async {
    try {
      final response = await _channel.invokeMethod('invokeVenta', {
        'monto': monto,
        'cedula': cedula,
        'soloTD': soloTD,
        'soloTC': soloTC,
        'montoEditable': montoEditable,
        'source': 'payment_gateway', // Identificador de la fuente de respuesta
      });
      // print('Respuesta de la venta: $response');
      onSuccess(response);
    } catch (e) {
      print("Error al invocar venta: $e");
      throw e;
    }
  }
}
