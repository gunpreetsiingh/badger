import 'package:badger/screens/addTask.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadTasks();
  }

  void loadTasks() async {
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      isLoading = true;
      h1 = size.height * 0.80;
      h2 = size.height * 0.78;
      h3 = size.height * 0.76;
      w = size.width;
    });
    listTasks.clear();
    data = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('tasks')
        .where('completed', isEqualTo: false)
        .get();
    if (data.docs.isEmpty) {
      setState(() {
        isEmpty = true;
      });
    } else {
      setState(() {
        isEmpty = false;
        data.docs.forEach((element) {
          listTasks.add(GestureDetector(
            onTap: () async {
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
      });
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
                                  var result = await Navigator.of(context)
                                      .pushNamed('/account');
                                  if (result != null) {
                                    loadTasks();
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
                                  var result = await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => AddTask(
                                          false, '', '', '', true, 1, false),
                                    ),
                                  );
                                  if (result != null) {
                                    loadTasks();
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
            ],
          ),
        ),
      ),
    );
  }
}
