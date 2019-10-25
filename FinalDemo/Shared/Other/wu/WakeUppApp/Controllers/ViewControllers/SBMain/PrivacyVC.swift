//
//  PrivacyVC.swift
//  WakeUppApp
//
//  Created by C025 on 05/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
//import PrivacyUtils

enum enumPrivacy : Int {
    case enumPrivacy_None = 0
    case enumPrivacy_LastSeen
    case enumPrivacy_ProfilePhoto
    case enumPrivacy_About
    case enumPrivacy_Status
    case enumPrivacy_BlockedContacts
    case enumPrivacy_ReadReceipts
}

class PrivacyVC: UIViewController, PopupVC_Delegate {
    
    //MARK: Outlet
    @IBOutlet weak var btnLastSeen: UIButton!
    @IBOutlet weak var lblLastSeen: UILabel!
    
    @IBOutlet weak var btnProfilePhoto: UIButton!
    @IBOutlet weak var lblProfilePhoto: UILabel!
    
    @IBOutlet weak var btnAbout: UIButton!
    @IBOutlet weak var lblAbout: UILabel!
    
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var lblStatus: UILabel!
    
    @IBOutlet weak var btnBlockedContacts: UIButton!
    @IBOutlet weak var lblBlockedContacts: UILabel!
    
    @IBOutlet weak var imgReadReceipts: UIImageView!
    @IBOutlet weak var btnReadReceipts: UIButton!
    
    //MARK: Variable
    var objEnumPrivacy : enumPrivacy = enumPrivacy.enumPrivacy_None // Detect who button click flag manage
    var objEnumPrivacyOption : enumPrivacyOption = enumPrivacyOption.enumPrivacyOption_Nobody // Detect who option flag manage
    //var objEnumPrivacyOption : PrivacyUtils.enumPrivacyOption = enumPrivacyOption.enumPrivacyOption_Nobody // Detect who option flag manage
    var flag_ReadReceipts : Bool = true // For use Manage Read Receipts
    let imgReadReceipts_yes : UIImage = #imageLiteral(resourceName: "switch_on")
    let imgReadReceipts_no : UIImage = #imageLiteral(resourceName: "switch_off")
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fillValue()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:-  Delegate Method
    //MARK:  PopupVC_Delegate
    func manage_BlockContactUpdate() {
        let arrBlockUser : NSArray = APP_DELEGATE.get_BlockContactList()
        lblBlockedContacts.text = arrBlockUser.count == 0 ? "0" : "\(arrBlockUser.count)"
    }
    
    //MARK:-  Custom Function
    func fillValue() -> Void {
        //Last Seen
        
        lblLastSeen.text = get_StatusValue(statusFlag: UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_LastSeen))
        
