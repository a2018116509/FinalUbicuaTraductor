import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io' as Io;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String parsedtext = '';
  String text = '';
  parsethetext() async {
    // pick a image
    final imagefile = await ImagePicker()
        .getImage(source: ImageSource.gallery, maxWidth: 670, maxHeight: 970);

    // prepare the image
    var bytes = Io.File(imagefile.path.toString()).readAsBytesSync();
    String img64 = base64Encode(bytes);
    print(img64.toString());

    // send to OCR api 
    var url = 'https://api.ocr.space/parse/image';
    var payload = {"base64Image": "data:image/jpg;base64,${img64.toString()}"};
    var header = {"apikey": 'ffdbb1f6c388957'};
    var post = await http.post(url = url, body: payload, headers: header);

    // get result from OCR api
    var result = jsonDecode(post.body);
    setState(() {
      parsedtext = result['ParsedResults'][0]['ParsedText'];
    });

  //send to API translator
  var response = await http.post(
      Uri.encodeFull("https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&to=es"),
      headers: {"Ocp-Apim-Subscription-Key": "4ca648d6df9346de8f8a6b0835f30164" , "Ocp-Apim-Subscription-Region": "eastus" , "Content-Type": "application/json"},
      body: jsonEncode([
        {"Text":parsedtext}
      ])
  );

  //Valores necesarios
  var translation = jsonDecode(response.body);
  text = translation[0]["translations"][0]["text"];
  var toLanguage = translation[0]["translations"][0]["to"];
  var fromLanguage = translation[0]["detectedLanguage"]["language"];

  //send to API
  var responset = await http.post(
      Uri.encodeFull("https://apiproductortraduccion.azurewebsites.net/api/traductor"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(<String, String>{
        "NameDevice":"Prueba Examen",
        "Date": DateFormat('yyyy-MM-ddTkk:ss').format(DateTime.now()).toString(),
        "Translation":text,
        "FromLanguage" : fromLanguage,
        "ToLanguage" : toLanguage
      })
    );
    print(responset.body);
    return responset.body;

  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 30.0),
            alignment: Alignment.center,
            child: Text(
              "OCR APP",
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w700, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 15.0),
          Container(
            width: MediaQuery.of(context).size.width / 2,
            child: RaisedButton(
              onPressed: () => parsethetext(),
              child: Text(
                'Imagen',
                style: GoogleFonts.montserrat(
                    fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SizedBox(height: 70.0),
          Container(
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                Text(
                  "El texto, es:",
                  style: GoogleFonts.montserrat(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.0),
                Text(
                  text,
                  style: GoogleFonts.montserrat(
                      fontSize: 25, fontWeight: FontWeight.bold),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
