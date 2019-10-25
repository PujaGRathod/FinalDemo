//
//  CommonGroupsVC.swift
//  WakeUppApp
//
//  Created by Admin on 14/07/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class CommonGroupsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var arrCommonGroups = [StructGroupDetails]()
    var selectedUserID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrCommonGroups = CoreDBManager.sharedDatabase.getCommonGroupsListWithUserID(userId: selectedUserID)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func btnBackClicked(_ sender: Any) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
}

extension CommonGroupsVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommonGroupCell") as! CommonGroupCell
        
        let group = arrCommonGroups[indexPath.row]
        cell.lblGroupName.text = group.name
        cell.lblMembers.text = "\(group.members.components(separatedBy: ",").count) members"
        cell.imgGroupIcon.sd_setImage(with: URL.init(string: "\(group.icon)"), placeholderImage: GroupPlaceholderImage)

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCommonGroups.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let convo = loadVC(strStoryboardId: SB_CHAT, strVCId: idGroupChatVC) as! GroupChatVC
        let groupDetails = arrCommonGroups[indexPath.row]
        convo.calledfrom = "messages"
        convo.selectedGroupId = groupDetails.group_id
        convo.groupName = groupDetails.name
        APP_DELEGATE.appNavigation?.pushViewController(convo, animated: true)
    }
    
}