        //Profile Photo
        lblProfilePhoto.text = get_StatusValue(statusFlag: UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_ProfilePhoto))
        
        //About
        lblAbout.text = get_StatusValue(statusFlag: UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_About))
        
        //Status
        lblStatus.text = enumPrivacyOption.enumPrivacyOption_Mycontact.rawValue
        lblStatus.text = get_StatusValue_story(statusFlag: UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_Status)) //PV
        
        //Block Contact
        self.manage_BlockContactUpdate()
        
        //Read Receipts
        let strReadReceipts : String = UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_ReadReceipts)
        if (strReadReceipts.uppercased() == "1".uppercased()) {
            flag_ReadReceipts = true
            imgReadReceipts.image = imgReadReceipts_yes
        }
        else {
            flag_ReadReceipts = false
            imgReadReceipts.image = imgReadReceipts_no
        }
    }
    
    func get_StatusValue(statusFlag : String) -> String {
        var strStatusFlagValue : String = enumPrivacyOption.enumPrivacyOption_Nobody.rawValue
        
        if (statusFlag.uppercased() == "0".uppercased()) {
            strStatusFlagValue = enumPrivacyOption.enumPrivacyOption_Nobody.rawValue
        }
        else if (statusFlag.uppercased() == "1".uppercased()) {
            strStatusFlagValue = enumPrivacyOption.enumPrivacyOption_Mycontact.rawValue
        }
        else if (statusFlag.uppercased() == "2".uppercased()) {
            strStatusFlagValue = enumPrivacyOption.enumPrivacyOption_Everyone.rawValue
        }
        return strStatusFlagValue
    }
    func get_StatusValue_story(statusFlag : String) -> String {
        var strStatusFlagValue : String = enumPrivacyOption.enumPrivacyOption_Nobody.rawValue
        
        if (statusFlag.uppercased() == "0".uppercased()) {
            strStatusFlagValue = enumPrivacyOption.enumPrivacyOption_Nobody.rawValue
        }
        else if (statusFlag.uppercased() == "3".uppercased()) {
            strStatusFlagValue = "My Contacts Except"
        }
        else if (statusFlag.uppercased() == "4".uppercased()) {
            strStatusFlagValue = "Only Share with"
        }
        else {
            strStatusFlagValue = enumPrivacyOption.enumPrivacyOption_Mycontact.rawValue
        }
        
        return strStatusFlagValue
    }
    func privacyOption(strMess:String) -> Void {
        
        let alert = UIAlertController(title: "Changes to your privacy settings won't affect status updates that you've sent already.'", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: enumPrivacyOption.enumPrivacyOption_Nobody.rawValue, style: .default, handler: { _ in
            self.privacyOption_Select(strSelectedValue: enumPrivacyOption.enumPrivacyOption_Nobody.rawValue)
            self.set_ParameterForUpdateSetting(enumPrivacyOption: enumPrivacyOption.enumPrivacyOption_Nobody)
        }))
        alert.addAction(UIAlertAction(title: enumPrivacyOption.enumPrivacyOption_Mycontact.rawValue, style: .default, handler: { _ in
            self.privacyOption_Select(strSelectedValue: enumPrivacyOption.enumPrivacyOption_Mycontact.rawValue)
            self.set_ParameterForUpdateSetting(enumPrivacyOption: enumPrivacyOption.enumPrivacyOption_Mycontact)
        }))
        alert.addAction(UIAlertAction(title: "My Contacts Except", style: .default, handler: { _ in
//            self.privacyOption_Select(strSelectedValue: "My Contacts Except")
//            self.update_status_setting(vall: "3")
              self.lblStatus.text = "My Contacts Except"
            let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: idSelectMembersVC) as! SelectMembersVC
            //vc.forGroupChat = true
            vc.pagetitle = "My Contacts Except"
            vc.objEnumSelectMember = .enumSelectMember_StatusPrivacy
            APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Only Share With", style: .default, handler: { _ in
//            self.privacyOption_Select(strSelectedValue: "Only Share With")
//            self.update_status_setting(vall: "4")
              self.lblStatus.text = "Only Share With"
            let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: idSelectMembersVC) as! SelectMembersVC
            //vc.forGroupChat = true
            vc.pagetitle = "Only Share With"
            vc.objEnumSelectMember = .enumSelectMember_StatusPrivacy
            APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
        }))
      
        if strMess == "Status" // Objenumprivcy
        { }
        else {
        alert.addAction(UIAlertAction(title: enumPrivacyOption.enumPrivacyOption_Everyone.rawValue, style: .default, handler: { _ in
            self.privacyOption_Select(strSelectedValue: enumPrivacyOption.enumPrivacyOption_Everyone.rawValue)
            self.set_ParameterForUpdateSetting(enumPrivacyOption: enumPrivacyOption.enumPrivacyOption_Everyone)
        }))
        }
        
        alert.addAction(UIAlertAction.init(title: "Cancel".uppercased(), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Set Selected Option set in Label
    func privacyOption_Select(strSelectedValue:String) -> Void {
        switch objEnumPrivacy {
        case .enumPrivacy_None:
            break
        case .enumPrivacy_LastSeen:
            lblLastSeen.text = strSelectedValue
            break
        case .enumPrivacy_ProfilePhoto:
            lblProfilePhoto.text = strSelectedValue
            break
        case .enumPrivacy_About:
            lblAbout.text = strSelectedValue
            break
        case .enumPrivacy_Status:
            lblStatus.text = strSelectedValue
            break
        case .enumPrivacy_BlockedContacts:
            break
        case .enumPrivacy_ReadReceipts:
            break
        }
    }
    
    func update_status_setting(vall:String)
    {
        var strAppliedSettingChanges_Action : String = ""
        var strAppliedSettingChanges_Value : String = ""
        strAppliedSettingChanges_Action = "status_privacy"
        strAppliedSettingChanges_Value = vall
        UserDefaultManager.setStringToUserDefaults(value: strAppliedSettingChanges_Value , key: kPrivacy_Status)
        UserDefaultManager.setStringToUserDefaults(value: "status_privacy", key: "UpdateUserSettings")
        if (strAppliedSettingChanges_Action.count == 0) { return }
        let parameter:NSDictionary = ["service":APIUpdateUserSettings,
                                      "request": ["action":strAppliedSettingChanges_Action,
                                                  "value":strAppliedSettingChanges_Value,
                                                  "userid":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)],
                                      "auth" : getAuthForService()]
        APP_DELEGATE.api_UpdateUserSettings(parameter: parameter)
    }
    
    //Set Selected Option set in Label
    func set_ParameterForUpdateSetting(enumPrivacyOption:enumPrivacyOption) -> Void {
        
        var strAppliedSettingChanges_Action : String = "" // Get what setting option change
        var strAppliedSettingChanges_Value : String = "" //Get what setting option changes values
        switch objEnumPrivacy {
        case .enumPrivacy_None: break
        case .enumPrivacy_LastSeen:
            strAppliedSettingChanges_Action = "lastseen_privacy"
            strAppliedSettingChanges_Value = String(enumPrivacyOption.hashValue)
            
            //Change Values in UserDefault
            UserDefaultManager.setStringToUserDefaults(value: strAppliedSettingChanges_Value , key: kPrivacy_LastSeen)
            
            //Manage in App Delegate
            UserDefaultManager.setStringToUserDefaults(value: "lastseen_privacy", key: "UpdateUserSettings")
            break
            
        case .enumPrivacy_ProfilePhoto:
            strAppliedSettingChanges_Action = "photo_privacy"
            strAppliedSettingChanges_Value = String(enumPrivacyOption.hashValue)
            
            //Change Values in UserDefault
            UserDefaultManager.setStringToUserDefaults(value: strAppliedSettingChanges_Value , key: kPrivacy_ProfilePhoto)
            
            //Manage in App Delegate
            UserDefaultManager.setStringToUserDefaults(value: "photo_privacy", key: "UpdateUserSettings")
            break
            
        case .enumPrivacy_About:
            strAppliedSettingChanges_Action = "about_privacy"
            strAppliedSettingChanges_Value = String(enumPrivacyOption.hashValue)
            
            //Change Values in UserDefault
            UserDefaultManager.setStringToUserDefaults(value: strAppliedSettingChanges_Value , key: kPrivacy_About)
            
            //Manage in App Delegate
            UserDefaultManager.setStringToUserDefaults(value: "about_privacy", key: "UpdateUserSettings")
            break
            
        case .enumPrivacy_Status:
            strAppliedSettingChanges_Action = "status_privacy"
            strAppliedSettingChanges_Value = String(enumPrivacyOption.hashValue)
            
            //Change Values in UserDefault
            UserDefaultManager.setStringToUserDefaults(value: strAppliedSettingChanges_Value , key: kPrivacy_Status)
            
            //Manage in App Delegate
            UserDefaultManager.setStringToUserDefaults(value: "status_privacy", key: "UpdateUserSettings")
            break
            
        case .enumPrivacy_BlockedContacts: break
        case .enumPrivacy_ReadReceipts:
            //Called API in button click.
            break
        }
        
        //If Not any Changes action for return
        if (strAppliedSettingChanges_Action.count == 0) { return }
        
        //Set Parameter for called API
        let parameter:NSDictionary = ["service":APIUpdateUserSettings,
                                      "request": ["action":strAppliedSettingChanges_Action,
                                                   "value":strAppliedSettingChanges_Value,
                                                   "userid":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)],
                                      "auth" : getAuthForService()]
        //print("APIUpdateUserSettings parameter: \(parameter)")
        APP_DELEGATE.api_UpdateUserSettings(parameter: parameter)
    }
    
    //MARK: - Button action method
    @IBAction func btnBackAction() {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnPrivacyButtonAction(_ sender: UIButton) {
        if (sender == btnLastSeen) {
            objEnumPrivacy = .enumPrivacy_LastSeen
            self.privacyOption(strMess: "Last Seen")
        }
        else if (sender == btnProfilePhoto) {
            objEnumPrivacy = .enumPrivacy_ProfilePhoto
            self.privacyOption(strMess: "Profile Photo")
        }
        else if (sender == btnAbout) {
            objEnumPrivacy = .enumPrivacy_About
            self.privacyOption(strMess: "About")
        }
        else if (sender == btnStatus) {
            objEnumPrivacy = .enumPrivacy_Status
            self.privacyOption(strMess: "Status")
        }
        else if (sender == btnBlockedContacts)
        {
            //Check NoOfBlockContact then open Popup
            if (TRIM(string: lblBlockedContacts.text as Any).uppercased() == "0".uppercased())
            {
                showMessage("No blocked contacts");
                return
            }
            
            objEnumPrivacy = .enumPrivacy_BlockedContacts
            
            let objPopupVC : PopupVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idPopupVC) as! PopupVC
            objPopupVC.delegate = self
            objPopupVC.objEnumPopup = .enumPopup_BlockContact
            objPopupVC.strTitle = "Blocked Contacts".uppercased()
            
            objPopupVC.modalPresentationStyle = .overCurrentContext
            self.present(objPopupVC, animated: true, completion: nil)
        }
        else if (sender == btnReadReceipts) {
            objEnumPrivacy = .enumPrivacy_ReadReceipts
            
            if flag_ReadReceipts == false {
                imgReadReceipts.image = imgReadReceipts_yes
                flag_ReadReceipts = true
            }
            else {
                imgReadReceipts.image = imgReadReceipts_no
                flag_ReadReceipts = false
            }
            
            
            //Manage in App Delegate
            UserDefaultManager.setStringToUserDefaults(value: "read_receipts_privacy", key: "UpdateUserSettings")
            
            //Called API
            let strStatus : String = flag_ReadReceipts == true ? "1" : "0"
            let parameter:NSDictionary = ["service":APIUpdateUserSettings,
                                          "request":
                                            ["action":"read_receipts_privacy",
                                             "value":strStatus,
                                             "userid":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)],
                                          "auth" : getAuthForService()]
            //print("APIUpdateUserSettings parameter: \(parameter)")
            APP_DELEGATE.api_UpdateUserSettings(parameter: parameter)
            
            //Change Values in UserDefault
            UserDefaultManager.setStringToUserDefaults(value: strStatus , key: kPrivacy_ReadReceipts)
        }
    }
}

