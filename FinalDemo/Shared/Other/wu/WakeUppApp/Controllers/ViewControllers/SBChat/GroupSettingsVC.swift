//
//  GroupSettingsVC.swift
//  WakeUppApp
//
//  Created by C025 on 09/07/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class GroupSettingsVC: UIViewController {

    //MARK: Outlet
    @IBOutlet weak var btnEditGroupInfo: UIButton!
    @IBOutlet weak var lblEditGroupInfo_Status: UILabel!
    
    @IBOutlet weak var btnSendMessasge: UIButton!
    @IBOutlet weak var lblSendMessasge_Status: UILabel!
    
    @IBOutlet weak var btnEditGroupAdmins: UIButton!
    
    var selectedGroup:GroupInfo!
    
    //MARK: Variable
    var strAllMembers : String = "All members"
    var strOnlyAdmins : String = "Only admins"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.fillValue()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:-  Custom Function
    func fillValue() -> Void {
        self.lblEditGroupInfo_Status.text = self.strOnlyAdmins
        self.lblSendMessasge_Status.text = self.strOnlyAdmins
        
        if selectedGroup.edit_permission! == "0"{
            self.lblEditGroupInfo_Status.text = self.strAllMembers
        }
        
        if selectedGroup.msg_permission! == "0"{
            self.lblSendMessasge_Status.text = self.strAllMembers
        }
    }
    
    //MARK:- Button action methods
    @IBAction func btnBackAction() {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnEditGroupInfoAction() {
        let alert = UIAlertController(title: "Edit group info",
                                      message: "Choose who can change this group’s subject, icon and description", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: self.strAllMembers, style: .default, handler: { _ in
            self.lblEditGroupInfo_Status.text = self.strAllMembers
            self.updateGroupSettings(edit_permission:"0" , msg_permission: self.selectedGroup.msg_permission!)
        }))
        alert.addAction(UIAlertAction(title: self.strOnlyAdmins, style: .default, handler: { _ in
            self.lblEditGroupInfo_Status.text = self.strOnlyAdmins
            self.updateGroupSettings(edit_permission:"1" , msg_permission: self.selectedGroup.msg_permission!)
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel".uppercased(), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnSendMessasgeAction() {
        let alert = UIAlertController(title: "Send messasge",
                                      message: "Choose who can send messages to this group", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: self.strAllMembers, style: .default, handler: { _ in
            self.lblSendMessasge_Status.text = self.strAllMembers
            self.updateGroupSettings(edit_permission: self.selectedGroup.edit_permission!, msg_permission: "0")
        }))
        alert.addAction(UIAlertAction(title:self.strOnlyAdmins , style: .default, handler: { _ in
            self.lblSendMessasge_Status.text = self.strOnlyAdmins
            self.updateGroupSettings(edit_permission: self.selectedGroup.edit_permission!, msg_permission: "1")
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel".uppercased(), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnEditGroupAdminsAction() {
        showMessage("Work in Progress...")
    }
}

extension GroupSettingsVC {
    
    func updateGroupSettings(edit_permission:String, msg_permission:String){
        let dic = [
            "editpermission" : edit_permission,
            "msgpermission" : msg_permission,
            "groupid" : selectedGroup.groupId
        ]
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck("Update_GroupPermission",dic).timingOut(after: 30) { data in
            let data = data as Array
            if(data.count > 0) {
                APP_DELEGATE.appNavigation?.popViewController(animated: true)
            }
        }
    }
    
}
