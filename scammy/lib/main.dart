import 'dart:async';
import 'dart:convert';

//import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttie/fluttie.dart';
import 'package:scammy/Detail.dart';

import 'Holder.dart';
import 'Scammer.dart';

Future<void> main() async {
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'scammy-79cb3',
    options: Platform.isIOS
        ? const FirebaseOptions(
            googleAppID: '1:645409949429:android:351117f0c68435d2',
            gcmSenderID: '297855924061',
            databaseURL: 'https://scammy-79cb3.firebaseio.com',
          )
        : const FirebaseOptions(
            googleAppID: '1:645409949429:android:351117f0c68435d2',
            apiKey: 'AIzaSyASmEBVzCgUA-OZplLkcfDvi9wBFy7T4Y0 ',
            databaseURL: 'https://scammy-79cb3.firebaseio.com',
          ),
  );
  runApp(new MaterialApp(
    title: 'Scammy',
    color: Colors.redAccent,
    home: new Home(app: app),
  ));
}

class Home extends StatefulWidget {
  final FirebaseApp app;

  Home({this.app});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  List<DataSearched> lsearchs = List();
  List<String> menuItems = ["Name", "PhoneNo", "Bank", "Username"];
  List<DropdownMenuItem> _unitMenuItems;
  DataSearched lsearch;

  DatabaseReference itemRef;
  DatabaseReference itemRef2;
  Query dataRef;
  Query dataRef2;
  PageController _controller;
  int _page = 0;
  Map<dynamic, dynamic> data2;

  /** FLUTTIE **/
  FluttieAnimationController fluttie;
  bool ready = false;

  String _dAnimation;
  String _dguide;
  bool _progressBarActive = false;

  /** FLUTTIE **/

  String _gInput;
  String _fromValue;
  String _example;
  TextInputType _textInputType;

  @override
  void initState() {
    super.initState();
    lsearch = DataSearched();
    _createDropdownMenuItems();
    _setDefaults();
//    itemRef = FirebaseDatabase.instance.reference().child("Scammer");

//    database.reference().child("main").once().then((DataSnapshot snapshot){
////    print('Connected to second database and read ${snapshot.value}');
//    scammers.add(new Scammer(snapshot.value["bank"], snapshot.value["Case"], snapshot.value["name"], snapshot.value["phone"], snapshot.value["username"]));
//    print( "Nama ${snapshot.value['name']}");
//    });
//    database.setPersistenceEnabled(true);
//    database.setPersistenceCacheSizeBytes(10000000);
//    itemRef.onChildAdded.listen(_onEntryAdded);
//    itemRef.onChildChanged.listen(_onEntryChanged);
//    itemRef.keepSynced(true);
    prepareAnimation();
    _controller = new PageController();
  }

  prepareAnimation() async {
    // Checks if the platform we're running on is supported by the animation plugin
    bool canBeUsed = await Fluttie.isAvailable();
    if (!canBeUsed) {
      print("Animations are not supported on this platform");
      return;
    }
    var instance = new Fluttie();

    // Load our first composition for the emoji animation
    var emojiComposition = await instance.loadAnimationFromAsset(_dAnimation);
    // And prepare its animation, which should loop infinitely and take 2s per
    // iteration. Instead of RepeatMode.START_OVER, we could have choosen
    // REVERSE, which would play the animation in reverse on every second iteration.
    fluttie = await instance.prepareAnimation(emojiComposition,
        duration: const Duration(seconds: 3),
        repeatCount: const RepeatCount.infinite(),
        repeatMode: RepeatMode.START_OVER);

    // Load the composition for our star animation. Notice how we only have to
    // load the composition once, even though we're using it for 5 animations!
//    var composition =
//        await instance.loadAnimationFromAsset("assets/animations/star.json");

    // Create the star animation with the default setting. 5 times. The
    // preferredSize needs to be set because the original star animation is quite
    // small. See the documentation for the method prepareAnimation for details.
//    for (int i = 0; i < 5; i++) {
//      starAnimations.add(
//          await instance.prepareAnimation(
//              composition, preferredSize: Fluttie.kDefaultSize
//          )
//      );
//    }
    // Loading animations may take quite some time. We should check that the
    // widget is still used before updating it, it might have been removed while
    // we were loading our animations!
    if (mounted) {
      setState(() {
        ready = true; // The animations have been loaded, we're ready
        fluttie.start(); //start our looped emoji animation
      });
    }
  }

