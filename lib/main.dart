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
} // MyApp


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum ContentType { url, contacto }

class _MyHomePageState extends State<MyHomePage> {
  List<SharedFile>? list;
  late StreamSubscription _intentDataStreamSubscription;
  late List<SharedMediaFile> _sharedFiles;
  String? _sharedText;
  Image? _contactPhoto;
  int currentPageIndex = 0;
  IconData currentIcon = Icons.tap_and_play;
  Function()? currentFunction;
  String _resultado = "Pulsar";
  late List<String> palabras;
  bool isButtonDisabled = true;
  String _urlToWrite = "";
  String? _nameToWrite = "";
  String? _phoneToWrite = "";
  String _emailToWrite = "";
  ContentType _selectedContentType = ContentType.contacto;
  bool selectedButton = false;
  bool selectedButton2 = false;
  bool selectedButton3 = false;
  String? _contact;
  //plugin instance
  final _flutterNfcHcePlugin = FlutterNfcHce();
  TextEditingController _urlController = TextEditingController(text: "https://");
  bool _startNFC = false;


  // void _mostrarCuadroTexto() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return _buildContentInputDialog(context);
  //     },
  //   );
  // }
  //
  // Widget _buildContentInputDialog(BuildContext context) {
  //   return AlertDialog(
  //     title: Text("Ingresar ${_selectedContentType == ContentType.url
  //         ? 'URL'
  //         : 'Contacto'}"),
  //     content: _getContentInputField(),
  //     actions: <Widget>[
  //       TextButton(
  //         child: Text("Cancelar"),
  //         onPressed: () {
  //           Navigator.of(context).pop();
  //         },
  //       ),
  //       TextButton(
  //         child: Text("Aceptar"),
  //         onPressed: () {
  //           if (_selectedContentType == ContentType.url) {
  //             _writeUrl();
  //           } else {
  //             _writeContact();
  //           }
  //           Navigator.of(context).pop();
  //         },
  //       ),
  //     ],
  //   );
  // }

  // Widget _getContentInputField() {
  //   if (_selectedContentType == ContentType.url) {
  //     TextEditingController _urlController = TextEditingController(
  //         text: "https://");
  //     return TextField(
  //       controller: _urlController,
  //       onChanged: (value) {
  //         _urlToWrite = value;
  //       },
  //     );
  //   } else {
  //     TextEditingController _nombreController = TextEditingController();
  //     TextEditingController _telefonoController = TextEditingController();
  //     TextEditingController _emailController = TextEditingController();
  //
  //     return Column(
  //       children: [
  //         TextField(
  //           controller: _nombreController,
  //           decoration: InputDecoration(labelText: 'Nombre'),
  //           onChanged: (value) {
  //             _nameToWrite = value;
  //           },
  //         ),
  //         TextField(
  //           controller: _telefonoController,
  //           keyboardType: TextInputType.phone,
  //           decoration: InputDecoration(labelText: 'Teléfono'),
  //           onChanged: (value) {
  //             _phoneToWrite = value;
  //           },
  //         ),
  //         TextField(
  //           controller: _emailController,
  //           keyboardType: TextInputType.emailAddress,
  //           decoration: InputDecoration(labelText: 'Correo electrónico'),
  //           onChanged: (value) {
  //             _emailToWrite = value;
  //           },
  //         ),
  //       ],
  //     );
  //   }
  // }


