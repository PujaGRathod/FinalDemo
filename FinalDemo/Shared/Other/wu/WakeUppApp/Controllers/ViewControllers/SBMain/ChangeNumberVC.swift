//
//  ChangeNumberVC.swift
//  WakeUppApp
//
//  Created by C025 on 15/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class ChangeNumberVC: UIViewController {
    //MARK: Outlet
    
    @IBOutlet weak var viewConfirmation: UIView!
    @IBOutlet weak var lc_viewConfirmation_x: NSLayoutConstraint!
    @IBOutlet weak var lblConfirmationMess: UILabel!
    @IBOutlet weak var btnConfirmationNext: UIButton!
    
    @IBOutlet weak var viewChangeNo: UIView!
    @IBOutlet weak var lc_viewChangeNo_x: NSLayoutConstraint!
    @IBOutlet weak var txtCountryCode_old: UITextField!
    @IBOutlet weak var txtMobileNo_old: UITextField!
    @IBOutlet weak var txtCountryCode_new: UITextField!
    @IBOutlet weak var txtMobileNo_new: UITextField!
    
    @IBOutlet weak var viewVarifyOTP: UIView!
    @IBOutlet weak var lc_viewVarifyOTP_x: NSLayoutConstraint!
    @IBOutlet weak var lblVarifyOTPMess: UILabel!
    @IBOutlet var txt1: UITextField!
    @IBOutlet var txt2: UITextField!
    @IBOutlet var txt3: UITextField!
    @IBOutlet var txt4: UITextField!
    @IBOutlet weak var btnResendOTP: UIButton!
    
    @IBOutlet weak var btnVarify: UIButton!
    
    
    //MARK: Variable
    var showView_Duration = 0.50 //Use for manage show and dismiss view nimation duration.
    var curretTextField : UITextField!
    var countyCode_old = String()
    var countyCode_new = String()
    var strUserAddedOTP : String = "" //Store User enter OTP
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        let UserPhone : String = UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)
        //print("UserPhone : \(UserPhone)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Custom function
    func setupUI() {
        self.view.disableKeybordWhenTapped = true
        
        //ChangeNumberView
        txtCountryCode_old.addPaddingLeftIcon(UIImage.init(named: "countrycode_textbox")!, padding: 15)
        txtMobileNo_old.addPaddingLeftIcon(UIImage.init(named: "mobile_textbox")!, padding: 15)
        txtCountryCode_old.delegate = self
        txtMobileNo_old.delegate = self
        
        txtCountryCode_new.addPaddingLeftIcon(UIImage.init(named: "countrycode_textbox")!, padding: 15)
        txtMobileNo_new.addPaddingLeftIcon(UIImage.init(named: "mobile_textbox")!, padding: 15)
        txtCountryCode_new.delegate = self
        txtMobileNo_new.delegate = self
        
        
        //ConfirmationView
        var strConfiMess : String = ""
        strConfiMess += "Changing your phone number will migrate your account into, group and settings."
        strConfiMess += "\n\nBefore proceeding, please confirm that you are able to receive SMS or calls at your new number."
        strConfiMess += "\n\nIf you both a new phone and a new number. First, change your number on your old phone."
        lblConfirmationMess.text = strConfiMess
        lblConfirmationMess.numberOfLines = 0
        lblConfirmationMess.sizeToFit()
        
        //Varify OTP View
        var strVarifyOTPMess : String = ""
        strVarifyOTPMess += "Please type a verification code send to"
        strVarifyOTPMess += "\n(\(countyCode_new)) \(TRIM(string: txtMobileNo_new.text!))"
        lblVarifyOTPMess.text = strVarifyOTPMess
        lblVarifyOTPMess.numberOfLines = 0
        
        //Manange TextFiled
        let arrTxt : NSArray = [txt1, txt2, txt3, txt4]
        for objTxt in arrTxt {
            (objTxt as! UITextField).delegate = self
            (objTxt as! UITextField).addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        }
        
        //Default Hide-OR-ChangePostion
        runAfterTime(time: 0.10) {
            self.lc_viewChangeNo_x.constant = SCREENHEIGHT() //Change Number View
            self.lc_viewVarifyOTP_x.constant = SCREENHEIGHT() //Varify OTP View
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: - Button action method
    @IBAction func btnBackAction() {
        if (self.lc_viewChangeNo_x.constant == 0) &&
            (self.lc_viewVarifyOTP_x.constant != 0) {
            UIView.animate(withDuration: showView_Duration) {
                self.lc_viewChangeNo_x.constant = SCREENWIDTH()
                self.view.layoutIfNeeded()
            }
        }
        else if (self.lc_viewVarifyOTP_x.constant == 0) {
            UIView.animate(withDuration: showView_Duration) {
                self.lc_viewVarifyOTP_x.constant = SCREENWIDTH()
                self.view.layoutIfNeeded()
            }
        }
        else {
            APP_DELEGATE.appNavigation?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnConfirmationNextAction() {
        UIView.animate(withDuration: showView_Duration) {
            self.lc_viewChangeNo_x.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func btnChangeNumberAction() {
        //Check Validation
        if (validateTxtFieldLength(txtCountryCode_old, withMessage: Enter_Old_CountryCode) &&
            validateTxtFieldLength(txtMobileNo_old, withMessage: Enter_Old_MobileNumber))
        {
            var strCountryCode_old : String = TRIM(string: countyCode_old)
            strCountryCode_old = strCountryCode_old.replacingOccurrences(of: "+", with: "")
            let strPhoneNo_Old : String = TRIM(string: txtMobileNo_old.text!)
            
            var UserCountryCode : String = UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode)
            UserCountryCode = UserCountryCode.replacingOccurrences(of: "+", with: "")
            let UserPhone : String = UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)
            
            if (UserCountryCode.uppercased() != strCountryCode_old.uppercased()) {
                showMessage("Invalid current country code")
                txtCountryCode_old.shake()
                return
            }
            if (UserPhone.uppercased() != strPhoneNo_Old.uppercased()) {
                showMessage("Invalid current phone number")
                txtMobileNo_old.shake()
                return
            }
            
            if (validateTxtFieldLength(txtCountryCode_new, withMessage: Enter_New_CountryCode) &&
                validateTxtFieldLength(txtMobileNo_new, withMessage: Enter_New_MobileNumber)) {
                
                //Check It's same number
                if (TRIM(string: txtMobileNo_new.text!).uppercased() == strPhoneNo_Old.uppercased()) {
                    showMessage("Old number and new number are same.")
                    txtMobileNo_old.shake()
                    txtMobileNo_new.shake()
                    return
                }
                
                //Called API Send OTP
                self.btnReSendCodeAction()
            }
        }
    }
    
    @IBAction func btnReSendCodeAction() {
        
        var strCountryCode_new : String = TRIM(string: countyCode_new)
        strCountryCode_new = strCountryCode_new.replacingOccurrences(of: "+", with: "")
        
        
        //Called API
        let parameter:NSDictionary = ["service":APIChangeNumber_SendOTP,
                                      "request":
                                        ["phoneno":TRIM(string: self.txtMobileNo_new.text!),
                                         "country_code":strCountryCode_new,
                                         "old_phone":TRIM(string: self.txtMobileNo_old.text!)], 
            "auth" : getAuthForService()]
        //print("APIChangeNumber_SendOTP parameter: \(parameter)")
        self.api_ChangePhoneNumber_SendOTP(parameter: parameter)
    }
    
    @IBAction func btnVarifyOTPAction() {
        if (validateTxtFieldLength(txt1, withMessage: InvalidOTP) &&
            validateTxtFieldLength(txt2, withMessage: InvalidOTP) &&
            validateTxtFieldLength(txt3, withMessage: InvalidOTP) &&
            validateTxtFieldLength(txt4, withMessage: InvalidOTP)) {
            let arrPassword : NSArray = [TRIM(string: self.txt1.text!),
                                         TRIM(string: self.txt2.text!),
                                         TRIM(string: self.txt3.text!),
                                         TRIM(string: self.txt4.text!)]
            let strEnterOTP : String = arrPassword.componentsJoined(by: "")
            
            //Called API
            let parameter:NSDictionary = ["service":APIChangeNumber_VerficationByOTP,
                                          "request":[
                                            //"old_phone":TRIM(string: self.txtMobileNo_old.text!),
                                            "phoneno":TRIM(string: txtMobileNo_new.text!),
                                            "code":strEnterOTP],
                                          "auth" : getAuthForService()]
            //print("APIChangeNumber_VerficationByOTP parameter: \(parameter)")
            self.api_ChangePhoneNumber_VerficationByOTP(parameter: parameter)
        }
    }
    
    //MARK: - API
    func api_ChangePhoneNumber_SendOTP(parameter : NSDictionary)
    {
        self.view.endEditing(true)
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIChangeNumber_SendOTP, parameters: parameter, keyname: "", message: "", showLoader: true) {
            (error,apistatus,statusmessage,responseArray,responseDict) in
            
            hideLoaderHUD()
            hideMessage()
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_ChangePhoneNumber_SendOTP(parameter: parameter)
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    let strReceivedOTP : String = responseDict?.value(forKey: kCode) as! String
                    if strReceivedOTP.count == 0 {
                        showMessage(statusmessage)
                        return
                    }
                    
                    var strVarifyOTPMess : String = ""
                    strVarifyOTPMess += "Please type a verification code send to"
                    strVarifyOTPMess += "\n(\(self.countyCode_new)) \(TRIM(string: self.txtMobileNo_new.text!))"
                    self.lblVarifyOTPMess.text = strVarifyOTPMess
                    self.lblVarifyOTPMess.numberOfLines = 0
                    
                    //Show Varify OTP View
                    if (self.lc_viewVarifyOTP_x.constant != 0) {
                        UIView.animate(withDuration: self.showView_Duration) {
                            self.lc_viewVarifyOTP_x.constant = 0
                            self.view.layoutIfNeeded()
                        }
                    }
                }
            }
        }
    }
    
    func api_ChangePhoneNumber_VerficationByOTP(parameter : NSDictionary) {
        self.view.endEditing(true)
        self.view.isUserInteractionEnabled = false
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIChangeNumber_VerficationByOTP, parameters: parameter, keyname: "", message: "", showLoader: true) {
            (error,apistatus,statusmessage,responseArray,responseDict) in
            
            hideLoaderHUD()
            hideMessage()
            self.view.isUserInteractionEnabled = true
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_ChangePhoneNumber_VerficationByOTP(parameter: parameter)
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    showMessage(statusmessage)
                    
                    let dicData : NSDictionary = responseDict?.value(forKey: kData) as! NSDictionary
                    if dicData.allKeys.count == 0 { return }
                    
                    //Update PhoneNumber in UserDefault
                    UserDefaultManager.setStringToUserDefaults(value: TRIM(string: self.txtMobileNo_new.text!), key: kAppUserMobile)
                    
                    //APP_DELEGATE.appNavigation?.popToRootViewController(animated: true) //Back to RootVC
                    APP_DELEGATE.appNavigation?.popViewController(animated: true) //Back to ViewController
                }
            }
        }
    }
}

