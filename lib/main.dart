import 'dart:convert';
import 'dart:io';

import 'package:badger/constants.dart';
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
import 'package:http/http.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:system_alert_window/system_alert_window.dart' as saw;
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  manageOverlay();
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

void manageOverlay() {
  saw.SystemAlertWindow.registerOnClickListener(callBackFunction);
  Workmanager().initialize(callBackDispatcher);
  Workmanager().registerPeriodicTask(
    '1',
    'unique_task_name',
    frequency: Duration(minutes: 15),
    initialDelay: Duration(minutes: 30),
  );
}

void callBackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    print('================ bg task');
    showOverlay();
    print('================ bg task completed');
    return Future.value(true);
  });
}

Future<void> showOverlay() async {
  await saw.SystemAlertWindow.requestPermissions;
  saw.SystemWindowHeader header = saw.SystemWindowHeader(
    title: saw.SystemWindowText(
      text: "Badger Alert!",
      fontSize: 20,
      textColor: Colors.white,
      fontWeight: saw.FontWeight.BOLD,
    ),
    padding: saw.SystemWindowPadding.setSymmetricPadding(15, 15),
    decoration: saw.SystemWindowDecoration(
      startColor: Colors.blue[900],
      endColor: Colors.blue[900],
    ),
    buttonPosition: saw.ButtonPosition.TRAILING,
    button: saw.SystemWindowButton(
      text: saw.SystemWindowText(
          text: "Close", fontSize: 12, textColor: Colors.blue[900]),
      tag: "focus_button",
      width: 0,
      padding:
          saw.SystemWindowPadding(left: 10, right: 10, bottom: 10, top: 10),
      height: saw.SystemWindowButton.WRAP_CONTENT,
      decoration: saw.SystemWindowDecoration(
        startColor: Colors.white,
        endColor: Colors.white,
        borderWidth: 0,
        borderRadius: 30.0,
      ),
    ),
  );

  saw.SystemWindowFooter footer = saw.SystemWindowFooter(
      buttons: [
        saw.SystemWindowButton(
          text: saw.SystemWindowText(
            text: "Close",
            fontSize: 16,
            textColor: Colors.white,
            fontWeight: saw.FontWeight.BOLD,
          ),
          tag: "focus_button",
          width: 0,
          padding:
              saw.SystemWindowPadding(left: 10, right: 10, bottom: 10, top: 10),
          height: saw.SystemWindowButton.WRAP_CONTENT,
          decoration: saw.SystemWindowDecoration(
            startColor: Colors.blue[900],
            endColor: Colors.blue[900],
            borderWidth: 0,
            borderRadius: 30.0,
          ),
        ),
      ],
      padding: saw.SystemWindowPadding(left: 16, right: 16, bottom: 12),
      decoration: saw.SystemWindowDecoration(startColor: Colors.white),
      buttonsPosition: saw.ButtonPosition.CENTER);

  saw.SystemWindowBody body = saw.SystemWindowBody(
    rows: [
      saw.EachRow(
        columns: [
          saw.EachColumn(
            text: saw.SystemWindowText(
              text:
                  "Don\'t waste your precious time. You have pending tasks to complete.",
              fontSize: 16,
              textColor: Colors.black,
              fontWeight: saw.FontWeight.BOLD,
            ),
          ),
        ],
        gravity: saw.ContentGravity.CENTER,
      ),
    ],
    padding: saw.SystemWindowPadding(left: 16, right: 16, bottom: 12, top: 12),
  );

  saw.SystemAlertWindow.showSystemWindow(
      height: 230,
      header: header,
      body: body,
      footer: footer,
      margin: saw.SystemWindowMargin(left: 15, right: 15, top: 15, bottom: 15),
      gravity: saw.SystemWindowGravity.TOP,
      notificationTitle: "Badger Alert",
      notificationBody: "You have pending tasks to complete.",
      prefMode: saw.SystemWindowPrefMode.OVERLAY);
  //Using SystemWindowPrefMode.DEFAULT uses Overlay window till Android 10 and bubble in Android 11
  //Using SystemWindowPrefMode.OVERLAY forces overlay window instead of bubble in Android 11.
  //Using SystemWindowPrefMode.BUBBLE forces Bubble instead of overlay window in Android 10 & above
}

///
/// As this callback function is called from background, it should be declared on the parent level
/// Whenever a button is clicked, this method will be invoked with a tag (As tag is unique for every button, it helps in identifying the button).
/// You can check for the tag value and perform the relevant action for the button click
///
void callBackFunction(String tag) {
  switch (tag) {
    case "simple_button":
      print("Simple button has been clicked");
      break;
    case "focus_button":
      print("Focus button has been clicked");
      saw.SystemAlertWindow.closeSystemWindow();
      break;
    case "personal_btn":
      print("Personal button has been clicked");
      break;
    default:
      print("OnClick event of $tag");
  }
}

void initOneSignal() async {
  print('initializing one signal');
  OneSignal.shared.setAppId("7c82bf82-8c5f-497e-a26f-0977f1a15b28");
}

Future<Response> triggerNotification() async {
  String tokenId = '';
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
      "headings": {"en": 'Background task title.'},
      "contents": {"en": 'Task message.'},
      "android_sound": "alert",
      "priority": 10,
    }),
  );
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
