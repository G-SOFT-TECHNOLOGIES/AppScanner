import 'dart:async';

import 'package:bahiascanner/bahiascanner_method_channel.dart';
import 'package:bahiascanner_example/scan_code_page.dart';
import 'package:bahiascanner_example/settingsScreen.dart';
import 'package:bahiascanner_example/socket.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
    late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startWebSocket(); // Iniciar WebSocket al principio
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancelar el temporizador al salir de la pantalla
    super.dispose();
  }

  void _startWebSocket() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      SocketManager.iniciarWebSocket();
    });
    SocketManager.onSocketConnected = _redirectToAnotherRoute;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 8), // Espacio entre el texto y la imagen
            Image.asset(
              'assets/logo.png', // Ruta de la imagen
              width: 180, // Ancho de la imagen
              height: 180, // Altura de la imagen
              // Puedes ajustar el ancho y la altura según tu preferencia
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
            // onPressed: _callInvokeVenta,
            icon: const Icon(
              Icons.settings,
            ),
          ),
        ],
        
      ),
        body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width *
              0.5, // 80% del ancho de la pantalla
          height: MediaQuery.of(context).size.height *
              0.5, // 60% de la altura de la pantalla
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  'assets/scanner.png', // Ruta de la imagen
                  width: double.infinity, // Ancho de la imagen igual al ancho del contenedor
                  height: double.infinity, // Altura de la imagen igual a la altura del contenedor
                  fit: BoxFit.contain, // Ajuste de la imagen para que quepa dentro del contenedor
                ),
              ),
              const SizedBox(height: 16), // Espacio entre el Image y el texto
             const  Text(
                'Escanea tu producto',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8), // Espacio entre los textos
              const Text(
                'Powered By AgylSoft',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    
    );
  }

    void _redirectToAnotherRoute() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ScanCodePage()), // Reemplaza 'OtraRuta()' por el nombre de tu otra ruta
    );
  }

 static void _callInvokeVenta() async {
    try {
      await MethodChannelBahiascanner.invokeVenta(
        monto: 100.00,
        cedula: '19796106',
        soloTD: true,
        soloTC: false,
        montoEditable: false,
        onSuccess: (response) {
          print('recibido');
          print(response);
          // enviarResult(json.encode(response));
        },
      );
    } catch (e) {
      print("Error al llamar a invokeVenta: $e");
    }
  }
}
