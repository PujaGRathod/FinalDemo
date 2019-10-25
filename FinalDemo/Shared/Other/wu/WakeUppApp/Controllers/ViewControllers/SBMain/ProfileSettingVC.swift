//
//  ProfileSettingVC.swift
//  WakeUppApp
//
//  Created by C025 on 24/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class ProfileSettingVC: UIViewController {
    // MARK: - Variable
    
    @IBOutlet weak var imhProfile_Photo: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblUserBio: UILabel!
    @IBOutlet weak var btnProfileSetting: UIButton!
    
    @IBOutlet weak var btnAccountSetting: UIButton!
    @IBOutlet weak var btnChatSetting: UIButton!
    @IBOutlet weak var btnNotifiSetting: UIButton!
    @IBOutlet weak var btnInviteFriend: UIButton!
    @IBOutlet weak var btHelpAboutUs: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.fillValues()
    }
    
    // MARK: - Custom Function
    //---> Fill Value
    func fillValues() -> Void {
        let strPhoto = UserDefaultManager.getStringFromUserDefaults(key:kAppUserProfile)
        let strUsername = UserDefaultManager.getStringFromUserDefaults(key:kAppUserFullName)
        let strBio = UserDefaultManager.getStringFromUserDefaults(key:kBio)
        
        imhProfile_Photo.sd_setImage(with: URL(string: strPhoto), placeholderImage: ProfilePlaceholderImage)
        imhProfile_Photo.cornerRadius = imhProfile_Photo.frame.height/2
        lblUserName.text = strUsername.count == 0 ? "---" : strUsername
        lblUserBio.text = strBio.count == 0 ? "---" : strBio
    }
    
    // MARK: - Button Action Method
    @IBAction func btnBackAction() {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnSettingAction(_ sender: UIButton) {
        
        if (sender == btnProfileSetting) {
            let objVC : EditProfileVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idEditProfileVC) as! EditProfileVC
            APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
        }
        else if (sender == btnAccountSetting) {
            let objVC : AccountSettingsVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idAccountSettingsVC) as! AccountSettingsVC
            APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
        }
        else if (sender == btnChatSetting) {
            let objVC : ChatSettingsVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idChatSettingsVC) as! ChatSettingsVC
            APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
        }
        else if (sender == btnNotifiSetting) {
            let objVC : NotificationSettingsVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idNotificationSettingsVC) as! NotificationSettingsVC
            APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
        }
        else if (sender == btnInviteFriend) {
            inviteFriend()
        }
        else if (sender == btHelpAboutUs) {
            let objVC : HelpAboutUsVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idHelpAboutUsVC) as! HelpAboutUsVC
            APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
        }
    }
}

