import Flutter
import UIKit
import MobileRTC

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func applicationWillResignActive(_ application: UIApplication) {
    MobileRTC.shared().appWillResignActive()
    super.applicationWillResignActive(application)
  }
  
  override func applicationDidBecomeActive(_ application: UIApplication) {
    MobileRTC.shared().appDidBecomeActive()
    super.applicationDidBecomeActive(application)
  }
  
  override func applicationDidEnterBackground(_ application: UIApplication) {
    MobileRTC.shared().appDidEnterBackground()
    super.applicationDidEnterBackground(application)
  }
  
  override func applicationWillTerminate(_ application: UIApplication) {
    MobileRTC.shared().appWillTerminate()
    super.applicationWillTerminate(application)
  }
}