  void _writeUrl() async {
    try {
      setState(() {
        _resultado = "Acerca tu teléfono a otro para compartir la URL";
        selectedButton2 = false;
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
        selectedButton2 = false;

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


  // Función para mostrar la ventana emergente de ayuda
  void _showHelpDialog() {
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

                String content = _mensaje.text.toString();

                if (content.startsWith("URL:")) {
                  // Es una URL
                  setState(() {
                    _resultado =
                        content.substring(4) + "\nAbriendo navegador...";
                  });

                  // esperar 1 segundo antes de abrir el navegador
                  await Future.delayed(Duration(milliseconds: 2000));

                  Uri url = Uri.parse(content.substring(4));
                  //lanzo el navegador predeterminado del movil con la url
                  if (await canLaunchUrl(url)) {
                    await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                    setState(() {
                      _resultado =
                          content.substring(4);
                    });
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
                        "---- Contacto recibido ----\n" + "Nombre: " + palabras[0] +
                            "\nTeléfono: " + palabras[1] + "\nEmail: " +
                            palabras[2];
                    isButtonDisabled = false;
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
      setState(() {
        /// desactivo boton
        isButtonDisabled = true;
      });
      // Mostrar un SnackBar para indicar que el contacto ha sido añadido
      final snackBar = SnackBar(
        content: Text('Contacto añadido con éxito'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } // addContact()




    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            switch (index) {
              case 0:
                currentPageIndex = index;
                currentIcon = Icons.tap_and_play;
                setState(() {
                  currentFunction = initNFC;
                  selectedButton = false;
                  selectedButton2 = false;
                  _startNFC = false;
                  isButtonDisabled = true;
                });

                break;
              case 1:
                currentPageIndex = index;
                currentIcon = Icons.send;
                setState(() {
                  currentFunction = _writeUrl;
                  selectedButton = true;
                  selectedButton2 = false;
                });

                break;
              case 2:
                currentPageIndex = index;

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


      floatingActionButton:
        Visibility(
          visible: selectedButton2,
          child: FloatingActionButton(
            onPressed: currentFunction,
            child: Icon(currentIcon),
          ),
        ),


      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: Text(widget.title,
          style: TextStyle(
            color: Colors.white, // Set the text color to white
          ),
        ),
        actions: <Widget>[
          // Añadir el botón de ayuda en la AppBar
          IconButton(
            icon: Icon(Icons.help,
              color: Colors.white,
            ),
            onPressed: () {
              _showHelpDialog();
            },
          ),
        ],
      ),


      body:
      Container(
        color: Colors.deepPurpleAccent,
        child: <Widget>[

          /// Read page
            Center(
              child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Visibility(
                      visible: !_startNFC,
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
                      visible: !_startNFC,
                      child: ElevatedButton(
                      onPressed: () {
                        initNFC();
                        setState(() {
                          _startNFC = true;
                        });

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
                      visible: _startNFC,
                      child:
                        Text('$_resultado',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                    ),

                    SizedBox(height: 20),

                    Visibility(
                      visible: _startNFC,
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
                          addContact();
                        },
                        child: Text('Añadir a contactos'),
                      ),
                    ),
                  ],
                ),
            ),



          /// Send page
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Visibility(
                  visible: selectedButton,
                  child: Column(
                    children: <Widget>[
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.web),
                          title: Text('URL'),
                          subtitle: Text('Envía una página web'),
                          onTap: () {
                            setState(() {
                              _selectedContentType = ContentType.url;
                              selectedButton = false; // botones URL, contacto...
                              selectedButton2 = true; //boton flotante
                              selectedButton3 = false; // enviar contacto
                            });
                          },
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.contacts),
                          title: Text('Contacto de agenda'),
                          subtitle: Text('Envía un contacto nuevo o existente'),
                          onTap: () {
                            setState(() {
                              _selectedContentType = ContentType.contacto;
                              selectedButton = false; // botones URL, contacto...
                              selectedButton2 = true; //boton flotante
                              selectedButton3 = true; // enviar contacto
                              currentFunction = _writeContact;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),


                Visibility(
                  visible: selectedButton2 && selectedButton3,
                  child:
                  Container(
                    width: 300.0,
                    decoration: BoxDecoration(
                      color: Colors.white, // Fondo blanco del Container
                      borderRadius: BorderRadius.circular(10.0), // Borde redondeado, ajusta según sea necesario
                    ),
                    child:
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _nameToWrite = value;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0), // Ajusta el espacio interno según sea necesario
                        hintText: 'Nombre',
                        border: InputBorder.none, // Elimina el borde del TextField
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Visibility(
                  visible: selectedButton2 && selectedButton3,
                  child:
                  Container(
                    width: 300.0,
                    decoration: BoxDecoration(
                      color: Colors.white, // Fondo blanco del Container
                      borderRadius: BorderRadius.circular(10.0), // Borde redondeado, ajusta según sea necesario
                    ),
                    child:
                    TextField(
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        setState(() {
                          _phoneToWrite = value;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0), // Ajusta el espacio interno según sea necesario
                        hintText: 'Teléfono',
                        border: InputBorder.none, // Elimina el borde del TextField
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Visibility(
                  visible: selectedButton2 && selectedButton3,
                  child:
                  Container(
                    width: 300.0,
                    decoration: BoxDecoration(
                      color: Colors.white, // Fondo blanco del Container
                      borderRadius: BorderRadius.circular(10.0), // Borde redondeado, ajusta según sea necesario
                    ),
                    child:
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        setState(() {
                          _emailToWrite = value;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0), // Ajusta el espacio interno según sea necesario
                        hintText: 'Email',
                        border: InputBorder.none, // Elimina el borde del TextField
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                Visibility(
                  visible: _selectedContentType == ContentType.contacto &&
                      !selectedButton && selectedButton2,
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

                Visibility(
                  visible: !selectedButton2 && !selectedButton,
                  child:
                  Text('$_resultado',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                Visibility(
                  visible: !selectedButton2 && !selectedButton,
                  child:
                  Icon(Icons.tap_and_play,
                    color: Colors.white,
                    size: 50,),
                ),

                Visibility(
                  visible: selectedButton2 && !selectedButton3,
                  child:
                    Container(
                      width: 300.0,
                      decoration: BoxDecoration(
                        color: Colors.white, // Fondo blanco del Container
                        borderRadius: BorderRadius.circular(10.0), // Borde redondeado, ajusta según sea necesario
                      ),
                      child:
                        TextField(
                          controller: _urlController,
                          onChanged: (value) {
                            setState(() {
                              _urlToWrite = value;
                            });
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0), // Ajusta el espacio interno según sea necesario
                            hintText: 'Ingrese la URL',
                            border: InputBorder.none, // Elimina el borde del TextField
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),


          /// Historial page
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Card(
                  child: ListTile(
                    leading: Icon(Icons.notifications_sharp),
                    title: Text('Notification 1'),
                    subtitle: Text('This is a notification'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.notifications_sharp),
                    title: Text('Notification 2'),
                    subtitle: Text('This is a notification'),
                  ),
                ),
              ],
            ),
          ),

        ][currentPageIndex],
      ),

      // drawer: Drawer(
      //   child: drawerItems,
      // ),
    );
  } // Widget build
} // class _MyHomeState()






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

