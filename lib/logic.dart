import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_nfc_hce/flutter_nfc_hce.dart';
import 'package:intl/intl.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'model/record.dart';
import 'package:add_2_calendar/add_2_calendar.dart';


class NfcHandler {
  // List<SharedFile>? list;
  // IconData currentIcon = Icons.tap_and_play;
  // String? _contact;
  final _flutterNfcHcePlugin = FlutterNfcHce(); //plugin instance
  // TextEditingController _urlController = TextEditingController(text: "https://");


  // constructor
  // NfcHandler({
  //   // this.list,
  //   // this.currentIcon = Icons.tap_and_play,
  // });



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



  void writeLocation(double latitudeToWrite, double longitudeToWrite, String address) async {
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
      var content = "LOCATION:" + latitudeToWrite.toString() + "*" + longitudeToWrite.toString() + "*" + address;

      //start nfc hce
      var result = await _flutterNfcHcePlugin.startNfcHce(content);
    } catch (e) {
      // Manejar cualquier error
      print('Error en NFC: $e');
    }
  } //writeLocation()



  void writeEvent(String titleToWrite, String locationToWrite, String initialDateToWrite, String endDateToWrite) async {
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
      var content = "EVENT:" + titleToWrite! + "*" + locationToWrite! + "*" +
          initialDateToWrite + "*" + endDateToWrite;

      //start nfc hce
      var result = await _flutterNfcHcePlugin.startNfcHce(content);
    } catch (e) {
      // Manejar cualquier error
      print('Error en NFC: $e');
    }
  } // _writeEvent()




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


  void openMaps(String latitude, String longitude) async {
    String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=' + latitude + "," + longitude;

    Uri url = Uri.parse(googleMapsUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'No se pudo abrir Google Maps';
    }
  } // openMaps()

  // Función para lanzar la URL en el navegador
  Future<String> launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      return '';
    } else {
      return 'No es posible abrir la URL';
    }
  } // launchURL


  void addEvent(String title, String location, String initialDate, String endDate) async {
    DateFormat formatoFecha = DateFormat('dd/MM/yyyy');
    final Event event = Event(
      title: title,
      location: location,
      startDate: formatoFecha.parse(initialDate),
      endDate: formatoFecha.parse(endDate),
    );
    Add2Calendar.addEvent2Cal(event);
  } // addContact()

} // class NfcHandler
