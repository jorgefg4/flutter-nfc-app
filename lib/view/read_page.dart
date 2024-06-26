import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../logic.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool locationVisible = false;
  bool startNFC = false;
  bool showText = true;
  String address = "";

//inicializo el manejador
  NfcHandler nfcHandler = NfcHandler();

  List<String> historial = [];

  Future<void> cargarHistorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      historial = prefs.getStringList('historial') ?? [];
    });
  }

  Future<void> guardarHistorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('historial', historial);
  }

  void initNFC() async {
    //comprueba si NFC está activado
    bool nfcAvailable = await NfcManager.instance.isAvailable();
    if (nfcAvailable == false) {
      setState(() {
        resultado =
            "NFC descativado. Por favor, actívalo e inicia de nuevo la lectura.";
      });
      return;
    }

    cargarHistorial();
    String result = await nfcHandler.initNFC();

    if (historial.length >= 10) {
      // Si la longitud es mayor o igual a 10, elimina el elemento más antiguo
      historial.removeAt(0);
    }

    if (result.startsWith("URL:")) {
      // Es una URL
      setState(() {
        resultado = "---- URL recibida ----\n\n" +
            result.substring(4) +
            "\n\nAbriendo navegador...";
      });
      // esperar 1 segundo antes de abrir el navegador
      await Future.delayed(Duration(milliseconds: 2000));

      String result2 = await nfcHandler.launchURL(result.substring(4));
      if (result2 == 'No es posible abrir la URL') {
        setState(() {
          resultado = "---- URL recibida ----\n\n" +
              result.substring(4) +
              "\n\nNo es posible abrir la URL";
        });
      } else {
        setState(() {
          resultado = "---- URL recibida ----\n\n" + result.substring(4);
          historial.add(result);
        });
      }
    } else if (result.startsWith("CONTACTO:")) {
      // Es un contacto
      String contactoData = result.substring(9);
      palabras = contactoData.split("*");
      resultado = "---- Contacto recibido ----\n\n" +
          "Nombre: " +
          palabras[0] +
          "\nTeléfono: " +
          palabras[1] +
          "\nEmail: " +
          palabras[2];
      isButtonDisabled = false;
      setState(() {
        resultado;
      });
      historial.add(result);
    } else if (result.startsWith("LOCATION:")) {
      // Es una ubicacion
      String wifiData = result.substring(9);
      palabras = wifiData.split("*");
      setState(() {
        locationVisible = true;
        address = palabras[2];
      });
      // esperar 1 segundo antes de abrir maps
      await Future.delayed(Duration(milliseconds: 3000));
      nfcHandler.openMaps(palabras[0], palabras[1]);
      setState(() {
        showText = false;
      });
      historial.add(result);
    } else if (result.startsWith("EVENT:")) {
      // Es un evento
      String eventData = result.substring(6);
      palabras = eventData.split("*");
      setState(() {
        resultado = "---- Evento recibido ----\n\n" +
            "Título: " +
            palabras[0] +
            "\nLugar: " +
            palabras[1] +
            "\nFecha inicio: " +
            palabras[2] +
            "\nFecha fin: " +
            palabras[3] +
            "\n\nAbriendo calendario...";
      });
      // esperar 1 segundo antes de abrir calendario
      await Future.delayed(Duration(milliseconds: 3000));

      nfcHandler.addEvent(palabras[0], palabras[1], palabras[2], palabras[3]);
      setState(() {
        resultado = "---- Evento recibido ----\n\n" +
            "Título: " +
            palabras[0] +
            "\nLugar: " +
            palabras[1] +
            "\nFecha inicio: " +
            palabras[2] +
            "\nFecha fin: " +
            palabras[3];
      });
      historial.add(result);
    }
    guardarHistorial();
  } // initNFC()

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepPurpleAccent,
      child: Center(
        child: Column(
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
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Text(
                  "Pulsar para leer",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),

            Visibility(
              visible: startNFC && !locationVisible,
              child: Text(
                '$resultado',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ),

            Visibility(
                visible: startNFC && locationVisible,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(
                        text: "---- Ubicación recibida ----\n\n",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                          text: address,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          )),
                      TextSpan(
                        text: showText ? "\n\nAbriendo mapas..." : "",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )),

            SizedBox(height: 20),

            Visibility(
              visible: startNFC,
              child: Icon(
                Icons.tap_and_play,
                color: Colors.white,
                size: 50,
              ),
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
