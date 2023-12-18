import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_hce/flutter_nfc_hce.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:url_launcher/url_launcher.dart';
import 'model/record.dart';


class NfcHandler {

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
  final _flutterNfcHcePlugin = FlutterNfcHce(); //plugin instance
  TextEditingController _urlController = TextEditingController(
      text: "https://");
  bool _startNFC = false;


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
                      "---- Contacto recibido ----\n" + "Nombre: " +
                          palabras[0] +
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


}
