import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:hive/hive.dart';
import 'package:system_alert_window/system_alert_window.dart' as saw;

import 'main.dart';

class Constants {
  static var hiveDB = Hive.box('myBox');

  static void showSnackBar(String text, bool error, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            error ? Icons.error_rounded : Icons.check_circle_rounded,
            color: Colors.white,
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.fade,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: error ? Colors.red : Colors.blue[900],
    ));
  }

  static void showOverlay() async {
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
            text: "Close",
            fontSize: 16,
            textColor: Colors.blue[900],
            fontWeight: saw.FontWeight.BOLD),
        tag: "close_button",
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
      decoration: saw.SystemWindowDecoration(
        startColor: Colors.orange[800],
        endColor: Colors.orange[800],
      ),
    );

    saw.SystemWindowBody body = saw.SystemWindowBody(
      decoration: saw.SystemWindowDecoration(
        startColor: Colors.orange[800],
        endColor: Colors.orange[800],
      ),
      rows: [
        saw.EachRow(
          columns: [
            saw.EachColumn(
              text: saw.SystemWindowText(
                text:
                    "Don\'t waste your precious time. You have pending tasks to complete.\n\nOpen Badger to view your pending tasks.",
                fontSize: 16,
                textColor: Colors.white,
                fontWeight: saw.FontWeight.BOLD,
              ),
            ),
          ],
          gravity: saw.ContentGravity.CENTER,
        ),
      ],
      padding:
          saw.SystemWindowPadding(left: 16, right: 16, bottom: 12, top: 12),
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
      // prefMode: saw.SystemWindowPrefMode.OVERLAY,
    );
  }
}
