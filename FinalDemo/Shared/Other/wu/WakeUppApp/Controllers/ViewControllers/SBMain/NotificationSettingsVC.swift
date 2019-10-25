//
//  NotificationSettingsVC.swift
//  WakeUppApp
//
//  Created by C025 on 05/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class NotificationSettingsVC: UIViewController {
    
    //MARK: Outlet
    //Message
    @IBOutlet weak var imgShowNoti_Message: UIImageView!
    @IBOutlet weak var btnShowNoti_Message: UIButton!
    
    @IBOutlet weak var viewNotiMessage: UIView!
    @IBOutlet weak var btnSound_Message: UIButton!
    @IBOutlet weak var lblSound_Message: UILabel!
    
    //Group
    @IBOutlet weak var imgShowNoti_Group: UIImageView!
    @IBOutlet weak var btnShowNoti_Group: UIButton!
    
    @IBOutlet weak var viewNotiGroup: UIView!
    @IBOutlet weak var btnSound_Group: UIButton!
    @IBOutlet weak var lblSound_Group: UILabel!
    
    //MARK: Variable
    var flag_ShowNoti_Message : Bool = true // For use Manage Read Show Notification status
    var flag_ShowNoti_Group : Bool = true // For use Manage Read Show Notification status
    
    let imgShowNoti_yes : UIImage = #imageLiteral(resourceName: "switch_on")
    let imgShowNoti_no : UIImage = #imageLiteral(resourceName: "switch_off")
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fillValue()
        
        self.lblSound_Message.text = "Note (Default)"
        self.lblSound_Group.text = "Note (Default)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:-  Custom Function
    func fillValue() -> Void {
        //Mess Notification
        let strShowNotification_Mess : String = UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_Notification_Message)
        if (strShowNotification_Mess.uppercased() == "1".uppercased()) {
            flag_ShowNoti_Message = true
            imgShowNoti_Message.image = imgShowNoti_yes
        }
        else {
            flag_ShowNoti_Message = false
            imgShowNoti_Message.image = imgShowNoti_no
        }
        //Manage Sound View
        viewNotiMessage.alpha = flag_ShowNoti_Message == false ? 0.50 : 1
        
        //Group Notification
        let strShowNotification_Group : String = UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_Notification_Group)
        if (strShowNotification_Group.uppercased() == "1".uppercased()) {
            flag_ShowNoti_Group = true
            imgShowNoti_Group.image = imgShowNoti_yes
        }
        else {
            flag_ShowNoti_Group = false
            imgShowNoti_Group.image = imgShowNoti_no
        }
        //Manage Sound View
        viewNotiGroup.alpha = flag_ShowNoti_Group == false ? 0.50 : 1
    }
    
    //MARK: - Button action method
    @IBAction func btnBackAction() {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnNotificationSettingButtonAction(_ sender: UIButton) {
        if (sender == btnShowNoti_Message) {
            if flag_ShowNoti_Message == false {
                imgShowNoti_Message.image = imgShowNoti_yes
                flag_ShowNoti_Message = true
            }
            else {
                imgShowNoti_Message.image = imgShowNoti_no
                flag_ShowNoti_Message = false
            }
            
            
            //Manage Sound View
            viewNotiMessage.alpha = flag_ShowNoti_Message == false ? 0.50 : 1
            
            //Called API
            let strStatus : String = flag_ShowNoti_Message == true ? "1" : "0"
            let parameter:NSDictionary = ["service":APIUpdateUserSettings,
                                          "request":["action":"message_notification",
                                                     "value":strStatus],
                                          "auth" : getAuthForService()]
            //print("APIUpdateUserSettings parameter: \(parameter)")
            APP_DELEGATE.api_UpdateUserSettings(parameter: parameter)
            
            //Change Values in UserDefault
            UserDefaultManager.setStringToUserDefaults(value: strStatus , key: kPrivacy_Notification_Message)
        }
        
        if (sender == btnShowNoti_Group) {
            if flag_ShowNoti_Group == false {
                imgShowNoti_Group.image = imgShowNoti_yes
                flag_ShowNoti_Group = true
            }
            else {
                imgShowNoti_Group.image = imgShowNoti_no
                flag_ShowNoti_Group = false
            }
            
            
            //Manage Sound View
            viewNotiGroup.alpha = flag_ShowNoti_Group == false ? 0.50 : 1
            
            //Called API
            let strStatus : String = flag_ShowNoti_Message == true ? "1" : "0"
            let parameter:NSDictionary = ["service":APIUpdateUserSettings,
                                          "request":
                                            ["action":"group_notification",
                                             "value":strStatus],
                                          "auth" : getAuthForService()]
            //print("APIUpdateUserSettings parameter: \(parameter)")
            APP_DELEGATE.api_UpdateUserSettings(parameter: parameter)
            
            //Change Values in UserDefault
            UserDefaultManager.setStringToUserDefaults(value: strStatus , key: kPrivacy_Notification_Group)
        }
        else if (sender == btnSound_Message ) {
            if flag_ShowNoti_Message == false { return }
            
            let alert = UIAlertController(title: "Notificaton", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "None".uppercased(), style: .default, handler: { _ in
                self.lblSound_Message.text = "None"
            }))
            alert.addAction(UIAlertAction(title: "Note (Default)".uppercased(), style: .default, handler: { _ in
                self.lblSound_Message.text = "Note (Default)"
            }))
            alert.addAction(UIAlertAction.init(title: "Cancel".uppercased(), style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if (sender == btnSound_Group) {
            if flag_ShowNoti_Group == false { return }
            
            let alert = UIAlertController(title: "Notificaton", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "None".uppercased(), style: .default, handler: { _ in
                self.lblSound_Group.text = "None"
            }))
            alert.addAction(UIAlertAction(title: "Note (Default)".uppercased(), style: .default, handler: { _ in
                self.lblSound_Group.text = "Note (Default)"
            }))
            alert.addAction(UIAlertAction.init(title: "Cancel".uppercased(), style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
