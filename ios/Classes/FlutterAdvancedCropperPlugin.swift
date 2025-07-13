import Flutter
import UIKit

public class FlutterAdvancedCropperPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_advanced_cropper", binaryMessenger: registrar.messenger())
    let instance = FlutterAdvancedCropperPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "getPlatformVersion" {
      result("iOS " + UIDevice.current.systemVersion)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
}