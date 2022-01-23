import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tapkey_flutter_plugin2/tapkey_flutter_plugin2.dart';
import 'package:tapkey_flutter_plugin2_example/ExampleLocksChangedHandler.dart';
import 'package:tapkey_flutter_plugin2_example/ExampleTokenRefreshHandler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (! (await Permission.locationAlways.isGranted)) {
    await [Permission.locationAlways].request();
    await Permission.locationAlways.request();
  }

  // TapkeyFlutterPlugin2.instance.tokenRefreshHandler = ExampleTokenRefreshHandler();
  // TapkeyFlutterPlugin2.instance.locksChangedHandler = ExampleLocksChangedHandler();
  // await TapkeyFlutterPlugin2.instance.startForegroundScan();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState2 extends State<MyApp> {
  String _platformVersion = 'Unknown';
  TapkeyFlutterPlugin2 tapkeyPlugin = null; // TapkeyFlutterPlugin2.instance;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await tapkeyPlugin.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
        home: Scaffold(
        appBar: AppBar(
        title: Text('Running on: $_platformVersion\n'),
      ),
    ));
  }

}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _lockId = 'C1-16-48-0F';
  bool _isLockNearby = false;

  // TapkeyFlutterPlugin2 tapkeyPlugin = TapkeyFlutterPlugin2.instance;
  // tapkeyPlugin.tokenRefreshHandler = new ExampleTokenRefreshHandler();
  // tapkeyPlugin.locksChangedHandler = new ExampleLocksChangedHandler();

  TapkeyFlutterPlugin2 tapkeyPlugin = new TapkeyFlutterPlugin2(new ExampleTokenRefreshHandler(), new ExampleLocksChangedHandler());

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    await tapkeyPlugin.startForegroundScan();

    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await tapkeyPlugin.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Running on: $_platformVersion\n'),
              // TextField(
              //   decoration: InputDecoration(
              //     border: OutlineInputBorder(),
              //     labelText: 'lock Id'
              //   ),
              //   onChanged: (str) => _lockId = str,
              // ),
              RaisedButton(
                onPressed: login,
                child: Text("Login"),
              ),
              RaisedButton(
                  onPressed: getLocks,
                child: Text("Get Locks"),
              ),
              RaisedButton(
                onPressed: refreshKeys,
                child: Text("Refresh Keys"),
              ),
              RaisedButton(
                  onPressed: isLockNearby,
                child: Text("Is Lock Nearby?"),
              ),
              Text('Is lock nearby: $_isLockNearby'),
              RaisedButton(
                  onPressed: triggerLock,
                child: Text("Trigger Lock"),
              ),
              RaisedButton(
                onPressed: requestPermissions,
                child: Text("Request Permissions"),
              )
            ]
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    try {
      String accessToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ik1yNS1BVWliZkJpaTdOZDFqQmViYXhib1hXMCIsImtpZCI6Ik1yNS1BVWliZkJpaTdOZDFqQmViYXhib1hXMCJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLndpbmRvd3MubmV0IiwiaXNzIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvN2JlZWZmMDAtZWU4Yy00OTQyLWJhYmUtZTBiZjAzZGQzNDk2LyIsImlhdCI6MTY0MjgxMTU4NSwibmJmIjoxNjQyODExNTg1LCJleHAiOjE2NDI4MTY2MTUsImFjciI6IjEiLCJhaW8iOiJFMlpnWUloOU9PT0o0L1NENnQ5VFducGsvazVTc3E3eWxkdTdnS3Z2N1BHRHpUS2JWY1VBIiwiYW1yIjpbInB3ZCJdLCJhcHBpZCI6ImFkNjQwZWI4LTYzODgtNGNjMi1hODc4LTcwYzY4Njg3N2YxNSIsImFwcGlkYWNyIjoiMSIsImZhbWlseV9uYW1lIjoiQUNDRVNTIiwiZ2l2ZW5fbmFtZSI6IkFQSSIsImlwYWRkciI6IjEzLjc5LjE1Ny45MiIsIm5hbWUiOiJBUEkgQUNDRVNTIiwib2lkIjoiYjM3YjBmYTUtMTMzMi00NWIwLThlMDYtNTQ2MzllNjU0ZmU5IiwicHVpZCI6IjEwMDMyMDAxMEI0RDY0RDQiLCJyaCI6IjAuQVNJQUFQX3VlNHp1UWttNnZ1Q19BOTAwbHJnT1pLMklZOEpNcUhod3hvYUhmeFVpQURnLiIsInNjcCI6IlVzZXIuUmVhZCIsInN1YiI6IjdaNWFyTE9NcmpwU3FOQ25FR0VxVmVJaTAyUDNoR3Q1dm9sMHNKNXN6TkUiLCJ0ZW5hbnRfcmVnaW9uX3Njb3BlIjoiRVUiLCJ0aWQiOiI3YmVlZmYwMC1lZThjLTQ5NDItYmFiZS1lMGJmMDNkZDM0OTYiLCJ1bmlxdWVfbmFtZSI6ImIzN2IwZmE1LTEzMzItNDViMC04ZTA2LTU0NjM5ZTY1NGZlOUB3aXR0ZWRpZ2l0YWxiMmN1YXQub25taWNyb3NvZnQuY29tIiwidXBuIjoiYjM3YjBmYTUtMTMzMi00NWIwLThlMDYtNTQ2MzllNjU0ZmU5QHdpdHRlZGlnaXRhbGIyY3VhdC5vbm1pY3Jvc29mdC5jb20iLCJ1dGkiOiJ2ZVlHblRvV0VVMkhEUHM5RDVJTEFBIiwidmVyIjoiMS4wIn0.Z5TbgnnmxmUzH-ZUgJWC91-fhUt3o-u5YOHi-WVYkAvihJgAXGzhc6cZR0dEPHdx1p0jsJDlBVPj0AZrh8cZj2s3fEloFgZnq71R5LPUmoj26YcnYWymSz_gySCT44cojPbwfPbGsSksJ6YE2lmD7oE6btzdLd19cyQTCKnxmZ6KbwTmgSPLP8RhSSXpEYXiz-NIUo4KwtjuH6ioi6x0JZlUm5t0YtVuApW7Ve7XyQUznPbF90E1bdPkmH_cuxE_3BmyESJ27tCP2JdnytElau69HEvl1X9Xnjm_DrTLXkZT5bmCWWHNAdBdv-WkQBQkbbASWbdlMvDUTTL7Kj8Ssg";

      String userId = await tapkeyPlugin.login(accessToken);
      print('UserId: ${userId}');
    } on Exception catch (e) {
      print("There was an issue with login");
    }
  }

  Future<void> isLockNearby() async {
    bool isLockNearby = await tapkeyPlugin.isLockNearby(_lockId);

    setState(() {
      _isLockNearby = isLockNearby;
    });
  }

  Future<void> triggerLock() async {
    String deviceId = _lockId;

    await tapkeyPlugin.triggerLock(deviceId);
  }

  Future<void> getLocks() async {
    var results = await tapkeyPlugin.getLocks();

    print('got locks');
  }

  Future<void> refreshKeys() async {
    await tapkeyPlugin.refreshKeys();
  }

  Future<void> requestPermissions() async {
    await Permission.locationAlways.request();
  }

}

