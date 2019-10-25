
//
//  TwoStepVerification_SetPasswordVC.swift
//  WakeUppApp
//
//  Created by C025 on 18/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

enum enumSetPassword : Int {
    case enumSetPassword_None = 0
    case enumSetPassword_AddPassword
    case enumSetPassword_ConfirmPassword
    case enumSetPassword_Done
    case enumSetPassword_VerifyPassword //Manage if User login 2nd time login into application and 02-Step-Varification is allowed.
}

protocol TwoStepVerification_SetPasswordVC_Delegate : AnyObject {
    func getStatus_TwoStepVerificationSetPassword(TwoStepVarificationStatus: Bool?) -> Void
}

class TwoStepVerification_SetPasswordVC: UIViewController {
    
    weak var delegate: TwoStepVerification_SetPasswordVC_Delegate?
    
    @IBOutlet weak var btnBack: UIButton!
    
    //MARK: Outlet
    @IBOutlet weak var viewEnableDone: UIView!
    @IBOutlet weak var lblEnableDoneMess: UILabel!
    @IBOutlet weak var btnEnableDone: UIButton!
    
    @IBOutlet weak var viewSetPassword: UIView!
    @IBOutlet weak var lblSetPasswordMess: UILabel!
    @IBOutlet var txt1: UITextField!
    @IBOutlet var txt2: UITextField!
    @IBOutlet var txt3: UITextField!
    @IBOutlet var txt4: UITextField!
    @IBOutlet var txt5: UITextField!
    @IBOutlet var txt6: UITextField!
    @IBOutlet weak var btnNext: UIButton!
    
    //MARK: Variable
    var objEnumSetPassword : enumSetPassword = .enumSetPassword_None //For manage Password Fill status
    var strNewPassword : String = "" //Store User enter new password
    var strConfirmPassword : String = "" //Store User enter confirm password
    
    var strTwoStepVarificationPassword : String = "" //Store User enter confirm password
    var TwoStepVarificationPasswordChange : Bool = false //User for check PIN change or not
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.manage_SetPasswordView() //Set Password View
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Custom Function
    func setupUI() {
        
        //Set Title
        var strTitle : String = "Two-step Variication"
        strTitle = self.TwoStepVarificationPasswordChange == true ? "Change PIN" : strTitle
        self.btnBack.setTitle(strTitle, for: .normal)
        
        //--- --- --- --- --- --- --- --- --->
        //EnableDone View
        lblEnableDoneMess.text = "Two-step verification is enabled."
        lblEnableDoneMess.numberOfLines = 0
        
        btnEnableDone.cornerRadius = 10
        
        //--- --- --- --- --- --- --- --- --->
        //Set Password View
        lblSetPasswordMess.text = ""
        lblSetPasswordMess.numberOfLines = 0
        
        btnNext.cornerRadius = 10
        
        //Manange TextFiled
        let arrTxt : NSArray = [txt1, txt2, txt3, txt4, txt5, txt6]
        for objTxt in arrTxt {
            (objTxt as! UITextField).delegate = self
            (objTxt as! UITextField).addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        }
    }
    
    //Set Password View
    func manage_SetPasswordView() -> Void {
        viewEnableDone.isHidden = true
        viewSetPassword.isHidden = true
        
        var strSetPassMess : String = ""
        switch objEnumSetPassword {
        case .enumSetPassword_None:
            break
            
        case .enumSetPassword_AddPassword:
            viewSetPassword.isHidden = false
            strSetPassMess = "Enter a 06-digit PIN which you’ll be asked for when you register your phone number with \(APPNAME):"
            break
            
        case .enumSetPassword_ConfirmPassword:
            viewSetPassword.isHidden = false
            strSetPassMess = "Confirm your PIN:"
            break
            
        case .enumSetPassword_Done:
            viewEnableDone.isHidden = false
            if (self.TwoStepVarificationPasswordChange == true) {
                self.lblEnableDoneMess.text = "PIN change successfully."
            }
            else {
                self.lblEnableDoneMess.text = "Two-step verification is enabled."
            }
            break
        case .enumSetPassword_VerifyPassword:
            viewSetPassword.isHidden = false
            strSetPassMess = "Enter a 06-digit PIN which you’ll be allowed two-step verification when you register your phone number with \(APPNAME):"
            break
        }
        
        //--- --- --- --- --- --- --- --- --->
        //Set title of Password View
        lblSetPasswordMess.text = strSetPassMess
    }
    
