import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

// https://api.hgbrasil.com/finance
const request = "https://api.hgbrasil.com/finance";

void main() async {
  runApp(MaterialApp(
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
    home: Home(),
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
  double dolar;
  double euro;

  final realControler = TextEditingController();

  final dolarControler = TextEditingController();

  final euroControler = TextEditingController();

  void _realChanger(String texto) {
    if (texto.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(texto);
    dolarControler.text = (real / dolar).toStringAsFixed(2);

    euroControler.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanger(String texto) {
    if (texto.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(texto);
    realControler.text = (dolar * this.dolar).toStringAsFixed(2);

    euroControler.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanger(String texto) {
    if (texto.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(texto);
    realControler.text = (euro * this.euro).toStringAsFixed(2);

    dolarControler.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void _clearAll() {
    realControler.text = "";
    dolarControler.text = "";
    euroControler.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor de Moedas"),
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
                    "Carregando Dados...",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao Carregar Dados  :( ",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(
                          Icons.monetization_on,
                          size: 150,
                          color: Colors.amber,
                        ),
                        Divider(),
                        buildTextfield(
                            "Reais", "R", realControler, _realChanger),
                        Divider(),
                        buildTextfield(
                            "Dólares", "US", dolarControler, _dolarChanger),
                        Divider(),
                        buildTextfield(
                            "Euros", "€", euroControler, _euroChanger),
                        Divider(),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextfield(String moeda, String prefix,
    TextEditingController controle, Function funcao) {
  return TextField(
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    onChanged: funcao,
    controller: controle,
    decoration: InputDecoration(
      labelText: (moeda),
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: "$prefix\$",
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25),
  );
}
