import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart' as Picker;
import '../logic.dart';



//Página para ENVIAR
class SendPage extends StatefulWidget {
  const SendPage({Key? key}) : super(key: key);

  @override
  _SendPageState createState() => _SendPageState();
}

enum ContentType { url, contacto }

class _SendPageState extends State<SendPage> {
  final GlobalKey<_SendPageState> _sendPageKey = GlobalKey<_SendPageState>();

  Function()? currentFunction;
  String resultado = "";
  bool isButtonDisabled = true;
  String _urlToWrite = "";
  String? _nameToWrite = "";
  String? _phoneToWrite = "";
  String _emailToWrite = "";
  ContentType _selectedContentType = ContentType.contacto;
  bool selectedButton = true;
  bool selectedButton2 = false;
  bool selectedButton3 = false;
  String? _contact;
  TextEditingController _urlController = TextEditingController(text: "https://");

//inicializo el manejador
  NfcHandler nfcHandler = NfcHandler();

  void writeUrl() async {
    setState(() {
      resultado = "Acerca tu teléfono a otro para compartir la URL";
      selectedButton2 = false;
    });
    nfcHandler.writeUrl(_urlToWrite);
  }

  void writeContact() async {
    setState(() {
      resultado = "Acerca tu teléfono a otro para compartir el contacto";
      selectedButton2 = false;
      /// desactivo boton
      isButtonDisabled = true;
    });
    nfcHandler.writeContact(_nameToWrite!, _phoneToWrite!, _emailToWrite);
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepPurpleAccent,
      child:
      /// Send page
      Center(
        child: Stack(
            children: <Widget>[
              Column(
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
                                currentFunction = writeUrl;
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
                                currentFunction = writeContact;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),



                  // formulario enviar contacto
                  Visibility(
                    visible: selectedButton2 && selectedButton3,
                    child:
                    Container(
                      width: 300.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0), // Borde redondeado
                      ),
                      child:
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _nameToWrite = value;
                          });
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0), // Borde redondeado
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
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0), // Borde redondeado
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
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                          hintText: 'Email',
                          border: InputBorder.none, // Elimina el borde del TextField
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // botón importar contacto
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
                        writeContact();
                      },
                    ),
                  ),

                  Visibility(
                    visible: !selectedButton2 && !selectedButton,
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
                    visible: !selectedButton2 && !selectedButton,
                    child:
                    Icon(Icons.tap_and_play,
                      color: Colors.white,
                      size: 50,),
                  ),

                  //formulario URL
                  Visibility(
                    visible: selectedButton2 && !selectedButton3,
                    child:
                    Container(
                      width: 300.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0), // Borde redondeado
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
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                          hintText: 'Ingrese la URL',
                          border: InputBorder.none, // Elimina el borde del TextField
                        ),
                      ),
                    ),
                  ),

                  // botón flotante
                  Visibility(
                    visible: selectedButton2,
                    child:
                    Align(),
                  ),
                ],
              ),
              Visibility(
                visible: selectedButton2,
                child:
                Positioned(
                  bottom: 16.0,
                  right: 10.0,
                  child:
                  FloatingActionButton(
                    onPressed: currentFunction,
                    child: Icon(Icons.send),
                  ),
                ),
              ),
            ]
        ),
      ),
    );
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }
} // class _SendPageState
