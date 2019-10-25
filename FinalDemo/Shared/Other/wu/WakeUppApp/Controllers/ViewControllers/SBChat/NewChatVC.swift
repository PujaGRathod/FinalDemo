//
//  NewChatVC.swift
//  WakeUppApp
//
//  Created by Admin on 28/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class NewChatVC: UIViewController {

    @IBOutlet weak var lbltitle: UILabel!
    @IBOutlet weak var txtCode: UITextField!
    @IBOutlet weak var txtMobile: UITextField!
    var redirectfrom = ""
    var countyCode = "91"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtCode.text = "India" + " (+91)"
        if redirectfrom == "DeleteChat"
        {
            lbltitle.text = "Enter your phone number:"
        }
        else
        {
            lbltitle.text = "New Chat"
        }
        layoutUI()
    }
    
    func layoutUI(){
        txtCode.addPaddingLeftIcon(UIImage.init(named: "countrycode_textbox")!, padding: 15)
        txtMobile.addPaddingLeftIcon(UIImage.init(named: "mobile_textbox")!, padding: 15)
        txtCode.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.50) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
        UIApplication.shared.statusBarView?.backgroundColor = .clear
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnSubmitClicked(_ sender: Any) {
        if validateTxtFieldLength(txtCode, withMessage: CodeSelect) &&
            validateTxtFieldLength(txtMobile, withMessage: EnterMobileNumber) {
            
            let strCountryCode : String = countyCode
            let strPhoneNo : String = txtMobile.text!
            var strFullPhoneNo : String = "\(strCountryCode)\(strPhoneNo)"
            strFullPhoneNo = TRIM(string: strFullPhoneNo)
            
            var strCurrentUserPhoneNo : String = UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode)
            strCurrentUserPhoneNo += UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)
            strCurrentUserPhoneNo = TRIM(string: strCurrentUserPhoneNo)
            
          
            if redirectfrom == "DeleteChat"
            {
                self.view.endEditing(true)
                if (strFullPhoneNo == strCurrentUserPhoneNo)
                {
                    showStatusBarMessage("Deleting...")
                    CoreDBManager.sharedDatabase.deleteAllMessageFromLocalDB()
                    CoreDBManager.sharedDatabase.deleteAllGroupMessageFromLocalDB()
                    CoreDBManager.sharedDatabase.deleteAllFriendsFromLocalDB()
                    let URL_dirCurrentChat : URL = getURL_Chat_Directory()
                    runAfterTime(time: 0.10, block: {
                        let arrContent = getAllContent(inDirectoryURL: URL_dirCurrentChat)
                        for filePath : URL in arrContent {
                            removeFile_onURL(fileURL: filePath)
                        }
                    })
                    let URL_dirCurrentChat2 : URL = getURL_Group_Directory()
                    runAfterTime(time: 0.20, block: {
                        let arrContent = getAllContent(inDirectoryURL: URL_dirCurrentChat2)
                        for filePath : URL in arrContent {
                            removeFile_onURL(fileURL: filePath)
                        }
                    })
                    showMessage("Deleted successfully")
                     closeVC()
                }
                else
                {
                     showAlertMessage("The number you entered does not match with your account.", okButtonTitle: "Cancel")
                }
            }
            else
            {
                if (strFullPhoneNo == strCurrentUserPhoneNo) {
                    showAlertMessage("You don't chat with own number", okButtonTitle: "Cancel")
                    return
                }
                self.apiCheckUser()
            }
           
        }
    }
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        closeVC()
    }
    
    @objc func closeVC() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.backgroundColor = .clear
        }) { (finished) in
            UIApplication.shared.statusBarView?.backgroundColor = themeWakeUppColor
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func apiCheckUser() {
        self.view.endEditing(true)
        let parameter:NSDictionary = ["service":APICheckUserExistsWithPhone,
                                      "request":[
                                        "phoneno":"\(txtMobile.text!)",
                                        "countrycode" : "\(countyCode)"],
                                      "auth" : getAuthForService()
        ]
        
        showHUD()

        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APICheckUserExistsWithPhone, parameters: parameter, keyname: ResponseKey as NSString, message: APICheckUserWithPhoneMessage, showLoader: false){ (error,apistatus,statusmessage,responseArray,responseDict) in
            
            hideHUD()
            
            if error != nil{
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.apiCheckUser()
                })
                return
            }
            else {
                if apistatus == "0"{
                    showMessage("User not found")
                }else{
                    let user = responseArray?.firstObject! as! User
                    let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: idChatVC) as! ChatVC
                    vc.selecteduserid = user.userId
                    vc.calledfrom = "messages"
                    vc.username = user.fullName!
                    
                    var dictionary = [String:String]()
                    dictionary["id"] = user.userId
                    dictionary["createddate"] = user.creationDatetime
                    dictionary["platform"] = user.platform
                    dictionary["textmessage"] = ""
                    dictionary["receiverid"] = ""
                    dictionary["senderid"] = user.userId
                    dictionary["sendername"] = user.fullName
                    dictionary["isdeleted"] = "0"
                    dictionary["isread"] = "0"
                    dictionary["mediaurl"] = ""
                    dictionary["messagetype"] = "0"
                    dictionary["chatid"] = "0"
                    dictionary["image"] = user.imagePath
                    dictionary["is_online"] = user.isOnline
                    dictionary["last_login"] = user.lastLogin
                    dictionary["username"] = user.fullName
                    dictionary["user_id"] = ""
                    dictionary["muted_by_me"] = user.mutedByMe
                    dictionary["country_code"] = user.countryCode
                    dictionary["phoneno"] = user.phoneno
                    dictionary["blocked_contacts"] = user.blockedContacts
                    dictionary["parent_id"] = ""
                    dictionary["ishidden"] = "0"
                    
                    vc.selectedUser = StructChat.init(dictionary: dictionary)
                    
                    self.closeVC()
                    APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
                }
                print(responseDict!)
            }
        }
    }
    
}

extension NewChatVC : UITextFieldDelegate
{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if textField == self.txtCode
        {
            self.view.endEditing(true)
            let countyvc = loadVC(strStoryboardId: SB_MAIN, strVCId: idCountrypickerVC) as! SRCountryPickerController
            countyvc.countryDelegate = self
            self.navigationController?.pushViewController(countyvc, animated: true)
            return false
        }
        return true
    }
}
extension NewChatVC: CountrySelectedDelegate
{
    func SRcountrySelected(countrySelected country: Country)
    {
        self.txtCode.text = country.country_name + " (" + country.dial_code + ")"
        self.countyCode = country.dial_code.replacingOccurrences(of: "+", with: "")
    }
}
