import 'dart:convert';
import 'dart:io';

import 'package:badger/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class AddTask extends StatefulWidget {
  bool update;
  String docID, name, description;
  bool working;
  int importance;
  bool complete;
  AddTask(this.update, this.docID, this.name, this.description, this.working,
      this.importance, this.complete);

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  var size;
  var txtName = TextEditingController();
  var txtDescription = TextEditingController();
  var txtDate = TextEditingController();
  var txtHour = TextEditingController();

  bool one = true, two = false, three = false;
  bool isLoading = true;
  late var data;
  String fromTime = '', toTime = '';
  bool time1 = true, time2 = false;

  String dateTimeWorking = '', dateTimePersonal = '';
  late DateTime finalWorking, finalPersonal;

  String tokenId = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    load();
    prefill();
    // triggerNotification();
  }

  Future<Response> triggerNotification() async {
    print('triggering notification for ${time1 ? fromTime : toTime}');
    String priorityValue = one ? 'Low' : (two ? 'Medium' : 'High');
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
        "headings": {"en": 'Task: ${txtName.text}'},
        "contents": {"en": 'Priority: $priorityValue! Complete your task.'},
        "android_sound": "alert",
        "delayed_option": "timezone",
        "delivery_time_of_day": "${time1 ? fromTime : toTime}",
      }),
    );
  }

  void load() async {
    print(DateTime.now());
    if (Platform.isAndroid) {
      var status = await OneSignal.shared.getDeviceState();
      tokenId = status!.userId!.toString();
      print('token: $tokenId');
    }
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    data = doc.data();
    setState(() {
      try {
        fromTime = data['from'];
        toTime = data['to'];
        if (fromTime.toString() == 'null') {
          fromTime = '09:00';
        }
        if (toTime.toString() == 'null') {
          toTime = '17:00';
        }
      } catch (e) {
        fromTime = '09:00';
        toTime = '17:00';
      }
    });
    print('$fromTime - $toTime');
    dateTimeWorking =
        DateFormat('yyyy-MM-dd').format(DateTime.now()) + ' ' + fromTime;
    dateTimePersonal =
        DateFormat('yyyy-MM-dd').format(DateTime.now()) + ' ' + toTime;
    finalWorking = DateTime.parse(dateTimeWorking);
    finalPersonal = DateTime.parse(dateTimePersonal).add(Duration(seconds: 1));
    setState(() {
      isLoading = false;
    });
  }

  void prefill() {
    if (widget.update) {
      setState(() {
        txtName.text = widget.name;
        txtDescription.text = widget.description;
        if (widget.working) {
          time1 = true;
          time2 = false;
        } else {
          time1 = false;
          time2 = true;
        }
      });
      switch (widget.importance) {
        case 1:
          one = true;
          two = false;
          three = false;
          break;
        case 2:
          one = false;
          two = true;
          three = false;
          break;
        case 3:
          one = false;
          two = false;
          three = true;
          break;
      }
    }
  }

  void createTask() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('tasks')
        .doc(widget.update ? widget.docID : null)
        .set({
      'name': txtName.text,
      'description': txtDescription.text,
      'working': time1 ? true : false,
      'importance': one ? 1 : (two ? 2 : 3),
      'timestamp': DateTime.now().toString(),
      'completed': false,
    });
    var response = await triggerNotification();
    print('response: ${response.body}');
    Constants.showSnackBar(
        'All set! You\'ll receive a notification for this task on time.',
        false,
        context);
    Navigator.of(context).pop(true);
  }

  void deleteTask() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('tasks')
        .doc(widget.docID)
        .delete();
    Navigator.of(context).pop(true);
  }

  void alterCompletion(bool status) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('tasks')
        .doc(widget.update ? widget.docID : null)
        .set({
      'name': txtName.text,
      'description': txtDescription.text,
      'working': time1 ? true : false,
      'importance': one ? 1 : (two ? 2 : 3),
      'timestamp': DateTime.now().toString(),
      'completed': status,
    });
    Navigator.of(context).pop(true);
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
                            child: Container(
                              height: size.height * 0.8,
                              width: double.infinity,
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
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          icon: Icon(
                                            Icons.arrow_back_rounded,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Text(
                                            widget.update
                                                ? widget.name
                                                : 'New Task',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            color: Colors.orange,
                                            shape: BoxShape.rectangle,
                                          ),
                                          child: TextButton(
                                            child: Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text(
                                                widget.update
                                                    ? 'Update'
                                                    : 'Save',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            onPressed: () {
                                              createTask();
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.blue,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: TextField(
                                          controller: txtName,
                                          decoration: const InputDecoration(
                                            labelText: 'Name',
                                            contentPadding:
                                                EdgeInsets.only(left: 20),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.blue,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: TextField(
                                          controller: txtDescription,
                                          decoration: const InputDecoration(
                                            labelText: 'Description',
                                            contentPadding:
                                                EdgeInsets.only(left: 20),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    CheckboxListTile(
                                      value: time1,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      title: Text(
                                        'Working Hours',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '$fromTime - $toTime',
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.5),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          if (val!) {
                                            time1 = true;
                                            time2 = false;
                                          }
                                        });
                                      },
                                    ),
                                    CheckboxListTile(
                                      value: time2,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      title: Text(
                                        'Personal Hours',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          if (val!) {
                                            time1 = false;
                                            time2 = true;
                                          }
                                        });
                                      },
                                    ),
                                    Text(
                                      'Importance Of Task:',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              one = true;
                                              two = false;
                                              three = false;
                                            });
                                          },
                                          child: Container(
                                            height: 40,
                                            width: 40,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: one
                                                  ? Colors.blue[900]
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              border: Border.all(
                                                color: Colors.blue[900]!,
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              '1',
                                              style: TextStyle(
                                                color: one
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              one = false;
                                              two = true;
                                              three = false;
                                            });
                                          },
                                          child: Container(
                                            height: 40,
                                            width: 40,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: two
                                                  ? Colors.blue[900]
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              border: Border.all(
                                                color: Colors.blue[900]!,
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              '2',
                                              style: TextStyle(
                                                color: two
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              one = false;
                                              two = false;
                                              three = true;
                                            });
                                          },
                                          child: Container(
                                            height: 40,
                                            width: 40,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: three
                                                  ? Colors.blue[900]
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              border: Border.all(
                                                color: Colors.blue[900]!,
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              '3',
                                              style: TextStyle(
                                                color: three
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Visibility(
                                            visible: widget.update,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                color: Colors.blue[900],
                                                shape: BoxShape.rectangle,
                                              ),
                                              child: TextButton(
                                                child: Padding(
                                                  padding: EdgeInsets.all(5),
                                                  child: Text(
                                                    widget.complete
                                                        ? 'Mark Uncomplete'
                                                        : 'Mark Complete',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  alterCompletion(
                                                      widget.complete
                                                          ? false
                                                          : true);
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Visibility(
                                            visible: widget.update,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                color: Colors.red,
                                                shape: BoxShape.rectangle,
                                              ),
                                              child: TextButton(
                                                child: Padding(
                                                  padding: EdgeInsets.all(5),
                                                  child: Text(
                                                    'Delete Task',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  deleteTask();
                                                },
                                              ),
                                            ),
                                          ),
                                        ])
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
