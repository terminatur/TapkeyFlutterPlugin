import 'dart:typed_data';

import 'package:flutter/foundation.dart';

class BleLock {
  Uint8List incompleteLockId;
  bool isLockIdComplete;
  String bluetoothAddress;
  DateTime lastSeen;
  int rssi;

  BleLock(this.incompleteLockId,
      this.isLockIdComplete,
      this.bluetoothAddress,
      this.lastSeen,
      this.rssi);

  factory BleLock.fromMap(Map<String, Object> map) {
    return BleLock(
        map["incompleteLockId"] as Uint8List,
        map["isLockIdComplete"] as bool,
        map["bluetoothAddress"] as String,
        DateTime.fromMillisecondsSinceEpoch(map["lastSeen"] as int),
        map["rssi"] as int
    );
  }

}