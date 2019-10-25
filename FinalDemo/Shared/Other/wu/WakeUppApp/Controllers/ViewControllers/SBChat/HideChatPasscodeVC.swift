//
//  HideChatPasscodeVC.swift
//  WakeUppApp
//
//  Created by Admin on 25/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import CoreData
import Zip
import LocalAuthentication
class HideChatPasscodeVC: UIViewController {
    
    @IBOutlet weak var lbltouchid: UILabel!
    @IBOutlet weak var vwheight: NSLayoutConstraint!
    @IBOutlet weak var vwContainerToTop: NSLayoutConstraint!
    @IBOutlet weak var btntouch: UIButton!
    @IBOutlet weak var vwContainer: UIView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblNote: UILabel!
    
    @IBOutlet weak var vwTextFields: UIView!
    @IBOutlet weak var txt1: UITextField!
    @IBOutlet weak var txt2: UITextField!
    @IBOutlet weak var txt3: UITextField!
    @IBOutlet weak var txt4: UITextField!
    
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var btnForgotPin: UIButton!
    @IBOutlet weak var btnResendOTP: UIButton!
    
    var originalContainerToTop:CGFloat = 0.0
    let modifiedContainerToTop:CGFloat = -700
    
    var isQuickSetupClicked = false
    
    var failedAttepts = 0
    
    var quickSetupAssignedPin1 = ""
    var quickSetupAssignedPin2 = ""
    
    var isJustForSecurityPurpose = false //WHEN HIDE/UNHIDE CHAT
    var isJustCheckValidPassword = false
    
    var validateHandler : ((_ success:Bool)->Void)?
    var isForgotPasswordClicked = false
    var strForgotPassword_receivedOTP = ""
    var isForgotPassword_VerifyOTP = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        originalContainerToTop = vwContainerToTop.constant
        vwContainerToTop.constant = modifiedContainerToTop
        
        vwTextFields.isHidden = true
        self.btnForgotPin.isHidden = true
        self.btnResendOTP.isHidden = true
        
        if UserDefaultManager.getBooleanFromUserDefaults(key: kHiddenChatSetupDone){
            self.vwheight.constant = 400
            lblNote.isHidden = true
            vwTextFields.isHidden = false
            btnContinue.setTitle("Continue", for: .normal)
            isQuickSetupClicked = true
            //lblTitle.text = "Enter PIN"
            lblTitle.text = "Enter PIN to unlock"
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06, execute: {
            //                self.txt1.becomeFirstResponder()
            //            })
            txt1.isSecureTextEntry = true
            txt2.isSecureTextEntry = true
            txt3.isSecureTextEntry = true
            txt4.isSecureTextEntry = true
            self.lbltouchid.isHidden = false
            self.btntouch.isHidden = false
            
        }
        else {
            self.vwheight.constant = 280
            lblNote.isHidden = false
            vwTextFields.isHidden = true
            btnContinue.setTitle("Quick Setup", for: .normal)
            self.lbltouchid.isHidden = true
            self.btntouch.isHidden = true
            UserDefaultManager.setStringToUserDefaults(value: "", key: kHiddenChatPin)
        }
        
        txt1.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        txt2.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        txt3.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        txt4.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        
        if (isJustCheckValidPassword == true) {
            lblNote.isHidden = true
            vwTextFields.isHidden = false
            btnContinue.setTitle("Validate", for: .normal)
            isQuickSetupClicked = true
            lblTitle.text = "Enter your Current PIN"
        }
    }
    
