//import 'dart:convert';

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

class Detail extends StatefulWidget {
  String names;
  List<dynamic> cases;
  List<dynamic> banks;
  List<dynamic> usernames;
  List<dynamic> phones;

  @override
  _DetailState createState() => _DetailState();

  Detail({this.banks, this.cases, this.names, this.phones, this.usernames});

}

class _DetailState extends State<Detail> {
  Future<Null> _launched;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: new Container(
        child: ListView(
          children: [
            new Column(
              children: <Widget>[
                Card(child: Text("Name ${widget.names}")),
                _ExpansionTile("Bank List: ", widget.banks, "Bank" , "BankName"),
                _ExpansionTile("Phone Number: ", widget.phones, "Phone" , null),
                _ExpansionTile("Username: ", widget.usernames, "Username" , null),
                _ExpansionTile2("Cases: ", widget.cases, "url"),

              ],
            ),
          ]
        ),
      ),
    );
  }




  Widget _ListView2(List data, String type) {
    String toLaunch;
    return ListView.builder(
        shrinkWrap: true,
        padding: new EdgeInsets.all(8.0),
        itemExtent: 20.0,
        itemCount: data?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                      text: "Case ${index + 1}",
                      style: new TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          setState(() {
                            toLaunch = data[index][type];
                            _launched = _launchInBrowser(toLaunch);
                          });
                        }),
                ),
                Expanded(
                  flex: 1,
                  child: new FutureBuilder<Null>(
                      future: _launched, builder: _launchStatus),
                ),
              ],
            ),
          );
        });
  }

  Future<Null> _launchInWebViewOrVC(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: true, forceWebView: true);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<Null> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _launchStatus(BuildContext context, AsyncSnapshot<Null> snapshot) {
    if (snapshot.hasError) {
      return new Text('Error: ${snapshot.error}');
    } else {
      return const Text('');
    }
  }


  Widget _ListView3(List data, String type) {
    return ListView.builder(
        shrinkWrap: true,
        padding: new EdgeInsets.all(8.0),
        itemExtent: 20.0,
        itemCount: data?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          return Text(
            "${data[index][type]}",
            softWrap: false,
          );
        });
  }

  Widget _ListView4(List data, String type ,String other) {
    return ListView.builder(
        shrinkWrap: true,
        padding: new EdgeInsets.all(8.0),
        itemExtent: 20.0,
        itemCount: data?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          return Text(
            "${data[index][other]}" + ": " + "${data[index][type]}",
            softWrap: false,
          );
        });
  }

  Widget _ExpansionTile(String title,List data,String type,String other){
    if(other?.isNotEmpty == true){
      return Card(
        child: ExpansionTile(
          title: Text(title),
          initiallyExpanded: true,
          children: <Widget>[
            _ListView4(data, type , other)
          ],
        ),
      );
    }else{
      return Card(
        child: ExpansionTile(
          title: Text(title),
          initiallyExpanded: true,
          children: <Widget>[
            _ListView3(data, type)
          ],
        ),
      );
    }
  }
  Widget _ExpansionTile2(String title,List data,String type){
    return Card(
      child: ExpansionTile(
        title: Text(title),
        initiallyExpanded: true,
        children: <Widget>[
          _ListView2(data, type)
        ],
      ),
    );
  }
}


