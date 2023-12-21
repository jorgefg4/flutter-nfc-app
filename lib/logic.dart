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
  IconData currentIcon = Icons.tap_and_play;
  String? _contact;
  final _flutterNfcHcePlugin = FlutterNfcHce(); //plugin instance
  TextEditingController _urlController = TextEditingController(text: "https://");



  // constructor
  NfcHandler({
    this.list,
    this.currentIcon = Icons.tap_and_play,
  });




  void writeUrl(String urlToWrite) async {
    try {
      //getPlatformVersion
      var platformVersion = await _flutterNfcHcePlugin.getPlatformVersion();

      //isNfcHceSupported
      bool? isNfcHceSupported = await _flutterNfcHcePlugin.isNfcHceSupported();

      //isSecureNfcEnabled
      bool? isSecureNfcEnabled = await _flutterNfcHcePlugin.isSecureNfcEnabled();

      //isNfcEnabled
      bool? isNfcEnabled = await _flutterNfcHcePlugin.isNfcEnabled();

      //start nfc hce
      var result = await _flutterNfcHcePlugin.startNfcHce("URL:" + urlToWrite);
    } catch (e) {
      // Manejar cualquier error
      print('Error en NFC: $e');
    }
  } // _writeUrl()



  void writeContact(String nameToWrite, String phoneToWrite, String emailToWrite) async {
    try {
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
      var content = "CONTACTO:" + nameToWrite! + "*" + phoneToWrite! + "*" +
          emailToWrite;

      //start nfc hce
      var result = await _flutterNfcHcePlugin.startNfcHce(content);
    } catch (e) {
      // Manejar cualquier error
      print('Error en NFC: $e');
    }
  } // _writeContact()




  Future<String> initNFC() async {
    Completer<String> completer = Completer<String>();

    try {
      await NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        String resultado = "resultado vacio";

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
              resultado = content;
            }
          }
        }
        completer.complete(resultado);
      });
    } catch (e) {
      // Manejar cualquier error
      print('Error en NFC: $e');
    }

    return completer.future;
  } // initNFC()



  void addContact(String name, String phone, String email) async {
    // Crear un nuevo contacto
    Contact contacto = Contact(
      givenName: name,
      phones: [Item(label: 'teléfono', value: phone)],
      emails: [Item(label: 'email', value: email)],
    );
    await ContactsService.addContact(contacto);
  } // addContact()

} // class NfcHandler
