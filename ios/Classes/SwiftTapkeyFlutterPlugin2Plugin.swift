import Flutter
import UIKit
import TapkeyMobileLib
import witte_mobile_library
import AppAuth

public class SwiftTapkeyFlutterPlugin2Plugin: NSObject, FlutterPlugin {
//    private var TKMServiceFactory: TKMServiceFactory!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "tapkey_flutter_plugin2", binaryMessenger: registrar.messenger())
        let instance = SwiftTapkeyFlutterPlugin2Plugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            handleGetPlaformVersionMethodCall(call: call, result: result);
            break;
        default:
            result(FlutterMethodNotImplemented);
            break;
        }
    }
    
    private func handleGetPlaformVersionMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
    }
}
