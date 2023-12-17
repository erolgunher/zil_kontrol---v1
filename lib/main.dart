import 'dart:async';
import 'dart:io';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenStatus();
  }
}

class _HomeScreenStatus extends State {
  String Durum = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Okul Zilini Kontrol Et"),
          backgroundColor: Colors.yellowAccent,
          centerTitle: true,
          foregroundColor: Colors.black38,
        ),
        body: Center(child: buildBody()),backgroundColor: Colors.black38,);
  }

  Widget buildBody() {
    get_Data();
    const oneSec = Duration(seconds: 1);
    late var timerim = new Timer.periodic(oneSec, (Timer t) {
      get_Data();
    });
    final ButtonStyle style = ElevatedButton.styleFrom(minimumSize:Size(200, 50) ,
      textStyle: const TextStyle(fontSize: 20),

    );
    final yaziSitili = TextStyle(

        fontSize: 20,
        color: Colors.amber,
        backgroundColor: Colors.black38,
        fontWeight: FontWeight.w900);
    return Column(
      children: <Widget>[
        const SizedBox(height: 30),
        ElevatedButton(
          style: style,
          onPressed: () => sendData("kapali"),
          child: const Text('Durdur'),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          style: style,
          onPressed: () => sendData("acik"),
          child: const Text('Çalıştır'),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          style: style,
          onPressed: () => sendData("marsac"),
          child: const Text('Marşı çal'),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          style: style,
          onPressed: () => sendData("marskapat"),
          child: const Text('Marşı kapat'),
        ),
        Text(Durum, style: yaziSitili,textAlign:TextAlign.center ),
      ],
    );
  }

  post_Data(String data) async {
    try {
      final uri = Uri.parse(
          'https://api.thingspeak.com/update?api_key=WBTUVXCQUHL7SZSO');
      final headers = {'Content-Type': 'application/json'};
      Map<String, dynamic> body = {'field1': data};
      String jsonBody = json.encode(body);
      final encoding = Encoding.getByName('utf-8');

      Response response = await post(
        uri,
        headers: headers,
        body: jsonBody,
        encoding: encoding,
      );

      int statusCode = response.statusCode;
      String responseBody = response.body;
      if (response.body.toString() != "0") {
        setState(() {
          this.Durum = data;
        });
      }
    } on Exception catch (_) {
      this.Durum = "İnternet bağlantınızı kontrol edin!";
    }
  }

  get_Data()  {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() async {
        try {
          final uri = Uri.parse(
              'https://dweet.io/get/latest/dweet/for/nazimzil');
          final response = await http.get(uri);
          var d = response.body.toString().split('"');
          setState(() {
            if (d[3]=="succeeded") {
              DateTime now = DateTime.now();
              String formattedDate =DateFormat.Hms().format(now);
              this.Durum = d[27] + "\n" + formattedDate;
            }
          });
        } on Exception catch (_) {
          this.Durum = "İnternet bağlantınızı kontrol edin!";
        }
      });
    });

  }

  sendData(String data) async {
    try {
      final uri = Uri.parse(
          'https://dweet.io/dweet/for/nazimzil?durum='+data+'&guncelleme=yok');
      final response = await http.get(uri);
      var d = response.body.toString().split('"');
      setState(() {
       if (d[3]=="succeeded") {
         DateTime now = DateTime.now();
         String formattedDate = DateFormat.Hms().format(now);
         this.Durum = d[27] + "\n" + formattedDate;
       }
       else sendData(data);
      });
    } on Exception catch (_) {
      this.Durum = "İnternet bağlantınızı kontrol edin!";
    }
  }

}