extension ChangeNumberVC : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.txtCountryCode_old {
            self.curretTextField = self.txtCountryCode_old
            
            self.view.endEditing(true)
            let countyvc = loadVC(strStoryboardId: SB_MAIN, strVCId: idCountrypickerVC) as! SRCountryPickerController
            countyvc.countryDelegate = self
            APP_DELEGATE.appNavigation?.pushViewController(countyvc, animated: true)
            return false
        }
        else if textField == self.txtCountryCode_new {
            self.curretTextField = self.txtCountryCode_new
            
            self.view.endEditing(true)
            let countyvc = loadVC(strStoryboardId: SB_MAIN, strVCId: idCountrypickerVC) as! SRCountryPickerController
            countyvc.countryDelegate = self
            APP_DELEGATE.appNavigation?.pushViewController(countyvc, animated: true)
            return false
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        switch textField {
        case txt1, txt2, txt3, txt4:
            guard let text = textField.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 1
        //break
        default:
            return true
            //break
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        let text = textField.text
        if text?.utf16.count == 1 {
            switch textField {
            case txt1:
                txt2.becomeFirstResponder()
                break
            case txt2:
                txt3.becomeFirstResponder()
                break
            case txt3:
                txt4.becomeFirstResponder()
                break
            case txt4:
                break
            default:
                break
            }
        }
        else {
            switch textField {
            case txt2:
                txt1.becomeFirstResponder()
                break
            case txt3:
                txt2.becomeFirstResponder()
                break
            case txt4:
                txt3.becomeFirstResponder()
                break
            default:
                break
            }
        }
    }
}

extension ChangeNumberVC: CountrySelectedDelegate {
    func SRcountrySelected(countrySelected country: Country) {
        if self.curretTextField == self.txtCountryCode_old {
            self.txtCountryCode_old.text = country.country_name + " (" + country.dial_code + ")"
            self.countyCode_old = country.dial_code
        }
        else if self.curretTextField == self.txtCountryCode_new {
            self.txtCountryCode_new.text = country.country_name + " (" + country.dial_code + ")"
            self.countyCode_new = country.dial_code
        }
    }
}

