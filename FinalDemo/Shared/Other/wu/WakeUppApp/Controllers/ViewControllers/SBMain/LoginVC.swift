//
//  LoginVC.swift
//  WakeUppApp
//
//  Created by Payal Umraliya on 21/03/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import TransitionButton


class LoginVC: UIViewController {
    
    var countyCode = "91"
    
    @IBOutlet var lblPrivacyPolicy: UILabel! 
    @IBOutlet var btnproceed: TransitionButton!
    @IBOutlet var btnterms: UIButton!
    @IBOutlet var txtcode: UITextField!
    @IBOutlet var txtmobile: UITextField!
    
    let key_TermsAndConditions : String = "Terms and Conditions"
    let key_PrivacyPolicy : String = "Privacy Policy"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        txtcode.text = "India" + " (+91)"
        
        UserDefaultManager.clearUserdefaullts()
    }
    
    func setupUI()
    {
        self.view.disableKeybordWhenTapped = true
        txtcode.addPaddingLeftIcon(UIImage.init(named: "countrycode_textbox")!, padding: 15)
        txtmobile.addPaddingLeftIcon(UIImage.init(named: "mobile_textbox")!, padding: 15)
        txtcode.delegate = self
        
        
        btnterms.isHidden = true
        self.setup_PrivacyPolicy_and_TermsOfUse()
    }
    
    func setup_PrivacyPolicy_and_TermsOfUse() {
        /*//More Help : https://samwize.com/2016/03/04/how-to-create-multiple-tappable-links-in-a-uilabel/
         
         let string = "By Signing up, you agree to the \(key_TermsAndConditions) & \(key_PrivacyPolicy)"
         lblPrivacyPolicy.text = string
         let attriString = NSMutableAttributedString(string: string)
         let attributes = [//kCTForegroundColorAttributeName: UIColor.lightGray,
         kCTForegroundColorAttributeName : Color_Hex(hex: "#1FC797"),
         NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue] as [AnyHashable : Any]
         
         let range1 = (string as NSString).range(of: key_TermsAndConditions)
         //attriString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: range1)
         attriString.addAttributes(attributes as! [NSAttributedStringKey : Any], range: range1)
         
         let range2 = (string as NSString).range(of: key_PrivacyPolicy)
         //attriString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: range2)
         attriString.addAttributes(attributes as! [NSAttributedStringKey : Any], range: range2)
         
         lblPrivacyPolicy.attributedText = attriString*/
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapLabel(sender:)))
        tap.numberOfTapsRequired = 1
        self.lblPrivacyPolicy.isUserInteractionEnabled = true
        self.lblPrivacyPolicy.addGestureRecognizer(tap)
    }
    
    @objc func tapLabel(sender: UITapGestureRecognizer) {
        //nho set user interactive cho term
        let text = (lblPrivacyPolicy.text)!
        let termsRange = (text as NSString).range(of: key_TermsAndConditions)
        let privacyRange = (text as NSString).range(of: key_PrivacyPolicy)
        
        if sender.didTapAttributedTextInLabel(label: lblPrivacyPolicy, inRange: termsRange) {
            //print("Tapped : \(key_TermsAndConditions)")
            
            let objVC : WebviewVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idWebviewVC) as! WebviewVC
            objVC.strTitle = key_TermsAndConditions
            objVC.strURL = URL_TermsOfUse
            APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
        } else if sender.didTapAttributedTextInLabel(label: lblPrivacyPolicy, inRange: privacyRange) {
            //print("Tapped : \(key_PrivacyPolicy)")
            
            let objVC : WebviewVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idWebviewVC) as! WebviewVC
            objVC.strTitle = key_PrivacyPolicy
            objVC.strURL = URL_PrivacyPolicy
            APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
        } else {
            //print("Tapped : none")
        }
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    @IBAction func btntermsclicked(_ sender: Any)
    {
    }
    @IBAction func btnproceedclicked(_ sender: Any)
    {
        self.view.endEditing(true) //PV
        
        if validateTxtFieldLength(txtcode, withMessage: CodeSelect) &&
            validateTxtFieldLength(txtmobile, withMessage: EnterMobileNumber) {
            //self.api_sendOTP()
            
            //PV
            let confirmAlert = UIAlertController.init(title: "We will be verifying the mobile number" , message: "\n\n+\(self.countyCode) \(self.txtmobile.text ?? "")\n\nIs this OK, or would you like to edit the number?", preferredStyle: .alert)
            let attWithMedia = UIAlertAction.init(title: "EDIT".uppercased(), style: .default) { (action) in
                self.txtmobile.becomeFirstResponder()
            }
            confirmAlert.addAction(attWithMedia)
            
            let attWithoutMedia = UIAlertAction.init(title: "OK".uppercased(), style: .default) { (action) in
                self.api_sendOTP()
            }
            confirmAlert.addAction(attWithoutMedia)
            
            self.present(confirmAlert, animated: true, completion: nil)
        }
    }
    
    //MARK:- API
    func api_Login()
    {
        self.view.endEditing(true)
        let parameter:NSDictionary = ["service":APILogin,
                                      "request":["data":[
                                        "phoneno":txtmobile.text!,
                                        "platform":PlatformName,
                                        "device_id":GetDeviceToken]]]
        
        self.view.isUserInteractionEnabled = false
        self.btnproceed.startAnimation()
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APILogin, parameters: parameter, keyname: ResponseKey as NSString, message: APISocialLoginMessage, showLoader: false){ (error,apistatus,statusmessage,responseArray,responseDict) in
            
            self.btnproceed.stopAnimation()
            self.view.isUserInteractionEnabled = true
            
            if error != nil
            {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_Login()
                })
                return
            }
            else
            {
                if Int(apistatus) == 0
                {
                    self.api_sendOTP()
                }
                else
                {
                    let homevc = loadVC(strStoryboardId: SB_CHAT, strVCId: idChatListVC) as! ChatListVC
                    APP_DELEGATE.appNavigation?.pushViewController(homevc, animated: true)
                }
            }
        }
    }
    func api_sendOTP()
    {
        if isConnectedToNetwork() == false { return }
        
        let parameter:NSDictionary = ["service":APISendOTP,
                                      "request":["phoneno":txtmobile.text!,
                                                 "country_code":self.countyCode.replacingOccurrences(of: "+", with: "")]]
        self.view.isUserInteractionEnabled = false
        self.btnproceed.startAnimation()
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APISendOTP, parameters: parameter, keyname: ResponseKey as NSString, message: APISocialLoginMessage, showLoader: false){
            (error,apistatus,statusmessage,responseArray,responseDict) in
            
            self.btnproceed.stopAnimation()
            self.view.isUserInteractionEnabled = true
            if error != nil
            {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_sendOTP()
                })
                self.btnproceed.stopAnimation()
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
                        UserDefaultManager.setStringToUserDefaults(value: self.txtmobile.text!, key: kAppUserMobile)
                        UserDefaultManager.setStringToUserDefaults(value: self.countyCode.replacingOccurrences(of: "+", with: ""), key: kAppUserCountryCode)
                        let verify = loadVC(strStoryboardId: SB_MAIN, strVCId: idVerificationVC) as! VerificationVC
                        verify.codesent = responseArray![0] as! String
                        
                        APP_DELEGATE.appNavigation?.pushViewController(verify, animated: true)
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
extension LoginVC : UITextFieldDelegate
{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if textField == self.txtcode
        {
            self.view.endEditing(true)
            let countyvc = loadVC(strStoryboardId: SB_MAIN, strVCId: idCountrypickerVC) as! SRCountryPickerController
            countyvc.countryDelegate = self
            APP_DELEGATE.appNavigation?.pushViewController(countyvc, animated: true)
            return false
        }
        return true
    }
}
extension LoginVC: CountrySelectedDelegate
{
    func SRcountrySelected(countrySelected country: Country)
    {
        self.txtcode.text = country.country_name + " (" + country.dial_code + ")"
        self.countyCode = country.dial_code
    }
}


// Manage lblPrivacyPolicy TapGesture detect particuler word pass in arrgugement
extension  UITapGestureRecognizer  {
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}

