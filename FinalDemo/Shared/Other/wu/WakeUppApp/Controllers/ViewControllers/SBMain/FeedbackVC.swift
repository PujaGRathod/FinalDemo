//
//  FeedbackVC.swift
//  WakeUppApp
//
//  Created by C025 on 28/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class FeedbackVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    //MARK: Outlet
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtMessage: IQTextView!
    @IBOutlet weak var lblMessageCount: UILabel!
    
    //MARK: -
    let totalMessLenth : Int = 130
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Custom Function
    func setupUI()  {
        self.txtTitle.delegate = self
        self.txtEmail.delegate = self
        self.txtMessage.delegate = self
        
        //Add Padding in TextFiled
        txtTitle.addPaddingLeft(8)
        txtEmail.addPaddingLeft(8)
        
        //Paceholder of TextView
        txtMessage.placeholder = " Your Feedback..."
    
        self.Manage_MessCharacterCount()
    }
    
    func Manage_MessCharacterCount() -> Void {
        var strCountMess : String = ""
        strCountMess = String(format: "%d", self.txtMessage.text.count)
        strCountMess += "/"
        strCountMess += String(format: "%d", totalMessLenth)
        self.lblMessageCount.text = strCountMess
    }
    
    //MARK: TextField Delegate method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        /*if textField == txtTitle {
            txtMessage.becomeFirstResponder()
        }*/
        
        if textField == txtTitle {
            txtEmail.becomeFirstResponder()
        }
        else if textField == txtEmail {
            txtMessage.becomeFirstResponder()
        }
        
        return true
    }
    
    //MARK: TextView Delegate method
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        /*//if (text == "\n") { //Working Id click Done button on Keybord
        if (self.txtMessage.text.count >= totalMessLenth) {
            textView.resignFirstResponder()
            return true
        }*/
        
        let flag : Bool = self.txtMessage.text.count + (text.count - range.length) <= totalMessLenth;
        return flag
    }
    func textViewDidChange(_ textView: UITextView) {
        self.Manage_MessCharacterCount()
    }
    
    //MARK: - Button action method
    @IBAction func btnBackAction() {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnSubmitAction() {
        //Validation
        //Title
        if (TRIM(string: txtTitle.text as Any).count == 0) {
            txtTitle.shake()
            showMessage("Please enter Feedback Title");
            return
        }
        
        //Email
        let strEmail : String = TRIM(string: txtEmail.text as Any)
        if (strEmail.count == 0) {
            txtEmail.shake()
            showMessage("Please enter email address");
            return
        }
        //Valid Email
        if (validateEmailAddress(self.txtEmail, withMessage: "Please enter valid email address")) == false {
            //txtTitle.shake()
            //showMessage("Please enter valid email address");
            return
        }
        
        //Biodata
        if (TRIM(string: txtMessage.text as Any).count == 0) {
            txtMessage.shake()
            showMessage("Please enter Feedback Message");
            return
        }
        
        //Called API for send Feedback
        self.api_AddFeedback()
    }

    //MARK:- API
    func api_AddFeedback() {
        self.view.endEditing(true)
        let parameter:NSDictionary = ["service":APIAddFeedback,
                                      "request":["data":[
                                        "subject": TRIM(string: txtTitle.text as Any),
                                        "email": TRIM(string: txtEmail.text as Any),
                                        "message":TRIM(string: txtMessage.text as Any)]],
                                      "auth" : getAuthForService()]
        self.view.isUserInteractionEnabled = false
        
        showHUD()
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIAddFeedback, parameters: parameter, keyname: "", message: APIAddFeedbackMessage, showLoader: true, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            
            self.view.isUserInteractionEnabled = true
            hideLoaderHUD()
            hideHUD()
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_AddFeedback()
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    //Reset From
                    self.txtTitle.text = ""
                    self.txtEmail.text = ""
                    self.txtMessage.text = ""
                    self.Manage_MessCharacterCount()
                    
                    //Back To Screen
                    self.btnBackAction()
                    
                    //Show Success Mess.
                    let strMessage: String = responseDict!.object(forKey: kMessage) as! String
                    showMessage(strMessage)
                }
            }
        })
    }
}
