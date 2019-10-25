//
//  AppDelegate.swift
//  remone
//
//  Created by Arjav Lad on 19/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import FBSDKLoginKit
import Firebase
import GoogleMaps
import Fabric
import Crashlytics
import UserNotifications
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?

    var userlocation: UserLocation = UserLocation.init()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        GMSServices.provideAPIKey("AIzaSyCUpuSjiTAllW2SqdTGoEghWrQ-6Hf7dVU")
        FirebaseApp.configure()
        _ = Analytics.shared
        Fabric.with([Crashlytics.self])
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Cancel".localized
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        GMSPlacesClient.provideAPIKey("AIzaSyBfPEWuljkVcsFkkW6HgdC1AgPRoZHBNIU")

        if let user = APIManager.shared.loginSession?.user {
            APIManager.shared.getDefaultOfficeSearchFilter()
            APIManager.shared.loginSession?.updateUser()
            if user.isSignupComplete {
                self.registerForNotifcation()
            } else {
                application.unregisterForRemoteNotifications()
            }
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
            application.unregisterForRemoteNotifications()
        }

        //                        UserDefaults.standard.set(["ja", "en"], forKey: "AppleLanguages")
        UserDefaults.standard.set(["ja"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()

        RMLoginSession.setupLoginFlow()

        if let userInfo = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String:Any] {
            self.handlePushNotifications(with: userInfo)
        }
        return true
    }


    private func updateLocationSetup() {
        self.userlocation.locationUpdatedBlock = { (location, error) in
            if let _ = error {
            } else if let location = location?.currentLocation {
                print(location)
            } else {
                print("location not found")
            }
        }
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if let _ = APIManager.shared.loginSession?.user,
            let location = self.userlocation.currentLocation {
            APIManager.shared.loginSession?.user.userLocation?.coordinates = location
            APIManager.shared.loginSession?.save()
//            APIManager.shared.updateLocation(at: location.latitude, longitude: location.longitude, { (success) in
//
//            })
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handle = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        return handle
    }
    
    func registerForNotifcation() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.alert, .sound, .badge]) { (granted: Bool, error: Error?) in
                if (error != nil) {
                    print("Failed to request authorization")
                    return
                }
                if granted {
                    DispatchQueue.main.async {
                        UNUserNotificationCenter.current().delegate = self
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                } else {
                    print("The user refused the push notification")
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let hex = deviceToken.map( {String(format: "%02x", $0) }).joined(separator: "")
        APIManager.shared.loginSession?.updateDeviceToken(hex)
        print("Token: \(hex)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Token failed with: \(error.localizedDescription)")
//        self.window?.rootViewController?.showAlert("Device Token Not Found", message: "Error:\n \(error.localizedDescription)")
    }

    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let payload = response.notification.request.content.userInfo as? [String:Any] {
            self.handlePushNotifications(with: payload)
        }
        _ = self.getTopMostNavigationController()
        completionHandler()
    }

    private func getTabbarController() -> UITabBarController? {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate,
            let window = delegate.window else {
                return nil
        }
        let tabbar = (window.rootViewController as? UINavigationController)?.viewControllers.first as? DashboardTabbarVC
        return tabbar
    }
    
    private func handlePushNotifications(with payload: [String : Any]) {
        guard let notification = APIManager.shared.notification(from: payload) else {
            return
        }
        self.open(notification: notification)
    }
    
    private func open(notification:NotificationModel) {
        self.markNotificationAsRead(notification)
        switch notification.type {
        case .post, .like, .comment:             
            self.openPost(notification: notification)
        case .followRequest:
            self.openNotificationRequests()
        case .followRequestAccepted:
            if let rootVC = self.getTopMostNavigationController() {
                UserProfileVC.loadUserProfile(for: notification.actionUserID, on: rootVC)
            }
        default:
            print("Unknown type")
        }
    }

    func markNotificationAsRead(_ notification: NotificationModel) {
        APIManager.shared.markNotificationAsRead(notification: [notification]) { (error) in
            if UIApplication.shared.applicationIconBadgeNumber > 0 {
                UIApplication.shared.applicationIconBadgeNumber -= 1
            } else {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }
    }
    
    private func openPost(notification: NotificationModel) {

        func openTimeSatmp(for id: String) {
            var request = APIManager.TimestampAPI.getTimestamp.request()
            request.id = id
            self.window?.rootViewController?.showLoader()
            APIManager.shared.getTimestampDetails(request: request, responseClosure: { (response) in
                self.window?.rootViewController?.hideLoader()
                if let timestamp = response.timestamp {
                    let storyboard = UIStoryboard(name: "Timeline", bundle: nil)
                    if let vc = storyboard.instantiateViewController(withIdentifier: "TimestampDetailsVC") as? TimestampDetailsVC {
                        vc.timeStamp = timestamp
                        self.getTopMostNavigationController()?.pushViewController(vc, animated: true)
                    }
                }
            })
        }

        if let id = notification.timestampId {
            if let topvc = self.getTopMostNavigationController()?.viewControllers.last as? TimestampDetailsVC {
                if topvc.timeStamp.id == id {
                    topvc.fetchComments()
                } else {
                    openTimeSatmp(for: id)
                }
            } else {
                openTimeSatmp(for: id)
            }
        }
    }
    
    private func openNotificationRequests() {
        let topmostNavController = self.getTopMostNavigationController()
        if topmostNavController?.topViewController?.isKind(of: NotificationVC.classForCoder()) == true,
            let vc = topmostNavController?.topViewController as? NotificationVC {
            vc.segmentNotificationType.selectedSegmentIndex = 1
            vc.reload()
            return
        }
        let storyboard = UIStoryboard(name: "Timeline", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "NotificationVC") as? NotificationVC {
            vc.shouldOpenRequestTab = true
            topmostNavController?.pushViewController(vc, animated: true)
        }
    }
    
    private func getTopMostNavigationController() -> UINavigationController? {
        if let presentedVC = self.getTabbarController()?.presentedViewController as? UINavigationController {
            return presentedVC
        } else if let nav1 = self.getTabbarController()?.viewControllers?.first as? UINavigationController {
            self.getTabbarController()?.selectedIndex = 0
            return nav1
        }
        return nil
    }
}

