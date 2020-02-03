import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:firebase_admob/firebase_admob.dart';

const request = "https://api.hgbrasil.com/finance?format=json&key=286830dd";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final bitcoinController = TextEditingController();
  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
    bitcoinController.text = "";
  }

  double dolar;
  double euro;
  double bitcoin;


  void _realChanged (String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
    bitcoinController.text = (real/bitcoin).toStringAsFixed(5);

  }
  void _dolarChanged (String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
    bitcoinController.text = (dolar*this.dolar / bitcoin).toStringAsFixed(5);

  }
  void _euroChanged (String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro*this.euro).toStringAsFixed(2);
    dolarController.text = (euro*this.euro/dolar).toStringAsFixed(2);
    bitcoinController.text = (euro*this.euro / bitcoin).toStringAsFixed(5);

  }
  void _bitcoinChanged (String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double bitcoin = double.parse(text);
    realController.text = (bitcoin*this.bitcoin).toStringAsFixed(2);
    dolarController.text = (bitcoin*this.bitcoin / dolar).toStringAsFixed(2);
    euroController.text = (bitcoin*this.bitcoin / euro).toStringAsFixed(2);

  }

  @override
  Widget build(BuildContext context) {


    FirebaseAdMob.instance.initialize(appId:"ca-app-pub-1396334732722035~4635669181");
//    myBanner
//    // typically this happens well before the ad is shown
//      ..load()
//      ..show(
//
//        // Positions the banner ad 60 pixels from the bottom of the screen
//        anchorOffset: 60.0,
//        // Positions the banner ad 10 pixels from the center of the screen to the right
//        horizontalCenterOffset: 10.0,
//        // Banner Position
//        anchorType: AnchorType.bottom,
//
//      );
    myInterstitial
      ..load()
      ..show(
        anchorType: AnchorType.bottom,
        anchorOffset: 0.0,
        horizontalCenterOffset: 0.0,
      );


    return Scaffold(
        backgroundColor: Colors.black12,
        appBar: AppBar(
          title: Text("ConvCoins"),
          backgroundColor: Colors.amber,
          centerTitle: true,

        ),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: Text(
                      "Carregando dados...",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                default:
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Erro ao carregar dados...",
                        style: TextStyle(color: Colors.amber, fontSize: 25.0),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    dolar =snapshot.data["results"]["currencies"]["USD"]["buy"];
                    euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                    bitcoin = snapshot.data["results"]["currencies"]["BTC"]["buy"];

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(Icons.autorenew,
                              size: 150.0, color: Colors.yellowAccent),

                          buildTextFild("Dolar", "US\$", dolarController, _dolarChanged),
                          Divider(),
                          buildTextFild("Real", "R\$", realController, _realChanged),
                          Divider(),
                          buildTextFild("Euro", "€", euroController, _euroChanged),
                          Divider(),
                          buildTextFild("Bitcoin", "₿", bitcoinController, _bitcoinChanged),

                        ],
                      ),
                    );
                  }
              }
            }));
  }
}

Widget buildTextFild(String label,String prefix, TextEditingController c, Function f){
    return TextField(
      controller: c,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.amber),
          border: OutlineInputBorder(),
          prefixText: prefix),
      style:
      TextStyle(color: Colors.amber, fontSize: 25.0),
      onChanged: f,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
    );
}
MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  keywords: <String>['finance', 'economy'],
  contentUrl: 'https://flutter.io',
  childDirected: false, // or MobileAdGender.female, MobileAdGender.unknown
  testDevices: <String>[], // Android emulators are considered test devices
);

BannerAd myBanner = BannerAd(
  // Replace the testAdUnitId with an ad unit id from the AdMob dash.
  // https://developers.google.com/admob/android/test-ads
  // https://developers.google.com/admob/ios/test-ads
  adUnitId:"ca-app-pub-1396334732722035/8031988717",
  size: AdSize.smartBanner,
  targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    print("BannerAd event is $event");
  },
);

InterstitialAd myInterstitial = InterstitialAd(
  // Replace the testAdUnitId with an ad unit id from the AdMob dash.
  // https://developers.google.com/admob/android/test-ads
  // https://developers.google.com/admob/ios/test-ads
  adUnitId:"ca-app-pub-1396334732722035/6588358184",
  targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    print("InterstitialAd event is $event");
  },
);
