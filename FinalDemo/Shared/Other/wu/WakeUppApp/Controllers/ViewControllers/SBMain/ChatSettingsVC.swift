//
//  ChatSettingsVC.swift
//  WakeUppApp
//
//  Created by C025 on 05/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import Zip

class ChatSettingsVC: UIViewController {
    
    //MARK: Outlet
    @IBOutlet weak var lblFontSize: UILabel!
    @IBOutlet weak var btnFontSize: UIButton!
    @IBOutlet weak var btnFontSize_Small: UIButton!
    @IBOutlet weak var btnFontSize_Medium: UIButton!
    @IBOutlet weak var btnFontSize_Large: UIButton!
    @IBOutlet weak var btnFontSizeDismiss: UIButton!
    @IBOutlet weak var viewFontSize: UIView!
    @IBOutlet weak var lc_viewFontSize_x: NSLayoutConstraint!
    
    @IBOutlet weak var btnEnterIsSend: UIButton!
    
    @IBOutlet weak var btnChatBackup: UIButton!
    @IBOutlet weak var btnClearAllChat: UIButton!
    @IBOutlet weak var btnDeleteAllChat: UIButton!
    
    //MARK: Variable
    var flag_SaveCameraRoll : Bool = true // For use Manage SaveCameraRoll status
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Default Hide PopupView
        lc_viewFontSize_x.constant = SCREENWIDTH()
        self.view.layoutIfNeeded()
        
        setCurrentFontSize()
        
