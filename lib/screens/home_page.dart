import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class Tournament {
  final String name;
  final String coverUrl;
  final String gameName;

  Tournament({this.name, this.coverUrl, this.gameName});

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      name: json['name'],
      coverUrl: json['cover_url'],
      gameName: json['game_name'],
    );
  }
  static List<Tournament> parseList(List<dynamic> list) {
    return list.map((i) => Tournament.fromJson(i)).toList();
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hasMore;
  int _pageNumber;
  String _nextCursor;
  bool _error;
  bool _loading;
  final int _defaultPhotosPerPageCount = 10;
  List<Tournament> _tournaments;
  final int _nextPageThreshold = 5;
  List<Tournament> list = List();

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  @override
  void initState() {
    super.initState();
    _hasMore = true;
    _pageNumber = 1;
    _error = false;
    _loading = true;
    _tournaments = [];
    _nextCursor = '';
    _fetchTournaments();
  }

  Future<void> _fetchTournaments() async {
    try {
      var currentApiUrl =
          'http://tournaments-dot-game-tv-prod.uc.r.appspot.com/tournament/api/tournaments_list_v2?limit=10&status=all';
      if (_nextCursor.isNotEmpty) {
        currentApiUrl += '&cursor=$_nextCursor';
      }
      print('API URL = $currentApiUrl');
      final response = await http.get(currentApiUrl);
      print(response);
      print(response.statusCode);
      print(response.body);
      final jsonBody = json.decode(response.body);
      print('JSONBODY');
      print(jsonBody);
      print('JSONBODY.data');
      print(jsonBody['data']['tournaments']);
      List<Tournament> fetchedTournaments =
          Tournament.parseList(jsonBody['data']['tournaments']);
      setState(() {
        _hasMore = false;
        _loading = false;
        _pageNumber = _pageNumber + 1;
        _nextCursor = jsonBody['data']['cursor'];
        _tournaments.addAll(fetchedTournaments);
      });
      print('nextCursor = $_nextCursor');
    } catch (e) {
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  Widget getTournaments() {
    if (_tournaments.isEmpty) {
      if (_loading) {
        return Center(
            child: Padding(
          padding: const EdgeInsets.all(8),
          child: CircularProgressIndicator(),
        ));
      } else if (_error) {
        return Center(
            child: InkWell(
          onTap: () {
            setState(() {
              _loading = true;
              _error = false;
              _fetchTournaments();
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text("Error while loading tournaments, tap to try again"),
          ),
        ));
      }
    } else {
      return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _tournaments.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _tournaments.length - _nextPageThreshold) {
              _fetchTournaments();
            }
            if (index == _tournaments.length) {
              if (_error) {
                return Center(
                    child: InkWell(
                  onTap: () {
                    setState(() {
                      _loading = true;
                      _error = false;
                      _fetchTournaments();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                        "Error while loading tournaments, tap to try again"),
                  ),
                ));
              } else {
                return Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                ));
              }
            }
            final Tournament tournament = _tournaments[index];
            return Card(
              margin: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(25.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 100,
                    decoration: new BoxDecoration(
                      borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(25.0),
                        topRight: const Radius.circular(25.0),
                      ),
                      image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: new NetworkImage(
                          tournament.coverUrl,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                          child: SizedBox(
                            child: Text(
                              tournament.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                          child: SizedBox(
                            child: Text(
                              tournament.gameName,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
    }
    return Container();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          color: Colors.grey.shade700,
          icon: Icon(
            Icons.short_text,
          ),
          onPressed: () => _scaffoldKey.currentState.openDrawer(),
        ),
        title: Center(
          child: const Text(
            'Flyingwolf',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                'Options',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                ),
              ),
              decoration: BoxDecoration(
                  color: Colors.green,
                  image: DecorationImage(
                      fit: BoxFit.fill, image: AssetImage('images/logo.png'))),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () => {},
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
            children: <Widget>[
//              Container(
//                height: 50.0,
//                child: Center(
//                  child: Text(
//                    'Flyingwolf',
//                    style: TextStyle(
//                      fontSize: 18,
//                      fontWeight: FontWeight.bold,
//                    ),
//                  ),
//                ),
//              ),
              SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    height: 100.0,
                    width: 100.0,
                    margin: EdgeInsets.only(left: 20.0),
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                        fit: BoxFit.fill,
                        image:
                            new NetworkImage("https://i.imgur.com/BoN9kdC.png"),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 50.0,
                        child: Center(
                          child: Text(
                            'Simon Baker',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(50.0),
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              height: 50.0,
                              child: Center(
                                child: Text(
                                  '2250',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Container(
                              height: 50.0,
                              child: Center(
                                child: Text('Elo rating'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 30.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 100,
                    width: 110,
                    decoration: new BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [
                            Colors.orangeAccent.shade700,
                            Colors.orangeAccent.shade200,
                          ]),
                      borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(25.0),
                        bottomLeft: const Radius.circular(25.0),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            child: Text(
                              '34',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade50,
                              ),
                            ),
                          ),
                          Text(
                            'Tournaments played',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade50,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 1.0,
                  ),
                  Container(
                    height: 100,
                    width: 110,
                    decoration: new BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [
                            Colors.purple.shade700,
                            Colors.purple.shade200,
                          ]),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            '09',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade50,
                            ),
                          ),
                          Text(
                            'Tournaments won',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade50,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 1.0,
                  ),
                  Container(
                    height: 100,
                    width: 110,
                    decoration: new BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [
                            Colors.red.shade700,
                            Colors.redAccent.shade100,
                          ]),
                      borderRadius: new BorderRadius.only(
                        topRight: const Radius.circular(25.0),
                        bottomRight: const Radius.circular(25.0),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            '26%',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade50,
                            ),
                          ),
                          Text(
                            'Winning Percentage',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade50,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30.0,
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                        'Recommended for you',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              getTournaments(),
            ],
          ),
        ),
      ),
    );
  }
}
