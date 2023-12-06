import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:prueba1/model/record.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_nfc_hce/flutter_nfc_hce.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart' as Picker;
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:path/path.dart' as path;
import 'package:whatsapp_stickers_plus/exceptions.dart';
import 'package:whatsapp_stickers_plus/whatsapp_stickers.dart';


void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key}); //constructor

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickNFC',
      theme:
        // ThemeData(
        // primarySwatch: Colors.deepPurple,
        // ),
        ThemeData(useMaterial3: true),
      home: const MyHomePage(title: 'QuickNFC'),
    );
  } // Widget build
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
  List<SharedFile>? list;
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


    // For sharing images coming from outside the app while the app is in the memory
    // _intentDataStreamSubscription =
    //     FlutterSharingIntent.instance.getMediaStream()
    //         .listen((List<SharedFile> value) {
    //       if (value.isNotEmpty) {
    //         setState(() {
    //           list = value;
    //           Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
    //               NewPage4(imagePath: value.map((f) => f.value).join(","))));
    //         });
    //         print("Shared: getMediaStream ${value.map((f) => f.value).join(
    //             ",")}");
    //       }
    //     }, onError: (err) {
    //       print("getIntentDataStream error: $err");
    //     });
    //
    // // For sharing images coming from outside the app while the app is closed
    // FlutterSharingIntent.instance.getInitialSharing().then((
    //     List<SharedFile> value) {
    //   print("Shared: getInitialMedia ${value.map((f) => f.value).join(",")}");
    //   if (value.isNotEmpty) {
    //     setState(() {
    //       list = value;
    //       Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
    //           NewPage4(imagePath: value.map((f) => f.value).join(","))));
    //     });
    //   }
    // });


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
        if (isUrl(value.toString())) {
          _sharedText = value;
          Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
              NewPage3(urlToWrite: _sharedText.toString())));
        }
      });
    });
  } // initState()




  @override
  Widget build(BuildContext context) {

    // final drawerItems = ListView(
    // children: <Widget>[
    // // drawerHeader,
    // ListTile(
    // title: const Text('Read NFC'),
    // onTap: () {
    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => NewPage1()));
    // },
    // ),
    // ListTile(
    // title: const Text('Write NFC'),
    // onTap: () {
    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => NewPage2()));
    // },
    // ),
    // ListTile(
    // title: const Text('other drawer item'),
    // onTap: () {},
    // ),
    // ],
    // );


    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            switch (index) {
              case 0:
              // Navigate to the Home page
                break;
              case 1:
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => NewPage1()));
                break;
              case 2:
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => NewPage2()));
                break;
              case 3:
              // Navigate to the History page
                break;
            }
          });
        },
        // indicatorColor: Colors.amber,
        // selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
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
              'Bienvenido a QuickNFC',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      // drawer: Drawer(
      //   child: drawerItems,
      // ),
    );
  } // Widget build
} // class _MyHomeState()


class NewPage1 extends StatefulWidget {
  @override
  _NewPage1State createState() => _NewPage1State();
}

