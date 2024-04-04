import UIKit
import Flutter
import GoogleMaps  // Add this import
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // TODO: Add your Google Maps API key
    GMSServices.provideAPIKey("AIzaSyC0HFYMtOc0tak9xNzJ3muRKDpyU-bJIUM")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
