//
//  ImportExportProcessVC.swift
//  WakeUppApp
//
//  Created by Admin on 07/08/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import CloudKit
import CoreData

import Sync
import Zip
let iCloudUpload_FileName = "\(Folder_Backup).zip"

enum enumImportExportAction : Int {
    case None = 0
    //Manage Personal Chat Export/Import
    case Export_PersonalChat
    case Export_PersonalChat_withContent
    //Manage Group Chat Export/Import
    case Export_GroupChat
    case Export_GroupChat_withContent
    //Manage Broadcast Chat Export/Import
    case Export_Broadcast
    case Export_Broadcast_withContent
    //Manage Hide Personal-&-Group Chat Backup Export/Import
    case Export_HiddenChat
    case Import_HiddenChat
    //Manage Chat Backup Export/Import
    case Export_AppChat
    case Import_AppChat
}

struct PersonalChatInfo {
    var userID : String
    var CountryCode: String
    var PhoneNo:String
    var ProfileImageURL:String
    var DisplayNameOfTitle:String
}

struct GroupChatInfo {
    var GroupID : String
    var GroupImageURL:String
    var DisplayNameOfTitle:String
    var userID : String
    var CountryCode: String
    var PhoneNo:String
}

struct BroadcastChatInfo {
    var BroadcastID : String
    var BroadcastImageURL:String
    var DisplayNameOfTitle:String
    var userID : String
    var CountryCode: String
    var PhoneNo:String
}

struct HiddenChatInfo {
    var arrPersonalChat : [StructChat]
    var arrGroupChat : [StructGroupDetails]
}

class ImportExportProcessVC: UIViewController {

    // MARK: - Outlet
    @IBOutlet weak var viewMain: UIView!
    
    @IBOutlet weak var viewProcess: UIView!
    
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var imgActionLogo: UIImageView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    @IBOutlet weak var lblAction_Title: UILabel!
    @IBOutlet weak var lblAction_Description: UILabel!
    
    @IBOutlet weak var btnCancel: UIButton!
    
    // MARK: - Variable
    var objEnumImpExpoAction : enumImportExportAction = .None //For manage what web API Called, get value in Privious VC
    let animation_duration = 0.250
    let img_none = UIImage.init()
    let img_success = #imageLiteral(resourceName: "cam_done")
    let img_error = #imageLiteral(resourceName: "remove_mark")
    
    var strImgURL : String = ""
    var strTitle : String = ""
    
    //Personal Chat
    var objPersonalChatInfo : PersonalChatInfo = PersonalChatInfo.init(userID: "",
                                                                       CountryCode: "",
                                                                       PhoneNo: "",
                                                                       ProfileImageURL: "",
                                                                       DisplayNameOfTitle: "")
    var strUserID : String = ""
    var strUserCountryCodeOfPhoneNo : String = ""
    var strUserPhoneNo : String = ""
    
    //Group Chat
    var objGroupChatInfo : GroupChatInfo = GroupChatInfo.init(GroupID: "",
                                                              GroupImageURL: "",
                                                              DisplayNameOfTitle: "",
                                                              userID: "",
                                                              CountryCode: "",
                                                              PhoneNo: "")
    var strGroupID : String = ""
    
    //Broadcast Chat
    var objBroadcastChatInfo : BroadcastChatInfo = BroadcastChatInfo.init(BroadcastID: "",
                                                                          BroadcastImageURL: "",
                                                                          DisplayNameOfTitle: "",
                                                                          userID: "",
                                                                          CountryCode: "",
                                                                          PhoneNo: "")
    var strBroadcastID : String = ""
    
    //Hidden Chat
    var objHiddenChatInfo : HiddenChatInfo = HiddenChatInfo.init(arrPersonalChat: [],
                                                                 arrGroupChat: [])
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()

        //viewProcess.cornerRadius = 10
        
        //Manage BG Color
        viewMain.backgroundColor = UIColor.clear
        
        runAfterTime(time: animation_duration * 1.5) {
            UIView.animate(withDuration: self.animation_duration, animations: {
                //self.viewMain.backgroundColor = RGBA(226, 238, 233, 0.50)
                self.viewMain.backgroundColor = UIColor.init(red: 170/255, green: 170/255, blue: 170/255, alpha: 0.50)
            })
        }
        
        //Fill Default values and set values are getting privious ViewController.
        self.fillValues()
        
