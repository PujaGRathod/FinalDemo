//
//  AccountSettingsVC.swift
//  WakeUppApp
//
//  Created by C025 on 05/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class AccountSettingsVC: UIViewController {
    
    //MARK: Outlet
    @IBOutlet weak var btnPrivacy: UIButton!
    @IBOutlet weak var btnTwoStepVerification: UIButton!
    @IBOutlet weak var btnChangeNo: UIButton!
    @IBOutlet weak var btnDeleteAccount: UIButton!
    
    //MARK: Variable
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Custom Function
    
    //MARK: - Button action method
    @IBAction func btnBackAction() {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnAccountSettingAction(_ sender: UIButton) {
        if (sender == btnPrivacy) {
            let objVC : PrivacyVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idPrivacyVC) as! PrivacyVC
            APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
        }
        else if (sender == btnTwoStepVerification) {
            
            //Get Status
            var strTwoStepVarification_status : Bool = false
            if (UserDefaultManager.getBooleanFromUserDefaults(key: kIsTwoStepVerification) == true) {
                strTwoStepVarification_status = true
            }
            
            let objVC : TwoStepVerificationVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idTwoStepVerificationVC) as! TwoStepVerificationVC
            objVC.twoStepVarification_status = strTwoStepVarification_status //Send Status
            APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
        }
        else if (sender == btnChangeNo) {
            let objVC : ChangeNumberVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idChangeNumberVC) as! ChangeNumberVC
            APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
        }
        else if (sender == btnDeleteAccount) {
            //self.deleteAccount()
            let objVC : DeleteMyAccountVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idDeleteMyAccountVC) as! DeleteMyAccountVC
            APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
        }
    }
}
