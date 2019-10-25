//
//  RMLoginSession.swift
//  remone
//
//  Created by Arjav Lad on 25/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit

private let LocalDataVersion = "1.2"
private let SessionKey: String = "RMLoginSession\(LocalDataVersion)"

class RMLoginSession: NSObject, NSCoding {

    private var tokenString: String
    private var deviceToken: String = ""

    var token: String {
        return self.tokenString
    }
    var user: RMUser

    init(token: String, user: RMUser) {
        self.tokenString = token
        self.user = user
    }

    required init?(coder aDecoder: NSCoder) {
        if let token = aDecoder.getStringValue(for: "token"),
            let user: RMUser = aDecoder.decodeObject(forKey: "user") as? RMUser {

            self.deviceToken = aDecoder.getStringValue(for: "DeviceToken") ?? ""
            self.tokenString = token
            self.user = user
        } else {
            return nil
        }
    }

    func updateDeviceToken(_ tokenString: String) {
        self.deviceToken = tokenString
        APIManager.shared.addDeviceToken(tokenString)
        self.save()
    }

    func updateUser(_ completion: (() -> Void)? = nil) {
        APIManager.shared.getUserProfile(for: user.id) { (fetchedUser, error) in
            if let fetchedUser = fetchedUser {
                self.user = fetchedUser
                self.save()
                completion?()
            }
        }
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.tokenString, forKey: "token")
        aCoder.encode(self.user, forKey: "user")
        aCoder.encode(self.deviceToken, forKey: "DeviceToken")
    }

    func setToken(_ token: String) {
        self.tokenString = token
        self.save()
    }

    func save() {
        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(data, forKey: SessionKey)
        UserDefaults.standard.synchronize()
    }

    func logout(_ completion: @escaping () -> Void) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        APIManager.shared.deleteDeviceToken(self.deviceToken) {
            RMLoginSession.clearLocalSession()
            UIApplication.shared.unregisterForRemoteNotifications()
            completion()
        }
    }

    func updateCurrentUserProfile() {
        APIManager.shared.getUserProfile(for: self.user.id) { (fetcheduser, error) in
            if let fetcheduser = fetcheduser {
                self.user = fetcheduser
                self.save()
            }
        }
    }

    class func setupLoginFlow() {
        func setRootController(_ vc: UIViewController) {
            if let delegate = UIApplication.shared.delegate as? AppDelegate,
                let window = delegate.window {
                window.rootViewController = vc
            }
        }

        if let session = RMLoginSession.getLocalSession() {
            if session.user.isSignupComplete {
                let dashboardStoryboard = UIStoryboard.init(name: "Dashboard", bundle: nil)
                setRootController(dashboardStoryboard.instantiateViewController(withIdentifier: "navDashboard"))
                return
            } else {
                RMLoginSession.clearLocalSession()
            }
        } else {
            RMLoginSession.setupLogoutFlow()
        }
    }

    class func setupLogoutFlow() {
        let welComeStoryboard = UIStoryboard.init(name: "Welcome", bundle: nil)
        if let delegate = UIApplication.shared.delegate as? AppDelegate,
            let window = delegate.window {
            if let navSplash = welComeStoryboard.instantiateViewController(withIdentifier: "navSplash") as? UINavigationController {
                if let splash = navSplash.viewControllers.first as? SplashVC {
                    splash.showSplash = false
                    window.rootViewController = navSplash
                }
            }
        }
    }

    class func createSession(with token: String, user: RMUser) -> RMLoginSession {
        let session = RMLoginSession.init(token: token, user: user)
        session.save()
        return session
    }

    class func clearLocalSession() {
        UserDefaults.standard.removeObject(forKey: SessionKey)
        UserDefaults.standard.synchronize()
    }
    
    class func getLocalSession() -> RMLoginSession? {
        if let data = UserDefaults.standard.object(forKey: SessionKey) as? Data {
            if let session = NSKeyedUnarchiver.unarchiveObject(with: data) as? RMLoginSession {
                return session
            }
        }
        return nil
    }

}
