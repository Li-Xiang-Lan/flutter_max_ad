import Flutter
import UIKit

public class FlutterMaxAdPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_max_ad", binaryMessenger: registrar.messenger())
    let instance = FlutterMaxAdPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "dismissMaxAdView":
        var top = getTopViewController()
        top?.dismiss(animated: true)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

   func getTopViewController() -> UIViewController? {
          var rootViewController: UIViewController?
          if #available(iOS 13.0, *) {
            let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
            rootViewController = keyWindow?.rootViewController
          } else {
            rootViewController = UIApplication.shared.keyWindow?.rootViewController
          }
          while let presentedViewController = rootViewController?.presentedViewController {
            rootViewController = presentedViewController
          }
          return rootViewController
    }
}