  Future<void> whileData(String list, String input, String type) async {
    var i = 0;
    DataSnapshot data2;
    do {
      itemRef2 = await FirebaseDatabase.instance.reference().child("Scammer");
      dataRef2 = await itemRef2
          .orderByChild("$list/$i/$type")
          .startAt("$input")
          .endAt("$input\uf8ff");

      i++;
      await dataRef2.once().then((DataSnapshot data) {
        data2 = data;
      });
      dataRef2.onChildAdded.listen(_sDataList);
    } while (data2.value == null && i <= 9);
    if (data2.value == null) {
    setState(() {
      print("Data null");
      _dguide = "Sorry , can't find what you're searching for";
      _dAnimation = "assets/animation/empty_box.json";
      prepareAnimation();
      _progressBarActive = false;
    });
    }else{
      setState(() {
        _progressBarActive = false;
        print("Data not null");
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    fluttie?.dispose();
    _controller.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  void _setDefaults() {
    setState(() {
      _fromValue = menuItems[0];
      _example = "etc: YAP BOON FATT";
      _dguide = "Start searching using the field: ";
      _dAnimation = "assets/animation/search_ask_loop.json";
      _textInputType = TextInputType.text;
    });
  }

  void _onChanged(dynamic value) {
    setState(() {
      _fromValue = value;
      searchLT(value);
    });
  }

//  _onEntryChanged(Event event) {
//    var old = scammers.singleWhere((entry) {
//      return entry.key == event.snapshot.key;
//    });
//    setState(() {
//      scammers[scammers.indexOf(old)] = Scammer.fromSnapshot(event.snapshot);
//    });
//  }

//  void handleSubmit() {
//    final FormState form = formKey.currentState;
//
//    if (form.validate()) {
//      form.save();
//      form.reset();
//      itemRef.push().set(item.toJson());
//    }
//  }

  // TODO change logo and text for bottom navigation
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new PageView(
        controller: _controller,
        children: [
          new Container(
            margin: EdgeInsets.only(top: 20.0),
            color: Colors.transparent,
            child: new Column(
              children: <Widget>[
                Container(
                  height: 80.0,
                  child: Card(
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Column(
                            children: <Widget>[
                              Text(
                                "Search by:",
                                textAlign: TextAlign.start,
                              ),
                              _createDropdown(_fromValue, _onChanged),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                          ),
                        ),
                        _SearchWidget(),
                        RaisedButton(
                          color: Colors.red,
                          onPressed: getInput,
                          child: Icon(
                            Icons.search,
                            size: 20.0,
                            color: Colors.white,
                          ),
                        )
                      ],
                      crossAxisAlignment: CrossAxisAlignment.center,
                    ),
                  ),
                ),
                Expanded(child: listView()),
//                _raisedButton(),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
          Holder(),
//              new Container(color: Colors.grey),
        ],
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: new BottomNavigationBar(
        items: [
          new BottomNavigationBarItem(
              icon: new Icon(
                Icons.search,
                color: Colors.redAccent,
              ),
              title: new Text(
                "Search",
                style: TextStyle(color: Colors.redAccent),
              )),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.list, color: Colors.redAccent),
              title: new Text(
                "List",
                style: TextStyle(color: Colors.redAccent),
              ))
//              new BottomNavigationBarItem(
//                  icon: new Icon(Icons.people),
//                  title: new Text("community")
//              )
        ],
        currentIndex: _page,
        onTap: navigationTap,
      ),
      appBar: new AppBar(
        backgroundColor: Colors.red,
        title: new Center(
            child: new Image(
          image: AssetImage("assets/images/scammy_grey_white.png"),
          height: 50.0,
        )),
      ),
    );
  }

// TODO create appropiate
  Widget _SearchWidget() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: 30.0, right: 30.0),
        child: TextField(
          autofocus: false,
//          validator:(val) => val.isEmpty? " can't be empty." : null,
          onChanged: (val) => _gInput = val,
          keyboardType: _textInputType,
          decoration: InputDecoration(
              labelText: _example,
              helperStyle: TextStyle(
                fontSize: 5.0,
              )),
        ),
      ),
    );
  }

  void searchLT(String value) {
    switch (value) {
      case ("Name"):
        {
          setState(() {
            _example = "etc: YAP BOON FATT";
            _textInputType = TextInputType.text;
          });
        }
        break;
      case ("PhoneNo"):
        {
          setState(() {
            _example = "etc: 0193159986";
            _textInputType = TextInputType.phone;
          });
        }
        break;
      case ("Bank"):
        {
          setState(() {
            _example = "etc: Bank No";
            _textInputType = TextInputType.number;
          });
        }
        break;
      case ("Username"):
        {
          setState(() {
            _example = "etc: militarysmurf";
            _textInputType = TextInputType.text;
          });
        }
    }
  }

  /** testWidget **/

  void getInput() {
    print(_gInput);
    setState(() {
      if (_gInput == null || _gInput.isEmpty) {
        return lsearchs.clear();
      } else {
        lsearchs.clear();
        _progressBarActive = true;
        return _FirebaseQuery(_gInput, _fromValue);
      }
    });
  }

  _FirebaseQuery(String input, String value) {
    switch (value) {
      case ("Name"):
        {
          itemRef2 = FirebaseDatabase.instance.reference().child("Scammer");
          dataRef = itemRef2
              .orderByChild("Name")
              .startAt("$input")
              .endAt("$input"+"\uf8ff");
          dataRef.once().then((DataSnapshot data){
            setState(() {
              if(data.value != null){
                _progressBarActive = false;
              }else{
                _dguide = "Sorry , can't find what you're searching for";
                _dAnimation = "assets/animation/empty_box.json";
                prepareAnimation();
                _progressBarActive = false;
              }
            });
          });
          dataRef.onChildAdded.listen(_sDataList);

        }
        break;

      case ("PhoneNo"):
        {
          whileData("ListP", input, "Phone");
        }
        break;

      case ("Bank"):
        {
          whileData("ListB", input, "Bank");
        }
        break;

      case ("Username"):
        {
          whileData("ListU", input, "Username");
        }
        break;
    }
  }

  _sDataList(Event data) {
    setState(() {
      print("New data ${data.snapshot.value}");
      lsearchs.add(DataSearched.fromSnapshot(data.snapshot));
    });
  }


  Widget listView() {
    if (_progressBarActive == true) {
      return Center(child: Container(
          child: const CircularProgressIndicator(),
      ));

    } else {
      if (lsearchs.isEmpty) {
//        print("Null success $lsearchs");
        return Column(
          children: <Widget>[
            Container(
              width: 150.0,
              child: Padding(
                  padding:
                  const EdgeInsets.only(left: 5.0, right: 5.0, top: 30.0),
                  child: FluttieAnimation(fluttie)),
            ),
            Padding(
                padding: const EdgeInsets.only(
                    left: 5.0, right: 5.0, top: 30.0),
                child: Text(_dguide)),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        );
      } else {
        return Padding(
          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
          child: Card(
            margin: EdgeInsets.only(top: 15.0, bottom: 15.0),
            child: ListView.builder(
              shrinkWrap: true,
              padding: new EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
              itemBuilder: (BuildContext context, int index) {
                return listView2(index);
              },
              itemCount: lsearchs?.length ?? 0,
            ),
          ),
        );
      }
    }
  }

  Widget listView2(int index) {
    final _rowHeight = 30.0;
    final _borderRadius = BorderRadius.horizontal(
        left: Radius.circular(2.0), right: Radius.circular(2.0));

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        height: _rowHeight,
        child: InkWell(
          borderRadius: _borderRadius,
          highlightColor: Colors.grey,
          splashColor: Colors.white12,
          onTap: () => _navigateToDetail(context, index),
          child: Row(
            children: <Widget>[
              Expanded(child: Text("${lsearchs[index].names}"))
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, int index) {
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white,
//              opacity: 0.2,
            ),
            elevation: 1.0,
            title: Text(
              "Scammer info",
              style: TextStyle(inherit: true, color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.red,
          ),
          body: Detail(
            banks: lsearchs[index].banks,
            cases: lsearchs[index].cases,
            names: lsearchs[index].names,
            phones: lsearchs[index].phones,
            usernames: lsearchs[index].usernames,
          ),
          // This prevents the attempt to resize the screen when the keyboard
          // is opened
          resizeToAvoidBottomPadding: false,
        );
      },
    ));
  }

  Widget _createDropdown(String currentValue, ValueChanged<dynamic> onChanged) {
    return Container(
      width: 100.0,
      decoration: BoxDecoration(
        // This sets the color of the [DropdownButton] itself
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(
          color: Colors.grey[400],
          width: 0.5,
          style: BorderStyle.solid,
        ),
      ),
      child: Theme(
        // This sets the color of the [DropdownMenuItem]
        data: Theme.of(context).copyWith(
              canvasColor: Colors.white,
            ),
        child: DropdownButtonHideUnderline(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton(
              value: currentValue,
              items: _unitMenuItems,
              onChanged: onChanged,
              style:
                  TextStyle(fontSize: 12.0, color: Colors.black, inherit: true),
//              style: Theme.of(context).textTheme.title,
              isDense: true,
              elevation: 1,
            ),
          ),
        ),
      ),
    );
  }

  void _createDropdownMenuItems() {
    var newItems = <DropdownMenuItem>[];
    for (var unit in menuItems) {
      newItems.add(DropdownMenuItem(
        value: unit,
        child: Container(
          child: Text(
            unit,
            softWrap: true,
          ),
        ),
      ));
    }
    setState(() {
      _unitMenuItems = newItems;
    });
  }

  void navigationTap(int page) => _controller.animateToPage(page,
      duration: const Duration(milliseconds: 300), curve: Curves.ease);
}

class DataSearched {
  String names;
  List<dynamic> cases;
  List<dynamic> banks;
  List<dynamic> usernames;
  List<dynamic> phones;

  DataSearched(
      {this.names, this.cases, this.banks, this.usernames, this.phones});

  DataSearched.fromSnapshot(DataSnapshot snapshot)
      : banks = snapshot.value["ListB"],
        cases = snapshot.value["ListC"],
        names = snapshot.value["Name"],
        phones = snapshot.value["ListP"],
        usernames = snapshot.value["ListU"];
}
