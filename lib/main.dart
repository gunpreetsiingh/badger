import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:badger/screens/account.dart';
import 'package:badger/screens/addTask.dart';
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
  await AndroidAlarmManager.initialize();
  initOneSignal();
  runApp(MyApp());
}

void initOneSignal() async {
  print('initializing one signal');
  OneSignal.shared.setAppId("7c82bf82-8c5f-497e-a26f-0977f1a15b28");
  // OneSignal.shared.setNotificationWillShowInForegroundHandler(
  //     (OSNotificationReceivedEvent event) {
  //   // Will be called whenever a notification is received in foreground
  //   // Display Notification, pass null param for not displaying the notification
  //   event.complete(event.notification);
  // });

  // OneSignal.shared
  //     .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
  //   // Will be called whenever a notification is opened/button pressed.
  // });

  // OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
  //   // Will be called whenever the permission changes
  //   // (ie. user taps Allow on the permission prompt in iOS)
  // });

  // OneSignal.shared
  //     .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
  //   // Will be called whenever the subscription changes
  //   // (ie. user gets registered with OneSignal and gets a user ID)
  // });

  // OneSignal.shared.setEmailSubscriptionObserver(
  //     (OSEmailSubscriptionStateChanges emailChanges) {
  //   // Will be called whenever then user's email subscription changes
  //   // (ie. OneSignal.setEmail(email) is called and the user gets registered
  // });
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
