//
//  ChatHistoryVC.swift
//  WakeUppApp
//
//  Created by Admin on 07/08/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import Zip

class ChatHistoryVC: UIViewController {

    // MARK: - Outlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewRestoreChat: UIView!
    @IBOutlet weak var lc_viewRestoreChat_Height: NSLayoutConstraint!
    
    @IBOutlet weak var viewEmpty: UIView!
    @IBOutlet weak var lblEmptyMess: UILabel!
    
    // MARK: - Variable
    var strUserID : String = ""
    var strTitle : String = ""
    var strCountryCodeOfPhoneNo : String = "" // Get Particuler Contact No CountryCode
    var strUserPhoneNo : String = ""
    var strProfilePhotoURL : String = ""
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewEmpty.isHidden = true
        self.tableView.isHidden = true
        if (APP_DELEGATE.User_Exists_inBlockContactList(strUserID: self.strUserID) == true) {
            self.viewEmpty.isHidden = false
            self.lblEmptyMess.text = "This contact is blocked, So you will not be able to view chat history operation."
        }
        else {
            self.tableView.isHidden = false
            self.manage_HiddenChat_RestoreOption()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: -
    //Manage Hidden chat restore option
    func manage_HiddenChat_RestoreOption() -> Void {
        if (APP_DELEGATE.User_Exists_inHiddenChat_UserList(strUserID: strUserID) == true) { self.lc_viewRestoreChat_Height.constant = 60 }
        else { self.lc_viewRestoreChat_Height.constant = 0 }
        
        self.tableView.layoutIfNeeded()
    }
    
    /*func manage_ExportChat(withMedia : Bool) {
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
            showMessage("No chat available for you and \(self.strTitle)")
        }
        else {
            //Save in File
            //NOTE: create - "Document/(AppName)/Chat_UserContactNo" folder and save chat data in this folder.
            
            let chatBackupFolderURL : URL = getURL_ChatWithUser_Directory(countryCode: self.strCountryCodeOfPhoneNo, PhoneNo: self.strUserPhoneNo)
            //Check folder creded or not
            if (chatBackupFolderURL.lastPathComponent.count == 0) {
                showMessage("Error:\nSomething was wrong. Couldn't complete backup. Please try after some time")
                return
            }
            
            //Set Backup fileName and fileType
            var strFileName = "\(APPNAME)_\(Folder_Chat)Backup_\(self.strCountryCodeOfPhoneNo)\(self.strUserPhoneNo).txt" //.TXT File
            
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
                        
                        //share(shareContent: [zipFilePath])
                        self.share_ExportChat(chatContent: [zipFilePath])
                        
                        
                        //Remove file in Dir.
                        removeFile_onURL(fileURL: txtExtFilePath.absoluteURL)
                    }
                    catch {
                        hideHUD() // Hide Loader
                        
                        //print("Something went wrong")
                        showMessage("Error:\nSomething was wrong. Couldn't complete backup. Please try after some time")
                    }
                }
                else {
                    //share(shareContent: [fileUrl])
                    self.share_ExportChat(chatContent: [fileUrl])
                }
            } catch {
                hideHUD() // Hide Loader
                
                //print("Error: \(error)")
                //print("Error: \(error.localizedDescription)")
                showMessage("Error:\nSomething was wrong. Couldn't complete backup. Please try after some time")
            }
        }
    }
    
    //MARK: Share Export chat content
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
    }*/
    
    // MARK: - Button action
    @IBAction func btnBackClicked(_ sender: Any) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnExportChatAction(_ sender: Any) {
        let confirmAlert = UIAlertController.init(title: "Export Chat" , message: "Attaching media will generate a larger chat archive.", preferredStyle: .actionSheet)
        let attWithMedia = UIAlertAction.init(title: "Attach Media", style: .default) { (action) in
            //self.manage_ExportChat(withMedia: true)
            
            let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ImportExportProcessVC" ) as! ImportExportProcessVC
            let objPersonalChatInfo = PersonalChatInfo.init(userID: self.strUserID,
                                                            CountryCode: self.strCountryCodeOfPhoneNo,
                                                            PhoneNo: self.strUserPhoneNo,
                                                            ProfileImageURL: self.strProfilePhotoURL,
                                                            DisplayNameOfTitle: self.strTitle)
            objVC.objPersonalChatInfo = objPersonalChatInfo
            objVC.objEnumImpExpoAction = .Export_PersonalChat_withContent
            objVC.Popup_Show(onViewController: self)
        }
        confirmAlert.addAction(attWithMedia)
        
        let attWithoutMedia = UIAlertAction.init(title: "Without Media", style: .default) { (action) in
            //self.manage_ExportChat(withMedia: false)
            
            let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ImportExportProcessVC" ) as! ImportExportProcessVC
            let objPersonalChatInfo = PersonalChatInfo.init(userID: self.strUserID,
                                                            CountryCode: self.strCountryCodeOfPhoneNo,
                                                            PhoneNo: self.strUserPhoneNo,
                                                            ProfileImageURL: self.strProfilePhotoURL,
                                                            DisplayNameOfTitle: self.strTitle)
            objVC.objPersonalChatInfo = objPersonalChatInfo
            objVC.objEnumImpExpoAction = .Export_PersonalChat
            objVC.Popup_Show(onViewController: self)
        }
        confirmAlert.addAction(attWithoutMedia)
        
        let action_no = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        confirmAlert.addAction(action_no)
        
        present(confirmAlert, animated: true, completion: nil)
        //---------------------------------->
    }
    
    @IBAction func btnRestoreChatAction(_ sender: Any) {
        //iCloud_Download_HiddenChat()
        
        let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ImportExportProcessVC" ) as! ImportExportProcessVC
        objVC.strImgURL = self.strProfilePhotoURL
        objVC.strTitle = self.strTitle
        objVC.objEnumImpExpoAction = .Import_HiddenChat
        objVC.Popup_Show(onViewController: self)
    }
    
    @IBAction func btnClearChatAction(_ sender: Any) {
        if (self.strUserID.count == 0) { return }
        
        /*let confirm = UIAlertController.init(title: nil, message: "Are you sure you want to clear all chat messages in \(self.strTitle)?", preferredStyle: .alert)
        
        let actionYes = UIAlertAction.init(title: "Yes", style: .destructive, handler: { (action) in
            
            //Delete All Chat in Core data.
            CoreDBManager.sharedDatabase.deleteAllChatMessagesWith(userId: self.strUserID)
            
            //Remove All content in ChatDir.
            let URL_dirCurrentChat : URL = getURL_ChatWithUser_Directory(countryCode: self.strCountryCodeOfPhoneNo, PhoneNo: self.strUserPhoneNo)
            runAfterTime(time: 0.10, block: {
                let arrContent = getAllContent(inDirectoryURL: URL_dirCurrentChat)
                //print("arr : \(arrContent.count)")
                for filePath : URL in arrContent {
                    //print("getAllContent_inDir - FilePath: \(filePath)")
                    removeFile_onURL(fileURL: filePath)
                }
            })
            
            //Move to Back
            //APP_DELEGATE.appNavigation?.popViewController(animated: true)
            //APP_DELEGATE.appNavigation?.popToRootViewController(animated: true)
            
            let objChatListVC = loadVC(strStoryboardId: SB_CHAT, strVCId: idChatListVC)
            APP_DELEGATE.appNavigation?.pushViewController(objChatListVC, animated: true)
        })
        confirm.addAction(actionYes)
        
        let actionNo = UIAlertAction.init(title: "No", style: .cancel, handler:nil)
        confirm.addAction(actionNo)
        
        self.present(confirm, animated: true, completion: nil)*/
        
        let action = UIAlertController.init(title: nil, message: "Delete Messages", preferredStyle: .actionSheet)
        let action_ClearAllExceptStarred = UIAlertAction.init(title: "Clear all except starred", style: .default, handler: { (action) in
            
            let URL_dirCurrentChat : URL = getURL_ChatWithUser_Directory(countryCode: self.strCountryCodeOfPhoneNo, PhoneNo: self.strUserPhoneNo)
            var arrMess : [StructChat] = CoreDBManager.sharedDatabase.personalChat_Get_StarredChatMessages_with(userId: self.strUserID)
            arrMess = arrMess.filter({$0.kmessagetype == "1"})
            
            runAfterTime(time: 0.10, block: {
                let arrContent = getAllContent(inDirectoryURL: URL_dirCurrentChat)
                let arrContentName : NSMutableArray = NSMutableArray.init()
                for objURL in arrContent { arrContentName.add(objURL.lastPathComponent) }
                
                for objURL in arrMess {
                    let strFileName : String = objURL.kmediaurl.lastPathComponent
                    if strFileName.count > 0 {
                        if arrContentName.contains(strFileName) == true { arrContentName.remove(strFileName) }
                        else {
                            //print("No file avalilable")                            
                        }
                    }
                }
                //Remove file in Local chat dir.
                for fileName in arrContentName {
                    removeFile(fileName: fileName as! String, inDirectory: URL_dirCurrentChat)
                }
            })
            
            //Delete Chat in Core data.
            CoreDBManager.sharedDatabase.personalChat_Delete_AllChatMessages_ExceptStarred_with(userId: self.strUserID)
            
            //Move to Back
            let objChatListVC = loadVC(strStoryboardId: SB_CHAT, strVCId: idChatListVC)
            APP_DELEGATE.appNavigation?.pushViewController(objChatListVC, animated: true)
        })
        action.addAction(action_ClearAllExceptStarred)
        
        let action_ClearAll = UIAlertAction.init(title: "Clear all messages", style: .destructive, handler: { (action) in
            //Delete All Chat in Core data.
            CoreDBManager.sharedDatabase.deleteAllChatMessagesWith(userId: self.strUserID)
            
            //Remove All content in ChatDir.
            let URL_dirCurrentChat : URL = getURL_ChatWithUser_Directory(countryCode: self.strCountryCodeOfPhoneNo, PhoneNo: self.strUserPhoneNo)
            runAfterTime(time: 0.10, block: {
                let arrContent = getAllContent(inDirectoryURL: URL_dirCurrentChat)
                //print("arr : \(arrContent.count)")
                for filePath : URL in arrContent {
                    //print("getAllContent_inDir - FilePath: \(filePath)")
                    removeFile_onURL(fileURL: filePath)
                }
            })
            
            //Move to Back
            let objChatListVC = loadVC(strStoryboardId: SB_CHAT, strVCId: idChatListVC)
            APP_DELEGATE.appNavigation?.pushViewController(objChatListVC, animated: true)
        })
        action.addAction(action_ClearAll)
        
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        action.addAction(actionCancel)
        self.present(action, animated: true, completion: nil)
    }

}
