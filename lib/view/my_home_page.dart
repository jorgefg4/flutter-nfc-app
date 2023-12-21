import 'dart:async';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prueba1/view/read_page.dart';
import 'package:prueba1/view/send_page.dart';
import 'package:prueba1/view/send_url_page.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key}); //constructor

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickNFC',
      theme:
      ThemeData(useMaterial3: true),
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


  @override
  void initState() {
    super.initState();

    bool isUrl(String value) {
      // Expresión regular para comprobar si la cadena es una URL
      RegExp urlRegex = RegExp(
        r'^(http|https):\/\/([^\s]+)/?$',
        caseSensitive: false,
        multiLine: false,
      );
      return urlRegex.hasMatch(value);
    }

    // solicito permisos para acceder a agenda de contactos
    Permission permission = Permission.contacts;
    permission.request();


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
            'Aquí puedes proporcionar información de ayuda.',
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




  @override
  Widget build(BuildContext context) {

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            switch (index) {
              case 0:
                setState(() {
                  currentPageIndex = index;
                });

                break;
              case 1:
                setState(() {
                  currentPageIndex = index;
                });

                break;
              case 2:
                setState(() {
                  currentPageIndex = index;
                });

                break;
            }
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.nfc),
            label: 'Leer',
          ),
          NavigationDestination(
            icon: Icon(Icons.messenger_sharp),
            label: 'Enviar',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('2'),
              child: Icon(Icons.history),
            ),
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
        ],
      ),

      //
      //     /// Historial page
      //     Padding(
      //       padding: EdgeInsets.all(8.0),
      //       child: Column(
      //         children: <Widget>[
      //           Card(
      //             child: ListTile(
      //               leading: Icon(Icons.notifications_sharp),
      //               title: Text('Notification 1'),
      //               subtitle: Text('This is a notification'),
      //             ),
      //           ),
      //           Card(
      //             child: ListTile(
      //               leading: Icon(Icons.notifications_sharp),
      //               title: Text('Notification 2'),
      //               subtitle: Text('This is a notification'),
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //
      //   ][currentPageIndex],
      // ),

      // drawer: Drawer(
      //   child: drawerItems,
      // ),
    );
  } // Widget build
} // class _MyHomeState()