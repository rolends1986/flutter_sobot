import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
       let flutterViewController: FlutterViewController = window?.rootViewController as! FlutterViewController
     //
      GeneratedPluginRegistrant.register(with: self)
      let navigationController = UINavigationController(rootViewController: flutterViewController)
      navigationController.isNavigationBarHidden = true
      navigationController.navigationBar.isTranslucent=true;
      window?.rootViewController = navigationController
     // mainCoordinator = AppCoordinator(navigationController: navigationController)
      window?.makeKeyAndVisible()
      //
      return super.application(application,     didFinishLaunchingWithOptions: launchOptions)
  }
}
