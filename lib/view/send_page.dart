import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart' as Picker;
import '../logic.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

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
  String _urlToWrite = "";
  String? _nameToWrite = "";
  String? _phoneToWrite = "";
  String _emailToWrite = "";
  String _locationToWrite = "";
  String _titleToWrite = "";
  late double _latitude;
  late double _longitude;
  String? _address = "";
  ContentType _selectedContentType = ContentType.contacto;
  bool selectedButton = true;
  bool selectedButton2 = false;
  bool selectedButton3 = false;
  bool selectedButton4 = false;
  bool selectedButton5 = false;
  String? _contact;
  TextEditingController _urlController =
      TextEditingController(text: "https://");
  String _selectedInitialDate = 'Fecha de inicio';
  String _selectedEndDate = 'Fecha de fin   ';

// inicializar el manejador
  NfcHandler nfcHandler = NfcHandler();

  void writeUrl() async {
    //comprueba si NFC está activado
    bool nfcAvailable = await NfcManager.instance.isAvailable();
    if (nfcAvailable == false) {
      setState(() {
        resultado =
            "NFC descativado. Por favor, actívalo e inicia de nuevo el envío.";
        selectedButton2 = false;
      });
      return;
    }

    setState(() {
      resultado = "Acerca tu teléfono a otro para compartir la URL";
      selectedButton2 = false;
    });
    nfcHandler.writeUrl(_urlToWrite);
  }

  void writeContact() async {
    //comprueba si NFC está activado
    bool nfcAvailable = await NfcManager.instance.isAvailable();
    if (nfcAvailable == false) {
      setState(() {
        resultado =
            "NFC descativado. Por favor, actívalo e inicia de nuevo el envío.";
        selectedButton2 = false;
      });
      return;
    }

    setState(() {
      resultado = "Acerca tu teléfono a otro para compartir el contacto";
      selectedButton2 = false;
    });
    nfcHandler.writeContact(_nameToWrite!, _phoneToWrite!, _emailToWrite);
  }

  void writeLocation() async {
    //comprueba si NFC está activado
    bool nfcAvailable = await NfcManager.instance.isAvailable();
    if (nfcAvailable == false) {
      setState(() {
        resultado =
            "NFC descativado. Por favor, actívalo e inicia de nuevo el envío.";
        selectedButton2 = false;
        selectedButton4 = false;
      });
      return;
    }

    setState(() {
      resultado = "Acerca tu teléfono a otro para compartir la ubicación";
      selectedButton2 = false;
      selectedButton4 = false;
    });
    nfcHandler.writeLocation(_latitude, _longitude, _address!);
  } // writeLocation()

  void writeEvent() async {
    //comprueba si NFC está activado
    bool nfcAvailable = await NfcManager.instance.isAvailable();
    if (nfcAvailable == false) {
      setState(() {
        resultado =
            "NFC descativado. Por favor, actívalo e inicia de nuevo el envío.";
        selectedButton2 = false;
      });
      return;
    }

    setState(() {
      resultado = "Acerca tu teléfono a otro para compartir el evento";
      selectedButton2 = false;
    });
    nfcHandler.writeEvent(_titleToWrite!, _locationToWrite!,
        _selectedInitialDate, _selectedEndDate);
  } // writeEvent()

  Future<void> _selectInitialDate(BuildContext context) async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2200),
      locale: const Locale('es', 'ES'),
    );
    if (d != null) // si el usuario selecciono una fecha
      setState(() {
        _selectedInitialDate = new DateFormat.yMd('es_ES').format(d);
      });
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2200),
      locale: const Locale('es', 'ES'),
    );
    if (d != null) // si el usuario selecciono una fecha
      setState(() {
        _selectedEndDate = new DateFormat.yMd('es_ES').format(d);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepPurpleAccent,
      child: Center(
        child: Stack(
          children: <Widget>[
            Visibility(
              visible: selectedButton,
              child: ListView(
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
                          selectedButton4 = false; // enviar ubicacion
                          selectedButton5 = false; // enviar calendario
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
                          selectedButton4 = false; // enviar ubicacion
                          selectedButton5 = false; // enviar calendario
                          currentFunction = writeContact;
                        });
                      },
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text('Ubicación'),
                      subtitle:
                          Text('Envía una ubicación seleccionando de un mapa'),
                      onTap: () {
                        setState(() {
                          _selectedContentType = ContentType.url;
                          selectedButton = false; // botones URL, contacto...
                          selectedButton2 = false; //boton flotante
                          selectedButton3 = false; // enviar contacto
                          selectedButton4 = true; // enviar ubicacion
                          selectedButton5 = false; // enviar calendario
                        });
                      },
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.calendar_month),
                      title: Text('Evento de calendario'),
                      subtitle: Text('Envía un evento de calendario'),
                      onTap: () {
                        setState(() {
                          _selectedContentType = ContentType.url;
                          selectedButton = false; // botones URL, contacto...
                          selectedButton2 = true; //boton flotante
                          selectedButton3 = false; // enviar contacto
                          selectedButton4 = false; // enviar ubicacion
                          selectedButton5 = true; // enviar calendario
                          currentFunction = writeEvent;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // formulario enviar contacto
                Visibility(
                  visible: selectedButton2 && selectedButton3,
                  child: Container(
                    width: 300.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(10.0), // Borde redondeado
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _nameToWrite = value;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                        hintText: 'Nombre',
                        border:
                            InputBorder.none, // Elimina el borde del TextField
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Visibility(
                  visible: selectedButton2 && selectedButton3,
                  child: Container(
                    width: 300.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(10.0), // Borde redondeado
                    ),
                    child: TextField(
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        setState(() {
                          _phoneToWrite = value;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                        hintText: 'Teléfono',
                        border:
                            InputBorder.none, // Elimina el borde del TextField
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Visibility(
                  visible: selectedButton2 && selectedButton3,
                  child: Container(
                    width: 300.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(10.0), // Borde redondeado
                    ),
                    child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        setState(() {
                          _emailToWrite = value;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                        hintText: 'Email',
                        border:
                            InputBorder.none, // Elimina el borde del TextField
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // botón importar contacto
                Visibility(
                  visible: _selectedContentType == ContentType.contacto &&
                      !selectedButton &&
                      selectedButton2,
                  child: ElevatedButton(
                    child: const Text("Seleccionar contacto de agenda..."),
                    onPressed: () async {
                      final Picker.FullContact contact =
                          (await Picker.FlutterContactPicker.pickFullContact());
                      setState(() {
                        _contact = contact.toString();
                        _nameToWrite = contact.name?.nickName;
                        _phoneToWrite = contact.phones?.first.number;
                        // print("CONTACT: " + contact.toString());
                      });
                      writeContact();
                    },
                  ),
                ),

                Visibility(
                  visible:
                      !selectedButton2 && !selectedButton && !selectedButton4,
                  child: Text(
                    '$resultado',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                Visibility(
                  visible:
                      !selectedButton2 && !selectedButton && !selectedButton4,
                  child: Icon(
                    Icons.tap_and_play,
                    color: Colors.white,
                    size: 50,
                  ),
                ),

                //formulario URL
                Visibility(
                  visible: selectedButton2 &&
                      !selectedButton3 &&
                      !selectedButton4 &&
                      !selectedButton5,
                  child: Container(
                    width: 300.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(10.0), // Borde redondeado
                    ),
                    child: TextField(
                      controller: _urlController,
                      onChanged: (value) {
                        setState(() {
                          _urlToWrite = value;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                        hintText: 'Ingrese la URL',
                        border:
                            InputBorder.none, // Elimina el borde del TextField
                      ),
                    ),
                  ),
                ),

                // formulario enviar evento calendario
                Visibility(
                  visible: selectedButton2 && selectedButton5,
                  child: Text(
                    "Detalles de evento",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Visibility(
                  visible: selectedButton2 && selectedButton5,
                  child: Container(
                    width: 300.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(10.0), // Borde redondeado
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _titleToWrite = value;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                        hintText: 'Título',
                        border:
                            InputBorder.none, // Elimina el borde del TextField
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Visibility(
                  visible: selectedButton2 && selectedButton5,
                  child: Container(
                    width: 300.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(10.0), // Borde redondeado
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _locationToWrite = value;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                        hintText: 'Lugar',
                        border:
                            InputBorder.none, // Elimina el borde del TextField
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Visibility(
                  visible: selectedButton2 && selectedButton5,
                  child: Container(
                    width: 300.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(10.0), // Borde redondeado
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        InkWell(
                          child: Text(_selectedInitialDate,
                              style: TextStyle(
                                color: Color(0xFF7A7472),
                                fontWeight: FontWeight.w500,
                                fontSize: 15.5,
                                fontFamily: 'calibri',
                              )),
                          onTap: () {
                            _selectInitialDate(context);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_today),
                          tooltip: 'Pulsa para seleccionar una fecha',
                          onPressed: () {
                            _selectInitialDate(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Visibility(
                  visible: selectedButton2 && selectedButton5,
                  child: Container(
                    width: 300.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(10.0), // Borde redondeado
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        InkWell(
                          child: Text(_selectedEndDate,
                              style: TextStyle(
                                color: Color(0xFF7A7472),
                                fontWeight: FontWeight.w500,
                                fontSize: 15.5,
                                fontFamily: 'calibri',
                              )),
                          onTap: () {
                            _selectEndDate(context);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_today),
                          tooltip: 'Pulsa para seleccionar una fecha',
                          onPressed: () {
                            _selectEndDate(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: selectedButton2 && selectedButton5,
                  child: SizedBox(height: 70),
                ),

                // botón flotante
                Visibility(
                  visible: selectedButton2,
                  child: Align(),
                ),
              ],
            ),
            Visibility(
              visible: selectedButton2,
              child: Positioned(
                bottom: 16.0,
                right: 10.0,
                child: FloatingActionButton(
                  onPressed: currentFunction,
                  child: Icon(Icons.send),
                ),
              ),
            ),

            // mapa
            Visibility(
                visible: selectedButton4,
                child: OpenStreetMapSearchAndPick(
                  buttonTextStyle: const TextStyle(
                      fontSize: 18, fontStyle: FontStyle.normal),
                  buttonColor: Colors.deepPurpleAccent,
                  buttonText: 'Enviar ubicación',
                  locationPinIconColor: Colors.deepPurpleAccent,
                  locationPinText: '',
                  onPicked: (pickedData) {
                    _latitude = pickedData.latLong.latitude;
                    _longitude = pickedData.latLong.longitude;
                    _address = pickedData.addressName;
                    // print(pickedData.latLong.latitude);
                    // print(pickedData.latLong.longitude);
                    // print(pickedData.address);
                    // print(pickedData.addressName);
                    writeLocation();
                  },
                )),
          ],
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
