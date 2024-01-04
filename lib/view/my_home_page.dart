import 'dart:async';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prueba1/view/read_page.dart';
import 'package:prueba1/view/send_page.dart';
import 'package:prueba1/view/send_url_page.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'history_page.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key}); //constructor

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickNFC',
      theme:
      ThemeData(useMaterial3: true),

      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('es', 'ES'), // Establece el idioma español
      ],

      home: const MyHomePage(title: 'QuickNFC'),
    );
  } // Widget build
} // MyApp




class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  late StreamSubscription _intentDataStreamSubscription;
  String? _sharedText;
  int currentPageIndex = 0;
  List<String> historial = [];
  late String helpMessage;

  Future<void> requestPermission() async {

    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.contacts,
      Permission.calendarFullAccess,
    ].request();

  }

  @override
  void initState() {
    super.initState();
    helpMessage = 'Puede leer contenido de otro teléfono pulsando el botón de iniciar lectura y acercando su teléfono a otro a una distancia de pocos centímetros. Asegúrese de que NFC está activado en su terminal. ';

    bool isUrl(String value) {
      // Expresión regular para comprobar si la cadena es una URL
      RegExp urlRegex = RegExp(
        r'^(http|https):\/\/([^\s]+)/?$',
        caseSensitive: false,
        multiLine: false,
      );
      return urlRegex.hasMatch(value);
    }

    requestPermission();





    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
          setState(() {
            _sharedText = value;
            if (value.isNotEmpty) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                  SendUrlPage(urlToSend: _sharedText.toString())));
            }
            print("LA URL ES: " + _sharedText.toString());
          });
        }, onError: (err) {
          print("getLinkStream error: $err");
        });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) {
      setState(() {
        if (isUrl(value.toString())) {
          _sharedText = value;
          Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
              SendUrlPage(urlToSend: _sharedText.toString())));
        }
      });
    });
  } // initState()




  // Función para mostrar la ventana emergente de ayuda
  void showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ayuda'),
          content: Text(
              helpMessage,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }


  void _showBackDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Estás seguro?'),
          content: const Text(
            '¿Estás seguro de salir de la aplicación?',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Salir'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {

    return
      PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) {
            if (didPop) {
              return;
            }
            _showBackDialog();
          },
    child: Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            switch (index) {
              case 0:
                setState(() {
                  currentPageIndex = index;
                  helpMessage = 'Puede leer contenido de otro teléfono pulsando el botón de iniciar lectura y acercando su teléfono a otro a una distancia de pocos centímetros. Asegúrese de que NFC está activado en su terminal. ';
                });

                break;
              case 1:
                setState(() {
                  currentPageIndex = index;
                  helpMessage = 'Seleccione uno de los formatos de información disponibles para enviar hacia otro teléfono. También puede utilizar la función de compartir URL desde cualquier aplicación externa.';
                });

                break;
              case 2:
                setState(() {
                  currentPageIndex = index;
                  helpMessage = 'Esta página muestra el historial de los últimos 10 elementos leídos. Pulse sobre cualquiera de ellos para visualizar o guardar.';
                });

                break;
            }
          });
        },
        selectedIndex: currentPageIndex,
        destinations:   <Widget>[
          NavigationDestination(
            icon: Icon(Icons.nfc),
            label: 'Leer',
          ),
          NavigationDestination(
            icon: Icon(Icons.messenger_sharp),
            label: 'Enviar',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
        ],
      ),



      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: Text(widget.title,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          // Añadir el botón de ayuda en la AppBar
          IconButton(
            icon: Icon(Icons.help,
              color: Colors.white,
            ),
            onPressed: () {
              showHelpDialog();
            },
          ),
        ],
      ),


      body:
      IndexedStack(
        index: currentPageIndex,
        children: [
          ReadPage(key: UniqueKey()),
          SendPage(key: UniqueKey()),
          HistoryPage(key: UniqueKey()),
        ],
      ),
    ),
      );
  } // Widget build
} // class _MyHomeState()