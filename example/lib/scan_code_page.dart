import 'dart:typed_data';

import 'package:bahiascanner/bahiascanner_method_channel.dart';
import 'package:bahiascanner_example/settingsScreen.dart';
import 'package:bahiascanner_example/socket.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audioplayers/audioplayers.dart';

class ScanCodePage extends StatefulWidget {
  const ScanCodePage({Key? key}) : super(key: key);

  @override
  State<ScanCodePage> createState() => _ScanCodePageState();
}

class _ScanCodePageState extends State<ScanCodePage> {
  bool _canScan = true; // Indica si se puede realizar otro escaneo
  final AudioPlayer audioPlayer = AudioPlayer();
  String audioPath = 'synthesize.mp3';

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
            icon: const Icon(
              Icons.settings,
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width *
              0.8, // 80% del ancho de la pantalla
          height: MediaQuery.of(context).size.height *
              0.6, // 60% de la altura de la pantalla
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: MobileScanner(
                  controller: MobileScannerController(
                    detectionSpeed: DetectionSpeed.normal,
                    returnImage: true,
                  ),
                  onDetect: (capture) async {
                    // Verificar si se puede realizar otro escaneo
                    if (_canScan) {
                      final List<Barcode> barcodes = capture.barcodes;
                      final Uint8List? image = capture.image;
                      for (final barcode in barcodes) {
                        print('Barcode found! ${barcode.rawValue}');
                        try {
                          // Configura el archivo de audio
                          await audioPlayer
                              .setSourceAsset('synthesize.mp3');

                          // Reproduce el audio
                          await audioPlayer.resume();
                        } catch (e) {
                          print('Error al reproducir el audio: $e');
                        }
                        SocketManager.enviarResult(barcode.rawValue.toString());
                      }
                      if (image != null) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                barcodes.first.rawValue ?? "",
                              ),
                              content: Image(
                                image: MemoryImage(image),
                              ),
                            );
                          },
                        );
                        // Deshabilitar el escaneo por un período de 2 segundos
                        setState(() {
                          _canScan = false;
                        });
                        Future.delayed(const Duration(seconds: 2), () {
                          setState(() {
                            Navigator.of(context).pop();
                            _canScan = true;
                          });
                        });
                      }
                    }
                  },
                ),
              ),
              SizedBox(height: 16), // Espacio entre el MobileScanner y el texto
              Text(
                'Escanea tu producto',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8), // Espacio entre los textos
              Text(
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

  void _callInvokeVenta() async {
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
