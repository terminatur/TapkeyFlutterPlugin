
import 'dart:async';
import 'dart:collection';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:tapkey_flutter_plugin2/auth/TokenRefreshHandler.dart';
import 'package:tapkey_flutter_plugin2/bleLock/LocksChangedHandler.dart';

import 'models/BleLock.dart';

export 'package:tapkey_flutter_plugin2/models/BleLock.dart';
export 'package:tapkey_flutter_plugin2/bleLock/LocksChangedHandler.dart';
export 'package:tapkey_flutter_plugin2/auth/TokenRefreshHandler.dart';

class TapkeyFlutterPlugin2 {
  static final TapkeyFlutterPlugin2 _instance = TapkeyFlutterPlugin2();
  static TapkeyFlutterPlugin2 get instance => _instance;

  final MethodChannel _channel = const MethodChannel('tapkey_flutter_plugin2');

  LocksChangedHandler _locksChangedHandler;
  set locksChangedHandler(LocksChangedHandler handler) => _locksChangedHandler = handler;
  LocksChangedHandler get locksChangedHandler => _locksChangedHandler;

  TokenRefreshHandler _tokenRefreshHandler;
  set tokenRefreshHandler(TokenRefreshHandler handler) => _tokenRefreshHandler = handler;
  TokenRefreshHandler get tokenRefreshHandler => _tokenRefreshHandler;

  TapkeyFlutterPlugin2() {
    _channel.setMethodCallHandler(_callbackHandlerMethod);
  }

  Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<String> login(String accessToken) async {
    Map<String, Object> arguments = new Map<String, Object>();
    arguments["accessToken"] = accessToken;

    final String userId = await _channel.invokeMethod('login', arguments);

    print("Obtained user id in flinkey side: ${userId}");
    return userId;
  }

  Future startForegroundScan() async {
    await _channel.invokeMethod("startForegroundScan");
  }
  
  Future stopForegroundScan() async {
    await _channel.invokeMethod("stopForegroundScan");
  }

  Future<bool> isLockNearby(String lockId) async {
    Map<String, Object> arguments = new Map<String, Object>();
    arguments["lockId"] = lockId;

    bool isLockNearby = await _channel.invokeMethod<bool>("isLockNearby", arguments);

    return isLockNearby;
  }

  Future triggerLock(String lockId) async {
    Map<String, Object> arguments = new Map<String, Object>();
    arguments["lockId"] = lockId;

    await _channel.invokeMethod("triggerLock", arguments);
  }
  
  Future logout() async {
    await _channel.invokeMethod("lockout");
  }
  
  Future refreshKeys() async {
    await _channel.invokeMethod("refreshKeys");
  }

  Future<List<BleLock>> getLocks() async {
    var lockResults = await _channel.invokeListMethod("getLocks");

    List<BleLock> locks = lockMapsToBleLocks(lockResults);

    return locks;
  }

  List<BleLock> lockMapsToBleLocks(List<dynamic> lockMaps) {
    List<BleLock> locks = new List();

    lockMaps.forEach((element) {
      var map = element as Map;
      var castMap = map.cast<String, Object>();
      BleLock lock = BleLock.fromMap(castMap);
      locks.add(lock);
    });

    return locks;
  }

  /*
  * TODO: Callback 1: on locks updated
  * TODO: Callback 2: Need new access access token
  * */

  Future<dynamic> _callbackHandlerMethod(MethodCall call) {
    print("Flutter callbackHandler: ${call.method}");
    dynamic arguments = call.arguments;

    switch (call.method) {
      case "getIdToken":
        if (_tokenRefreshHandler != null) {
          return _tokenRefreshHandler.getIdToken();
        }
        break;
      case "onLocksChanged":
        if (_locksChangedHandler != null) {
          List<dynamic> lockMaps = arguments as List;
          List<BleLock> locks = lockMapsToBleLocks(lockMaps);
          _locksChangedHandler.onLocksChanged(locks);
        }
        break;
      default:
        throw MissingPluginException("${call.method} is not implemented");
    }

    return Future.value(null);
  }
}
