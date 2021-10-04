import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkingHours extends StatefulWidget {
  const WorkingHours({Key? key}) : super(key: key);

  @override
  _WorkingHoursState createState() => _WorkingHoursState();
}

class _WorkingHoursState extends State<WorkingHours> {
  var size;
  bool isLoading = true;
  late var data;
  String fromTime = '', toTime = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    load();
  }

  Future<Null> _selectTime(BuildContext context, bool from) async {
    var picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.parse(
          '${DateFormat('yyyy-MM-dd').format(DateTime.now())} ${from ? fromTime : toTime}')),
    );
    if (picked != null) {
      setState(() {
        if (from) {
          fromTime =
              '${picked.hour < 10 ? '0${picked.hour}' : picked.hour}:${picked.minute.toString() == '0' ? '00' : (picked.minute < 10 ? '0${picked.minute}' : '${picked.minute}')}';
        } else {
          toTime =
              '${picked.hour < 10 ? '0${picked.hour}' : picked.hour}:${picked.minute.toString() == '0' ? '00' : (picked.minute < 10 ? '0${picked.minute}' : '${picked.minute}')}';
        }
      });
    }
  }

  void load() async {
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
    setState(() {
      isLoading = false;
    });
  }

  void save() {
    data['from'] = fromTime;
    data['to'] = toTime;
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set(data);
    Navigator.of(context).pop();
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                            'Working Hours',
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
                                                'Save',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            onPressed: () {
                                              save();
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Visibility(
                                      visible: !isLoading,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              _selectTime(context, true);
                                            },
                                            child: new Container(
                                              padding: EdgeInsets.all(15),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[900],
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      'From: $fromTime',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Icon(
                                                    Icons
                                                        .arrow_forward_ios_rounded,
                                                    color: Colors.white,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              _selectTime(context, false);
                                            },
                                            child: new Container(
                                              padding: EdgeInsets.all(15),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[900],
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      'To: $toTime',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Icon(
                                                    Icons
                                                        .arrow_forward_ios_rounded,
                                                    color: Colors.white,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: isLoading,
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                      ),
                                    ),
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
