import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:prueba1/model/record.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_nfc_hce/flutter_nfc_hce.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart' as Picker;


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
      home: const MyHomePage(title: 'QuickNFC'),
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
  // late StreamSubscription _intentDataStreamSubscription;
  // List<SharedFile>? list;
  late StreamSubscription _intentDataStreamSubscription;
  late List<SharedMediaFile> _sharedFiles;
  String? _sharedText;
  Image? _contactPhoto;

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
                      NewPage3(urlToWrite: _sharedText.toString())));
            }
            print("LA URL ES: " + _sharedText.toString());
          });
        }, onError: (err) {
          print("getLinkStream error: $err");
        });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) {
      setState(() {
        if(isUrl(value.toString())){
          _sharedText = value;
          Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
              NewPage3(urlToWrite: _sharedText.toString())));
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
            Text(
              'Esta es la página de bienvenida. Para acceder a la funcionalidad, use el menú.',
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
  bool _contactoLeido = false;
  late List<String> palabras;
  bool isButtonDisabled = false;

  void initNFC() async {
    try {
      setState(() {
        _resultado = "Esperando lectura...";
      });
      await NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        // Se ha descubierto una etiqueta NFC
        print('Tag descubierta: ${tag.data}');

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


              // esperar 1 segundo antes de abrir el navegador
              await Future.delayed(Duration(milliseconds: 1000));

              String content = _mensaje.text.toString();

              if (content.startsWith("URL:")) {
                // Es una URL
                setState(() {
                  _resultado =
                      _mensaje.text.toString() + " Abriendo navegador...";
                });
                Uri url = Uri.parse(content.substring(4));
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

              } else if (content.startsWith("CONTACTO:")) {
                // Es un contacto
                String contactoData = content.substring(9);
                palabras = contactoData.split("*");
                setState(() {
                  _resultado = "Contacto recibido:\n" + "Nombre: " + palabras[0] + "\nTeléfono: " + palabras[1] + "\nEmail: " + palabras[2];
                  _contactoLeido = true;
                });
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



  void addContact() async {
    // Crear un nuevo contacto
    Contact contacto = Contact(
      givenName: palabras[0],
      phones: [Item(label: 'teléfono', value: palabras[1])],
      emails: [Item(label: 'email', value: palabras[2])],
    );
    await ContactsService.addContact(contacto);
    setState(() { /// desactivo boton
      isButtonDisabled = true;
    });
    // Mostrar un SnackBar para indicar que el contacto ha sido añadido
    final snackBar = SnackBar(
      content: Text('Contacto añadido con éxito'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

              SizedBox(height: 20), // Espacio entre el texto y el botón

            Visibility(
              visible: _contactoLeido && !isButtonDisabled,
              child: ElevatedButton(
                onPressed: () {
                    addContact();
                },
                child: Text('Añadir a contactos'),
              ),
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


  @override
  void dispose() {
    // Detener la sesión de NFC al abandonar la página
    NfcManager.instance.stopSession();
    print("Detuve la sesión de NFC");
    super.dispose();
  }
} // _NewPage1State






class NewPage2 extends StatefulWidget {
  @override
  _NewPage2State createState() => _NewPage2State();
}

enum ContentType { url, contacto }

class _NewPage2State extends State<NewPage2> {
  bool isButtonDisabled = false;
  String _resultado = "Pulsar para enviar URL";
  String _urlToWrite = "";
  String? _nameToWrite = "";
  String? _phoneToWrite = "";
  String _emailToWrite = "";
  ContentType _selectedContentType = ContentType.url;
  String? _contact;
  //plugin instance
  final _flutterNfcHcePlugin = FlutterNfcHce();

  void _mostrarCuadroTexto(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildContentInputDialog(context);
      },
    );
  }

  Widget _buildContentInputDialog(BuildContext context) {
    return AlertDialog(
      title: Text("Ingresar ${_selectedContentType == ContentType.url ? 'URL' : 'Contacto'}"),
      content: _getContentInputField(),
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
            if (_selectedContentType == ContentType.url) {
              _writeUrl();
            } else {
              _writeContact();
            }

            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _getContentInputField() {
    if (_selectedContentType == ContentType.url) {
      TextEditingController _urlController = TextEditingController(text: "https://");
      return TextField(
        controller: _urlController,
        onChanged: (value) {
          _urlToWrite = value;
        },
      );
    } else {
      TextEditingController _nombreController = TextEditingController();
      TextEditingController _telefonoController = TextEditingController();
      TextEditingController _emailController = TextEditingController();

      return Column(
        children: [
          TextField(
            controller: _nombreController,
            decoration: InputDecoration(labelText: 'Nombre'),
            onChanged: (value) {
              _nameToWrite = value;
            },
          ),
          TextField(
            controller: _telefonoController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: 'Teléfono'),
            onChanged: (value) {
              _phoneToWrite = value;
            },
          ),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: 'Correo electrónico'),
            onChanged: (value) {
              _emailToWrite = value;
            },
          ),
        ],
      );

    }
  }



  void _writeUrl() async {
    try {
      setState(() {
        _resultado = "Acerca tu teléfono a otro para compartir la URL";
      });

      //getPlatformVersion
      var platformVersion = await _flutterNfcHcePlugin.getPlatformVersion();

      //isNfcHceSupported
      bool? isNfcHceSupported = await _flutterNfcHcePlugin.isNfcHceSupported();

      //isSecureNfcEnabled
      bool? isSecureNfcEnabled = await _flutterNfcHcePlugin.isSecureNfcEnabled();

      //isNfcEnabled
      bool? isNfcEnabled = await _flutterNfcHcePlugin.isNfcEnabled();

      //start nfc hce
      var result = await _flutterNfcHcePlugin.startNfcHce("URL:" + _urlToWrite);


    } catch (e) {
      // Manejar cualquier error
      print('Error en NFC: $e');
    }
  } // _writeUrl()



  void _writeContact() async {
    try {
      setState(() {
        _resultado = "Acerca tu teléfono a otro para compartir el contacto";
        /// desactivo boton
        isButtonDisabled = true;
      });

      //getPlatformVersion
      var platformVersion = await _flutterNfcHcePlugin.getPlatformVersion();

      //isNfcHceSupported
      bool? isNfcHceSupported = await _flutterNfcHcePlugin.isNfcHceSupported();

      //isSecureNfcEnabled
      bool? isSecureNfcEnabled = await _flutterNfcHcePlugin.isSecureNfcEnabled();

      //isNfcEnabled
      bool? isNfcEnabled = await _flutterNfcHcePlugin.isNfcEnabled();

      //nfc content
      var content = "CONTACTO:" + _nameToWrite! + "*" + _phoneToWrite! + "*" + _emailToWrite;

      //start nfc hce
      var result = await _flutterNfcHcePlugin.startNfcHce(content);

    } catch (e) {
      // Manejar cualquier error
      print('Error en NFC: $e');
    }
  } // _writeContact()



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send NFC'),
        actions: [
          DropdownButton<ContentType>(
            value: _selectedContentType,
            onChanged: (ContentType? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedContentType = newValue;
                });
                if (newValue == ContentType.contacto) {
                  setState(() {
                    _resultado = "Pulsar para enviar Contacto";
                    isButtonDisabled = false; // activo boton
                  });
                } else{
                  setState(() {
                    _resultado = "Pulsar para enviar URL";
                  });
                }
              }
            },
            items: <DropdownMenuItem<ContentType>>[
              DropdownMenuItem<ContentType>(
                value: ContentType.url,
                child: Text('URL',
                  // style: TextStyle(
                  //   color: Colors.white, // Establecer el color del texto en blanco
                  // ),
                ),
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
            Text(
              '$_resultado',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Visibility(
              visible: _selectedContentType == ContentType.contacto && !isButtonDisabled,
              child: ElevatedButton(
                  child: const Text("Seleccionar contacto de agenda..."),
                  onPressed: () async {
                    final Picker.FullContact contact =
                    (await Picker.FlutterContactPicker.pickFullContact());
                    setState(() {
                      _contact = contact.toString();
                      _nameToWrite = contact.name?.nickName;
                      _phoneToWrite = contact.phones?.first.number;
                      print("CONTACT: " + contact.toString());
                    });
                    _writeContact();
                  },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarCuadroTexto(context),
        tooltip: 'Write NFC',
        child: const Icon(Icons.save_as),
      ),
    );
  }


  @override
  void dispose() {
    //stop nfc hce
    _flutterNfcHcePlugin.stopNfcHce();
    print("se ha parado el HCE");
    super.dispose();
  }
} // NewPage2State()








// para cuando se da al botón compartir url en una app externa
class NewPage3 extends StatefulWidget {
  final String urlToWrite;

  NewPage3({required this.urlToWrite});

  @override
  _NewPage3State createState() => _NewPage3State();
}

class _NewPage3State  extends State<NewPage3> {
  String _resultado = "Esperando para compartir...";
  final _flutterNfcHcePlugin = FlutterNfcHce();

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
      var result = await _flutterNfcHcePlugin.startNfcHce("URL:" + content);


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

  @override
  void dispose() {
    //stop nfc hce
    _flutterNfcHcePlugin.stopNfcHce();
    print("se ha parado el HCE");
    super.dispose();
  }
} // _NewPage3State






