//
//  VerificationVC.swift
//  WakeUppApp
//
//  Created by Payal Umraliya on 21/03/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import TransitionButton

class VerificationVC: UIViewController, TwoStepVerification_SetPasswordVC_Delegate{
    
    
    @IBOutlet var lblphone: UILabel!
    @IBOutlet var btnproceed: TransitionButton!
    @IBOutlet var btnresend: UIButton!
    @IBOutlet var btnback: UIButton!
    @IBOutlet var txt1: UITextField!
    @IBOutlet var txt2: UITextField!
    @IBOutlet var txt4: UITextField!
    @IBOutlet var txt3: UITextField!
    
    var codesent:String!
    var code = String()
    var mobile = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    func setupUI()
    {
        //print("Verification Code Sent : " + codesent)
        code = UserDefaultManager.getStringFromUserDefaults(key:kAppUserCountryCode)
        mobile = UserDefaultManager.getStringFromUserDefaults(key:kAppUserMobile)
        
        lblphone.text = "+\(code) \(mobile)"
        
        txt1.delegate = self
        txt2.delegate = self
        txt3.delegate = self
        txt4.delegate = self
        
        txt1.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        txt2.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        txt3.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        txt4.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
    
        //FOR TESTING
        if UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile) == "9998887770" || UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile) == "7778889990" || UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile) == "7777777777" || UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile) == "7575757575"
        {
            txt1.text = String(codesent.charactersArray[0])
            txt2.text = String(codesent.charactersArray[1])
            txt3.text = String(codesent.charactersArray[2])
            txt4.text = String(codesent.charactersArray[3])
        }
        else
        {
            txt1.text = ""
            txt2.text = ""
            txt3.text = ""
            txt4.text = ""
        }

    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    @IBAction func btnproceedclicked(_ sender: Any) {
        
        if validateTxtFieldLength(txt1, withMessage: InvalidOTP) &&
            validateTxtFieldLength(txt2, withMessage: InvalidOTP) &&
            validateTxtFieldLength(txt3, withMessage: InvalidOTP) &&
            validateTxtFieldLength(txt4, withMessage: InvalidOTP) {
            let codeadded = "\(txt1.text!)\(txt2.text!)\(txt3.text!)\(txt4.text!)"
            self.api_VerifyOTP(codeadded)
        }
    }
    
    @IBAction func btnbackclicked(_ sender: Any) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnresendclicked(_ sender: Any) {
        self.api_ResendOTP()
    }
    
    //MARK:- 02-Step-Varification SetPassword Delegate method
    func getStatus_TwoStepVerificationSetPassword(TwoStepVarificationStatus: Bool?) {
        if (TwoStepVarificationStatus == true) {
            let registervc = loadVC(strStoryboardId: SB_MAIN, strVCId: idRegisterVC) as! RegisterVC
            APP_DELEGATE.appNavigation?.pushViewController(registervc, animated: true)
        }
        else {
            APP_DELEGATE.appNavigation?.popViewController(animated: false)
        }
    }
    
    //MARK:- API
    func api_VerifyOTP(_ code:String) {
        
        if isConnectedToNetwork() == false { return }
        
        let parameter:NSDictionary = ["service":APIVerifyUser,
                                      "request":["phoneno":mobile,
                                                 "code":code]]
        self.view.isUserInteractionEnabled = false
        self.btnproceed.startAnimation()
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIVerifyUser, parameters: parameter, keyname: "", message: APISocialLoginMessage, showLoader: false){
            (error,apistatus,statusmessage,responseArray,responseDict) in
            
            self.btnproceed.stopAnimation()
            self.view.isUserInteractionEnabled = true
            if error != nil
            {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_VerifyOTP(code)
                })
                return
            }
            else
            {
                if Int(apistatus) == 0
                {
                    showMessage(InvalidOTP)
                }
                else
                {
                    UserDefaultManager.setStringToUserDefaults(value: responseDict!["token"] as! String, key:kToken )
                    let data = responseDict!["data"] as! NSDictionary
                    UserDefaultManager.setStringToUserDefaults(value: data.object(forKey: "user_id")! as! String, key:kAppUserId )
                    
                    UserDefaultManager.setBooleanToUserDefaults(value: true, key: kAppVerified)
                    
                    //let registervc = loadVC(strStoryboardId: SB_MAIN, strVCId: idRegisterVC) as! RegisterVC
                    //APP_DELEGATE.appNavigation?.pushViewController(registervc, animated: true)
                    
                    let strTwoStepVarificationStatis : String = data.value(forKey: "is_two_step_verification") as! String
                    if (strTwoStepVarificationStatis.uppercased() == "1".uppercased()) {
                        let objVC : TwoStepVerification_SetPasswordVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idTwoStepVerification_SetPasswordVC) as! TwoStepVerification_SetPasswordVC
                        objVC.delegate = self
                        objVC.objEnumSetPassword = .enumSetPassword_VerifyPassword
                        objVC.strTwoStepVarificationPassword = data.value(forKey: "pin") as! String
                        //APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
                        self.present(objVC, animated: true, completion: nil)
                    }
                    else {
                        let registervc = loadVC(strStoryboardId: SB_MAIN, strVCId: idRegisterVC) as! RegisterVC
                        APP_DELEGATE.appNavigation?.pushViewController(registervc, animated: true)
                    }
                }
            }
            
        }
    }
    func api_ResendOTP()
    {
        
        let parameter:NSDictionary = ["service":APISendOTP,
                                      "request":["phoneno":mobile,
                                                 "country_code":code]]
        self.view.isUserInteractionEnabled = false
        self.btnproceed.startAnimation()
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APISendOTP, parameters: parameter, keyname: ResponseKey as NSString, message: APISocialLoginMessage, showLoader: false){
            (error,apistatus,statusmessage,responseArray,responseDict) in
            
            self.btnproceed.stopAnimation()
            self.view.isUserInteractionEnabled = true
            if error != nil
            {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_ResendOTP()
                })
                return
            }
            else
            {
                if Int(apistatus) == 0
                {
                    showMessage(statusmessage)
                }
                else
                {
                    if responseArray!.count > 0
                    {
                        self.codesent = responseArray![0] as! String
                        showMessage(statusmessage)
                    }
                    else
                    {
                        showMessage(statusmessage)
                    }
                }
            }
            
        }
    }
}
extension VerificationVC:UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 1
    }
    @objc func textFieldDidChange(textField: UITextField){
        
        let text = textField.text
        
        if text?.utf16.count==1
        {
            switch textField{
            case txt1:
                txt2.becomeFirstResponder()
            case txt2:
                txt3.becomeFirstResponder()
            case txt3:
                txt4.becomeFirstResponder()
            case txt4:
                txt4.resignFirstResponder()
            default:
                break
            }
        }
        else
        {
            switch textField{
            case txt2:
                txt1.becomeFirstResponder()
            case txt3:
                txt2.becomeFirstResponder()
            case txt4:
                txt3.becomeFirstResponder()
            default:
                break
            }
        }
    }
    
}

