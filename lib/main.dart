import 'package:badger/constants.dart';
import 'package:badger/screens/account.dart';
import 'package:badger/screens/allApps.dart';
import 'package:badger/screens/authentication.dart';
import 'package:badger/screens/completedTasks.dart';
import 'package:badger/screens/dashboard.dart';
import 'package:badger/screens/splash.dart';
import 'package:badger/screens/subscribe.dart';
import 'package:badger/screens/workingHours.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  if (!Hive.isBoxOpen('myBox')) {
    await Hive.openBox('myBox');
  }
  if (!Constants.hiveDB.containsKey('permissions')) {
    Constants.hiveDB.put('permissions', false);
  }
  initOneSignal();
  runApp(MyApp());
}

void initOneSignal() async {
  print('initializing one signal');
  OneSignal.shared.setAppId("7c82bf82-8c5f-497e-a26f-0977f1a15b28");
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
        '/authentication': (context) => Authentication(),
        '/dashboard': (context) => Dashboard(),
        '/account': (context) => Account(),
        '/subscribe': (context) => Subscribe(),
        '/working-hours': (context) => WorkingHours(),
        '/completed-tasks': (context) => CompletedTasks(),
        '/all-apps': (context) => AllApps(),
      },
    );
  }
}
