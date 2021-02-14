import 'package:tapkey_flutter_plugin2/tapkey_flutter_plugin2.dart';

class ExampleLocksChangedHandler extends LocksChangedHandler {
  @override
  void onLocksChanged(List<BleLock> locks) {
    locks.forEach((element) {
      print("Flutter side: Lock updated: ${element.bluetoothAddress}");
    });
  }

}