        //Manage Entwr key send message status
        self.btnEnterIsSend.setImage(#imageLiteral(resourceName: "switch_off"), for: .normal)
        self.btnEnterIsSend.setImage(#imageLiteral(resourceName: "switch_on"), for: .selected)
        //Get status in UserDefault and set
        self.btnEnterIsSend.isSelected = UserDefaultManager.getBooleanFromUserDefaults(key: kEnterKeyIsSend)
    }
    
    func setCurrentFontSize() {
        switch UserDefaultManager.getStringFromUserDefaults(key: kChatFontCurrentSize) {
        case kChatFontSizeSmall:
            lblFontSize.text = "Small"
        case kChatFontSizeMedium:
            lblFontSize.text = "Medium"
        case kChatFontSizeLarge:
            lblFontSize.text = "Large"
        default:
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Custom Function
    func manage_FontSizePopup(showNow : Bool) {
        
        let duration = 0.40
        if(showNow == true) {
            //Set BG default BG
            self.viewFontSize.backgroundColor = UIColor.clear
            
            //Show View
            UIView.animate(withDuration: duration, animations: {
                self.lc_viewFontSize_x.constant = 0
                self.view.layoutIfNeeded()
            }) { (value: Bool) in
                //Change BG Color
                UIView.animate(withDuration: duration/2) {
                    self.viewFontSize.backgroundColor = COLOR_PopupBG
                }
            }
        }
        else {
            //Set BG default BG
            UIView.animate(withDuration: duration/2) {
                self.viewFontSize.backgroundColor = UIColor.clear
            }
            
            //Hide View
            runAfterTime(time: duration/2) {
                UIView.animate(withDuration: duration/2) {
                    self.lc_viewFontSize_x.constant = SCREENWIDTH()
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func manage_Restore_HiddenChat_Validation() {
        
        let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: "HideChatPasscodeVC") as! HideChatPasscodeVC
        vc.modalPresentationStyle = .overCurrentContext
        vc.isJustForSecurityPurpose = true
        vc.isJustCheckValidPassword = true
        APP_DELEGATE.appNavigation?.present(vc, animated: false, completion: nil)
        vc.validateHandler = {success in
            if success{
                //print("Valid Password")
                self.manage_Restore_HiddenChat()
            }
            else {
                //print("Wrong Password")
                //print("Wrong password\nPlease try again.")
            }
        }
    }
    
    func manage_Restore_HiddenChat() {
        self.dismiss(animated: false, completion: nil)
        runAfterTime(time: 1.20, block: {
            let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ImportExportProcessVC" ) as! ImportExportProcessVC
            objVC.strImgURL = ""
            objVC.strTitle = ""
            objVC.objEnumImpExpoAction = .Import_HiddenChat
            objVC.Popup_Show(onViewController: self)
        })
    }
    
    //MARK: - Button action method
    @IBAction func btnBackAction() {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnChatSettingAction(_ sender: UIButton) {
        
        if (sender == btnEnterIsSend) {
            self.btnEnterIsSend.isSelected = self.btnEnterIsSend.isSelected == true ? false : true
            
            //Stored Data in UserDefault
            UserDefaultManager.setBooleanToUserDefaults(value: self.btnEnterIsSend.isSelected, key: kEnterKeyIsSend)
        }
        else if (sender == btnChatBackup) {
            self.manage_ExportChat()
        }
        else if (sender == btnClearAllChat)
        {
            let alert = UIAlertController(title: "Deleting your chats will:", message: "• Delete your message history on this phone \n• Delete all sent and received media", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { _ in
                let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: "NewChatVC") as! NewChatVC
                vc.redirectfrom = "DeleteChat"
                let navigation = UINavigationController.init(rootViewController: vc)
                navigation.isNavigationBarHidden = true
                navigation.modalPresentationStyle = .overCurrentContext
                self.present(navigation, animated: true, completion: nil)
               
            }))
            alert.addAction(UIAlertAction.init(title: "Cancel".uppercased(), style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if (sender == btnDeleteAllChat)
        {
           
        }
    }
    
    @IBAction func btnFontSizeAction(_ sender: UIButton) {
        if (sender == btnFontSize) {
            self.manage_FontSizePopup(showNow: true)
            return
        }
        else if (sender == btnFontSizeDismiss) {
            self.manage_FontSizePopup(showNow: false)
            return
        }
        else if (sender == btnFontSize_Small) {
            UserDefaultManager.setStringToUserDefaults(value: kChatFontSizeSmall, key: kChatFontCurrentSize)
        }
        else if (sender == btnFontSize_Medium) {
            UserDefaultManager.setStringToUserDefaults(value: kChatFontSizeMedium, key: kChatFontCurrentSize)
        }
        else if (sender == btnFontSize_Large) {
            UserDefaultManager.setStringToUserDefaults(value: kChatFontSizeLarge, key: kChatFontCurrentSize)
        }
        UserDefaultManager.setBooleanToUserDefaults(value: true, key: kIsChatFontCurrentSizeSet)
        self.manage_FontSizePopup(showNow: false)
        setCurrentFontSize()
    }
    
    //MARK: - Manage Chat Backup
    func manage_ExportChat() -> Void {
        let ChatBackup = UIAlertController.init(title: "Chat backup" , message: "Back up your messages and media to iCloud. You can restore them when you reinstall \(APPNAME). Your messages and media will also back up to your phone's internal storage. Media and message you backup are not protected by \(APPNAME) end-to-end encryption white in iCloud.", preferredStyle: .actionSheet)
        
        let ChatBackup_AllChat = UIAlertAction.init(title: "All Chat".uppercased(), style: .default) { (action) in
            let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ImportExportProcessVC" ) as! ImportExportProcessVC
            objVC.strImgURL = ""
            objVC.strTitle = "Chat Backup"
            objVC.objEnumImpExpoAction = .Export_AppChat
            objVC.Popup_Show(onViewController: self)
        }
        ChatBackup.addAction(ChatBackup_AllChat)
        
        //Check Hiddent Set Password Set
        //if UserDefaultManager.getBooleanFromUserDefaults(key: kHiddenChatSetupDone) {
        let ChatBackup_HiddenChat = UIAlertAction.init(title: "Hidden chat".uppercased(), style: .default) { (action) in
            let hiddenChat = UIAlertController.init(title: "Backup Hidden Chat" , message: "Choose the option for performing actions of hidden chat", preferredStyle: .actionSheet)
            let hiddenChat_backup = UIAlertAction.init(title: "Hidden chat backup", style: .default) { (action) in
                //Remove already exist file in local directory.
                let arrContent = getAllContent(inDirectoryURL: getURL_HiddenChat_Directory())
                for objURL in arrContent { removeFile_onURL(fileURL: objURL)}
                let arrPersonalChat = CoreDBManager.sharedDatabase.getHiddenFriendList() //Personal Chat backup
                let arrGroupChat = CoreDBManager.sharedDatabase.getHiddenGroupList() //Group Chat backup
                
                //Show Process Loader
                let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ImportExportProcessVC" ) as! ImportExportProcessVC
                objVC.strImgURL = ""
                objVC.strTitle = "Backup hidden chat"
                let objHiddenChatInfo = HiddenChatInfo.init(arrPersonalChat: arrPersonalChat,
                                                            arrGroupChat: arrGroupChat)
                objVC.objHiddenChatInfo = objHiddenChatInfo
                objVC.objEnumImpExpoAction = .Export_HiddenChat
                objVC.Popup_Show(onViewController: self)
            }
            hiddenChat.addAction(hiddenChat_backup)
            
            let hiddenChat_restore = UIAlertAction.init(title: "Hidden chat restore", style: .default) { (action) in
                /*let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ImportExportProcessVC" ) as! ImportExportProcessVC
                objVC.strImgURL = ""
                objVC.strTitle = ""
                objVC.objEnumImpExpoAction = .Import_HiddenChat
                objVC.Popup_Show(onViewController: self)*/
                
                self.manage_Restore_HiddenChat_Validation()
            }
            hiddenChat.addAction(hiddenChat_restore)
            
            let hiddenChat_cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
            hiddenChat.addAction(hiddenChat_cancel)
            
            self.present(hiddenChat, animated: true, completion: nil)
        }
        ChatBackup.addAction(ChatBackup_HiddenChat)
        //}
        
        let ChatBackup_Cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        ChatBackup.addAction(ChatBackup_Cancel)
        
        self.present(ChatBackup, animated: true, completion: nil)
    }
}

