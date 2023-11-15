import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
// import 'dart:js';
import 'package:flutter/material.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
// import 'package:nfc_host_card_emulation/nfc_host_card_emulation.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:prueba1/model/record.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_nfc_hce/flutter_nfc_hce.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); //constructor

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC APP',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late StreamSubscription _intentDataStreamSubscription;
  List<SharedFile>? list;

  @override
  void initState() {
    super.initState();

    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = FlutterSharingIntent.instance.getMediaStream().listen((List<SharedFile> value) {
      setState(() {
        list = value;
        if (value.isNotEmpty) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
              NewPage3(urlToWrite: value.map((f) => f.value).join(","))));
        }
      });
      print("Shared: getMediaStream ${value.map((f) => f.value).join(",")}");
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    FlutterSharingIntent.instance.getInitialSharing().then((List<SharedFile> value) {
      print("Shared: getInitialMedia ${value.map((f) => f.value).join(",")}");
      setState(() {
        list = value;
        if (value.isNotEmpty) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
              NewPage3(urlToWrite: value.map((f) => f.value).join(","))));
        }
      });
    });
  } // initState()


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    const drawerHeader = UserAccountsDrawerHeader(
      accountName: Text('User Name'),
      accountEmail: Text('user.name@email.com'),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: FlutterLogo(size: 42.0),
      ),
      otherAccountsPictures: <Widget>[
        CircleAvatar(
          backgroundColor: Colors.yellow,
          child: Text('A'),
        ),
        CircleAvatar(
          backgroundColor: Colors.red,
          child: Text('B'),
        )
      ],
    );


    final drawerItems = ListView(
      children: <Widget>[
        drawerHeader,
        ListTile(
          title: const Text('Read NFC'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => NewPage1()));
          },
        ),
        ListTile(
          title: const Text('Write NFC'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => NewPage2()));
          },
        ),
        ListTile(
          title: const Text('other drawer item'),
          onTap: () {},
        ),
      ],
    );



    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        backgroundColor: Colors.blueAccent,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Write an URI: ',
            ),
            Text(
              'hola',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: drawerItems,
      ),
    );
  }
}





class NewPage1 extends StatefulWidget {
  @override
  _NewPage1State createState() => _NewPage1State();
}

class _NewPage1State  extends State<NewPage1> {
  String _resultado = "Pulsar para leer";

  void initNFC() async {
    try {
      setState(() {
        _resultado = "Esperando lectura...";
      });
      await NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        // Se ha descubierto una etiqueta NFC
        print('Tag descubierta: ${tag.data}');


        // var record = tag.data['ndef']['cachedMessage']['records'][0];
        // // print('RECORD:  ' + record);
        //
        // var identifier = Uint8List.fromList(record['identifier']);
        // print('IDENTIFIER:  ');
        // print(identifier);
        //
        // var payload = Uint8List.fromList(record['payload']);
        // print('PAYLOAD:  ');
        // print(payload);
        //
        // var type = Uint8List.fromList(record['type']);
        // print('TYPE:  ');
        // print(type);
        //
        // var typeNameFormat = Uint8List.fromList([record['typeNameFormat']]);
        // print('TYPENAME:  ');
        // print(typeNameFormat);
        //
        // // decoing
        // String payloadStr = Utf8Codec().decode(payload);
        // String typeStr = Utf8Codec().decode(type);
        // String typeNameFormatStr = Utf8Codec().decode(typeNameFormat);
        // // decoding value print
        // print('Payload: $payloadStr');
        // print('Type: $typeStr');
        // print('TypeNameFormat: $typeNameFormatStr');

        //////////////////////
        //lectura antigua
        /////////////////////
        Ndef? ndef = Ndef.from(tag);
        if (ndef == null) {
          print('Tag is not compatible with NDEF or is null');
          return;
        } else {
          print('Tag is compatible with NDEF');

          NdefMessage? data = await ndef.read();
          List<NdefRecord> lista = data.records;
          NdefRecord mensaje = lista.first;

          NdefTypeNameFormat tipo = mensaje.typeNameFormat;
          print("El tipo de mensaje leido es: " + tipo.name);

          if (mensaje.typeNameFormat == NdefTypeNameFormat.nfcWellknown) {
            final _mensaje = Record.fromNdef(mensaje);
            print(_mensaje);
            if (_mensaje is WellknownTextRecord) {
              //uso setState para que se actualice el texto en la interfaz
              setState(() {
                _resultado =
                    _mensaje.text.toString() + " Abriendo navegador...";
              });

              // esperar 1 segundo antes de abrir el navegador
              await Future.delayed(Duration(milliseconds: 1000));

              Uri url = Uri.parse(_mensaje.text.toString());
              //lanzo el navegador predeterminado del movil con la url
              if (await canLaunchUrl(url)) {
                await launchUrl(
                  url,
                  mode: LaunchMode.externalApplication,
                );
                return;
              } else {
                throw 'No se pudo abrir la URL';
              }
            }
          }
        }
      });
    } catch (e) {
      // Manejar cualquier error
      print('Error en NFC: $e');
    }
  } // initNFC()



  // Función para decodificar una lista de enteros en un string original
  String decodeIntegerListToString(List<int> encodedList) {
    String decodedString = '';
    for (int codeUnit in encodedList) {
      decodedString += String.fromCharCode(codeUnit);
    }
    return decodedString;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Read NFC"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('$_resultado',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: initNFC,
        tooltip: 'Read NFC',
        child: const Icon(Icons.tap_and_play),
      ),
    );
  }
} // _NewPage1State