class _NewPage1State extends State<NewPage1> {
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
                  _resultado =
                      "Contacto recibido:\n" + "Nombre: " + palabras[0] +
                          "\nTeléfono: " + palabras[1] + "\nEmail: " +
                          palabras[2];
                  _contactoLeido = true;
                });
              }
              // else if (content.startsWith("IMAGE:")) {
              //   // Es un sticker
              //   String imageBase64 = content.substring(6);
              //   // Decodifica la cadena base64
              //   Uint8List imageBytes = base64Decode(imageBase64);
              //   // Escribe los bytes en un archivo de imagen
              //   await File('/assets/sticker.webp').writeAsBytes(imageBytes);
              //
              //   const stickers = {
              //     'sticker.webp': ['☕', '🙂'],
              //     'icon.webp': ['☕', '🙂'],
              //     'icon2.webp': ['☕', '🙂'],
              //   };
              //
              //   Future installFromAssets() async {
              //     var stickerPack = WhatsappStickers(
              //       identifier: 'cuppyFlutterWhatsAppStickers',
              //       name: 'Cuppy Flutter WhatsApp Stickers',
              //       publisher: 'John Doe',
              //       trayImageFileName: WhatsappStickerImage.fromAsset(
              //           'assets/sticker.webp'),
              //       publisherWebsite: '',
              //       privacyPolicyWebsite: '',
              //       licenseAgreementWebsite: '',
              //     );
              //
              //     stickers.forEach((sticker, emojis) {
              //       stickerPack.addSticker(
              //           WhatsappStickerImage.fromAsset('assets/$sticker'),
              //           emojis);
              //     });
              //
              //     try {
              //       await stickerPack.sendToWhatsApp();
              //     } on WhatsappStickersException catch (e) {
              //       print("ERROR AL AÑADIR EL PAQUETE DE STICKERS A WHATSAPP:");
              //       print(e.cause);
              //     }
              //   }
              //
              //   installFromAssets();
              // }
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
    setState(() {
      /// desactivo boton
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
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineMedium,
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
      title: Text("Ingresar ${_selectedContentType == ContentType.url
          ? 'URL'
          : 'Contacto'}"),
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
      TextEditingController _urlController = TextEditingController(
          text: "https://");
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
      bool? isSecureNfcEnabled = await _flutterNfcHcePlugin
          .isSecureNfcEnabled();

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
      bool? isSecureNfcEnabled = await _flutterNfcHcePlugin
          .isSecureNfcEnabled();

      //isNfcEnabled
      bool? isNfcEnabled = await _flutterNfcHcePlugin.isNfcEnabled();

      //nfc content
      var content = "CONTACTO:" + _nameToWrite! + "*" + _phoneToWrite! + "*" +
          _emailToWrite;

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
                } else {
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
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineMedium,
            ),
            Visibility(
              visible: _selectedContentType == ContentType.contacto &&
                  !isButtonDisabled,
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

class _NewPage3State extends State<NewPage3> {
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
      bool? isSecureNfcEnabled = await _flutterNfcHcePlugin
          .isSecureNfcEnabled();

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
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineMedium,
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


// para cuando se da al botón compartir imagen en una app externa
// class NewPage4 extends StatefulWidget {
//   final String imagePath;
//
//   NewPage4({required this.imagePath});
//
//   @override
//   _NewPage4State createState() => _NewPage4State();
// }
//
// class _NewPage4State extends State<NewPage4> {
//   String _resultado = "Esperando para compartir...";
//   final _flutterNfcHcePlugin = FlutterNfcHce();
//
//   @override
//   void initState() {
//     super.initState();
//     writeNFC();
//   }
//
//   Future<String> imageToBase64(String imagePath) async {
//     // Lee el archivo de imagen como bytes
//     File imageFile = File(imagePath);
//     List<int> imageBytes = await imageFile.readAsBytes();
//
//     // Convierte los bytes en una cadena codificada en base64
//     String base64String = base64Encode(imageBytes);
//
//     return base64String;
//   }
//
//   void writeNFC() async {
//     try {
//       setState(() {
//         _resultado = "Acerca tu teléfono a otro para compartir la imagen";
//       });
//
//       //getPlatformVersion
//       var platformVersion = await _flutterNfcHcePlugin.getPlatformVersion();
//
//       //isNfcHceSupported
//       bool? isNfcHceSupported = await _flutterNfcHcePlugin.isNfcHceSupported();
//
//       //isSecureNfcEnabled
//       bool? isSecureNfcEnabled = await _flutterNfcHcePlugin
//           .isSecureNfcEnabled();
//
//       //isNfcEnabled
//       bool? isNfcEnabled = await _flutterNfcHcePlugin.isNfcEnabled();
//
//       String extension = path.extension(widget.imagePath);
//       if (extension.toLowerCase() == ".webp") {
//         try {
//           String base64String = await imageToBase64(widget.imagePath);
//           print('Imagen convertida a base64: $base64String');
//           int size = base64String.codeUnits.length * 2;
//           print("EL TAMAÑO ES: " + size.toString());
//
//           //start nfc hce
//           var result = await _flutterNfcHcePlugin.startNfcHce(
//               "IMAGE:" + base64String);
//         } catch (e) {
//           print('Error al convertir la imagen: $e');
//         }
//       } else {
//         setState(() {
//           _resultado =
//           'El formato de imagen seleccionado no es compatible. Pruebe con formatos ".webp"';
//         });
//       }
//     } catch (e) {
//       // Manejar cualquier error
//       print('Error en NFC: $e');
//     }
//   } // writeNFC()
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Write NFC'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text('$_resultado',
//               style: Theme
//                   .of(context)
//                   .textTheme
//                   .headlineMedium,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     //stop nfc hce
//     _flutterNfcHcePlugin.stopNfcHce();
//     print("se ha parado el HCE");
//     super.dispose();
//   }
// } // _NewPage4State






