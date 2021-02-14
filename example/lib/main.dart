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
  }

  TapkeyFlutterPlugin2.instance.tokenRefreshHandler = ExampleTokenRefreshHandler();
  TapkeyFlutterPlugin2.instance.locksChangedHandler = ExampleLocksChangedHandler();
  await TapkeyFlutterPlugin2.instance.startForegroundScan();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _lockId = 'C1-16-48-0F';
  bool _isLockNearby = false;

  TapkeyFlutterPlugin2 tapkeyPlugin = TapkeyFlutterPlugin2.instance;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
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
              )
            ]
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    try {
      String accessToken = "eyJhbGciOiJSUzI1NiIsImtpZCI6IkYyQjQwNjc0MUMxQTE5NzhEREIyNDA2OEM0MkVDQzdBQUFGOTY5OENSUzI1NiIsInR5cCI6IkpXVCIsIng1dCI6IjhyUUdkQndhR1hqZHNrQm94QzdNZXFyNWFZdyJ9.eyJuYmYiOjE2MTI2Mzk1MTIsImV4cCI6MTYxMjY0MzAzNSwiaXNzIjoiaHR0cHM6Ly9sb2dpbi50YXBrZXkuY29tIiwiYXVkIjoidGFwa2V5X2FwaSIsImNsaWVudF9pZCI6IndtYS1uYXRpdmUtbW9iaWxlLWFwcCIsImNsaWVudF90ZW5hbnQiOiJ3bWEiLCJjbGllbnRfdGstc2NvcGVzLXZlcnNpb24iOiIxIiwic3ViIjoid21hLm9hdXRoOzIwMzVjMjNhLWRlM2UtNDVjZS05ZjIyLTNjMGY3OWQwY2Q0OCIsImF1dGhfdGltZSI6MTYxMjYzOTUxMiwiaWRwIjoid21hLm9hdXRoIiwiZW1haWwiOiIyMDM1YzIzYS1kZTNlLTQ1Y2UtOWYyMi0zYzBmNzlkMGNkNDgiLCJpYXQiOjE2MTI2Mzk1MTIsInNjb3BlIjpbImhhbmRsZTprZXlzIiwicmVhZDp1c2VyIiwicmVnaXN0ZXI6bW9iaWxlcyJdLCJhbXIiOlsiaHR0cDovL3RhcGtleS5uZXQvb2F1dGgvdG9rZW5fZXhjaGFuZ2UiXX0.ijgtECbrEfzWjGYFeGmRtVEMX6cYeNe36MbEC6Uc7nEGiys1EpVH78XgY9TMIZkkU2Ckucc_sf5hG_8nzBfeyQuZbUEoDG1BYJ1V3UJDNK8Tpjg3NR5Rxt8EG0NTV0tjwrM_oUoJCtXuxmbY0a_mZLfA3wOG8j7N0KW0xrvzE5YlaQ3MXGT95XNYy9y9n2zZFJhxqo6s6pwpUHqDHNixqI95KhWBmaZkpPPAtBcnGeK3de3NADR2vh_u5gQ4p9g1UWxo_RCMU_hnKgrm2Fgm47eRRXyOykKc01VUT-Ru151RyT3hHmkm1TYZwnsqHVLCL3CCt2oJz80NXdhbbnTzRqCw5bxgWYMuF5i4bc3-PvCMDA9KNHcoMEhl9TLqeRvXbSBKiQCQDPQo19Q75sqs-vKyUpmvqTqd8CCELI67a_l_sSoPupsHXkEt2u0kpzc-cwHIt698332r238Bf_5gyhkTnfbtbwBI_LIhm2sJaMHz9GNDz8sD1t8i-i4pEDQ_FO-nrg-ePNjNPdcLB9DG6JgtlOH1z64C_TtJRxTUIq01pcc6YpozkPlWZnfEpVk9wv17voN8p7cpi9ml0029PGu-xLM3kEYX1XGZo9J-lUTywYvdwM_DXBuyDjRzBxL2Wo8Ubsu5fvC9cnCaXDHxxjjXopr4r0MGufBVQWa1j4Q";

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
}
