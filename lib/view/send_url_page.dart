import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../logic.dart';

//Página para ENVIAR URL desde app externa
class SendUrlPage extends StatefulWidget {
  final String urlToSend;

  SendUrlPage({required this.urlToSend});

  @override
  _SendUrlPageState createState() => _SendUrlPageState();
}

class _SendUrlPageState extends State<SendUrlPage> {
  Function()? currentFunction;
  String resultado = "";

  //inicializo el manejador
  NfcHandler nfcHandler = NfcHandler();

  @override
  void initState() {
    super.initState();
    writeUrl();
  }

  void writeUrl() async {
    setState(() {
      resultado = "Acerca tu teléfono a otro para compartir la URL";
    });
    nfcHandler.writeUrl(widget.urlToSend);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: Text(
          'QuickNFC',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        color: Colors.deepPurpleAccent,
        child: Center(
          child: Stack(
            children: <Widget>[
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '$resultado',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                    SizedBox(height: 20),
                    Icon(
                      Icons.tap_and_play,
                      color: Colors.white,
                      size: 50,
                    ),
                  ]),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }
} // class _SendUrlPageState
