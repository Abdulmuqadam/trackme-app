import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    guard let mapsAPIKey = Bundle.main.object(forInfoDictionaryKey: "GoogleMapsAPIKey") as? String,
          !mapsAPIKey.isEmpty,
          !mapsAPIKey.hasPrefix("$(") else {
      fatalError("GoogleMapsAPIKey must be supplied through the iOS build configuration.")
    }

    GMSServices.provideAPIKey(mapsAPIKey)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