        switch objEnumImpExpoAction {
        case .Export_PersonalChat:
            if valid_PersonalChatInfo() == false {
                //showMessage("Something was wrong.") //After live un-hide this line
                self.Popup_Hide(onViewController: self)
            }
            else {
                self.showProcess(Title: "Export chat", Description: "Export chat without media content.")
                self.manage_Export_PersonalChat(withMedia: false)
            }
        
        case .Export_PersonalChat_withContent:
            if valid_PersonalChatInfo() == false {
                //showMessage("Something was wrong.")
                self.Popup_Hide(onViewController: self)
            }
            else {
                self.showProcess(Title: "Export chat", Description: "Export chat with media content.")
                self.manage_Export_PersonalChat(withMedia: true)
            }
            
        case .Export_GroupChat:
            if valid_GroupChatInfo() == false {
                //showMessage("Something was wrong.") //After live un-hide this line
                self.Popup_Hide(onViewController: self)
            }
            else {
                self.showProcess(Title: "Export Group chat", Description: "Export group chat without media content.")
                self.manage_Export_GroupChat(withMedia: false)
            }
            break
            
        case .Export_GroupChat_withContent:
            if valid_GroupChatInfo() == false {
                //showMessage("Something was wrong.") //After live un-hide this line
                self.Popup_Hide(onViewController: self)
            }
            else {
                self.showProcess(Title: "Export Group chat", Description: "Export group chat with media content.")
                self.manage_Export_GroupChat(withMedia: true)
            }
            break
            
        case .Export_Broadcast:
            if valid_BroadcastChatInfo() == false {
                //showMessage("Something was wrong.") //After live un-hide this line
                self.Popup_Hide(onViewController: self)
            }
            else {
                self.showProcess(Title: "Export Broadcast chat", Description: "Export broadcast chat without media content.")
                self.manage_Export_BroadcastChat(withMedia: false)
            }
            break
            
        case .Export_Broadcast_withContent:
            if valid_BroadcastChatInfo() == false {
                //showMessage("Something was wrong.") //After live un-hide this line
                self.Popup_Hide(onViewController: self)
            }
            else {
                self.showProcess(Title: "Export Broadcast chat", Description: "Export broadcast chat with media content.")
                self.manage_Export_BroadcastChat(withMedia: true)
            }
            break
            
        case .Export_HiddenChat:
            if valid_HiddenChatInfo() == false {
                //showMessage("Something was wrong.") //After live un-hide this line
                self.Popup_Hide(onViewController: self)
            }
            else {
                self.showProcess(Title: "Export Hidden chat", Description: "Export your personal and group hidden chat.")
                self.manage_Export_HiddenChat()
            }
            break
            
        case .Import_HiddenChat:
            self.lblTitle.text = "Import Hidden chat"
            self.showProcess(Title: "Import Hidden chat", Description: "Import your personal and group hidden chat.")
            self.iCloud_Download_HiddenChat()
            break
            
        case .Export_AppChat:
            self.lblTitle.text = "Export chat"
            self.showProcess(Title: "Export chat", Description: "Export your personal and group chat.")
            self.manage_Export_Coredata()
            break
            
        case .Import_AppChat:
            self.viewProcess.isHidden = true
            self.showProcess(Title: "Import chat", Description: "Import your personal and group chat.")
            UserDefaultManager.setBooleanToUserDefaults(value: false, key: kIsRestored)
            //self.iCloud_RestoreChat() //---> Issue
            if iCloudAvailable() == true {
            self.iCloud_RestoreChat() }
            else { self.btnDismissAction() }
            break
            
        default:
            showMessage("Something was wrong.")
            self.showProcess_Error(Title: "Error", Description: "Something was wrong.")
            //self.Popup_Hide(onViewController: self)
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: -
    func fillValues() -> Void {
        switch objEnumImpExpoAction {
        /*case .None:
            break*/
        
        case .Export_PersonalChat, .Export_PersonalChat_withContent:
            self.strImgURL = objPersonalChatInfo.ProfileImageURL
            self.strTitle = objPersonalChatInfo.DisplayNameOfTitle
            self.strTitle = self.strTitle.count == 0 ? "Export Chat" : objPersonalChatInfo.DisplayNameOfTitle
            
            self.strUserID = objPersonalChatInfo.userID
            self.strUserCountryCodeOfPhoneNo = objPersonalChatInfo.CountryCode
            self.strUserPhoneNo = objPersonalChatInfo.PhoneNo
            break
          
        case .Export_GroupChat, .Export_GroupChat_withContent:
            self.strImgURL = objGroupChatInfo.GroupImageURL
            self.strTitle = objGroupChatInfo.DisplayNameOfTitle
            self.strTitle = self.strTitle.count == 0 ? "Export Group Chat" : objGroupChatInfo.DisplayNameOfTitle
            
            self.strGroupID = objGroupChatInfo.GroupID
            self.strUserID = objGroupChatInfo.userID
            self.strUserCountryCodeOfPhoneNo = objGroupChatInfo.CountryCode
            self.strUserPhoneNo = objGroupChatInfo.PhoneNo
            break
        
        case .Export_Broadcast, .Export_Broadcast_withContent:
            self.strImgURL = objBroadcastChatInfo.BroadcastImageURL
            self.strTitle = objBroadcastChatInfo.DisplayNameOfTitle
            self.strTitle = self.strTitle.count == 0 ? "Export Broadcast Chat" : objBroadcastChatInfo.DisplayNameOfTitle
            
            self.strBroadcastID = objBroadcastChatInfo.BroadcastID
            self.strUserID = objBroadcastChatInfo.userID
            self.strUserCountryCodeOfPhoneNo = objBroadcastChatInfo.CountryCode
            self.strUserPhoneNo = objBroadcastChatInfo.PhoneNo
            break
            
        default:
            break
        }
        
        //Fill Values
        //viewProcess.roundCorners(UIRectCorner.topLeft, radius: 10)
        //viewProcess.roundCorners(UIRectCorner.topRight, radius: 10)
        
        imgLogo.sd_setImage(with: strImgURL.url, placeholderImage: #imageLiteral(resourceName: "channel_placeholder"), options: []) { (image, error, cacheType, url) in
            if error != nil{
                self.imgLogo.image = #imageLiteral(resourceName: "channel_placeholder")
            }
        }
        self.lblTitle.text = self.strTitle
        
        self.imgActionLogo.image = img_none
        self.activityLoader.isHidden = true
        self.activityLoader.stopAnimating()
        
        self.lblAction_Title.text = ""
        self.lblAction_Description.text = ""
        
        self.btnCancel.isHidden = true
    }
    
    func showProcess(Title:String, Description:String) -> Void {
        self.activityLoader.isHidden = false
        self.activityLoader.startAnimating()
        self.imgActionLogo.image = img_none
        
        self.lblAction_Title.text = Title
        self.lblAction_Description.text = Description
        
        //self.btnCancel.isHidden = true
        self.btnCancel.isHidden = false
        self.btnCancel.setTitle("Cancel", for: .normal)
    }
    
    func showProcess_Success(Title:String, Description:String) -> Void {
        self.activityLoader.isHidden = true
        self.activityLoader.stopAnimating()
        self.imgActionLogo.image = img_success
        
        self.lblAction_Title.text = Title
        self.lblAction_Description.text = Description
        
        self.btnCancel.isHidden = false
        self.btnCancel.setTitle("Done", for: .normal)
    }
    
    func showProcess_Error(Title:String, Description:String) -> Void {
        self.activityLoader.isHidden = true
        self.imgActionLogo.image = img_error
        
        self.lblAction_Title.text = Title
        self.lblAction_Description.text = Description
        
        self.btnCancel.isHidden = false
        self.btnCancel.setTitle("Cancel", for: .normal)
    }
    
    func valid_PersonalChatInfo () -> Bool {
        if TRIM(string: strUserID).count == 0 {
            showMessage("UserID missing") //Only Testing purpose. | After live hide this line
            return false
        }
        if TRIM(string: strUserCountryCodeOfPhoneNo).count == 0 {
            showMessage("Country code of phone number missing") //Only Testing purpose. | After live hide this line
            return false
        }
        if TRIM(string: strUserPhoneNo).count == 0 {
            showMessage("Phone number missing") //Only Testing purpose. | After live hide this line
            return false
        }
        return true
    }
    
    func valid_GroupChatInfo () -> Bool {
        if TRIM(string: strGroupID).count == 0 {
            showMessage("GroupID missing") //Only Testing purpose. | After live hide this line
            return false
        }
        if TRIM(string: strTitle).count == 0 {
            showMessage("Group name missing") //Only Testing purpose. | After live hide this line
            return false
        }
        return true
    }
    
    func valid_BroadcastChatInfo () -> Bool {
        if TRIM(string: strBroadcastID).count == 0 {
            showMessage("BroadcastID missing") //Only Testing purpose. | After live hide this line
            return false
        }
        if TRIM(string: strTitle).count == 0 {
            showMessage("Broadcast name missing") //Only Testing purpose. | After live hide this line
            return false
        }
        return true
    }
    
    func valid_HiddenChatInfo () -> Bool {
        /*if self.objHiddenChatInfo.arrPersonalChat.count == 0 {
            showMessage("Hidden personal data not available") //Only Testing purpose. | After live hide this line
            return false
        }
        if self.objHiddenChatInfo.arrGroupChat.count == 0 {
            showMessage("Hidden group data not available") //Only Testing purpose. | After live hide this line
            return false
        }*/
        return true
    }
    
    // MARK: - Button action
    @IBAction func btnCancelAction(_ sender: Any) {
        
        if (self.imgActionLogo.image == img_none) {
            let alert = UIAlertController(title: nil, message: "Are you sure you went to dismiss \(self.lblAction_Title.text ?? "this") action?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { _ in
                self.imgActionLogo.image = self.img_error
                self.btnCancelAction(UIButton.init())
            }))
            alert.addAction(UIAlertAction(title: "NO", style: .default, handler: { _ in
                //---> Action
            }))
            //alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            APP_DELEGATE.appNavigation?.visibleViewController?.present(alert, animated: true, completion: nil)
        }
        else {
            viewMain.backgroundColor = UIColor.clear
            UIView.animate(withDuration: animation_duration) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //MARK: view present/dismiss action method
    @IBAction func btnDismissAction() {
        self.Popup_Hide(onViewController: UIViewController.init())
    }
    
    func Popup_Show(onViewController:UIViewController) -> Void {
        //self.Popup_Show(asViewController: self, onViewController: asViewController)
        
        DispatchQueue.main.async {
            self.modalPresentationStyle = .overCurrentContext
            self.modalTransitionStyle = .crossDissolve
            
            //onViewController.present(self, animated: false, completion: nil)
            UIApplication.shared.delegate?.window!?.rootViewController?.present(self, animated: false, completion: nil)
            
            //let nav = UINavigationController.init(rootViewController: self)
            //nav.navigationBar.isHidden = true
            //self.present(nav, animated: true, completion: nil)
        }
    }
    /*
    func Popup_Show(asViewController:UIViewController, onViewController: UIViewController) -> Void {
        DispatchQueue.main.async {
            asViewController.modalPresentationStyle = .overCurrentContext
            asViewController.modalTransitionStyle = .crossDissolve
     
            onViewController.present(asViewController, animated: false, completion: nil)
            //UIApplication.shared.delegate?.window!?.rootViewController?.present(objVC, animated: true, completion: nil)
        }
    }*/
    
    func Popup_Hide(onViewController: UIViewController) {
        let deadlineTime = DispatchTime.now() + animation_duration * 1.2
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            
            DispatchQueue.main.async {
                //self.viewLoader_Main.backgroundColor = UIColor.clear
                
                //onViewController.dismiss(animated: false, completion: nil)
                UIApplication.shared.delegate?.window!?.rootViewController?.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    //MARK:- Share Export chat content
    func share_ExportChat(chatContent:[Any]) -> Void  {
        hideHUD() // Hide Loader
        
        // set up activity view controller
        let activityViewController = UIActivityViewController(activityItems: chatContent, applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            /*if completed == false { self.showAlertMessage("not-completed") }
             else { self.showAlertMessage("completed") }*/
            
            //Remove File
            removeFile_onURL(fileURL: chatContent.first as! URL)
        }
        activityViewController.excludedActivityTypes = [ .airDrop, .postToFacebook, .postToTwitter, .message, .mail, .postToFlickr, .copyToPasteboard]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
}

//MARK:- Manage Export Data
extension ImportExportProcessVC {
    
    func manage_Export_HiddenChat() -> Void {
        //Personal Chat backup
        let arrPersonalChat = self.objHiddenChatInfo.arrPersonalChat
        for obj : StructChat in arrPersonalChat {
            self.manage_Export_HiddenPersonalChat(objPersonalChat: obj)
        }
        
        //Group Chat backup
        let arrGroupChat = self.objHiddenChatInfo.arrGroupChat
        for obj : StructGroupDetails in arrGroupChat {
            self.manage_Export_HiddenGroupChat(objGroupChat: obj)
        }
        
        //Create Zip file and share
        runAfterTime(time: 0.40) {
            let arrContent = getAllContent(inDirectoryURL: getURL_HiddenChat_Directory())
            if (arrContent.count > 0) {
                showHUD() //Show loader
                
                do {
                    let strZIPName = getURL_HiddenChat_Directory().lastPathComponent
                    let zipFilePath = try Zip.quickZipFiles([getURL_HiddenChat_Directory()], fileName: strZIPName) // Zip
                    //print("zipFilePath: \(zipFilePath)")
                    
                    //Remove All hidden chat expoted file in Document Dir.
                    //removeFile_onURL(fileURL: getURL_HiddenChat_Directory()) //Remove Dir.
                    let arrContent = getAllContent(inDirectoryURL: getURL_HiddenChat_Directory())
                    for objURL in arrContent { removeFile_onURL(fileURL: objURL)}
                    
                    hideHUD() // Hide Loader
                    
                    //Share/Upload Zip file
                    //share(shareContent: [zipFilePath])
                    self.iCloud_uploadContent(localURL: zipFilePath)
                }
                catch {
                    hideHUD() // Hide Loader
                    
                    //print("Something went wrong")
                    //showMessage("Error:\nSomething was wrong. Couldn't complete backup. Please try after some time")
                    self.showProcess_Error(Title: "Error", Description: "Something was wrong. Couldn't complete backup. Please try after some time")
                }
            }
            else {
                //showMessage("Error:\nSomething was wrong. Couldn't complete backup. Please try after some time")
                self.showProcess_Error(Title: "Error", Description: "Something was wrong. Couldn't complete backup. No chat available your personal and group hidden chat.")
            }
            
            //Clear-and-Unhide Chat
            self.manage_HiddenChat_Clear_and_Unhide()
        }
    }
    
    func manage_HiddenChat_Clear_and_Unhide() -> Void {
        //Personal Chat backup
        let arrPersonalChat = self.objHiddenChatInfo.arrPersonalChat
        for obj : StructChat in arrPersonalChat {
            CoreDBManager.sharedDatabase.deleteAllChatMessagesWith(userId: obj.kuserid)
            CoreDBManager.sharedDatabase.hideUnhidePersonalChat(for: obj, shouldHide: false)
            
            //Remove UserID in as HiddenChat in UserDefault
            APP_DELEGATE.RemoveUser_HiddenChat_UserList(strUserID: obj.kuserid)
        }
        
        //Group Chat backup
        let arrGroupChat = self.objHiddenChatInfo.arrGroupChat
        for obj : StructGroupDetails in arrGroupChat {
            CoreDBManager.sharedDatabase.deleteAllGroupChatMessagesOf(groupId: obj.group_id)
            CoreDBManager.sharedDatabase.hideUnhideGroupChat(for: obj.group_id, shouldHide: false)
            
            //Remove GroupID in as HiddenChat in UserDefault
            APP_DELEGATE.RemoveGroup_HiddenGroupChat_UserList(strGroupID: obj.group_id)
        }
    }
    
    //MARK: Personal Chat
    func manage_Export_PersonalChat(withMedia : Bool) {
        //Get ChatData
        var arrMsgs = [StructChat]()
        arrMsgs = CoreDBManager.sharedDatabase.getChatMessagesForUserID(userId: self.strUserID, includeDeleted: false)
        
        let arrChatInfo : NSMutableArray = NSMutableArray.init()
        for obj : StructChat in arrMsgs {
            //DateTime
            var strDateTime : String = obj.kcreateddate
            strDateTime = strDateTime.replacingOccurrences(of: "T", with: " ")
            strDateTime = strDateTime.replacingOccurrences(of: ".000Z", with: " ")
            strDateTime = DateFormater.getStringFromDateString(givenDate: strDateTime)
            
            //Sender Name
            var strMessSender : String = obj.ksenderid
            if (strMessSender == self.strUserID) { strMessSender = self.strTitle }
            else { strMessSender = UserDefaultManager.getStringFromUserDefaults(key:kAppUserFullName) }
            
            let strMessType : String = obj.kmessagetype
            var strMessConent : String = "<Media omitted>"
            if (strMessType == "0") { strMessConent = obj.kchatmessage.base64Decoded! }
            
            var strFinalMess : String = ""
            strFinalMess += "\(strDateTime) - "
            strFinalMess += "\(strMessSender) - "
            strFinalMess += "\(strMessConent)"
            arrChatInfo.add(strFinalMess)
        }
        //print("arrChatInfo total : \(arrChatInfo.count)")
        
        if (arrChatInfo.count == 0) {
            //showMessage("No chat available for you and \(self.strTitle)")
            showProcess_Error(Title: "Error", Description: "No chat available for you and \(self.strTitle)")
        }
        else {
            //Save in File
            //NOTE: create - "Document/(AppName)/Chat_UserContactNo" folder and save chat data in this folder.
            let chatBackupFolderURL : URL = getURL_ChatWithUser_Directory(countryCode: self.strUserCountryCodeOfPhoneNo, PhoneNo: self.strUserPhoneNo)
            
            //Check folder creded or not
            if (chatBackupFolderURL.lastPathComponent.count == 0) {
                //showMessage("Error:\nSomething was wrong. Couldn't complete backup. Please try after some time")
                showProcess_Error(Title: "Error", Description: "Something was wrong. Couldn't complete backup. Please try after some time")
                return
            }
            
            //Set Backup fileName and fileType
            var strFileName = "\(APPNAME)_\(Folder_Chat)Backup_\(self.strUserCountryCodeOfPhoneNo)\(self.strUserPhoneNo).txt" //.TXT File
            
            //Set filePath for store location in device.
            let fileUrl = chatBackupFolderURL.appendingPathComponent(strFileName)
            
            showHUD() //Show loader
            //Save CHat data in File.
            do {
                //Export .txt File
                let txtExtFilePath = chatBackupFolderURL.appendingPathComponent(strFileName)
                let strExportData : String = arrChatInfo.componentsJoined(by: "\n")
                try strExportData.write(to: txtExtFilePath, atomically: false, encoding: String.Encoding.utf8)
                //print("Success: \(txtExtFilePath)")
                
                hideHUD() // Hide Loader
                
                //Share the file.
                if (withMedia == true) {
                    //share(shareContent: [chatBackupFolderURL])
                    
                    showHUD() //Show loader
                    do {
                        strFileName = strFileName.replacingOccurrences(of: ".txt", with: "")
                        let zipFilePath = try Zip.quickZipFiles([chatBackupFolderURL], fileName: strFileName) // Zip
                        //print("zipFilePath: \(zipFilePath)")
                        
                        hideHUD() // Hide Loader
                        
                        self.showProcess_Success(Title: "Success", Description: "Export your \(self.strTitle) chat successfully")
                        
                        //share(shareContent: [zipFilePath])
                        self.share_ExportChat(chatContent: [zipFilePath])
                        
                        //Remove file in Dir.
                        removeFile_onURL(fileURL: txtExtFilePath.absoluteURL)
                    }
                    catch {
                        hideHUD() // Hide Loader
                        
                        //print("Something went wrong")
                        //showMessage("Error:\nSomething was wrong. Couldn't complete backup. Please try after some time")
                        showProcess_Error(Title: "Error", Description: "Something was wrong. Couldn't complete backup. Please try after some time")
                    }
                }
                else {
                    self.showProcess_Success(Title: "Success", Description: "Export your \(self.strTitle) chat successfully")
                    
                    //share(shareContent: [fileUrl])
                    self.share_ExportChat(chatContent: [fileUrl])
                }
            } catch {
                hideHUD() // Hide Loader
                
                //print("Error: \(error)")
                //print("Error: \(error.localizedDescription)")
                //showMessage("Error:\nSomething was wrong. Couldn't complete backup. Please try after some time")
                showProcess_Error(Title: "Error", Description: "Something was wrong. Couldn't complete backup. Please try after some time")
            }
        }
    }
    
    func manage_Export_HiddenPersonalChat(objPersonalChat:StructChat) {
        //Get ChatData
        var arrMsgs = [StructChat]()
        arrMsgs = CoreDBManager.sharedDatabase.getChatMessagesForUserID(userId: objPersonalChat.kuserid, includeDeleted: false)
        
        let arrChatInfo : NSMutableArray = NSMutableArray.init()
        for objPersonalChatInfo : StructChat in arrMsgs {
            //Export particuler chat all content
            let dicObj : NSMutableDictionary = NSMutableDictionary.init()
            
            let mirror = Mirror(reflecting: objPersonalChatInfo)
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
            //Export in JSON file
            let strFileName = "\(File_HiddenChat_User)\(objPersonalChat.kcountrycode)\(objPersonalChat.kphonenumber)" //###### NOTE ######: FolderName and fulPhoneNo joint by "_" , and called the followng funct to separate by this char. - "_" | So, don't replace the file name, if you change change logic in follwing func.
            export_ToJSONFile(array: arrChatInfo, strFileName: strFileName, inDirectory: getURL_HiddenChat_Directory())
        }
    }

//MARK: Group Chat
    func manage_Export_GroupChat(withMedia : Bool) {
        //Get ChatData
        var arrMsgs = [StructGroupChat]()
        arrMsgs = CoreDBManager.sharedDatabase.getMessagesForGroupID(groupId: self.strGroupID, includeDeleted: false)
        
        let arrGroupChatInfo : NSMutableArray = NSMutableArray.init()
        for obj : StructGroupChat in arrMsgs {
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
                    strMessSender = "+\(obj.countrycode) \(obj.phonenumber)"
                    
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
            arrGroupChatInfo.add(strFinalMess)
        }
        //print("arrChatInfo total : \(arrGroupChatInfo.count)")
        
        if (arrGroupChatInfo.count == 0) {
            //showMessage("No chat available for group \(strTitle)")
            showProcess_Error(Title: "Error", Description: "No chat available for \(self.strTitle)")
        }
        else {
            //Save in File
            //NOTE: create - "Document/(AppName)/Group_ID" folder and save chat data in this folder.
            let chatBackupFolderURL : URL = getURL_GroupChat_Directory(groupID: self.strGroupID)
            
            //Check folder creded or not
            if (chatBackupFolderURL.lastPathComponent.count == 0) {
                //showMessage("Error:\nSomething was wrong. Couldn't complete backup. Please try after some time")
                showProcess_Error(Title: "Error", Description: "Something was wrong. Couldn't complete backup. Please try after some time")
                return
            }
            
            //Set Backup fileName and fileType
            var strFileName = "\(APPNAME)_\(Folder_Group)\(Folder_Chat)Backup_\(self.strTitle).txt" //.TXT File
            
            //Set filePath for store location in device.
            let fileUrl = chatBackupFolderURL.appendingPathComponent(strFileName)
            
            showHUD() //Show loader
            //Save CHat data in File.
            do {
                //Export .txt File
                let txtExtFilePath = chatBackupFolderURL.appendingPathComponent(strFileName)
                let strExportData : String = arrGroupChatInfo.componentsJoined(by: "\n")
                try strExportData.write(to: txtExtFilePath, atomically: false, encoding: String.Encoding.utf8)
                //print("Success: \(txtExtFilePath)")
                
                hideHUD() // Hide Loader
                
                //Share the file.
                if (withMedia == true) {
                    //share(shareContent: [chatBackupFolderURL])
                    
                    showHUD() //Show loader
                    do {
                        strFileName = strFileName.replacingOccurrences(of: ".txt", with: "")
                        let zipFilePath = try Zip.quickZipFiles([chatBackupFolderURL], fileName: strFileName) // Zip
                        //print("zipFilePath: \(zipFilePath)")
                        
                        hideHUD() // Hide Loader
                        
                        self.showProcess_Success(Title: "Success", Description: "Export your \(self.strTitle) chat successfully")
                        
                        //share(shareContent: [zipFilePath])
                        self.share_ExportChat(chatContent: [zipFilePath])
                        
                        //Remove file in Dir.
                        removeFile_onURL(fileURL: txtExtFilePath.absoluteURL)
                    }
                    catch {
                        hideHUD() // Hide Loader
                        
                        //print("Something went wrong")
                        //showMessage("Error:\nSomething was wrong. Couldn't complete backup. Please try after some time")
                        showProcess_Error(Title: "Error", Description: "Something was wrong. Couldn't complete backup. Please try after some time")
                    }
                }
                else {
                    self.showProcess_Success(Title: "Success", Description: "Export your \(self.strTitle) chat successfully")
                    
                    //share(shareContent: [fileUrl])
                    self.share_ExportChat(chatContent: [fileUrl])
                }
            } catch {
                hideHUD() // Hide Loader
                
                //print("Error: \(error)")
                //print("Error: \(error.localizedDescription)")
                //showMessage("Error:\nSomething was wrong. Couldn't complete backup. Please try after some time")
                showProcess_Error(Title: "Error", Description: "Something was wrong. Couldn't complete backup. Please try after some time")
            }
        }
    }
    
    func manage_Export_HiddenGroupChat(objGroupChat:StructGroupDetails) {
        //Get ChatData
        var arrMsgs = [StructGroupChat]()
        arrMsgs = CoreDBManager.sharedDatabase.getMessagesForGroupID(groupId: objGroupChat.group_id, includeDeleted: false)
        
        let arrGroupChatInfo : NSMutableArray = NSMutableArray.init()
        for obj : StructGroupChat in arrMsgs {
            
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
            //Export in JSON file
            let strFileName = "\(File_HiddenChat_Group)\(objGroupChat.group_id)"
            export_ToJSONFile(array: arrGroupChatInfo, strFileName: strFileName, inDirectory: getURL_HiddenChat_Directory())
        }
    }

//MARK: Broadcast Chat
    func manage_Export_BroadcastChat(withMedia : Bool) {
        //Get ChatData
        var arrMessage = [StructBroadcastMessage]()
        arrMessage = CoreDBManager.sharedDatabase.getMessagesForBroadcastListID(broadcastListID: self.strBroadcastID)
        
        let arrGroupChatInfo : NSMutableArray = NSMutableArray.init()
        for obj : StructBroadcastMessage in arrMessage {
            //DateTime
            var strDateTime : String = obj.createddate
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            formatter.timeZone = TimeZone.current
            let date = formatter.date(from: strDateTime)
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            strDateTime = formatter.string(from: date!)
            //Sender Name
            var strMessSender : String = obj.senderid
            if (strMessSender == UserDefaultManager.getStringFromUserDefaults(key:kAppUserId)) {
                strMessSender = UserDefaultManager.getStringFromUserDefaults(key:kAppUserFullName)
            }
            else { strMessSender = obj.sendername }
            
            let strMessType : String = obj.messagetype
            var strMessConent : String = "<Media omitted>"
            if (strMessType == "0") { strMessConent = obj.textmessage.base64Decoded! }
            
            var strFinalMess : String = ""
            strFinalMess += "\(strDateTime) - "
            strFinalMess += "\(strMessSender) - "
            strFinalMess += "\(strMessConent)"
            arrGroupChatInfo.add(strFinalMess)
        }
        //print("arrChatInfo total : \(arrGroupChatInfo.count)")
        
        if (arrGroupChatInfo.count == 0) {
            //showMessage("No chat available for broadcast \(self.strTitle)")
            showProcess_Error(Title: "Error", Description: "No chat available for broadcast \(self.strTitle)")
        }
        else {
            //Save in File
            let chatBackupFolderURL : URL = getURL_BroadcastChat_Directory(BroadcastID: self.strBroadcastID)
            
            //Check folder creded or not
            if (chatBackupFolderURL.lastPathComponent.count == 0) {
                //showMessage("Error:\nSomething was wrong. Couldn't complete backup. Please try after some time")
                showProcess_Error(Title: "Error", Description: "Something was wrong. Couldn't complete backup. Please try after some time")
                return
            }
            
            //Set Backup fileName and fileType
            var strFileName = "\(APPNAME)_\(Folder_Broadcast)_Backup.txt" //.TXT File
            strFileName = strFileName.replacingOccurrences(of: " ", with: "")
            
            //Set filePath for store location in device.
            let fileUrl = chatBackupFolderURL.appendingPathComponent(strFileName)
            
            showHUD() //Show loader
            //Save CHat data in File.
            do {
                //Export .txt File
                let txtExtFilePath = chatBackupFolderURL.appendingPathComponent(strFileName)
                let strExportData : String = arrGroupChatInfo.componentsJoined(by: "\n")
                try strExportData.write(to: txtExtFilePath, atomically: false, encoding: String.Encoding.utf8)
                //print("Success: \(txtExtFilePath)")
                
                hideHUD() // Hide Loader
                
                //Share the file.
                if (withMedia == true) {
                    //share(shareContent: [chatBackupFolderURL])
                    
                    showHUD() //Show loader
                    do {
                        strFileName = strFileName.replacingOccurrences(of: ".txt", with: "")
                        let zipFilePath = try Zip.quickZipFiles([chatBackupFolderURL], fileName: strFileName) // Zip
                        //print("zipFilePath: \(zipFilePath)")
                        
                        hideHUD() // Hide Loader
                        
                        self.showProcess_Success(Title: "Success", Description: "Export your \(self.strTitle) broadcast chat successfully")
                        
                        //share(shareContent: [zipFilePath])
                        self.share_ExportChat(chatContent: [zipFilePath])
                        
                        //Remove file in Dir.
                        removeFile_onURL(fileURL: txtExtFilePath.absoluteURL)
                    }
                    catch {
                        hideHUD() // Hide Loader
                        
                        //print("Something went wrong")
                        //showMessage("Error:\nSomething was wrong. Couldn't complete backup. Please try after some time")
                        showProcess_Error(Title: "Error", Description: "Something was wrong. Couldn't complete backup. Please try after some time")
                    }
                }
                else {
                    self.showProcess_Success(Title: "Success", Description: "Export your \(self.strTitle) broadcast chat successfully")
                    
                    //share(shareContent: [fileUrl])
                    self.share_ExportChat(chatContent: [fileUrl])
                }
            } catch {
                hideHUD() // Hide Loader
                
                //print("Error: \(error)")
                //print("Error: \(error.localizedDescription)")
                //showMessage("Error:\nSomething was wrong. Couldn't complete backup. Please try after some time")
                showProcess_Error(Title: "Error", Description: "Something was wrong. Couldn't complete backup. Please try after some time")
            }
        }
    }
    
    //MARK: Export Coredata
    func manage_Export_Coredata() -> Void {
        //Create Folder
        let BackupURL = createFolder(folderName: Folder_Backup, inDirectory: getDocumentsDirectoryURL()!)!
        
        //Already exist file remove in dir.
        for filePath : URL in getAllContent(inDirectoryURL: BackupURL) { removeFile_onURL(fileURL: filePath) }
        
        //NOTE : Hide some content, Bcoz it's data not export.
        //Friends
         let fetchRequest_Friends: NSFetchRequest<CD_Friends> = CD_Friends.fetchRequest()
         let arrFriend = export_Coredata_Entity(fetchRequest: fetchRequest_Friends as! NSFetchRequest<NSFetchRequestResult>)
         export_ToJSONFile(array: arrFriend, strFileName: "\(ENTITY_FRIENDS)", inDirectory: BackupURL)
        
        //Chat
        let fetchRequest_Chat : NSFetchRequest<CD_Messages> = CD_Messages.fetchRequest()
        let arrChat = export_Coredata_Entity(fetchRequest: fetchRequest_Chat as! NSFetchRequest<NSFetchRequestResult>)
        export_ToJSONFile(array: arrChat, strFileName: "\(ENTITY_CHAT)", inDirectory: BackupURL)
        
        //Group
        //--------->
        /*let objContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest<CD_Friends>(entityName: ENTITY_FRIENDS)
        let disentity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ENTITY_FRIENDS, in: objContext)!
        let predicate = NSPredicate(format:"user_id == %@",objFriend.kuserid)
        fetchRequest.predicate = predicate
        fetchRequest.entity = disentity*/
        //<---------
        let fetchRequest_Group : NSFetchRequest<CD_Groups> = CD_Groups.fetchRequest()
        let predicate = NSPredicate(format:"group_id != %@","")
        fetchRequest_Group.predicate = predicate
        let arrGroup = export_Coredata_Entity(fetchRequest: fetchRequest_Group as! NSFetchRequest<NSFetchRequestResult>)
        export_ToJSONFile(array: arrGroup, strFileName: "\(ENTITY_GROUPS)", inDirectory: BackupURL)
        
        //Group Chat
        let fetchRequest_GroupChat : NSFetchRequest<CD_GroupMessages> = CD_GroupMessages.fetchRequest()
        let arrGroupChat = export_Coredata_Entity(fetchRequest: fetchRequest_GroupChat as! NSFetchRequest<NSFetchRequestResult>)
        export_ToJSONFile(array: arrGroupChat, strFileName: "\(ENTITY_GROUP_CHAT)", inDirectory: BackupURL)
        /*
         //Broadcast List
         let fetchRequest_BroadcastList : NSFetchRequest<CD_BroadcastList> = CD_BroadcastList.fetchRequest()
         let arrBroadcastList = export_Coredata_Entity(fetchRequest: fetchRequest_BroadcastList as! NSFetchRequest<NSFetchRequestResult>)
         export_ToJSONFile(array: arrBroadcastList, strFileName: "\(ENTITY_BROADCASTLIST)", inDirectory: BackupURL)
         
         //Broadcast Message
         let fetchRequest_BroadcastMess : NSFetchRequest<CD_BoardcastMessages> = CD_BoardcastMessages.fetchRequest()
         let arrBroadcastMess = export_Coredata_Entity(fetchRequest: fetchRequest_BroadcastMess as! NSFetchRequest<NSFetchRequestResult>)
         export_ToJSONFile(array: arrBroadcastMess, strFileName: "\(ENTITY_BROADCAST_MESSAGE)", inDirectory: BackupURL)
         
         //Stories
         let fetchRequest_Stories : NSFetchRequest<CD_Stories> = CD_Stories.fetchRequest()
         let arrStories = export_Coredata_Entity(fetchRequest: fetchRequest_Stories as! NSFetchRequest<NSFetchRequestResult>)
         export_ToJSONFile(array: arrStories, strFileName: "\(ENTITY_STORIES)", inDirectory: BackupURL)
         
         //Stories Viewers
         let fetchRequest_StoriesViewers : NSFetchRequest<CD_Stories_Viewers> = CD_Stories_Viewers.fetchRequest()
         let arrStoriesViewers = export_Coredata_Entity(fetchRequest: fetchRequest_StoriesViewers as! NSFetchRequest<NSFetchRequestResult>)
         export_ToJSONFile(array: arrStoriesViewers, strFileName: "\(ENTITY_STORIES_VIEWERS)", inDirectory: BackupURL)
         
         //Call History
         let fetchRequest_CallHistory : NSFetchRequest<CD_CallHistory> = CD_CallHistory.fetchRequest()
         let arrCallHistory = export_Coredata_Entity(fetchRequest: fetchRequest_CallHistory as! NSFetchRequest<NSFetchRequestResult>)
         export_ToJSONFile(array: arrCallHistory, strFileName: "\(ENTITY_CALL_HISTORY)", inDirectory: BackupURL)
         */
        
        //Include Content
        //save_Content(contentURL: getURL_WakeUpp_Directory(), withName: getURL_WakeUpp_Directory().lastPathComponent, inDirectory: BackupURL)
        
        //Export Chat
        let arrContent = getAllContent(inDirectoryURL: BackupURL)
        if (arrContent.count == 0) {
            showMessage("Unable to export chat. please try again.")
            self.showProcess_Error(Title: "Error", Description: "Something was wrong.\nUnable to export chat.\nPlease try again.")
        }
        else {
            do {
                //Zip
                let strFileName : String = BackupURL.lastPathComponent
                //let zipFilePath = try Zip.quickZipFiles([contentURL], fileName: strFileName) // Zip
                let zipFilePath = try Zip.quickZipFiles([BackupURL], fileName: strFileName, progress: { (progress) in
                    //print("Zip progress: \(progress)")
                })
                //print("zipFilePath: \(zipFilePath)")
                
                hideHUD() // Hide Loader
                
                //PV
                //Share Export chat zip file.
                self.iCloud_uploadContent(localURL: zipFilePath)
                
                //PV
                //Remove Directory and into exported JSON file in the Document directory/Backup Directory/JSON file.
                //let arrContent = getAllContent(inDirectoryURL: contentURL)
                //for objURL in arrContent { removeFile_onURL(fileURL: objURL) } //Remove JSON file
                removeFile_onURL(fileURL: BackupURL) //Remove Directory
            }
            catch {
                hideHUD() // Hide Loader
                
                //print("Something went wrong")
                //showMessage("Error:\nSomething was wrong. Couldn't complete backup. Please try after some time")
                self.showProcess_Error(Title: "Error", Description: "Something was wrong. Couldn't complete backup. No chat available your chat.")
            }
        }
    }
    
}

//MARK:- Manage Import Data
extension ImportExportProcessVC {
    func import_HiddenChat() -> Void {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            //Get Zip file in Document dir.
            let strZipFileName : String = "\(Folder_HiddenChat).zip"
            if isFileLocallyExist(fileName: strZipFileName, inDirectory: documentDirectory) {
                //print("Zip file exist")
                
                //Unzip the backup file
                let dirURL = getURL_LocallyFileExist(fileName: strZipFileName, inDirectory: documentDirectory)
                do {
                    //Unzip
                    //let unZipFilePath = try Zip.quickUnzipFile(dirURL)
                    let unzipFilePath = try Zip.quickUnzipFile(dirURL, progress: { (progress) in
                        //print("Unzip progress: \(progress)")
                    })
                    //print("unzipFilePath: \(unzipFilePath)")
                    
                    self.import_Coredata_Directory(inDirectoryURL: unzipFilePath, directoryName: Folder_HiddenChat)
                    
                    runAfterTime(time: 1.20, block: {
                        self.showProcess_Success(Title: "Success", Description: "Import your hidden \(self.strTitle) chat successfully.")
                        self.manage_HiddenChat_Clear_and_Unhide()
                    })
                }
                catch {
                    //print("Unzip File Error : \(error)")
                    self.showProcess_Error(Title: "Error", Description: "Something was wrong. \nNot possible to import your hidden chat.")
                }
            }
            else {
                //print("Zip file not-exist")
                //showMessage("Not possible to import chat")
                self.showProcess_Error(Title: "Error", Description: "Something was wrong. \nNot possible to import your hidden chat.")
            }
        }
    }
    //MARK: Coredata Import
    func import_Coredata() -> Void {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            //Get Zip file in Document dir.
            let strZipFileName : String = "\(Folder_Backup).zip"
            if isFileLocallyExist(fileName: strZipFileName, inDirectory: documentDirectory) {
                //print("Zip file exist")
                
                //Unzip the backup file
                let dirURL = getURL_LocallyFileExist(fileName: strZipFileName, inDirectory: documentDirectory)
                do {
                    //Unzip
                    //let unZipFilePath = try Zip.quickUnzipFile(dirURL)
                    let unzipFilePath = try Zip.quickUnzipFile(dirURL, progress: { (progress) in
                        //print("Unzip progress: \(progress)")
                    })
                    //print("unzipFilePath: \(unzipFilePath)")
                    
                    self.import_Coredata_Directory(inDirectoryURL: unzipFilePath, directoryName: Folder_Backup)
                    
                    runAfterTime(time: 1.20, block: {
                        self.showProcess_Success(Title: "Success", Description: "Import your chat successfully.")
                    })
                }
                catch {
                    //print("Unzip File Error : \(error)")
                }
            }
            else {
                //print("Zip file not-exist")
                showMessage("Not possible to import chat")
            }
        }
    }
    
    func import_Coredata_Directory(inDirectoryURL : URL, directoryName : String) -> Void {
        let arrDirContent = getAllContent(inDirectoryURL: inDirectoryURL)
        if (arrDirContent.count == 1) {
            let dirName : String = (arrDirContent.first?.lastPathComponent)!
            //if dirName.uppercased() == Folder_Backup.uppercased() {
            if dirName.uppercased() == directoryName.uppercased() {
                // Get All file one-by-one
                self.import_Coredata_Directory(inDirectoryURL: arrDirContent.first!, directoryName: directoryName)
            }
            else {
                let arrFile = arrDirContent.first?.lastPathComponent.components(separatedBy: ".")
                if (arrFile?.last?.uppercased() == "json".uppercased()) {
                    import_Coredata_ContentURL(arrContent: arrDirContent)
                }
            }
        }
        else {
            //print("Multiple file exist")
            
            for filePath : URL in arrDirContent {
                //let arrFile = arrDirContent.last?.lastPathComponent.components(separatedBy: ".")
                let arrFile = filePath.lastPathComponent.components(separatedBy: ".")
                if (arrFile.last?.uppercased() == "json".uppercased()) {
                    import_Coredata_ContentURL(arrContent: [filePath])
                }
                else {
                    //Check attach content is Dir. if YES , import the content in Wakeupp dir.
                }
            }
        }
    }
    
    func import_Coredata_ContentURL(arrContent : [URL]) -> Void {
        for filePath : URL in arrContent {
            //print("file : \(filePath.lastPathComponent)")
            
            guard let data = try? Data(contentsOf: filePath) else { return }
            guard let json = try! JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else { return }
            
            //Get JSON file name
            let arrJSONFile = filePath.lastPathComponent.components(separatedBy: ".")
            var strJSONFileName = arrJSONFile.first?.uppercased()
            strJSONFileName = strJSONFileName?.uppercased()
            
            var strEntityName : String = ""
            if (strJSONFileName == ENTITY_FRIENDS.uppercased()) { strEntityName = ENTITY_FRIENDS }
            else if (strJSONFileName == ENTITY_CHAT.uppercased()) { strEntityName = ENTITY_CHAT }
            else if (strJSONFileName == ENTITY_GROUPS.uppercased()) { strEntityName = ENTITY_GROUPS }
            else if (strJSONFileName == ENTITY_GROUP_CHAT.uppercased()) { strEntityName = ENTITY_GROUP_CHAT }
            else if (strJSONFileName == ENTITY_BROADCASTLIST.uppercased()) { strEntityName = ENTITY_BROADCASTLIST }
            else if (strJSONFileName == ENTITY_BROADCAST_MESSAGE.uppercased()) { strEntityName = ENTITY_BROADCAST_MESSAGE }
            else if (strJSONFileName == ENTITY_STORIES.uppercased()) { strEntityName = ENTITY_STORIES }
            else if (strJSONFileName == ENTITY_STORIES_VIEWERS.uppercased()) { strEntityName = ENTITY_STORIES_VIEWERS }
            else if (strJSONFileName == ENTITY_CALL_HISTORY.uppercased()) { strEntityName = ENTITY_CALL_HISTORY }
            
            //Import JSON Data in Coredata entity
            if (strEntityName.count != 0) { import_Coredata_Entity(entityName: strEntityName, jsonData: json) }
            else {
                let arrName = strJSONFileName?.components(separatedBy: "_")
                if (arrName?.first?.uppercased()  == Folder_Chat.uppercased()) {
                    strEntityName = ENTITY_CHAT
                    import_Coredata_Entity(entityName: strEntityName, jsonData: json)
                }
                if (arrName?.first?.uppercased()  == Folder_Group.uppercased()) {
                    strEntityName = ENTITY_GROUP_CHAT
                    import_Coredata_Entity(entityName: strEntityName, jsonData: json)
                }
            }
            
            //Remove file
            //removeFile_onURL(fileURL: arrContent.first!)
            removeFile_onURL(fileURL: filePath) //PV
        }
    }
    
    func import_Coredata_Entity(entityName:String, jsonData:[[String: Any]]) -> Void {
        
        let dataStack : DataStack = DataStack(modelName: "WakeUppApp")
        
        //dataStack.sync(jsonData, inEntityNamed: entityName) { (error : NSError?) in
        dataStack.sync(jsonData, inEntityNamed: entityName) { error in
            if (error != nil) {
                //print("Error : Import JSON file : \(entityName) | \(jsonData.count)")
            } else {
                //print("Success : Import JSON file : \(entityName) | \(jsonData.count)")
            }
        }
    }
}

//MARK:- Manage iCloud
extension ImportExportProcessVC {
    func iCloudAvailable() -> Bool{
        if FileManager.default.ubiquityIdentityToken != nil{
            //print("iCloud Available")
            //showMessage("iCloud Available")
            return true
        }
        else {
            //PV
            //print("iCloud Unavailable")
            showProcess_Error(Title: "Error", Description: "Something was wrong. Couldn't upload backup on iCloud.\n iCloud Unavailable")
            
            //showMessage("iCloud Unavailable")
            //self.btnDismissAction()
            
            /*//HAD TO CHECK CloudKit IN CAPABILITIES TO USE CKContainer. OTHERWISE iCloudDocuments WORKS FILE FOR UPLOADING AND DOWNLOADING FILES.
             CKContainer.default().accountStatus { (accountStatus, error) in
             
             var errMsg = ""
             
             switch accountStatus {
             case .available:
             //print("iCloud Available")
             case .noAccount:
             //print("No iCloud account")
             errMsg = "You have not logged-in to iCloud."
             case .restricted:
             //print("iCloud restricted")
             errMsg = "Parental Control / Device Management has denied iCloud access."
             case .couldNotDetermine:
             //print("Unable to determine iCloud status")
             errMsg = "Could not determine iCloud status.";
             print(error!)
             }
             
             let alert = UIAlertController.init(title: "iCloud", message: errMsg, preferredStyle: .alert)
             
             let actionOpenSettings = UIAlertAction.init(title: "Open Settings", style: .default, handler: { (action) in
             
             
             //let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) //OPENS CURRENT APP'S SETTINGS SCREEN IN SETTINGS APP
             let settingsUrl = URL(string: "App-Prefs:root=CASTLE") //OPENS SETTINGS APP
             if let url = settingsUrl, UIApplication.shared.canOpenURL(url) {
             if #available(iOS 10, *) {
             UIApplication.shared.open(url, options: [:], completionHandler: nil)
             } else {
             UIApplication.shared.openURL(url)
             }
             }
             
             })
             
             let actionOk = UIAlertAction.init(title: "Okay", style: .default, handler: nil)
             
             alert.addAction(actionOk)
             alert.addAction(actionOpenSettings)
             
             self.present(alert, animated: true, completion: nil)
             
             }*/
            return false
        }
    }
    
    func rootDirectory(forICloud completionHandler: @escaping (_: URL) -> Void) {
        DispatchQueue.global(qos: .default).async(execute: {() -> Void in
            let rootDirectory: URL? = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent(Folder_Backup)
            if rootDirectory != nil {
                if let aPath = rootDirectory?.path {
                    if !FileManager.default.fileExists(atPath: aPath, isDirectory: nil) {
                        //print("Create directory")
                        if let aDirectory = rootDirectory {
                            try? FileManager.default.createDirectory(at: aDirectory, withIntermediateDirectories: true, attributes: nil)
                        }
                    }
                }
            }
            DispatchQueue.main.async(execute: {() -> Void in
                completionHandler(rootDirectory!)
            })
        })
    }
    
   /* func storeFileToiCloud(localURL:URL?) -> Void {
        // Let's get the root directory for storing the file on iCloud Drive
        rootDirectory(forICloud: {(_ ubiquityURL: URL) -> Void in
            //print("1. ubiquityURL = \(ubiquityURL)\n")
            
            var ubqtURL = ubiquityURL
            // We also need the 'local' URL to the file we want to store
            //print("2. localURL = \(String(describing: localURL))\n")
            
            // Now, append the local filename to the ubqtURL
            if let aComponent = localURL?.lastPathComponent {
                let aComponent1 = ubqtURL.appendingPathComponent(aComponent)
                ubqtURL = aComponent1
            }
            //print("3. ubqtURL = \(ubqtURL)\n")
            
            if let aURL = localURL {
                //Remove already exists file in iCloud
                if FileManager.default.fileExists(atPath: ubqtURL.path){
                    self.iCloud_RemoveContent(contentName: (localURL?.lastPathComponent)!)
                }
                
                runAfterTime(time: 0.10, block: {
                    //Upload file in icloud
                    do {
                        try FileManager.default.copyItem(at: aURL, to: ubqtURL)
                        
                        //showMessage("iCloud upload success")
                        self.showProcess_Success(Title: "Success", Description: "Your chat backup successfully upload on your iCloud account")
                        
                        //PV
                        //Remove iCloud Upload file in Local Directory
                        removeFile_onURL(fileURL: aURL)
                    }
                    catch{
                        //print("Error occurred: \(String(describing: error))")
                        //showMessage("Error: \(error.localizedDescription)")
                        self.showProcess_Error(Title: "Error", Description: "Something was wrong. Couldn't upload your backup on your iCloud.\n\(error.localizedDescription)")
                    }})
            }
            else {
                self.showProcess_Error(Title: "Error", Description: "Something was wrong. Couldn't upload your backup on your iCloud.")
            }
        })
    }
    
    func getFileFromiCloud(ubiquityURL:URL?) -> URL {
        let localDocumentsURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last
        let myLocalFile = localDocumentsURL?.appendingPathComponent((ubiquityURL?.lastPathComponent)!)
        //print("Locally Saved File : \(myLocalFile!)\n")
        
        //Download file name related content already exists in Document directory (Local directory), To remove file in Document directory (Local directory).
        if FileManager.default.fileExists(atPath: (myLocalFile?.path)!){
            //PV
            //removeFile(fileName: (myLocalFile?.lastPathComponent)!, inDirectory: myLocalFile!)
            removeFile(fileName: (myLocalFile?.lastPathComponent)!, inDirectory: getDocumentsDirectoryURL()!)
        }
        
        do{
            try FileManager.default.copyItem(at: ubiquityURL!, to: myLocalFile!)
            //print("iCloud download ubiquityURL: \(String(describing: ubiquityURL))")
            //showMessage("iCloud download success") //PV
            
            return ubiquityURL!
        }
        catch {
            //print("getFileFromiCloud Download iCloud file Error:: \(error)")
            //showMessage("Error: \(error.localizedDescription)")
            
            self.showProcess_Error(Title: "Error", Description: "No such your hiddent chat data from iCloud.")
            
            //return URL.init(string: "")!
            return getDocumentsDirectoryURL()!
        }
    }
    */
    
    
    func storeFileToiCloud(localURL:URL?) {
        
        // Let's get the root directory for storing the file on iCloud Drive
        rootDirectory(forICloud: {(_ ubiquityURL: URL) -> Void in
            //print("1. ubiquityURL = \(ubiquityURL)\n")
            
            var ubqtURL = ubiquityURL
            
            // We also need the 'local' URL to the file we want to store
            //let localURL: URL? = self.localPath(forResource: "demo", ofType: "pdf")
            //print("2. localURL = \(String(describing: localURL))\n")
            // Now, append the local filename to the ubqtURL
            if let aComponent = localURL?.lastPathComponent {
                
                let aComponent1 = ubqtURL.appendingPathComponent(aComponent)
                ubqtURL = aComponent1
            }
            //print("3. ubqtURL = \(ubqtURL)\n")
            
            
            if let aURL = localURL {
                
                if FileManager.default.fileExists(atPath: ubqtURL.path){
                    do{
                        try FileManager.default.removeItem(at: ubqtURL)
                    }
                    catch{
                        print(error)
                    }
                }
                
                do{
                    try FileManager.default.copyItem(at: aURL, to: ubqtURL)
                     self.showProcess_Success(Title: "Success", Description: "Your chat backup successfully upload on your iCloud account")
                }
                catch{
                    //print("Error occurred: \(String(describing: error))")
                     self.showProcess_Error(Title: "Error", Description: "Something was wrong. Couldn't upload your backup on your iCloud.\n\(error.localizedDescription)")
                }
            }
            else {
                self.showProcess_Error(Title: "Error", Description: "Something was wrong. Couldn't upload your backup on your iCloud.")
            }
            
        })
    }
    
    func getFileFromiCloud(ubiquityURL:URL?) -> URL {
        
        let localDocumentsURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last
        let myLocalFile = localDocumentsURL?.appendingPathComponent((ubiquityURL?.lastPathComponent)!)
        
        //print("Locally Saved File : \(myLocalFile!)\n")
        
        if FileManager.default.fileExists(atPath: (myLocalFile?.path)!){
            do{
                try FileManager.default.removeItem(at: myLocalFile!)
            }
            catch{
                print(error)
            }
        }
        
        do{
            try FileManager.default.copyItem(at: ubiquityURL!, to: myLocalFile!)
              return ubiquityURL!
        }
        catch{
            print(error)
            return getDocumentsDirectoryURL()!
        }
      
    }
    
    
    
    //MARK: iCloud - Upload Data
    func iCloud_uploadContent(localURL:URL) -> Void  {
        if iCloudAvailable() {
            self.storeFileToiCloud(localURL: localURL)
        }
    }
    
     //MARK: iCloud - Download Data
    
    func iCloud_Download_HiddenChat() -> Void {
        if iCloudAvailable() {
            
            self.showProcess(Title: "Download hidden chat", Description: "Download your hidden chat in iCloud.")
            
            rootDirectory(forICloud: {(_ ubiquityURL: URL) -> Void in
                let fileURL = ubiquityURL.appendingPathComponent("\(Folder_HiddenChat).zip")
                //print("fileURL : \(fileURL)")
                
                let downloadContentURL = self.getFileFromiCloud(ubiquityURL: fileURL)
                //print("downloadContentURL : \(downloadContentURL)")
                
                //PV
                if (downloadContentURL.absoluteString != getDocumentsDirectoryURL()?.absoluteString) {
                    
                    self.showProcess(Title: "Import hidden chat", Description: "Download your hidden chat from iCloud.\nPlease wait...")
                    
                    //Download zip file and import into Coredata
                    self.import_HiddenChat()
                }
                else {
                    //------>
                }
            })
        }
    }
    
    func iCloud_RestoreChat() -> Void {
        if iCloudAvailable() == true {
            rootDirectory(forICloud: {(_ ubiquityURL: URL) -> Void in
                //print("ubiquityURL = \(ubiquityURL)\n")
                
                var ubqtURL = ubiquityURL
                ubqtURL = ubqtURL.appendingPathComponent(iCloudUpload_FileName)
                
                //Check file already exists file in iCloud
                if FileManager.default.fileExists(atPath: ubqtURL.path) {
                    //print("ubqtURL = \(ubqtURL)\n")
                    //print("Success : Get file already exist in iCloud - YES")
                    
                    let alert = UIAlertController(title: "Restore backup", message: "\nChat backup found\nRestore your chat messages and media from your phone's storage. If you don't restore now, you won't be able to restore leter.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Restore".uppercased(), style: .default, handler: { _ in
                        //print("Tap - Restore")
                        UserDefaultManager.setBooleanToUserDefaults(value: true, key: kIsRestored)
                        let downloadContentURL = self.getFileFromiCloud(ubiquityURL: ubqtURL)
                        //print("downloadContentURL : \(downloadContentURL)")
                        
                        if (downloadContentURL.absoluteString != getDocumentsDirectoryURL()?.absoluteString) {
                            self.viewProcess.isHidden = false
                            self.import_Coredata()
                        }
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Skip Restore".uppercased(), style: .destructive, handler: { _ in
                        //print("Tap - Skip Restore")
                        UserDefaultManager.setBooleanToUserDefaults(value: false, key: kIsRestored)
                        let alert_skip = UIAlertController(title: "Skip restoring your messages and media? You won't be able to restore later.", message: nil, preferredStyle: .alert)
                        alert_skip.addAction(UIAlertAction(title: "Skip Restore".uppercased(), style: .default, handler: { _ in
                            //print("Tap - Skip Restore")
                            
                            self.imgActionLogo.image = self.img_error
                            self.btnCancelAction(UIButton.init())
                        }))
                        alert_skip.addAction(UIAlertAction(title: "Cancel".uppercased(), style: .destructive, handler: { _ in
                            //print("Tap - Cancel")
                              UserDefaultManager.setBooleanToUserDefaults(value: false, key: kIsRestored)
                            self.iCloud_RestoreChat()
                        }))
                        APP_DELEGATE.appNavigation?.visibleViewController?.present(alert_skip, animated: true, completion: nil)
                    }))
                    
                    //self.present(alert, animated: true, completion: nil)
                    APP_DELEGATE.appNavigation?.visibleViewController?.present(alert, animated: true, completion: nil)
                }
                else {
                    //print("Ooops : Get file already exist in iCloud - NO")
                    self.btnDismissAction()
                }
                //print("Backup not avalable in iCloud")
            })
        }
        else {
            showProcess_Error(Title: "Error", Description: "Something was wrong. Couldn't find backup on iCloud.\n iCloud Unavailable")
        }
    }
    
    //MARK: iCloud Remove/Delete
    func iCloud_RemoveContent(contentName:String) -> Void {
        // Let's get the root directory for storing the file on iCloud Drive
        rootDirectory(forICloud: {(_ ubiquityURL: URL) -> Void in
            //print("ubiquityURL = \(ubiquityURL)\n")
            
            var ubqtURL = ubiquityURL
            ubqtURL = ubqtURL.appendingPathComponent(contentName)
            //print("ubqtURL = \(ubqtURL)\n")
            
            //Remove already exists file in iCloud
            if FileManager.default.fileExists(atPath: ubqtURL.path) {
                do {
                    try FileManager.default.removeItem(at: ubqtURL)
                    //print("Success : Already exist file remove in iCloud :\(ubqtURL)")
                }
                catch {
                    //print("Error : Already exist file remove in iCloud : \(String(describing: error))")
                }
            }
        })
    }
}
