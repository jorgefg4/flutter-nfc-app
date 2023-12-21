import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import '../logic.dart';


//Página para LECTURA
class ReadPage extends StatefulWidget {
  const ReadPage({Key? key}) : super(key: key);

  @override
  _ReadPageState createState() => _ReadPageState();
}

class _ReadPageState extends State<ReadPage> {

  final GlobalKey<_ReadPageState> _readPageKey = GlobalKey<_ReadPageState>();

  String resultado = "";
  late List<String> palabras;
  bool isButtonDisabled = true;
  bool startNFC = false;
//inicializo el manejador
  NfcHandler nfcHandler = NfcHandler();


  void initNFC() async {
    String result = await nfcHandler.initNFC();
    if (result.startsWith("URL:")) {
      // Es una URL
      setState(() {
        resultado = result.substring(4) + "\nAbriendo navegador...";
      });
      // esperar 1 segundo antes de abrir el navegador
      await Future.delayed(Duration(milliseconds: 2000));

      Uri url = Uri.parse(result.substring(4));
      //lanzo el navegador predeterminado del movil con la url
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'No se pudo abrir la URL';
      }
      setState(() {
        resultado = result.substring(4);
      });
    } else if (result.startsWith("CONTACTO:")) {
      // Es un contacto
      String contactoData = result.substring(9);
      palabras = contactoData.split("*");
      resultado = "---- Contacto recibido ----\n" + "Nombre: " + palabras[0] + "\nTeléfono: " + palabras[1] + "\nEmail: " + palabras[2];
      isButtonDisabled = false;
      setState(() {
        resultado;
      });
    }
  } // initNFC()


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepPurpleAccent,
      child:

      /// Read page
      Center(
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Visibility(
              visible: !startNFC,
              child: Text(
                "Lectura NFC",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 10),

            Visibility(
              visible: !startNFC,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    startNFC = true;
                    resultado = "Esperando lectura...";
                  });
                  initNFC();

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // Ajusta el radio según sea necesario
                  ),
                ),
                child: Text(
                  "Pulsar para leer",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.0, // Ajusta el tamaño del texto según sea necesario
                  ),
                ),
              ),
            ),

            Visibility(
              visible: startNFC,
              child:
              Text('$resultado',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ),

            SizedBox(height: 20),

            Visibility(
              visible: startNFC,
              child:
              Icon(Icons.tap_and_play,
                color: Colors.white,
                size: 50,),
            ),

            SizedBox(height: 20), // Espacio entre el texto y el botón

            Visibility(
              visible: !isButtonDisabled,
              child: ElevatedButton(
                onPressed: () {
                  nfcHandler.addContact(palabras[0], palabras[1], palabras[2]);
                  // Mostrar un SnackBar para indicar que el contacto ha sido añadido
                  final snackBar = SnackBar(
                    content: Text('Contacto añadido con éxito'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  setState(() {
                    /// desactivo boton
                    isButtonDisabled = true;
                  });
                },
                child: Text('Añadir a contactos'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }
} // class _ReadPageState