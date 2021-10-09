import 'dart:convert';
import 'dart:io';

import 'package:badger/constants.dart';
import 'package:badger/screens/addTask.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var size;
  bool isLoading = true, isEmpty = false;
  late QuerySnapshot data;
  List<Widget> listTasks = [];

  double h1 = 0, h2 = 0, h3 = 0, w = 0;

  late ConnectivityResult connectivityResult;
  var subscription;
  bool noConnection = false;

  var tasksGroup;
  Map offlineTasks = {};

  String tokenId = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        connectivityResult = result;
        switch (result) {
          case ConnectivityResult.none:
            noConnection = true;
            break;
          case ConnectivityResult.wifi:
            noConnection = false;
            break;
          case ConnectivityResult.mobile:
            noConnection = false;
            break;
        }
      });
    });
    loadTasks();
  }

  Future<Response> triggerNotification() async {
    if (Platform.isAndroid) {
      var status = await OneSignal.shared.getDeviceState();
      tokenId = status!.userId!.toString();
      print('token: $tokenId');
    }
    print('triggered notification');
    return post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "app_id": '7c82bf82-8c5f-497e-a26f-0977f1a15b28',
        "include_player_ids": [tokenId],
        "android_accent_color": "006699",
        "small_icon": "logo_small",
        "large_icon":
            "https://raw.githubusercontent.com/gunpreetsiingh/badger/master/assets/logoSmall.png",
        "headings": {"en": 'Reminder! You have pending tasks to complete.'},
        "contents": {"en": 'If not, mark them complete.'},
        "delayed_option": "timezone",
        "delivery_time_of_day":
            "${DateTime.now().add(Duration(minutes: 10)).toString()}",
      }),
    );
  }

  void loadTasks() async {
    connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      noConnection = true;
    } else {
      noConnection = false;
    }
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      isLoading = true;
      h1 = size.height * 0.80;
      h2 = size.height * 0.78;
      h3 = size.height * 0.76;
      w = size.width;
    });
    listTasks.clear();
    if (connectivityResult == ConnectivityResult.none) {
      loadTasksOffline();
    } else {
      loadTasksOnline();
    }
  }

  void loadTasksOffline() {
    Map data = Constants.hiveDB.get('tasks');
    if (data.isEmpty) {
      setState(() {
        isEmpty = true;
      });
    } else {
      setState(() {
        isEmpty = false;
        data.forEach((key, value) {
          listTasks.add(GestureDetector(
            onTap: () async {
              Constants.showSnackBar(
                'You can only view your tasks summary in offline mode.',
                true,
                context,
              );
            },
            child: new Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.orange[800],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      value['name'],
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                  )
                ],
              ),
            ),
          ));
        });
      });
    }
    if(listTasks.isNotEmpty){
      triggerNotification();
    }else{
      print('empty list');
    }
    setState(() {
      isLoading = false;
    });
  }

  void loadTasksOnline() async {
    setState(() {
      isLoading = true;
      h1 = size.height * 0.80;
      h2 = size.height * 0.78;
      h3 = size.height * 0.76;
      w = size.width;
    });
    listTasks.clear();
    tasksGroup = [];
    data = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('tasks')
        .where('completed', isEqualTo: false)
        .get();
    tasksGroup = data.docs;
    if (tasksGroup.isEmpty) {
      setState(() {
        isEmpty = true;
      });
    } else {
      setState(() {
        isEmpty = false;
        tasksGroup.forEach((element) {
          if (!noConnection) {
            offlineTasks[element.id] = {
              'name': element['name'],
              'description': element['description'],
              'working': element['working'],
              'importance': element['importance'],
              'timestamp': element['timestamp'],
              'completed': element['completed'],
            };
          }
          listTasks.add(GestureDetector(
            onTap: () async {
              if (noConnection) {
                Constants.showSnackBar(
                  'You can only view your tasks summary in offline mode.',
                  true,
                  context,
                );
              } else {
                var result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddTask(
                      true,
                      element.id,
                      element['name'],
                      element['description'],
                      element['working'],
                      element['importance'],
                      element['completed'] ?? false,
                    ),
                  ),
                );
                if (result != null) {
                  loadTasks();
                }
              }
            },
            child: new Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.orange[800],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      element['name'],
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                  )
                ],
              ),
            ),
          ));
        });
        if (!noConnection) {
          Constants.hiveDB.put('tasks', offlineTasks);
        }
      });
    }
    if(listTasks.isNotEmpty){
      triggerNotification();
    }else{
      print('empty list');
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 80,
                width: size.width,
                color: Colors.white,
                alignment: Alignment.center,
                child: Image(
                  image: AssetImage('assets/logo.png'),
                  width: 250,
                ),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Image(
                      image: AssetImage('assets/dashboard-bg.png'),
                      height: size.height - 80,
                      width: size.width,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          top: 40, left: 40, right: 40, bottom: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                  height: h1,
                                  width: w,
                                  padding: EdgeInsets.all(15),
                                  margin: EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.35),
                                        blurRadius: 15,
                                        spreadRadius: 5,
                                        offset: Offset(0, 0),
                                      )
                                    ],
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 600),
                                  curve: Curves.easeOut,
                                  height: h2,
                                  width: w,
                                  padding: EdgeInsets.all(15),
                                  margin: EdgeInsets.only(
                                      top: 10, left: 8, right: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.35),
                                        blurRadius: 15,
                                        spreadRadius: 5,
                                        offset: Offset(0, 0),
                                      )
                                    ],
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 700),
                                  curve: Curves.easeOut,
                                  height: h3,
                                  width: w,
                                  padding: EdgeInsets.all(15),
                                  margin: EdgeInsets.only(top: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.35),
                                        blurRadius: 15,
                                        spreadRadius: 5,
                                        offset: Offset(0, 0),
                                      )
                                    ],
                                  ),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    physics: BouncingScrollPhysics(),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Visibility(
                                          visible: !isLoading && !isEmpty,
                                          child: Text(
                                            'Fill Your Task',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Visibility(
                                          visible: !isLoading && !isEmpty,
                                          child: Column(
                                            children: listTasks,
                                          ),
                                        ),
                                        Visibility(
                                          visible: !isLoading && isEmpty,
                                          child: Text(
                                            'You have not created any tasks yet.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: isLoading && !isEmpty,
                                          child: Lottie.asset(
                                            'assets/animation-loading.json',
                                            width: 250,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  if (noConnection) {
                                    Constants.showSnackBar(
                                      'You can only view your tasks summary in offline mode.',
                                      true,
                                      context,
                                    );
                                  } else {
                                    var result = await Navigator.of(context)
                                        .pushNamed('/account');
                                    if (result != null) {
                                      loadTasks();
                                    }
                                  }
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.account_circle_rounded,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'Account',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    )
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (noConnection) {
                                    Constants.showSnackBar(
                                      'You can only view your tasks summary in offline mode.',
                                      true,
                                      context,
                                    );
                                  } else {
                                    var result =
                                        await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AddTask(
                                            false, '', '', '', true, 1, false),
                                      ),
                                    );
                                    if (result != null) {
                                      loadTasks();
                                    }
                                  }
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.description_outlined,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      'Add',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: noConnection,
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_off_outlined,
                        color: Colors.blue[900],
                        size: 20,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Offline mode is activated',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
