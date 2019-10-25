//
//  TwoStepVerificationVC.swift
//  WakeUppApp
//
//  Created by C025 on 16/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class TwoStepVerificationVC: UIViewController, UITextFieldDelegate, TwoStepVerification_SetPasswordVC_Delegate {
    
    //MARK: Outlet
    @IBOutlet weak var viewEnableNow: UIView!
    @IBOutlet weak var lblEnableMess: UILabel!
    @IBOutlet weak var btnEnable: UIButton!
    
    @IBOutlet weak var viewDisableNow: UIView!
    @IBOutlet weak var lblDisableMess: UILabel!
    
    //MARK: Variable
    var showView_Duration = 0.50 //Use for manage show and dismiss view animation duration.
    var twoStepVarification_status : Bool = false
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.layoutUI()
        self.manage_ShowView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: - Custom Function
    func layoutUI() {
        //Enable View--- --->
        lblEnableMess.text = "For added security, enable two-step verification, which will require a PIN when registering your phone number with \(APPNAME) again"
        lblEnableMess.numberOfLines = 0
        
        btnEnable.cornerRadius = 10
        
        //Disable View--- --->
        lblDisableMess.text = "Two-step verification is enabled. You’ll need to enter your PIN when registering your phone number with \(APPNAME) again"
        lblDisableMess.numberOfLines = 0
    }
    
    func manage_ShowView() {
        viewEnableNow.isHidden = true
        viewDisableNow.isHidden = true
        if (twoStepVarification_status == true) {
            viewDisableNow.isHidden = false
        }
        else {
            viewEnableNow.isHidden = false
        }
    }
    
    //MARK:- 02-Step-Varification SetPassword Delegate method
    func getStatus_TwoStepVerificationSetPassword(TwoStepVarificationStatus: Bool?) {
        self.twoStepVarification_status = TwoStepVarificationStatus!
        self.manage_ShowView()
    }
    
    //MARK: - Button action method
    @IBAction func btnBackAction() {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnEnableAction() {
        let objVC : TwoStepVerification_SetPasswordVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idTwoStepVerification_SetPasswordVC) as! TwoStepVerification_SetPasswordVC
        objVC.delegate = self
        objVC.objEnumSetPassword = .enumSetPassword_AddPassword
        APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
    }
    
    @IBAction func btnDisableAction() {
        let alert = UIAlertController(title: "Are you sure you want to disable two-step verification?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in
            //---> Manage Action
        }))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            //Set Parameter for called API
            let parameter:NSDictionary = ["service":APIUpdateUserSettings,
                                          "request": ["action":"is_two_step_verification",
                                                      "value":"0"],
                                          "auth" : getAuthForService()]
            //print("APIUpdateUserSettings parameter: \(parameter)")
            APP_DELEGATE.api_UpdateUserSettings(parameter: parameter)
            
            //Change Values in UserDefault
            UserDefaultManager.setStringToUserDefaults(value: "0", key: kIsTwoStepVerification)
            
            self.twoStepVarification_status = false
            self.manage_ShowView()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnChangePinAction() {
        
        let objVC : TwoStepVerification_SetPasswordVC = loadVC(strStoryboardId: SB_MAIN, strVCId:idTwoStepVerification_SetPasswordVC) as! TwoStepVerification_SetPasswordVC
        objVC.delegate = self
        objVC.objEnumSetPassword = .enumSetPassword_AddPassword
        objVC.TwoStepVarificationPasswordChange = true
        APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
    }
}

