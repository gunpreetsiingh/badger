import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AllApps extends StatefulWidget {
  const AllApps({Key? key}) : super(key: key);

  @override
  _AllAppsState createState() => _AllAppsState();
}

class _AllAppsState extends State<AllApps> {
  var size;
  List<Widget> allAppsList = [];
  bool isLoading = true, isEmpty = false;

  List<String> packages = [
    'com.facebook.katana',
    'com.facebook.lite',
    'com.facebook.orca',
    'com.facebook.mlite',
    'com.whatsapp',
    'com.whatsapp.w4b',
    'com.instagram.android',
    'com.snapchat.android',
    'org.telegram.messenger',
    'org.telegram.messenger.web',
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadApps();
  }

  void loadApps() async {
    try {
      packages.forEach((element) async {
        bool isInstalled = await DeviceApps.isAppInstalled(element);
        if (isInstalled) {
          Application? app = await DeviceApps.getApp(element);
          allAppsList.add(
            Container(
              padding: EdgeInsets.only(left: 15),
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
                      app!.appName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.add_circle_rounded,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          );
        }
      });
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        isLoading = false;
        isEmpty = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
        isEmpty = true;
      });
    }
    setState(() {});
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
                                            'All Apps',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Visibility(
                                        visible: !isLoading && !isEmpty,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: allAppsList,
                                        )),
                                    Visibility(
                                      visible: !isLoading && isEmpty,
                                      child: Text(
                                        'No apps found on the device or unable to load the apps.',
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
