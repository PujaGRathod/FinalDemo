//
//  HelpAboutUsVC.swift
//  WakeUppApp
//
//  Created by C025 on 05/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class HelpAboutUsVC: UIViewController {
    
    //MARK: Outlet
    @IBOutlet weak var btnFAQs: UIButton!
    @IBOutlet weak var btnAboutUs: UIButton!
    @IBOutlet weak var btnTermsOfUse: UIButton!
    @IBOutlet weak var btnPrivacyPolicy: UIButton!
    @IBOutlet weak var btnFeedback: UIButton!
    @IBOutlet weak var btnAppInfo: UIButton!
    
    @IBOutlet weak var viewAppInfo: UIView!
    
    @IBOutlet weak var lc_viewAppInfo_y: NSLayoutConstraint!
    //@IBOutlet weak var lblAppName: UILabel!
    @IBOutlet weak var lblAppVersion: UILabel!
    @IBOutlet weak var lblAppRights: UILabel!
    
    //MARK: Variable
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.layoutUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Custom Function
    func layoutUI() {
        
        //Set App Info
        //lblAppName.text = APPNAME
        lblAppVersion.text = "Version " + appVersion!
        
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        lblAppRights.text = "©\(year) \(APPNAME)\nAll Rights reserved."
        
        //Default Hide View
        runAfterTime(time: 0.10) {
            self.lc_viewAppInfo_y.constant = SCREENHEIGHT()
            self.view.layoutIfNeeded()
        }
    }
    
    func show_AppInfo(show : Bool) -> Void {
        if (show == false) {
            UIView.animate(withDuration: 0.50) {
                self.lc_viewAppInfo_y.constant = SCREENHEIGHT()
                self.view.layoutIfNeeded()
            }
        }
        else {
            UIView.animate(withDuration: 0.50) {
                self.lc_viewAppInfo_y.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    //MARK: - Button action method
    @IBAction func btnBackAction() {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnHelpAboutUsAction(_ sender: UIButton) {
        var strTitle = ""
        var strURL = ""
        
        if (sender == btnFAQs) {
            strTitle = "FAQ's"
            strURL = URL_FAQ
        }
        else if (sender == btnAboutUs) {
            strTitle = "About Us"
            strURL = URL_AboutUs
        }
        else if (sender == btnTermsOfUse) {
            strTitle = "Terms of Use"
            strURL = URL_TermsOfUse
        }
        else if (sender == btnPrivacyPolicy) {
            strTitle = "Privacy Policy"
            strURL = URL_PrivacyPolicy
        }
        else if (sender == btnAppInfo) {
            self.show_AppInfo(show: true)
            return
        }
        else if (sender == btnFeedback) {
            let objVC : FeedbackVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idFeedbackVC) as! FeedbackVC
            APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
            return
        }
        else {
            return
        }
        
        let objVC : WebviewVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idWebviewVC) as! WebviewVC
        objVC.strTitle = strTitle
        objVC.strURL = strURL
        APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
    }
    
    @IBAction func btnAppInfoDismissAction() {
        self.show_AppInfo(show: false)
    }
}
