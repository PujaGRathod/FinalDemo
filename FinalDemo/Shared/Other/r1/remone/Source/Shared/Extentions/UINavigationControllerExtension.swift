//
//  UINavigationControllerExtension.swift
//  remone
//
//  Created by Arjav Lad on 21/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    func removeShadowFromNavigationbar() {
        self.navigationBar.barTintColor = .white
        self.navigationBar.isTranslucent = false
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
    }

    func addShadowToNavigationbar() {
        self.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationBar.shadowImage = nil
    }
}
