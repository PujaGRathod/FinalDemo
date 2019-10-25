//
//  DashboardTabbarVC.swift
//  remone
//
//  Created by Arjav Lad on 09/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

protocol Refreshable {
    func refresh()
}

class DashboardTabbarVC: UITabBarController, UINavigationControllerDelegate, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        self.selectedIndex = 4
        self.tabBar.tintColor = APP_COLOR_THEME
        self.customizableViewControllers = nil
        self.moreNavigationController.navigationBar.tintColor = APP_COLOR_THEME
        self.moreNavigationController.navigationBar.isTranslucent = false
        self.moreNavigationController.delegate = self
        self.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let nav = viewController as? UINavigationController {
            if let vc = nav.viewControllers.first as? Refreshable {
                vc.refresh()
            }
        }
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let moreVC = navigationController.viewControllers.first {
            moreVC.navigationItem.rightBarButtonItem = nil
            moreVC.view.tintColor = APP_COLOR_THEME
        }
    }

}
