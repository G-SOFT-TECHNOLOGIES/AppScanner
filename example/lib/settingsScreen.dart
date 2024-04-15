import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController ipController = TextEditingController();
  final TextEditingController puertoController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    obtenerConfiguracion();
  }

  Future<void> obtenerConfiguracion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString('ip') ?? '192.168.0.1'; // IP por defecto si no se encuentra
    String puerto = prefs.getString('puerto') ?? '8080'; // Puerto por defecto si no se encuentra

    setState(() {
      ipController.text = ip;
      puertoController.text = puerto;
    });
  }

  Future<void> guardarConfiguracion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ip', ipController.text);
    await prefs.setString('puerto', puertoController.text);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Configuración guardada con éxito'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Configuración de IP y Puerto'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: ipController,
              decoration: InputDecoration(labelText: 'IP'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: puertoController,
              decoration: InputDecoration(labelText: 'Puerto'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                guardarConfiguracion();
              },
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
