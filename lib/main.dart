import 'package:badger/screens/account.dart';
import 'package:badger/screens/addTask.dart';
import 'package:badger/screens/authentication.dart';
import 'package:badger/screens/completedTasks.dart';
import 'package:badger/screens/dashboard.dart';
import 'package:badger/screens/splash.dart';
import 'package:badger/screens/subscribe.dart';
import 'package:badger/screens/workingHours.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Badger',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Splash(),
      routes: {
        '/authentication' : (context) => Authentication(),
        '/dashboard' : (context) => Dashboard(),
        '/account': (context) => Account(),
        '/subscribe': (context) => Subscribe(),
        '/working-hours': (context) => WorkingHours(),
        '/completed-tasks': (context) => CompletedTasks(),
      },
    );
  }
}
