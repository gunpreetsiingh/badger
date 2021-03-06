import 'package:badger/screens/authentication.dart';
import 'package:badger/screens/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  var size;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    navigate();
  }

  void navigate() async {
    await Future.delayed(Duration(milliseconds: 2500)); // 2500
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.of(context).pushNamed('/authentication');
    } else {
      Navigator.of(context).pushNamed('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: size.height,
        width: size.width,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image(
              image: AssetImage('assets/splash-bg.jpg'),
              fit: BoxFit.cover,
              height: size.height,
              width: size.width,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 100),
                Image(
                  image: AssetImage('assets/logo.png'),
                  width: 250,
                ),
                Lottie.asset(
                  'assets/animation-splash.json',
                  width: 250,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