class NewPage2 extends StatefulWidget {
  @override
  _NewPage2State createState() => _NewPage2State();
}

enum ContentType { url, contacto }

class _NewPage2State  extends State<NewPage2> {
  String _resultado = "Pulsar para escribir";
  String _urlToWrite = "";
  ContentType _selectedContentType = ContentType.url;


  void _mostrarCuadroTexto(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _urlController = TextEditingController(text: "https://"); // Establece el valor inicial
        String _textoIngresado = ""; // Variable para almacenar el texto ingresado
        TextEditingController _nombreController = TextEditingController();
        TextEditingController _telefonoController = TextEditingController();
        TextEditingController _emailController = TextEditingController();

        return AlertDialog(
          // title: Text("Ingresar URL"),
          title: Text("Ingresar ${_selectedContentType == ContentType.url ? 'URL' : 'Contacto'}"),
          content: _selectedContentType == ContentType.url ?
          TextField(
            controller: _urlController, // Usa el TextEditingController
            onChanged: (value) {
              _textoIngresado = value;
            },
            // decoration: InputDecoration(labelText: "Texto"),
          )
                : Column(
            children: [
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Teléfono'),
              ),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'Correo electrónico'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Aceptar"),
              onPressed: () {
                // // Aquí puedes hacer algo con el texto ingresado, como actualizar una variable en el estado
                // setState(() {
                //   _urlToWrite = _textoIngresado;
                // });

                if (_selectedContentType == ContentType.url) {
                  setState(() {
                    _urlToWrite = _urlController.text;
                  });
                } else {
                  // Aquí puedes hacer algo con la información de contacto
                  String nombre = _nombreController.text;
                  String telefono = _telefonoController.text;
                  String email = _emailController.text;
                  String informacionContacto = "Nombre: $nombre, Teléfono: $telefono, Email: $email";
                  // Puedes almacenar o utilizar informacionContacto según tus necesidades
                  // ...
                }


                //llamo al método para iniciar escritura
                writeNFC();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  } // _mostrarCuadroTexto()


    void writeNFC() async {
    try {
      setState(() {
        // _resultado = "Acerca tu teléfono a otro para compartir la URL";
        _resultado = "Acerca tu teléfono a otro para compartir la ${_selectedContentType == ContentType.url ? 'URL' : 'información de contacto'}";
      });

      //plugin instance
      final _flutterNfcHcePlugin = FlutterNfcHce();

      //getPlatformVersion
      var platformVersion = await _flutterNfcHcePlugin.getPlatformVersion();

      //isNfcHceSupported
      bool? isNfcHceSupported = await _flutterNfcHcePlugin.isNfcHceSupported();

      //isSecureNfcEnabled
      bool? isSecureNfcEnabled = await _flutterNfcHcePlugin.isSecureNfcEnabled();

      //isNfcEnabled
      bool? isNfcEnabled = await _flutterNfcHcePlugin.isNfcEnabled();

      //nfc content
      var content = _urlToWrite;

      //start nfc hce
      var result = await _flutterNfcHcePlugin.startNfcHce(_urlToWrite);



    } catch (e) {
      // Manejar cualquier error
      print('Error en NFC: $e');
    }
  } // writeNFC()



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Write NFC'),
        actions: [
          DropdownButton<ContentType>(
            value: _selectedContentType,
            onChanged: (ContentType? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedContentType = newValue;
                });
              }
            },
            items: <DropdownMenuItem<ContentType>>[
              DropdownMenuItem<ContentType>(
                value: ContentType.url,
                child: Text('URL'),
              ),
              DropdownMenuItem<ContentType>(
                value: ContentType.contacto,
                child: Text('Contacto'),
              ),
            ],
          ),
        ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('$_resultado',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarCuadroTexto(context), // Pasa el contexto actual
        tooltip: 'Write NFC',
        child: const Icon(Icons.save_as),
      ),
    );
  }
} // _NewPage2State









class NewPage3 extends StatefulWidget {
  final String urlToWrite;
  NewPage3({required this.urlToWrite});

  @override
  _NewPage3State createState() => _NewPage3State();
}

class _NewPage3State  extends State<NewPage3> {
  String _resultado = "Esperando para compartir...";

  @override
  void initState() {
    super.initState();
    writeNFC();
  }

  void writeNFC() async {
    try {
      setState(() {
        _resultado = "Acerca tu teléfono a otro para compartir la URL";
      });

      //plugin instance
      final _flutterNfcHcePlugin = FlutterNfcHce();

      //getPlatformVersion
      var platformVersion = await _flutterNfcHcePlugin.getPlatformVersion();

      //isNfcHceSupported
      bool? isNfcHceSupported = await _flutterNfcHcePlugin.isNfcHceSupported();

      //isSecureNfcEnabled
      bool? isSecureNfcEnabled = await _flutterNfcHcePlugin.isSecureNfcEnabled();

      //isNfcEnabled
      bool? isNfcEnabled = await _flutterNfcHcePlugin.isNfcEnabled();

      //nfc content
      var content = widget.urlToWrite;

      //start nfc hce
      var result = await _flutterNfcHcePlugin.startNfcHce(content);


    } catch (e) {
      // Manejar cualquier error
      print('Error en NFC: $e');
    }
  } // writeNFC()



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Write NFC'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('$_resultado',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
} // _NewPage3State






