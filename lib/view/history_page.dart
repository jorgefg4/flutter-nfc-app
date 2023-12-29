import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../logic.dart';


//Página para HISTORIAL
class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {

  final GlobalKey<_HistoryPageState> _readPageKey = GlobalKey<_HistoryPageState>();

  List<String> historial = [];
  bool historialCargado = false;
  //inicializo el manejador
  NfcHandler nfcHandler = NfcHandler();

  @override
  void initState() {
    super.initState();
    cargarHistorial();
  }


  Future<void> cargarHistorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      historial = prefs.getStringList('historial') ?? [];
    });
    historialCargado = true;
  }


  // Función para lanzar la URL en el navegador
  void launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'No se pudo abrir la URL';
    }
  }




  void _mostrarDialogoGuardarContacto(BuildContext context, List<String> contactoInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Guardar Contacto"),
          content: Text("¿Deseas guardar este contacto en la agenda?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                //inicializo el manejador
                NfcHandler nfcHandler = NfcHandler();
                nfcHandler.addContact(contactoInfo[0], contactoInfo[1], contactoInfo[2]);
                Navigator.of(context).pop(); // Cierra el diálogo después de guardar.
                final snackBar = SnackBar(
                  content: Text('Contacto añadido con éxito'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: Text("Guardar"),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {

    return Container(
      color: Colors.deepPurpleAccent,
      child: historialCargado ?
        Container(child: historial.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          Padding(
          padding: EdgeInsets.all(16.0),
          child:
          Text(
                "Prueba a leer para ver algo aquí.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ),
              Icon(
                Icons.history,
                color: Colors.white,
                size: 50,
              ),
            ],
          ),
        )
            : Padding(
          padding: EdgeInsets.all(8.0),
          child: ListView(
            children: List.generate(
              10,
                  (index) {
                if (index < historial.length) {
                  if (historial[index].startsWith("URL:")) {
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.web),
                        title: Text(historial[index].substring(4)),
                        subtitle: Text('URL'),
                        onTap: () {
                          launchURL(historial[index].substring(4));
                        },
                      ),
                    );
                  } else if (historial[index].startsWith("CONTACTO:")) {
                    String contactoData = historial[index].substring(9);
                    List<String> palabras = contactoData.split("*");
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.contacts),
                        title: Text(palabras[0]),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(palabras[1]),
                            Text(palabras[2]),
                          ],
                        ),
                        onTap: () {
                          _mostrarDialogoGuardarContacto(context, palabras);
                        },
                      ),
                    );
                  } else if (historial[index].startsWith("LOCATION:"))  {
                    String wifiData = historial[index].substring(9);
                    List<String> palabras = wifiData.split("*");
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.location_on),
                        title: Text(palabras[2]),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(palabras[0]),
                            Text(palabras[1])
                          ],
                        ),
                        onTap: () {
                            nfcHandler.openMaps(palabras[0], palabras[1]);
                        },
                      ),
                    );
                  }
                  else {
                    return SizedBox.shrink();
                  }
                } else {
                  return SizedBox.shrink(); // retorna widget vacío y sin espacio
                }
              },
            ).toList().reversed.toList(), // Invierte el orden de la lista
          ),
        ),
        ): Center(child: Text('cargando...',
                  style: TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
      )),
      );
  }
} // class _HistoryPageState