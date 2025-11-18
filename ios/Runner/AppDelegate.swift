import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Check if Firebase should be disabled (stub config file)
    let isFirebaseDisabled: Bool = {
      guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: path),
            let googleAppId = plist["GOOGLE_APP_ID"] as? String else {
        return false
      }
      return googleAppId == "stub"
    }()
    
    // Register plugins safely - if Firebase is disabled, use Objective-C exception handler
    if isFirebaseDisabled {
      // Use Objective-C helper to catch Firebase initialization exceptions
      registerPluginsSafely(self)
      print("✅ Plugin registration completed. App running without Firebase.")
    } else {
      // Normal registration when Firebase is enabled
      GeneratedPluginRegistrant.register(with: self)
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
