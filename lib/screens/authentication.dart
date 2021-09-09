import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class Authentication extends StatefulWidget {
  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isProcessing = false, isGoogleLoading = false, isFacebookLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void signInWithGoogle() async {
    setState(() {
      isGoogleLoading = true;
    });
    // Trigger the authentication flow
    var googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(credential);
    setState(() {
      isGoogleLoading = false;
    });
    QuerySnapshot usersData = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: googleUser.email)
        .get();
    if (usersData.docs.isEmpty) {
      createUserFromGoogleLogin(googleUser.email);
    }
    Navigator.of(context).pushNamed('/dashboard');
  }

  void signInWithFacebook() async {
    setState(() {
      isFacebookLoading = true;
    });
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {
      // you are logged
      final AccessToken accessToken = result.accessToken!;
      final AuthCredential credential =
          FacebookAuthProvider.credential(accessToken.token);
      await FirebaseAuth.instance.signInWithCredential(credential);
      FacebookAuth.instance.getUserData().then((userData) async {
        QuerySnapshot usersData = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: userData['email'])
            .get();
        if (usersData.docs.isEmpty) {
          createUserFromFbLogin(userData['email']);
        }
        Navigator.of(context).pushNamed('/dashboard');
      });
    }
    setState(() {
      isFacebookLoading = false;
    });
  }

  void registerUser() async {
    setState(() {
      isProcessing = true;
    });
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      createUser(userCredential);
      setState(() {
        isProcessing = false;
      });
      // create an account here
      Navigator.of(context).pushNamed('/dashboard');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        signIn();
      }
    } catch (e) {
      print(e);
    }
  }

  void signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      setState(() {
        isProcessing = false;
      });
      Navigator.of(context).pushNamed('/dashboard');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  void createUser(UserCredential userCredential) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
      'email': _emailController.text,
      'from': '09:00',
      'to': '17:00',
      'joinedOn': DateTime.now().toString(),
    });
  }

  void createUserFromGoogleLogin(String email) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'email': email,
      'from': '09:00',
      'to': '17:00',
      'joinedOn': DateTime.now().toString(),
    });
  }

  void createUserFromFbLogin(String email) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'email': email,
      'from': '09:00',
      'to': '17:00',
      'joinedOn': DateTime.now().toString(),
    });
  }

  var size;
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        decoration: new BoxDecoration(
            shape: BoxShape.rectangle,
            image: new DecorationImage(
                fit: BoxFit.fill, image: AssetImage('assets/splash-bg.jpg'))),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: size.width / 1.3,
                padding: EdgeInsets.all(15),
                decoration: new BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.white.withOpacity(0.85),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 5,
                      spreadRadius: 5,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Log In",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (!isGoogleLoading) {
                              signInWithGoogle();
                            }
                          },
                          icon: Stack(
                            children: [
                              Visibility(
                                visible: !isGoogleLoading,
                                child: FaIcon(
                                  FontAwesomeIcons.google,
                                  color: Colors.red[700],
                                ),
                              ),
                              Visibility(
                                visible: isGoogleLoading,
                                child: CircularProgressIndicator(
                                  color: Colors.red[700],
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        IconButton(
                          onPressed: () {
                            if (!isFacebookLoading) {
                              signInWithFacebook();
                            }
                          },
                          icon: Stack(
                            children: [
                              Visibility(
                                visible: !isFacebookLoading,
                                child: FaIcon(
                                  FontAwesomeIcons.facebook,
                                  color: Colors.blue[900],
                                ),
                              ),
                              Visibility(
                                visible: isFacebookLoading,
                                child: CircularProgressIndicator(
                                  color: Colors.blue[900],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "or",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    withEmailPassword(),
                    SizedBox(
                      height: 10,
                    ),
                    _buildForgotBtn(),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.orange,
                          shape: BoxShape.rectangle),
                      child: TextButton(
                        child: Stack(
                          children: [
                            Visibility(
                              visible: !isProcessing,
                              child: Text(
                                "Log In",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Visibility(
                              visible: isProcessing,
                              child: Container(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white)),
                            )
                          ],
                        ),
                        onPressed: () {
                          registerUser();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ]),
      ),
    );
  }

  Widget withEmailPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: Colors.grey,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
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
              borderRadius: BorderRadius.circular(50),
            ),
            child: TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(
                  Icons.vpn_key_rounded,
                  color: Colors.grey,
                ),
                border: InputBorder.none,
              ),
              obscureText: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotBtn() {
    return GestureDetector(
      onTap: () {},
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Forgot Password? ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Click Here',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