    func manage_Validation() -> Bool {
        let arrPassword : NSArray = [TRIM(string: self.txt1.text!),
                                     TRIM(string: self.txt2.text!),
                                     TRIM(string: self.txt3.text!),
                                     TRIM(string: self.txt4.text!),
                                     TRIM(string: self.txt5.text!),
                                     TRIM(string: self.txt6.text!)]
        let strEnterPass : String = arrPassword.componentsJoined(by: "")
        var strEnterPassErrorMess : String!
        
        switch objEnumSetPassword {
        case .enumSetPassword_AddPassword:
            self.strNewPassword = strEnterPass
            strEnterPassErrorMess = "Please enter 06-digit PIN"
            
            if (strEnterPass.count != 6) {
                showMessage(strEnterPassErrorMess)
                return false
            }
            break
            
        case .enumSetPassword_ConfirmPassword:
            self.strConfirmPassword = strEnterPass
            
            strEnterPassErrorMess = "Please re-enter your 06 digit PIN"
            if (strEnterPass.count != 6) {
                showMessage(strEnterPassErrorMess)
                return false
            }
            if (self.strConfirmPassword != self.strNewPassword) {
                showMessage("Confirm Password mismatch")
                return false
            }
            break
        case .enumSetPassword_VerifyPassword:
            self.strNewPassword = strEnterPass
            strEnterPassErrorMess = "Please enter your 06-digit PIN"
            if (strEnterPass.count != 6) {
                showMessage(strEnterPassErrorMess)
                return false
            }
            break
        case .enumSetPassword_None:
            break
        case .enumSetPassword_Done:
            break
        }
        return true
    }
    
    //MARK: - Button action method
    @IBAction func btnBackAction() {
        //APP_DELEGATE.appNavigation?.popViewController(animated: true)
        
        if (self.objEnumSetPassword == .enumSetPassword_VerifyPassword) {
            self.delegate?.getStatus_TwoStepVerificationSetPassword(TwoStepVarificationStatus: false)
            self.dismiss(animated: true, completion: nil)
        }
        else {
            APP_DELEGATE.appNavigation?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnNextAction() {
        
        //Check Validation
        if (self.manage_Validation() == false) { return }
        
        switch objEnumSetPassword {
        case .enumSetPassword_None:
            break
            
        case .enumSetPassword_AddPassword:
            self.txt1.text = ""
            self.txt2.text = ""
            self.txt3.text = ""
            self.txt4.text = ""
            self.txt5.text = ""
            self.txt6.text = ""
            self.objEnumSetPassword = .enumSetPassword_ConfirmPassword
            self.manage_SetPasswordView()
            
            txt1.becomeFirstResponder()
            break
            
        case .enumSetPassword_ConfirmPassword:
            self.view.endEditing(true) // Hide Keyboard
            
            //Set Parameter for called API - Enable TwoStepVarification
            let parameter:NSDictionary = ["service":APIUpdateUserSettings,
                                          "request": ["action":"is_two_step_verification",
                                                      "value":"1"],
                                          "auth" : getAuthForService()]
            //print("APIUpdateUserSettings parameter: \(parameter)")
            APP_DELEGATE.api_UpdateUserSettings(parameter: parameter)
            
            //Set Parameter for called API - Set TwoStepVarification Password
            let parameter_pin:NSDictionary = ["service":APIUpdateUserSettings,
                                              "request": ["action":"pin",
                                                          "value":self.strConfirmPassword],
                                              "auth" : getAuthForService()]
            //print("APIUpdateUserSettings parameter: \(parameter_pin)")
            APP_DELEGATE.api_UpdateUserSettings(parameter: parameter_pin)
            
            //Change Values in UserDefault
            UserDefaultManager.setStringToUserDefaults(value: "1" , key: kIsTwoStepVerification)
            
            self.objEnumSetPassword = .enumSetPassword_Done
            self.manage_SetPasswordView()
            break
            
        case .enumSetPassword_Done:
            break
        case .enumSetPassword_VerifyPassword:
            if (self.strTwoStepVarificationPassword.uppercased() == self.strNewPassword.uppercased()) {
                self.delegate?.getStatus_TwoStepVerificationSetPassword(TwoStepVarificationStatus: true)
                self.dismiss(animated: true, completion: nil)
            }
            else {
                showMessage("Invalid Password!")
            }
            break
        }
    }
    
    @IBAction func btnEnableDoneAction() {
        //Set UserDefault Value Change
        UserDefaultManager.setStringToUserDefaults(value: "1", key: kIsTwoStepVerification)
        
        self.delegate?.getStatus_TwoStepVerificationSetPassword(TwoStepVarificationStatus: true)
        self.btnBackAction()
    }
}

extension TwoStepVerification_SetPasswordVC:UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 1
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        let text = textField.text
        if text?.utf16.count == 1 {
            switch textField {
            case txt1:
                txt2.becomeFirstResponder()
            case txt2:
                txt3.becomeFirstResponder()
            case txt3:
                txt4.becomeFirstResponder()
            case txt4:
                txt5.becomeFirstResponder()
            case txt5:
                txt6.becomeFirstResponder()
            case txt6:
                //txt6.resignFirstResponder()
                break
            default:
                break
            }
        }
        else {
            switch textField {
            case txt2:
                txt1.becomeFirstResponder()
            case txt3:
                txt2.becomeFirstResponder()
            case txt4:
                txt3.becomeFirstResponder()
            case txt5:
                txt4.becomeFirstResponder()
            case txt6:
                txt5.becomeFirstResponder()
            default:
                break
            }
        }
    }
}