    func touchidAlert()
    {
        let bioAuth = BiometricAuthenticator()
        if bioAuth.isTouchIdEnabledOnDevice() || bioAuth.isFaceIdEnabledOnDevice() {
            bioAuth.authenticateWithBiometrics(localizedReason: "Authenticate the user with touch to unhide the hidden chat.", successBlock: {
                DispatchQueue.main.async {
                    if self.isJustForSecurityPurpose{
                        self.validateHandler?(true)
                    }else{
                        //showMessage("Hidden chats are now visible.")
                        APP_DELEGATE.isHiddenChatUnlocked = true
                    }
                    self.closeVC()
                }
            }, failureBlock: { (error) in
                if let error = error {
                    switch error.code {
                    case .appCancel:
                        //print("The app cancelled the prompt")
                        break
                    case .authenticationFailed:
                        //print("The provided finger print or face did not match the saved credential")
                        break
                    default:
                        // use the LAError codes to handle the different error scenarios
                        //print("error: \(error.code)")
                        break
                    }
                }
            })
        }
    }
    @IBAction func btntouchclicked(_ sender: UIButton) {
        self.view.endEditing(true)
        touchidAlert()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        vwContainerToTop.constant = originalContainerToTop
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            
        }) { (finished) in
            
        }
    }
    //MARK:-
    //Set Forgot PIN view
    func manage_ForgotPIN() -> Void {
        lblNote.isHidden = true
        vwTextFields.isHidden = false
        btnContinue.setTitle("Continue", for: .normal)
        
        let strCountryCode = "+\(UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode))"
        let strPhoneNo = UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)
        let strPhoneNo_Last04Char : String = strPhoneNo.suffix(4).description
        var strPhoneNo_Formated = strPhoneNo
        strPhoneNo_Formated = strPhoneNo_Formated.replacingOccurrences(of: strPhoneNo_Last04Char, with: "xxxx".uppercased())
        lblTitle.text = "Enter last 04 digit of your contact number\n\(strCountryCode) \(strPhoneNo_Formated)"
        lblTitle.numberOfLines = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06, execute: {
            self.txt1.becomeFirstResponder()
        })
        txt1.isSecureTextEntry = false
        txt2.isSecureTextEntry = false
        txt3.isSecureTextEntry = false
        txt4.isSecureTextEntry = false
        
        isForgotPasswordClicked = true
        self.btnForgotPin.isHidden = true
    }
    
    //Get confirmation of take backup of hidden Private chat
    func manage_BackupConfirmation() -> Void {
        let alert = UIAlertController(title: nil, message: "\(APPNAME) will remove all hidden private chats. \nIf you take hidden private chats on iCloud, Other-wise you won't be able to restore later your all hidden private chats.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Backup ", style: .default, handler: { _ in
            //PV
            //self.closeVC()
            //self.presentingViewController?.dismiss(animated: false, completion: nil)
            self.dismiss(animated: false, completion: nil)
            runAfterTime(time: 1.20, block: {
                self.manage_BackupForHiddenChat_Now()
            })
            
            /*
             //------------------------------------>
             //Set New PIN Setup
             self.isQuickSetupClicked = true
             self.isForgotPasswordClicked = false
             
             self.btnForgotPin.isHidden = true
             self.btnResendOTP.isHidden = true
             
             self.lblNote.isHidden = true
             self.vwTextFields.isHidden = false
             self.btnContinue.setTitle("Continue", for: .normal)
             self.isQuickSetupClicked = true
             self.lblTitle.text = "Enter new PIN"
             
             self.txt1.isSecureTextEntry = true
             self.txt2.isSecureTextEntry = true
             self.txt3.isSecureTextEntry = true
             self.txt4.isSecureTextEntry = true
             
             UserDefaultManager.setStringToUserDefaults(value: "", key: kHiddenChatPin)
             UserDefaultManager.setBooleanToUserDefaults(value: false, key: kHiddenChatSetupDone)
             //<------------------------------------
             */
        }))
        alert.addAction(UIAlertAction(title: "Skip Backup", style: .default, handler: { _ in
            self.manage_BackupForHiddenChat_Skip()
            self.closeVC()
        }))
        //alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        APP_DELEGATE.appNavigation?.visibleViewController?.present(alert, animated: true, completion: nil)
    }
    
    // Mange Skip action to Unhide hidden chat and Clear chat
    func manage_BackupForHiddenChat_Skip() -> Void {
        self.manage_HiddenChatClear()
        self.manage_HiddenChat_to_Unhidden()
        
        UserDefaultManager.setStringToUserDefaults(value: "", key: kHiddenChatPin)
        UserDefaultManager.setBooleanToUserDefaults(value: false, key: kHiddenChatSetupDone)
    }
    
    //Perform action of Personal and Group chat, Create Zip file of backup and upload in icloud.
    func manage_BackupForHiddenChat_Now() -> Void {
        
        //Remove already exist file in local directory.
        let arrContent = getAllContent(inDirectoryURL: getURL_HiddenChat_Directory())
        for objURL in arrContent { removeFile_onURL(fileURL: objURL)}
        
        let arrPersonalChat = CoreDBManager.sharedDatabase.getHiddenFriendList() //Personal Chat backup
        let arrGroupChat = CoreDBManager.sharedDatabase.getHiddenGroupList() //Group Chat backup
        
        //Show Process Loader
        let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ImportExportProcessVC" ) as! ImportExportProcessVC
        let objHiddenChatInfo = HiddenChatInfo.init(arrPersonalChat: arrPersonalChat,
                                                    arrGroupChat: arrGroupChat)
        objVC.objHiddenChatInfo = objHiddenChatInfo
        objVC.objEnumImpExpoAction = .Export_HiddenChat
        objVC.Popup_Show(onViewController: self)
    }
    
    func manage_BackupForHiddenChat_Personal(objChat:StructChat)
    {
        //print("objChat: \(objChat.kcountrycode) \(objChat.kphonenumber)")
        
        //Get ChatData
        var arrMsgs = [StructChat]()
        arrMsgs = CoreDBManager.sharedDatabase.getChatMessagesForUserID(userId: objChat.kuserid, includeDeleted: false)
        
        let arrChatInfo : NSMutableArray = NSMutableArray.init()
        for obj : StructChat in arrMsgs {
            /*
             //Export particuler selected chat content
             //DateTime
             var strDateTime : String = obj.kcreateddate
             strDateTime = strDateTime.replacingOccurrences(of: "T", with: " ")
             strDateTime = strDateTime.replacingOccurrences(of: ".000Z", with: " ")
             strDateTime = DateFormater.getStringFromDateString(givenDate: strDateTime)
             
             //Sender Name
             var strMessSender : String = obj.ksenderid
             if (strMessSender == UserDefaultManager.getStringFromUserDefaults(key:kAppUserId)) {
             //strMessSender = UserDefaultManager.getStringFromUserDefaults(key:kAppUserFullName)
             //strMessSender = "You"
             strMessSender = "+"
             strMessSender += UserDefaultManager.getStringFromUserDefaults(key:kAppUserCountryCode)
             strMessSender += UserDefaultManager.getStringFromUserDefaults(key:kAppUserMobile)
             }
             else {
             strMessSender = "+\(objChat.kcountrycode)\(objChat.kphonenumber)"
             }
             
             let strMessType : String = obj.kmessagetype
             var strMessConent : String = "<Media omitted>"
             if (strMessType == "0") { strMessConent = obj.kchatmessage.base64Decoded! }
             
             var strFinalMess : String = ""
             strFinalMess += "\(strDateTime) - "
             strFinalMess += "\(strMessSender) - "
             strFinalMess += "\(strMessConent)"
             //arrChatInfo.add(strFinalMess)*/
            
            //Export particuler chat all content
            let dicObj : NSMutableDictionary = NSMutableDictionary.init()
            
            let mirror = Mirror(reflecting: obj)
            for child in mirror.children  {
                //print("key: \(child.label), value: \(child.value)")
                dicObj.setValue(child.value, forKey: child.label!)
            }
            arrChatInfo.add(dicObj)
        }
        //print("arrChatInfo total : \(arrChatInfo.count)")
        
        if (arrChatInfo.count == 0) {
            //showMessage("No chat available for you and \(self.strTitle)")
        }
        else {
            //Save in File
            let chatBackupFolderURL : URL = getURL_HiddenChat_Directory() //createFolder(folderName: Folder_HiddenBackup, inDirectory: getURL_WakeUpp_Directory())!
            //Check folder creded or not
            if (chatBackupFolderURL.lastPathComponent.count == 0) {
                //showMessage("Error:\nSomething was wrong. Couldn't complete backup. Please try after some time")
                return
            }
            
            showHUD() //Show loader
            
            //Export in JSON file
            let strFileName = "\(File_HiddenChat_User)\(objChat.kcountrycode)\(objChat.kphonenumber)" //###### NOTE ######: FolderName and fulPhoneNo joint by "_" , and called the followng funct to separate by this char. - "_" | So, don't replace the file name, if you change change logic in follwing func.
            export_ToJSONFile(array: arrChatInfo, strFileName: strFileName, inDirectory: chatBackupFolderURL)
        }
    }
    
    func manage_BackupForHiddenChat_Group(objGroupChat:StructGroupDetails) {
        //Get ChatData
        var arrMsgs = [StructGroupChat]()
        arrMsgs = CoreDBManager.sharedDatabase.getMessagesForGroupID(groupId: objGroupChat.group_id, includeDeleted: false)
        
        let arrGroupChatInfo : NSMutableArray = NSMutableArray.init()
        for obj : StructGroupChat in arrMsgs {
            
            /*
             //Export particuler selected chat content
             //DateTime
             var strDateTime : String = obj.createddate
             strDateTime = strDateTime.replacingOccurrences(of: "T", with: " ")
             strDateTime = strDateTime.replacingOccurrences(of: ".000Z", with: " ")
             strDateTime = DateFormater.getStringFromDateString(givenDate: strDateTime)
             
             //Sender Name
             var strMessSender : String = obj.senderid
             if (strMessSender == UserDefaultManager.getStringFromUserDefaults(key:kAppUserId)) {
             strMessSender = UserDefaultManager.getStringFromUserDefaults(key:kAppUserFullName)
             }
             else {
             strMessSender = obj.sendername
             let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: obj.countrycode, phoneNo: obj.phonenumber)
             if objContactInfo.Name?.count == 0 {
             //print("NOT IN CONTACTS")
             strMessSender = "+\(obj.countrycode)\(obj.phonenumber)"
             
             //Comment this Line after add new filed in CoreData.
             if (TRIM(string: strMessSender) == "+") { strMessSender = obj.sendername }
             }
             else { strMessSender = objContactInfo.Name ?? "*** No name ***" }
             }
             
             let strMessType : String = obj.messagetype
             var strMessConent : String = "<Media omitted>"
             if (strMessType == "0") { strMessConent = obj.textmessage.base64Decoded! }
             
             var strFinalMess : String = ""
             strFinalMess += "\(strDateTime) - "
             strFinalMess += "\(strMessSender) - "
             strFinalMess += "\(strMessConent)"
             arrGroupChatInfo.add(strFinalMess)*/
            
            //Export particuler chat all content
            let dicObj : NSMutableDictionary = NSMutableDictionary.init()
            
            let mirror = Mirror(reflecting: obj)
            for child in mirror.children  {
                //print("key: \(child.label), value: \(child.value)")
                dicObj.setValue(child.value, forKey: child.label!)
            }
            arrGroupChatInfo.add(dicObj)
        }
        //print("arrGroupChatInfo total : \(arrGroupChatInfo.count)")
        
        if (arrGroupChatInfo.count == 0) {
            //showMessage("No chat available for group \(objGroupChat.name)")
        }
        else {
            //Save in File
            let chatBackupFolderURL : URL = getURL_HiddenChat_Directory()
            //Check folder creded or not
            if (chatBackupFolderURL.lastPathComponent.count == 0) {
                //showMessage("Error:\nSomething was wrong. Couldn't complete backup. Please try after some time")
                return
            }
            
            showHUD() //Show loader
            
            //Export in TXT file
            /*//Set Backup fileName and fileType
             let strFileName = "\(APPNAME)_Hidden\(Folder_Group)\(Folder_Chat)Backup_\(objGroupChat.name).txt" //.TXT File
             //Save Chat data in File.
             do {
             //Export .txt File
             let txtExtFilePath = chatBackupFolderURL.appendingPathComponent(strFileName)
             let strExportData : String = arrGroupChatInfo.componentsJoined(by: "\n")
             try strExportData.write(to: txtExtFilePath, atomically: false, encoding: String.Encoding.utf8)
             //print("Success: \(txtExtFilePath)")
             
             hideHUD() // Hide Loader
             //share(shareContent: [txtExtFilePath])
             } catch {
             hideHUD() // Hide Loader
             //print("Error: \(error.localizedDescription)")
             //showMessage("Error:\nSomething was wrong. Couldn't complete backup. Please try after some time")
             }*/
            
            //Export in JSON file
            let strFileName = "\(File_HiddenChat_Group)\(objGroupChat.group_id)"
            export_ToJSONFile(array: arrGroupChatInfo, strFileName: strFileName, inDirectory: chatBackupFolderURL)
        }
    }
    
    func manage_HiddenChatClear() -> Void {
        //Clear Personal chat
        let arrPersonalChat = CoreDBManager.sharedDatabase.getHiddenFriendList()
        for obj : StructChat in arrPersonalChat {
            CoreDBManager.sharedDatabase.deleteAllChatMessagesWith(userId: obj.kuserid)
        }
        
        //Clear Group chat
        let arrGroupChat = CoreDBManager.sharedDatabase.getHiddenGroupList()
        for obj : StructGroupDetails in arrGroupChat {
            CoreDBManager.sharedDatabase.deleteAllGroupChatMessagesOf(groupId: obj.group_id)
        }
    }
    
    func manage_HiddenChat_to_Unhidden() -> Void {
        //Unhidden Personal chat
        let arrPersonalChat = CoreDBManager.sharedDatabase.getHiddenFriendList()
        for obj : StructChat in arrPersonalChat {
            CoreDBManager.sharedDatabase.hideUnhidePersonalChat(for: obj, shouldHide: false)
        }
        
        //Unhidden Group chat
        let arrGroupChat = CoreDBManager.sharedDatabase.getHiddenGroupList()
        for obj : StructGroupDetails in arrGroupChat {
            CoreDBManager.sharedDatabase.hideUnhideGroupChat(for: obj.group_id, shouldHide: false)
        }
    }
    
    /*func encodable_asDictionary(obj : Encodable) throws -> [String: Any] {
     let data = try JSONEncoder().encode(obj)
     guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
     throw NSError()
     }
     return dictionary
     }*/
    
    
    //MARK:- Button Clicks
    @IBAction func btnContinueClicked(_ sender: Any) {
        
        if isQuickSetupClicked == false {
            lblNote.isHidden = true
            vwTextFields.isHidden = false
            btnContinue.setTitle("Continue", for: .normal)
            isQuickSetupClicked = true
            lblTitle.text = "Assign a PIN"
            lblTitle.text = "Enter your new 4 digit PIN"
            txt1.becomeFirstResponder()
            return
        }
        
        if isForgotPasswordClicked == true {
            let strEnterValue = txt1.text! + txt2.text! + txt3.text! + txt4.text!
            let strCountryCode = UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode)
            let strPhoneNo = UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)
            let strPhoneNo_Last04Char : String = strPhoneNo.suffix(4).description
            
            if isForgotPassword_VerifyOTP == true {
                if self.strForgotPassword_receivedOTP == strEnterValue {
                    
                    clearPIN()
                    self.manage_BackupConfirmation()
                    self.view.endEditing(true)
                }
                else {
                    showMessage("Invalid enter OTP")
                }
            }
            else {
                if strEnterValue.count < 4 { showMessage("Invalid last digit") }
                else {
                    if strPhoneNo_Last04Char == strEnterValue {
                        clearPIN()
                        txt1.becomeFirstResponder()
                        lblTitle.text = "Enter received OTP for send contact number\n+\(strCountryCode) \(strPhoneNo)"
                        self.btnResendOTP.isHidden = false
                        
                        let parameter:NSDictionary = ["service":APISendOTP,
                                                      "request":["phoneno":strPhoneNo,
                                                                 "country_code":strCountryCode]]
                        self.api_SendOTP(parameter: parameter)
                    }
                    else {
                        showMessage("Invalid last digit")
                    }
                }
            }
            return
        }
        
        let strPin = txt1.text! + txt2.text! + txt3.text! + txt4.text!
        let savedPin = UserDefaultManager.getStringFromUserDefaults(key: kHiddenChatPin)
        if savedPin.count < 4{
            //ASSIGNING A NEW PIN
            
            validateHandler = nil
            isJustForSecurityPurpose = false
            
            if strPin.count < 4{
                showMessage("Invalid PIN")
                validateHandler?(false) //PV
            }else{
                if quickSetupAssignedPin1.count == 0{
                    quickSetupAssignedPin1 = strPin
                    lblTitle.text = "Confirm PIN"
                    clearPIN()
                    txt1.becomeFirstResponder()
                }else{
                    quickSetupAssignedPin2 = strPin
                    if quickSetupAssignedPin1 == quickSetupAssignedPin2{
                        UserDefaultManager.setStringToUserDefaults(value: strPin, key: kHiddenChatPin)
                        UserDefaultManager.setBooleanToUserDefaults(value: true, key: kHiddenChatSetupDone)
                        //showMessage("PIN Saved")
                        closeVC()
                    }else{
                        clearPIN()
                        quickSetupAssignedPin2 = ""
                        showMessage("PIN and Confirm PIN mismatch")
                    }
                }
            }
        }
        else {
            //CHECK THE ENTERED PIN WITH USER-DEFAULT
            if strPin == savedPin {
                if isJustForSecurityPurpose{
                    validateHandler?(true)
                }else{
                    //showMessage("Hidden chats are now visible.")
                    APP_DELEGATE.isHiddenChatUnlocked = true
                }
                closeVC()
            }else{
                showMessage("Wrong PIN")
                clearPIN()
                txt1.shake(); txt2.shake(); txt3.shake(); txt4.shake()
                
                txt1.becomeFirstResponder()
                
                if (isJustCheckValidPassword == true) {
                    //validateHandler?(false)
                }
                else { btnForgotPin.isHidden = false }
                
                failedAttepts += 1
                if failedAttepts == 3{
                    if isJustForSecurityPurpose{
                        validateHandler?(false)
                    }
                    closeVC()
                }
            }
        }
    }
    
    func clearPIN(){
        txt1.clear(); txt2.clear(); txt3.clear(); txt4.clear()
    }
    
    @IBAction func btnCloseClicked(_ sender: Any) {
        self.view.endEditing(true)
        closeVC()
    }
    
    func closeVC(){
        vwContainerToTop.constant = modifiedContainerToTop
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            
            self.view.backgroundColor = UIColor.clear
        }) { (finished) in
            self.presentingViewController?.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func btnForgotPinAction(_ sender: Any) {
        if (isForgotPasswordClicked == true) { return }
        self.manage_ForgotPIN()
        
        //iCloud_Download_HiddenChat()
    }
    
    @IBAction func btnResendOTPAction(_ sender: Any) {
        let strCountryCode = UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode)
        let strPhoneNo = UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)
        let parameter:NSDictionary = ["service":APISendOTP,
                                      "request":["phoneno":strPhoneNo,
                                                 "country_code":strCountryCode]]
        self.api_SendOTP(parameter: parameter)
    }
    
    //MARK:- API
    func api_SendOTP(parameter : NSDictionary)
    {
        /*let parameter:NSDictionary = ["service":APISendOTP,
         "request":["phoneno":mobile,
         "country_code":code]]*/
        self.view.isUserInteractionEnabled = false
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APISendOTP, parameters: parameter, keyname: ResponseKey as NSString, message: APISocialLoginMessage, showLoader: false){
            (error,apistatus,statusmessage,responseArray,responseDict) in
            
            self.view.isUserInteractionEnabled = true
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_SendOTP(parameter: parameter   )
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                    self.btnResendOTP.isHidden = false
                }
                else {
                    if responseArray!.count > 0 {
                        self.strForgotPassword_receivedOTP = responseArray![0] as! String
                        self.isForgotPassword_VerifyOTP = true
                        
                        //Just for testing
                        self.txt1.text = String(self.strForgotPassword_receivedOTP.charactersArray[0])
                        self.txt2.text = String(self.strForgotPassword_receivedOTP.charactersArray[1])
                        self.txt3.text = String(self.strForgotPassword_receivedOTP.charactersArray[2])
                        self.txt4.text = String(self.strForgotPassword_receivedOTP.charactersArray[3])
                        
                        showMessage(statusmessage)
                        //self.btnResendOTP.isHidden = true
                    }
                    else {
                        showMessage(statusmessage)
                        self.btnResendOTP.isHidden = false
                    }
                }
            }
            
        }
    }
}

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}

extension HideChatPasscodeVC:UITextFieldDelegate {
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

