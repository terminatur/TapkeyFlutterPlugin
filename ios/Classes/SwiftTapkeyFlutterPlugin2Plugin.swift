import Flutter
import UIKit

public class SwiftTapkeyFlutterPlugin2Plugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "tapkey_flutter_plugin2", binaryMessenger: registrar.messenger())
    let instance = SwiftTapkeyFlutterPlugin2Plugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
