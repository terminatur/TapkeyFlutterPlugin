import 'package:tapkey_flutter_plugin2/models/BleLock.dart';

abstract class LocksChangedHandler {
  void onLocksChanged(List<BleLock> locks);
}