import UIKit
import Flutter
import GoogleMaps  // Hinzufügen

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    GMSServices.provideAPIKey("AIzaSyCN_n58PTrgbX_dzKhY59mP2faWfQhdMTc") // Hinzufügen

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
