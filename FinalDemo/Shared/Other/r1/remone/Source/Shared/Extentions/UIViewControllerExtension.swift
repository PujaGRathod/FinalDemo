//
//  UIViewControllerExtension.swift
//  remone
//
//  Created by Arjav Lad on 21/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

extension UIViewController {
    func showAlert(_ title: String?, message: String?, actionHandler: ((UIAlertAction) -> Swift.Void)? = nil) {
        self.showAlert(title, message: message, actionTitle: "ok", actionStyle: .default, actionHandler: actionHandler)
    }

    func showAlert(_ title: String?, message: String?, actionTitle: String, actionStyle: UIAlertActionStyle, actionHandler: ((UIAlertAction) -> Swift.Void)? = nil) {
        self.showAlert(title, message: message, actionTitles: [(actionTitle, actionStyle)], cancelTitle: nil, actionHandler: { (action, _) in
            actionHandler?(action)
        })
    }

    func showAlert(_ title: String?, message: String?, actionTitles: [(String, UIAlertActionStyle)], cancelTitle: String? = nil, actionHandler: ((UIAlertAction, Int) -> Swift.Void)? = nil, cancelActionHandler: ((UIAlertAction) -> Void)? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
            for (index, action) in actionTitles.enumerated() {
                alertController.addAction(UIAlertAction.init(title: action.0, style: action.1, handler: { (action) in
                    actionHandler?(action, index)
                }))
            }

            if let cancelTitle = cancelTitle {
                alertController.addAction(UIAlertAction.init(title: cancelTitle, style: .cancel, handler: cancelActionHandler))
            }

            self.present(alertController, animated: true) {

            }
        }
    }

    func showActionSheet(_ title: String?, message: String?, actionTitles: [(String, UIAlertActionStyle)], cancelTitle: String? = nil, actionHandler: ((UIAlertAction, Int) -> Swift.Void)? = nil, cancelActionHandler: ((UIAlertAction) -> Void)? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .actionSheet)
            for (index, action) in actionTitles.enumerated() {
                alertController.addAction(UIAlertAction.init(title: action.0, style: action.1, handler: { (action) in
                    actionHandler?(action, index)
                }))
            }
            if let cancelTitle = cancelTitle {
                alertController.addAction(UIAlertAction.init(title: cancelTitle, style: .cancel, handler: cancelActionHandler))
            }

            self.present(alertController, animated: true) {

            }
        }
    }

    private func getHUD(for view: UIView) -> MBProgressHUD? {
        for subView in view.subviews.reversed() {
            if subView is MBProgressHUD {
                return subView as? MBProgressHUD
            }
        }
        return nil
    }
    
    func showLoader(_ text: String? = nil) {
        if let appDel = UIApplication.shared.delegate as? AppDelegate {
            if let window = appDel.window {
                if let oldHUD = self.getHUD(for: window) {
                    oldHUD.hide(animated: true)
                }
                let hud = MBProgressHUD.showAdded(to: window, animated: true)
                hud.label.text = text
            }
        }
    }

    func hideLoader(animated: Bool = true) {
        if let appDel = UIApplication.shared.delegate as? AppDelegate {
            if let window = appDel.window {
                MBProgressHUD.hide(for: window, animated: animated)
            }
        }
    }

}

