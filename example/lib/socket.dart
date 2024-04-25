import 'package:bahiascanner/bahiascanner_method_channel.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

typedef ScanCallback = void Function();

class SocketManager {
  static ScanCallback? scanCallback;
  static bool scanning = true;
  static WebSocketChannel? channel; // Atributo para la conexión WebSocket
  static VoidCallback? onSocketConnected; // Nuevo callback para notificar la conexión del socket
  static VoidCallback? onSocketDisconnected; // Nuevo callback para notificar la conexión del socket

  // Método para obtener la configuración de IP y puerto
  static Future<Map<String, dynamic>> obtenerConfiguracionIPPuerto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString('ip') ?? '192.168.0.1';
    String puerto = prefs.getString('puerto') ?? '8080';
    return {'ip': ip, 'puerto': puerto};
  }

  // Método para iniciar la conexión WebSocket
  static Future<void> iniciarWebSocket() async {
    // Obtener la configuración de IP y puerto
    Map<String, dynamic> config = await obtenerConfiguracionIPPuerto();
    String? ip = config['ip'];
    String? puerto = config['puerto'];

    // Construir la URL del WebSocket
    final wsUrl = Uri.parse('ws://$ip:$puerto');
    print('Intentando conectar a: ws://$ip:$puerto');

    try {
        // Conectar al WebSocket
        channel = WebSocketChannel.connect(wsUrl);
        await channel!.ready;
        onSocketConnected?.call();
        // Escuchar mensajes del WebSocket
        channel!.stream.listen((message) async {
          // Manejar los mensajes recibidos
          // print('Tipo de mensaje: ${message.runtimeType}');
          print(message);
          if (message is String) {
            try {
              Map<String, dynamic> jsonMessage = json.decode(message);
              manejarMensaje(jsonMessage);
            } catch (e) {
              print('Error al decodificar el mensaje JSON: $e');
            }
          } else {
            print('Mensaje no válido: $message');
          }
        }, onDone: () {
          channel=null;
          onSocketDisconnected?.call();
          print('La conexión WebSocket se ha cerrado.');
        });
    } catch (e) {
        Future.delayed(const Duration(seconds: 5));
        print('Error al conectar al WebSocket: $e');
        print('Reintentando la conexión en 5 segundos...');
        // iniciarWebSocket();
    }
  }

  // Método para manejar los mensajes recibidos
  static void manejarMensaje(Map<String, dynamic> jsonMessage) {
    if (jsonMessage['comand'] == 'VENTA' &&
        jsonMessage.containsKey('monto') &&
        jsonMessage.containsKey('cedula')) {
        String montoString = jsonMessage['monto'];
        String cedula = jsonMessage['cedula'];
        scanning = false;

        // print(cedula);
        if (cedula != '') {
            cedula = jsonMessage['cedula'].substring(2);
        } else {
            cedula = '';
        }
        double monto = double.parse(montoString.replaceAll(',', '.'));
        _callInvokeVenta(monto, cedula);
    } else if (jsonMessage['comand'] == 'scanner' && scanCallback != null) {
        scanning = true;
        scanCallback!();
    } else if (jsonMessage['comand'] == 'stop_scanner') {
        print('Escaneo detenido por WebSocket.');
        scanning = false;
    }
  }

  // Método para llamar a invokeVenta
  static void _callInvokeVenta(double monto, String cedula) async {
    try {
      await MethodChannelBahiascanner.invokeVenta(
        monto: monto,
        cedula: cedula,
        soloTD: true,
        soloTC: false,
        montoEditable: false,
        onSuccess: (response) {
          // print('Recibido');
          // print(response);
          enviarResult(json.encode(response));
        },
      );
    } catch (e) {
      print("Error al llamar a invokeVenta: $e");
    }
  }

  // Método para enviar datos a través de la conexión WebSocket existente
  static void enviarResult(dynamic response) async {
    // await iniciarWebSocket();
    print(response);
    try {
      if (channel != null) {
        print('Eniviando datos');
        // await iniciarWebSocket();
        channel!.sink.add(response);
      } else {
        // await iniciarWebSocket();
        // channel!.sink.add(response);
        print('No se pudo enviar datos: No hay conexión WebSocket disponible.');
      }
    } catch (e) {
      print("Error al enviar datos a través del WebSocket: $e");
    }
  }
}
