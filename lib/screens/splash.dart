import 'package:badger/screens/authentication.dart';
import 'package:badger/screens/dashboard.dart';
import 'package:flutter/material.dart';

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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => Authentication(),
      ),
    );
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
            Container(
              width: 140,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Badger',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  LinearProgressIndicator(
                    color: Colors.black,
                    backgroundColor: Colors.black.withOpacity(0.30),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
