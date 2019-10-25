//
//  GroupInfoVC.swift
//  WakeUppApp
//
//  Created by Admin on 21/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftyJSON
//For Manage Crop Image
import IGRPhotoTweaks

import Contacts
import ContactsUI

//1st Cell in tableview for use added new memeber in groups.
class AddNewParticipantCell: UITableViewCell {
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var viewMain_Sub: UIView!
    
    @IBOutlet weak var lblNoOfParticipants: UILabel!
    @IBOutlet weak var btnAddNewParticippants: UIButton!
}

class GroupInfoVC: UIViewController {
    
    //MARK:- Outlet
    @IBOutlet weak var btnChangeGroupIcon: UIButton!
    
    @IBOutlet weak var viewtableView_Header: UIView!
    @IBOutlet weak var imgGroup: UIImageView!
    
    @IBOutlet weak var lblGroupName: UILabel!
    @IBOutlet weak var lblCreatedByAndOn: UILabel!
    
    @IBOutlet weak var lblNoOfMediaContent: UILabel!
    
    @IBOutlet weak var tableToTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var imgExitOrDelete: UIImageView!
    @IBOutlet weak var lblExitOrDelete: UILabel!
    
    @IBOutlet weak var viewGroupSetting: UIView!
    @IBOutlet weak var lc_viewGroupSetting_height: NSLayoutConstraint!
    
    @IBOutlet weak var lc_viewUserProfilePhoto_height: NSLayoutConstraint!
    @IBOutlet weak var lc_btnUserProfilePhoto_height: NSLayoutConstraint!
    
    //MARK:- Variable
    var selectedGroupDetails:StructGroupDetails!
    var selectedGroupInfo:GroupInfo?

    var photoBrowser:ChatAttachmentBrowser!

    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*self.automaticallyAdjustsScrollViewInsets = false
        tableView.contentInset = UIEdgeInsets.init(top: 180, left: 0, bottom: 0, right: 0)
        tableToTopConstraint.constant = 0*/
        
        lblGroupName.text = selectedGroupDetails.name
        lblCreatedByAndOn.text = ""//Created by \(selectedGroupDetails.createdby)"
        
        imgGroup.sd_setImage(with: URL(string: selectedGroupDetails.icon), placeholderImage: UIImage(named:"imageplaceholder"), options: []) { (image, error, cacheType, url) in
            if error != nil {
                self.imgGroup.image = UIImage(named:"imageplaceholder")
            }
        }
        
        self.set_NotificationObserver()
        api_groupInfo()
        
        self.viewGroupSetting.isHidden = true
        
        if amIAMemberOfGroup() == false {
            //footerView.isHidden = true
            footerView.isHidden = false
        }
    }
    
    /*override func viewDidAppear(_ animated: Bool) {
     api_groupInfo()
     }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //Hide Navigationbar | Save contact adter move on this screen for hide the navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        //Contact Sync | Get latest contact list saved in Device for help show added new contact.
        //ContactSync.shared.performSync() //Comment by Payal | 14-09-2018 | Add new memeber in contact after view this screen, perform this method for show updated names.
        runAfterTime(time: 0.50) { self.tableView.reloadData() } //Reload Table
    }
    
    //MARK:-
    @IBAction func imgGroupClicked(_ sender:UIButton){
        let configuration = ImageViewerConfiguration { config in
            config.imageView = self.imgGroup
        }
        let imageViewerController = ImageViewerController(configuration: configuration)
        present(imageViewerController, animated: true)
    }
    
    func isGroupMutedByMe() -> Bool{
        let mutedUsers = selectedGroupDetails.muted_by.components(separatedBy: ",")
        if mutedUsers.contains(UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)){
            return true
        }
        return false
    }
    
    func amIAMemberOfGroup() -> Bool{
        let members = selectedGroupDetails.members.components(separatedBy: ",")
        if members.contains(UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)){
            self.imgExitOrDelete.image = #imageLiteral(resourceName: "exit_group")
            self.lblExitOrDelete.text = "Exit Group"
            return true
        }
        
        self.imgExitOrDelete.image = #imageLiteral(resourceName: "delete_msgic")
        self.lblExitOrDelete.text = "Delete Group"
        return false
    }
    
    //MARK:- NotificationObserver
    func set_NotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(privacyChange_RefreshList(notification:)), name: NSNotification.Name(NC_PrivacyChange_Refresh_GroupInfoVC), object: nil)
    }
    //MARK: NotificationObserver Method
    @objc func privacyChange_RefreshList(notification : NSNotification) {
        if (notification.name.rawValue == NC_PrivacyChange_Refresh_GroupInfoVC) {
            self.tableView.reloadData()
        }
    }
    
    //MARK:- Button action methods
    @IBAction func btnBackClicked(_ sender: Any) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnMoreClicked(_ sender: Any) {
        
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        var strMuteOrUnmute = "Mute"
        if isGroupMutedByMe() { strMuteOrUnmute = "Unmute" }
        
        let actionMuteUnmute = UIAlertAction.init(title: strMuteOrUnmute, style: .default) { (action) in
            var previouslyMuted = self.selectedGroupDetails.muted_by.components(separatedBy: ",")
            if self.isGroupMutedByMe(){
                previouslyMuted.remove(at: previouslyMuted.index(of: UserDefaultManager.getStringFromUserDefaults(key: kAppUserId))!)
            }else{
                previouslyMuted.append(UserDefaultManager.getStringFromUserDefaults(key: kAppUserId))
            }
            
            if previouslyMuted.contains("") {
                let index = previouslyMuted.index(of: "")!
                previouslyMuted.remove(at: index)
            }
            
            let dic = ["mutedids":previouslyMuted.joined(separator: ","),
                "groupid":"\(self.selectedGroupDetails.group_id)"] as [String : Any]
            APP_DELEGATE.socketIOHandler?.socket?.emitWithAck("ChangeGroupMute_Status",dic).timingOut(after: 30) {data in
                let data = data as Array
                if(data.count > 0) {
                    hideLoaderHUD()
                    
                    APP_DELEGATE.socketIOHandler?.reloadFriendAndGroupList()
                    APP_DELEGATE.appNavigation?.popViewController(animated: true)
                }
            }
        }
        
        alert.addAction(actionMuteUnmute)
        
        /*if selectedGroupDetails.admins.components(separatedBy: ",").contains(UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)){
         
         let actionDeleteGroup = UIAlertAction.init(title: "Delete Group", style: .destructive) { (action) in
         
         }
         
         alert.addAction(actionDeleteGroup)
         
         }*/
        
        /*let actionMedia = UIAlertAction.init(title: "Media", style: .default) { (action) in
            self.title = "   "
            self.photoBrowser = ChatAttachmentBrowser.init(groupID: self.selectedGroupDetails.group_id, startingFromMediaURL: "", currentLocalDir: getURL_GroupChat_Directory(groupID: self.selectedGroupDetails.group_id))
            self.photoBrowser.openBrowser()
        }
        alert.addAction(actionMedia)*/
        
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func btnUpdatePhotoClicked(_ sender: Any) {
        ImagePicker.sharedInstance.delegate = self
        ImagePicker.sharedInstance.selectImage(sender: "Group Icon")
    }
    
    @IBAction func btnEditGroupClicked(_ sender: Any) {
        
        if amIAMemberOfGroup() {
            if let selectedGroupInfo = self.selectedGroupInfo{
                
                if selectedGroupInfo.edit_permission == "1"{
                    let member = selectedGroupInfo.members!.first(where: {$0.userId == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)})!
                    if member.isAdmin == false{
                        showMessage("Only admins can edit this group's info.")
                        return
                    }
                }
                
                let alert = UIAlertController(title: "New Group Name", message: "", preferredStyle: .alert)
                alert.addTextField { (textField : UITextField!) -> Void in
                    textField.placeholder = "Write name of your group"
                    textField.text = self.selectedGroupInfo?.name
                }
                let saveAction = UIAlertAction(title: "Save", style: .default, handler: { action -> Void in
                    let txtGroupName = alert.textFields![0] as UITextField
                    if let newGroupName = txtGroupName.text{
                        self.api_changeGroupName(newGroupName: newGroupName)
                    }
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                
                alert.addAction(saveAction)
                alert.addAction(cancelAction)
                
                alert.view.tintColor = themeWakeUppColor
                present(alert, animated: true, completion: nil)
                
            }
        }
        else {
            showMessage("You are no longer a member of this group.")
        }
        //TO REMOVE BORDERS OF TEXTFIELD IN ALERT
        /*for textfield in alert.textFields! {
         let container = textfield.superview
         let effectView = container?.superview?.subviews[0]
         if let effectsView = effectView{
         if effectsView is UIVisualEffectView{
         effectsView.removeFromSuperview()
         }
         }
         }*/
    }
    
    @IBAction func btnNoOfMediaContentAction(_ sender: Any) {        
        let URL_dirCurrentGroupChat : URL = getURL_GroupChat_Directory(groupID: self.selectedGroupDetails.group_id)
        let arrMediaURLInLocalDir = getAllContent(inDirectoryURL: URL_dirCurrentGroupChat)
        var arrMediaURLs : [String] = []
        var arrLinkURLs : [String] = []
        var arrDocsURLs : [String] = []
        for localURL in arrMediaURLInLocalDir {
            //Media
            if isPathForImage(path: localURL.absoluteString) { arrMediaURLs.append(localURL.absoluteString) }
            else if isPathForVideo(path: localURL.absoluteString) { arrMediaURLs.append(localURL.absoluteString) }
                //Docs
                else if isPathForAudio(path: localURL.absoluteString) { arrDocsURLs.append(localURL.absoluteString) }
                else if isPathForContact(path: localURL.absoluteString) { arrDocsURLs.append(localURL.absoluteString) }
            else { arrDocsURLs.append(localURL.absoluteString) }
        }
        
        //------------->
        //Docs -> Get and set Doc real name
        var arrDocument : [objDocumentInfo] = []
        for objURL in arrDocsURLs {
            let docsURL : URL = objURL.url!
            
            let objData = CoreDBManager.sharedDatabase.getDocumentForGroup(groupId: self.selectedGroupDetails.group_id, filename: docsURL.lastPathComponent)
            
            var strDocName : String = objData.textmessage.base64Decoded ?? ""
            if (strDocName.count == 0) { strDocName = docsURL.lastPathComponent }
            //print("strDocName: \(strDocName)")
            
            let objDocument = objDocumentInfo.init(strURL: objURL,
                                                   name: strDocName,
                                                   size: fileSizedetail(url: docsURL),
                                                   createDate: getfileCreatedDate(url: docsURL),
                                                   type: getFileType(for: objURL))
            arrDocument.append(objDocument)
        }
        //<-------------
        
        let action = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        //Media --------------->
        //if (arrMediaURLs.count != 0) {
            let action_Media = UIAlertAction.init(title: "Media", style: .default, handler: { (action) in
                self.photoBrowser = ChatAttachmentBrowser.init(groupID: self.selectedGroupDetails.group_id, startingFromMediaURL: "", currentLocalDir: getURL_GroupChat_Directory(groupID: self.selectedGroupDetails.group_id))
                self.photoBrowser.openBrowser()
            })
            action.addAction(action_Media)
        //}
        
        //Docs --------------->
        //if (arrDocument.count != 0) {
            let action_Docs = UIAlertAction.init(title: "Docs", style: .default, handler: { (action) in
                let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId: "ChatAttachMediaVC") as! ChatAttachMediaVC
                objVC.objEnumAttachMedia = .Docs
                
                let mediaContent = objAttachMedia.init(arrMedia: [],
                                                       arrLinks: [],
                                                       arrDocument: arrDocument)
                objVC.objMediaContent = mediaContent
                
                objVC.URL_CurrentDir = URL_dirCurrentGroupChat
                APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
            })
            action.addAction(action_Docs)
        //}
        
        //Link --------------->
        let arrMsgs = CoreDBManager.sharedDatabase.getMessagesForGroupID(groupId: self.selectedGroupDetails.group_id, includeDeleted: false)
        for obj in arrMsgs {
            if obj.messagetype == "4" { arrLinkURLs.append(obj.mediaurl) }
        }
        //if (arrLinkURLs.count != 0) {
            let action_Links = UIAlertAction.init(title: "Links", style: .default, handler: { (action) in
                let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId: "ChatAttachMediaVC") as! ChatAttachMediaVC
                objVC.objEnumAttachMedia = .Links
                
                //let objLinksInfo = LinksInfo.init(arrLinks: arrLinkURLs)
                //objVC.objLinksInfo = objLinksInfo
                let mediaContent = objAttachMedia.init(arrMedia: [],
                                                       arrLinks: arrLinkURLs,
                                                       arrDocument: [])
                objVC.objMediaContent = mediaContent
                
                objVC.URL_CurrentDir = URL_dirCurrentGroupChat
                APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
            })
            action.addAction(action_Links)
        //}
        
        
        //if action.actions.count != 0 {
            let action_Cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
            action.addAction(action_Cancel)
            
            self.present(action, animated: true, completion: nil)
        //}
    }
    
    @IBAction func btnGroupSettingAction(_ sender: Any) {
        if let selectedGroupInfo = self.selectedGroupInfo{
            let member = selectedGroupInfo.members?.last
            if (member?.userId?.uppercased() == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId).uppercased() && member?.isAdmin == true) {
                
                let objVC  : GroupSettingsVC = loadVC(strStoryboardId: SB_CHAT, strVCId: idGroupSettingsVC) as! GroupSettingsVC
                objVC.selectedGroup = selectedGroupInfo
                APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
            }
        }
    }
    
    @IBAction func btnExitGroupClicked(_ sender: Any) {
        if amIAMemberOfGroup() {
            let confirm = UIAlertController.init(title: nil, message: "Are you sure to exit from this group?", preferredStyle: .actionSheet)
        
            let actionYes = UIAlertAction.init(title: "Yes", style: .destructive) { (action) in
                self.api_exitGroup()
            }
            confirm.addAction(actionYes)
            
            let actionNo = UIAlertAction.init(title: "No", style: .cancel, handler: nil)
            confirm.addAction(actionNo)
            
            present(confirm, animated: true, completion: nil)
        }
        else {
            //Manage Delete Group
            //showMessage("Manage Delete Group")
            
            let confirm = UIAlertController.init(title: nil, message: "Delete this group?", preferredStyle: .actionSheet)
            
            let actionYes = UIAlertAction.init(title: "Yes", style: .destructive) { (action) in
                // Delete all group mess. Core data
                CoreDBManager.sharedDatabase.deleteAllGroupChatMessagesOf(groupId: self.selectedGroupDetails.group_id)
                
                //Delete Group in Coredata
                CoreDBManager.sharedDatabase.deleteGroup(groupID: self.selectedGroupDetails.group_id)
                
                //Reload ChatListVC table
                NotificationCenter.default.post(name: NSNotification.Name(NC_UserListRefresh), object: nil)
                
                //Move to ChatListVC
                //APP_DELEGATE.appNavigation?.popToViewController(loadVC(strStoryboardId: SB_CHAT, strVCId: idChatListVC), animated: true) //Crash the App
                APP_DELEGATE.appNavigation?.popToRootViewController(animated: true)
            }
            confirm.addAction(actionYes)
            
            let actionNo = UIAlertAction.init(title: "No", style: .cancel, handler: nil)
            confirm.addAction(actionNo)
            
            present(confirm, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnReportGroupClicked(_ sender: Any) {
        let confirm = UIAlertController.init(title: "Report spam and leave this group?", message: "If you report and leave, this chat's history will also be deleted. ", preferredStyle: .actionSheet)
        
        let action_yes = UIAlertAction.init(title: "Report and leave", style: .destructive) { (action) in
            //Exit Group
            self.api_exitGroup()
            
            //Clear Group Chat
            CoreDBManager.sharedDatabase.deleteAllGroupChatMessagesOf(groupId: self.selectedGroupDetails.group_id)
            
            //Report Spam
            let parameter:NSDictionary = ["service":APIReportSpam,
                                          "request":["spam_id":self.selectedGroupDetails.group_id,
                                                     "action":"group"],
                                          "auth" : getAuthForService()]
            APP_DELEGATE.api_SpamReport(parameter: parameter, successMess: "Report spam successfully.")
        }
        confirm.addAction(action_yes)
        
        let action_no = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        confirm.addAction(action_no)
        
        present(confirm, animated: true, completion: nil)
    }
}

//MARK:-
extension GroupInfoVC : CNContactViewControllerDelegate
{
    //MARK: Add Contact Delegate Method
    func add_ToContacts(strCountryCode: String, strPhoneNo:String)
    {
        let contact = ContactSync.shared.get_ContactObject(strCountryCode: strCountryCode, strPhoneNo: strPhoneNo)
        let controller = CNContactViewController(forNewContact: contact)
        controller.delegate = self
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        APP_DELEGATE.appNavigation?.pushViewController(controller, animated: true)
    }
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        if contact != nil {
            if contact!.phoneNumbers.count > 0
            {
                let objContact = ContactEntry.init(cnContact: contact!, false, contact!.phoneNumbers.first!)
                ContactSync.shared.AddContact_In_DeviceContactInfo(contact: objContact!)
            }
        }
        self.tableView.reloadData()
        APP_DELEGATE.appNavigation?.popViewController(animated: false)
    }
    
    func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        return true
    }
}

extension GroupInfoVC : UITableViewDelegate, UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) { return 1 }
        else { return selectedGroupInfo?.members?.count ?? 0 }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            var height : CGFloat = 40
            
            let member = selectedGroupInfo!.members?.last
            if (member?.userId?.uppercased() == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId).uppercased() && member?.isAdmin == true)
            { height = 90 }
            
            return height
        }
        else { return 66 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_addnew", for: indexPath) as! AddNewParticipantCell
            
            let arrMemberIDs = selectedGroupDetails.members.components(separatedBy: ",")
            cell.lblNoOfParticipants.text = "\(arrMemberIDs.count) of \(kMaxMembersInGroup + 1)" 
            
            cell.viewMain_Sub.isHidden = true
            let member = selectedGroupInfo!.members?.last
            if (member?.userId?.uppercased() == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId).uppercased() && member?.isAdmin == true) {
                cell.viewMain_Sub.isHidden = false
            }
            
            return  cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantCell", for: indexPath) as! ParticipantCell
        
        let member = selectedGroupInfo!.members![indexPath.row]
        var strTitle : String = ""
        var strSubTitle : String = ""
        
        let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: "", phoneNo: member.phoneno ?? "")
        if objContactInfo.Name?.count == 0 {
            strTitle = "+\(member.countryCode!) \(member.phoneno!)"
            //strSubTitle = "~\(member.fullName ?? "")" 
            //strSubTitle = "~\(member.username ?? "")"
            strSubTitle = "\(member.bio ?? "")"
        }
        else {
            strTitle = objContactInfo.Name ?? "*** No name ***"
            //strSubTitle = objContactInfo.CountryCode_PhoneNo ?? ""
            //strSubTitle = "+\(objContactInfo.CountryCode!) \(objContactInfo.PhoneNo!)"
            //strSubTitle = "~\(member.fullName ?? "")" 
            //strSubTitle = "~\(member.username ?? "")"
            strSubTitle = "\(member.bio ?? "")"
        }
        
        //Set Title - "You" if user are self
        if (member.userId?.uppercased() == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId).uppercased()) {
            strTitle = "You"
            strSubTitle = member.bio ?? "" 
        }
        
        //Load Photo
        if (Privacy_ProfilePhoto_Show(userID: member.userId!) == true) {
            cell.imgUser.sd_setImage(with: member.imagePath?.toUrl, placeholderImage: ProfilePlaceholderImage, options: [], completed: nil)
        }
        else {
            cell.imgUser.image = ProfilePlaceholderImage
        }
        
        //Fill Details
        cell.lblName.text = strTitle
        cell.lblBio.text = strSubTitle
        
        //Manage user Admin status base hide/show "admin" label.
        if member.isAdmin == false{
            cell.lblAdminWidth.constant = 0
        }else{
            cell.lblAdminWidth.constant = 42
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.section == 0) {
            let member = selectedGroupInfo!.members?.last
            if (member?.userId?.uppercased() == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId).uppercased() && member?.isAdmin == true) {
                let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: idSelectMembersVC) as! SelectMembersVC
                //vc.forAddMembersInGroup = true
                vc.objEnumSelectMember = .enumSelectMember_AddMembersInGroup
                //vc.preSelectedUserIDs = selectedGroupDetails.members.components(separatedBy: ",")
                vc.selectedGroupForAddMembers = selectedGroupDetails
                APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
            }else{
                //showMessage("You are no longer a member of this group.")
            }
            return
        }
        
        let member = selectedGroupInfo!.members![indexPath.row]
        
        //If User select own cell to return.
        let strLoginUserID : String = UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)
        if (member.userId?.uppercased() == strLoginUserID.uppercased()) { return }
        
        //Get All Admin User in Group
        let arrAdmins : NSMutableArray = NSMutableArray.init()
        for info : Members in (self.selectedGroupInfo?.members!)! {
            if info.isAdmin == true { arrAdmins.add(info.userId!) }
        }
        
        //Set User Title
        var strUserName : String = ""
        let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: "", phoneNo: member.phoneno ?? "")
        
        var isUserInContacts : Bool = false
        if objContactInfo.Name?.count == 0 {
            strUserName = "+\(member.countryCode!) \(member.phoneno!)"
        }
        else {
            strUserName = objContactInfo.Name!
            isUserInContacts = true
        }
        
        //Manage Show Action Sheet
        let actionSheet = UIAlertController.init(title: strUserName, message: nil, preferredStyle: .actionSheet)
        
        //Message
        let actionChat = UIAlertAction.init(title: "Message \(strUserName)", style: .default) { (action) in
            //showMessage(action.title!)
            
            let selectedUserInfo:StructChat = StructChat.init(dictionary: ["id":"1",
                                                                           "username":member.username! as Any,
                                                                           "user_id":member.userId! as Any,
                                                                           "country_code":member.countryCode! as Any,
                                                                           "phoneno":member.phoneno! as Any,
                                                                           "image":member.image! as Any])
            
            let convo = loadVC(strStoryboardId: SB_CHAT, strVCId:idChatVC ) as! ChatVC
            convo.calledfrom = "messages"
            convo.selecteduserid = member.userId
            convo.strTitle = strUserName 
            convo.username = member.username!
            convo.selectedUser = selectedUserInfo
            APP_DELEGATE.appNavigation?.pushViewController(convo, animated: true)
        }
        actionSheet.addAction(actionChat)
        
        //View
        let actionView = UIAlertAction.init(title: "View \(strUserName)", style: .default) { (action) in
            let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId: idChatUserInfoVC) as! ChatUserInfoVC
            objVC.strTitle = strUserName 
            objVC.strUserID = member.userId!
            objVC.strPhotoURL = member.image! 
            objVC.strUserName = member.username! 
            objVC.strCountryCodeOfPhoneNo = member.countryCode! 
            objVC.strUserPhoneNo = member.phoneno! 
            objVC.strUserBio = member.bio ?? ""
            objVC.flag_showChatButton = true
            APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
        }
        actionSheet.addAction(actionView)
        
        //REMOVE-or-ADD member FROM ADMIN
        if (arrAdmins.contains(strLoginUserID) == true) { //Check condition : If logn user already admin of this group, so provide this action activity manage otherwise none.
            var strMakeOrDismissAdmin = "Make group admin"
            if member.isAdmin! { strMakeOrDismissAdmin = "Dismiss as admin" }
            let actionAdmin = UIAlertAction.init(title: strMakeOrDismissAdmin, style: .default, handler: { (action) in
                
                if member.isAdmin!{
                    //REMOVE member FROM ADMIN
                    let arrAdmins : NSMutableArray = NSMutableArray.init()
                    for info : Members in (self.selectedGroupInfo?.members!)! {
                        if info.isAdmin == true { arrAdmins.add(info.userId!) }
                    }
                    if (arrAdmins.count == 1) { showMessage("Unable to dismiss as admin") } 
                    else { self.api_removeGroupAdmin(member: member) }
                }
                else {
                    //ADD member AS ADMIN
                    self.api_addGroupAdmin(member: member)
                }
            })
            actionSheet.addAction(actionAdmin)
            
            //Remove
            let actionRemove = UIAlertAction.init(title: "Remove \(strUserName)", style: .default) { (action) in
                //Get Group Member ID into remove selected UserID------>
                var arrAllUserID = self.selectedGroupInfo!.members!.map({$0.userId!})
                //print("All Group Memeber IDs: \(arrAllUserID)")
                
                arrAllUserID.remove(at: indexPath.row) //Remove Obje in array List
                let removedMember = self.selectedGroupInfo!.members!.remove(at: indexPath.row) //Remove Person in Array list
                //self.tableView.reloadData() //Reload Tableview
                self.tableView.deleteRows(at: [indexPath], with: .left) //Remove Cell
                
                //print("Remove person after Group Memeber IDs: \(arrAllUserID)")
                let members : String = arrAllUserID.joined(separator: ",")
                
                //Get Curret Admin in Group------>
                let arrAdmins : NSMutableArray = NSMutableArray.init()
                for info : Members in (self.selectedGroupInfo?.members!)! {
                    if info.isAdmin == true { arrAdmins.add(info.userId!) }
                }
                arrAdmins.remove(removedMember.userId!)
                let strAdmins = arrAdmins.componentsJoined(by: ",") //joined(separator: ",")
                
                let dic : NSDictionary = [
                    "groupid":self.selectedGroupInfo!.groupId!,
                    "group_members":members,
                    "username": UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
                    "new_members" : "",
                    "admins" : strAdmins,
                    "ownerphone" : "\(UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode))\(UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile))",
                    "mobilenolist" : removedMember.countryCode! + removedMember.phoneno!,
                    "platform" : PlatformName,
                    "removedid" : removedMember.userId!]
                //print("dic : \(dic)")
                self.api_RemoveMUser(dicParameter: dic, removedMember:removedMember)
            }
            actionSheet.addAction(actionRemove)
        }
        
        if isUserInContacts == false {
            //Add Contact
            let actionAddContact = UIAlertAction.init(title: "Add to Contact", style: .default) { (action) in
                //--->
                if #available(iOS 9.0, *) {
                    self.add_ToContacts(strCountryCode: member.countryCode ?? "", strPhoneNo: member.phoneno ?? "")
                }
                else { showMessage("Something was wrong!") }
            }
            actionSheet.addAction(actionAddContact)
            
            //Call
            let actionCall = UIAlertAction.init(title: "Call", style: .default) { (action) in
                //showMessage("Working Progress...")
                if let phoneCallURL:NSURL = NSURL(string:"tel://\(member.phoneno ?? "")") {
                    let application:UIApplication = UIApplication.shared
                    if (application.canOpenURL(phoneCallURL as URL)) {
                        application.open(phoneCallURL as URL, options: [:], completionHandler: nil)
                    }
                    else {
                        showMessage("Something was wrong!")
                    }
                }
            }
            actionSheet.addAction(actionCall)
        }
        
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(actionCancel)
        
        present(actionSheet, animated: true, completion: nil)
    }
}

extension GroupInfoVC {
    func manageGroupInfo() {
        //--- --- --- --- --- --- --- --- --- --- --- --- --->
        //Sorting Memeber list | 1st:Position-Login User, 2nd:All Group Admin, 3rd:Other User of group.
        var objArrMember = [Members]()
        objArrMember = (self.selectedGroupInfo?.members)!
        
        var objLoginUser : Members?
        var ListOfMemberIsAdmin = [Members]()
        var ListOfMemberIsNotAdmin = [Members]()
        for objMember : Members in objArrMember {
            //Get and Store Login User obj.
            if objMember.userId == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId) {
                objLoginUser = objMember
            }
            
            //Get and store Admin and Non-Admin User in array.
            if objMember.isAdmin == true {
                if objLoginUser?.userId != objMember.userId { ListOfMemberIsAdmin.append(objMember) }
            }
            else {
                if objLoginUser?.userId != objMember.userId { ListOfMemberIsNotAdmin.append(objMember) }
            }
        }
        
        //Remove all obj. and re-added by arranged array list.
        objArrMember.removeAll() //Remove all obj.
        
        if objLoginUser == nil {
            objArrMember = ListOfMemberIsAdmin + ListOfMemberIsNotAdmin //Add arranged obj. in array, but not add Own object
        }
        else {
            objArrMember = ListOfMemberIsAdmin + ListOfMemberIsNotAdmin + [objLoginUser!] //Add arranged obj. in array
        }
        self.selectedGroupInfo?.members = objArrMember //Update object in array of mmember.
        //--- --- --- --- --- --- --- --- --- --- --- --- --->
        
        /*
         //Manage AddNewParticipants view hide show
         if (objLoginUser == nil) || (objLoginUser?.isAdmin == false) {
         self.lc_viewAddNewParticipants_height.constant = 0
         self.view.layoutIfNeeded()
         }*/
        
        CoreDBManager.sharedDatabase.updateGroupInfo(groupInfo: self.selectedGroupInfo!)
        
        self.selectedGroupDetails = CoreDBManager.sharedDatabase.getGroupById(groupId: self.selectedGroupDetails.group_id)!
        
        /*if self.amIAMemberOfGroup() == false{
         //DELETE THIS GROUP FROM LOCAL DB & POP TO CHATLISTVC
         CoreDBManager.sharedDatabase.deleteGroup(groupID: self.selectedGroupInfo!.groupId!)
         APP_DELEGATE.appNavigation?.backToViewController(viewController: ChatListVC.self)
         }*/
        
        /*let createdDate = self.selectedGroupInfo!.createddate!.components(separatedBy: " ").first!
         let dateComponents = createdDate.components(separatedBy: "-")
         let formattedDate = "\(dateComponents.last!)/\(dateComponents[1])/\(dateComponents.first!)"*/
        
        let createdDate = self.selectedGroupInfo?.createddate!.replacingOccurrences(of: "T", with: " ")
        let formattedDate = createdDate?.replacingOccurrences(of: ".000Z", with: "")
        
        self.lblCreatedByAndOn.text = "Created By : \(self.selectedGroupInfo!.fullName!) - \(formattedDate!)"
        
        self.lblGroupName.text = self.selectedGroupInfo?.name
        
        //self.lblNoOfParticipants.text = "\(self.selectedGroupInfo!.members!.count) of \(kMaxMembersInGroup+1)"
        
        let strGroupIcon = Get_Group_Icon_URL + (self.selectedGroupInfo?.icon)!
        self.imgGroup.sd_setImage(with: strGroupIcon.toUrl, placeholderImage: UIImage(named:"imageplaceholder"), options: []) { (image, error, cacheType, url) in
            if error != nil{
                self.imgGroup.image = UIImage(named:"imageplaceholder")
            }
        }
        
        //No. Of Media Content
        self.lblNoOfMediaContent.text = "\(self.getData_NoOfMediaContent().count)"
        //self.lblNoOfMediaContent.text = ""
        
        //-------------------------------------------------->
        self.viewGroupSetting.clipsToBounds = true
        
        var height = self.viewtableView_Header.frame.height
        let member = selectedGroupInfo!.members?.last
        if (member?.userId?.uppercased() == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId).uppercased() && member?.isAdmin == true) {
            self.lc_viewGroupSetting_height.constant = 50 + 10 //PV
            self.viewGroupSetting.isHidden = false
        }
        else {
            self.lc_viewGroupSetting_height.constant = 0 //PV
            self.viewGroupSetting.isHidden = true
            
            height = height - self.viewGroupSetting.frame.height
        }
        //Update Height of HeaderView
        let frame = CGRect(x: 0, y: 0, width: self.view.width, height: height)
        self.viewtableView_Header.frame = frame
        
        self.tableView.layoutIfNeeded()
        //<--------------------------------------------------
        
        if self.amIAMemberOfGroup() == false{
            //self.footerView.isHidden = true
            self.footerView.isHidden = false
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        
        if selectedGroupInfo!.edit_permission == "1"{
            //let member = selectedGroupInfo!.members!.first(where: {$0.userId == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)})!
            if member?.isAdmin == false{
                //showMessage("Only admins can edit this group's info.")
                btnChangeGroupIcon.isHidden = true
            }else{
                btnChangeGroupIcon.isHidden = false
            }
        }else{
            btnChangeGroupIcon.isHidden = false
        }
        
        /*
        btnChangeGroupIcon.isHidden = true
        if selectedGroupInfo!.edit_permission == "1" {
            if (member?.userId?.uppercased() == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId).uppercased() && member?.isAdmin == true) {
                btnChangeGroupIcon.isHidden = false
            }
        }*/
        
        UIView.animate(withDuration: 0.50) {
            self.lc_viewUserProfilePhoto_height.constant = self.view.bounds.width //* 0.80
            self.lc_btnUserProfilePhoto_height.constant = self.lc_viewUserProfilePhoto_height.constant
            self.view.layoutIfNeeded()
        }
    }
    
    func getData_NoOfMediaContent() -> [URL] {
        let URL_dirCurrentGroupChat : URL = getURL_GroupChat_Directory(groupID: self.selectedGroupDetails.group_id)
        let totalContent = getAllContent(inDirectoryURL: URL_dirCurrentGroupChat)
        
        var arrMediaURLs : [URL] = []
        for localURL in totalContent {
            if isPathForImage(path: localURL.absoluteString){ arrMediaURLs.append(localURL) }
            else if isPathForVideo(path: localURL.absoluteString){ arrMediaURLs.append(localURL) }
        }
        return arrMediaURLs
    }
    
    @objc func api_groupInfo() {
        
        if isConnectedToNetwork() == false { return }
        
        let dicParam = ["groupid":selectedGroupDetails.group_id]
        //print("Called API - socket - Get_GroupInfo - param : \(dicParam) ")
        
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck("Get_GroupInfo",dicParam).timingOut(after: 1000)
        {data in
            //print("Called API - socket - Get_GroupInfo - respo. : \(data) ")
            let data = data as Array
            if(data.count > 0) {
                if data[0] is String { return }
                
                let jsonData = JSON(data.first! as! NSDictionary)
                self.selectedGroupInfo = GroupInfo.init(json: jsonData)
                self.manageGroupInfo()
                
                //print("Edit Grp Info Status : \(self.selectedGroupInfo!.edit_permission!)")
                //print("Mesg Grp Info Status : \(self.selectedGroupInfo!.msg_permission!)")
            }
        }
        
        /*let parameter:NSDictionary = ["service":APIGetGroupInfo,
                                      "request":["group_id" : selectedGroupDetails.group_id],
                                      "auth" : getAuthForService()]
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIGetGroupInfo, parameters: parameter, keyname: ResponseKey as NSString, message: "", showLoader: true){
            (error,apistatus,statusmessage,responseArray,responseDict) in
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_groupInfo()
                })
                return
            }
            else {
                self.selectedGroupInfo = responseArray?.firstObject as? GroupInfo
                self.manageGroupInfo()
            }
        }*/
    }
    
    func api_addGroupAdmin(member:Members){
        if isConnectedToNetwork() == false { return }
        
        let parameter:NSDictionary = ["service":APIAddGroupAdmin,
                                      "request":["user_id" : member.userId!,
                                                  "group_id" : selectedGroupDetails.group_id],
                                      "auth" : getAuthForService()]
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIAddGroupAdmin, parameters: parameter, keyname: "", message: "", showLoader: true){
            (error,apistatus,statusmessage,responseArray,responseDict) in
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_addGroupAdmin(member: member)
                })
                return
            }
            else
            {
                self.api_groupInfo()
                
                let textMessage = member.countryCode! + member.phoneno! + "| is now an admin"
                self.newSendMessage(message:textMessage)
            }
        }
    }
    
    func api_removeGroupAdmin(member:Members){
        if isConnectedToNetwork() == false { return }
        
        let parameter:NSDictionary = ["service":APIRemoveGroupAdmin,
                                      "request":["user_id" : member.userId!,
                                                 "group_id" : selectedGroupDetails.group_id],
                                      "auth" : getAuthForService()
        ]
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIRemoveGroupAdmin, parameters: parameter, keyname: "", message: "", showLoader: true){
            (error,apistatus,statusmessage,responseArray,responseDict) in
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_removeGroupAdmin(member: member)
                })
                return
            }
            else
            {
                self.api_groupInfo()
                
                let textMessage = member.countryCode! + member.phoneno! + "|was dismissed as admin"
                self.newSendMessage(message:textMessage)
            }
        }
    }
    
    func api_changeGroupName(newGroupName:String){
        
        if isConnectedToNetwork() == false { return }
        
        var imageName = ""
        if selectedGroupDetails.icon.count > 0{
            imageName = selectedGroupDetails.icon.lastPathComponent
        }
        
        let dict = ["groupid" : self.selectedGroupInfo?.groupId, "group_icon" : imageName, "group_name" : newGroupName]
        APP_DELEGATE.socketIOHandler?.socket?.emit("Update_GroupNameOrIcon",dict)
        self.perform(#selector(self.api_groupInfo), with: nil, afterDelay: 3.0)
        
        /*let parameter:NSDictionary = ["service":APIChangeGroupName,
         "request":[
         "group_name" : newGroupName,
         "group_id" : selectedGroupDetails.group_id
         ],
         "auth" : getAuthForService()
         ]
         
         HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIChangeGroupName, parameters: parameter, keyname: "", message: "", showLoader: true){
         (error,apistatus,statusmessage,responseArray,responseDict) in
         
         if error != nil {
         showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
         self.api_changeGroupName(newGroupName: newGroupName)
         })
         return
         }
         else
         {
         self.api_groupInfo()
         }
         
         }*/
    }
    
    func api_UploadGroupPicture(image:UIImage) {
        if isConnectedToNetwork() == false { return }
        
        showLoaderHUD(strMessage: "Uploading Group Image")
        let parameter :NSMutableDictionary = ["token_id":UserDefaultManager.getStringFromUserDefaults(key: kToken)]
        let imageData:Data = UIImageJPEGRepresentation(image, 0.6)!
        parameter.setObject(imageData, forKey: ("image" as NSString))
        
        HttpRequestManager.sharedInstance.requestWithPostMultipartParam(endpointurl: UploadGroupIcon, isImage: true, parameters: parameter) {(data, error, message, responseDict) -> Void in
            if error != nil
            {
                hideLoaderHUD()
                showMessageWithRetry(RetryMessage, 3, buttonTapHandler: { _ in
                    hideBanner()
                    self.api_UploadGroupPicture(image: image)
                })
                return
            }
            else if let data = data
            {
                let thedata = data as? NSDictionary
                if(thedata != nil)
                {
                    print(thedata!)
                    if (thedata?.count)! > 0
                    {
                        let uploadedImageName = thedata!.object(forKey: kData) as! String
                        let dict = ["groupid" : self.selectedGroupInfo?.groupId, "group_icon" : uploadedImageName, "group_name" : self.selectedGroupDetails.name]
                        APP_DELEGATE.socketIOHandler?.socket?.emit("Update_GroupNameOrIcon",dict)
                        //self.api_changeGroupPicture(imageName: uploadedImageName)
                        self.perform(#selector(self.api_groupInfo), with: nil, afterDelay: 3.0)
                    }
                }
                else
                {
                    
                }
                hideLoaderHUD()
            }
            else
            {
                hideLoaderHUD()
            }
        }
    }
    
    /*func api_changeGroupPicture(imageName:String){
     let parameter:NSDictionary = ["service":APIChangeGroupPhoto,
     "request":[
     "group_image" : imageName,
     "group_id" : selectedGroupDetails.group_id
     ],
     "auth" : getAuthForService()
     ]
     
     HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIChangeGroupPhoto, parameters: parameter, keyname: "", message: "", showLoader: true){
     (error,apistatus,statusmessage,responseArray,responseDict) in
     
     if error != nil {
     showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
     self.api_changeGroupPicture(imageName: imageName)
     })
     return
     }
     else
     {
     self.api_groupInfo()
     }
     
     }
     }*/
    
    func api_exitGroup(){
        if isConnectedToNetwork() == false  { return }
        
        let parameter:NSDictionary = ["service":APIExitGroup,
                                      "request":["user_id" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
                                                 "group_id" : selectedGroupDetails.group_id],
                                      "auth" : getAuthForService()]
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIExitGroup, parameters: parameter, keyname: "", message: "", showLoader: true){
            (error,apistatus,statusmessage,responseArray,responseDict) in
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_exitGroup()
                })
                return
            }
            else
            {
                self.api_groupInfo()
                
                let textMessage = UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode) + UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile) + " | left"
                
                self.newSendMessage(message:textMessage)
            }
        }
    }
    
    func api_RemoveMUser(dicParameter: NSDictionary, removedMember:Members) {
        if isConnectedToNetwork() == false { return }
        
         APP_DELEGATE.socketIOHandler?.socket?.emitWithAck("AddRemove_MembersInGroup",dicParameter).timingOut(after: 30) { data in
            let data = data as Array
            if(data.count > 0) {
                //if data[0] is String { return }
                
                //print("Done - Remove User")
                print(data.first!)
                hideLoaderHUD()
                
                self.api_groupInfo()               
            }
        }
    }
    
    func getFilteredMembersForSendMessage() -> String{
        
        let mutedIds = selectedGroupDetails.muted_by.components(separatedBy: ",")
        var allMembers = selectedGroupDetails.members.components(separatedBy: ",")
        
        for mutedId in mutedIds{
            let index = allMembers.index(of: mutedId)
            if let foundIndex = index{
                allMembers.remove(at: foundIndex)
            }
        }
        let filteredMembers = allMembers.joined(separator: ",")
        return filteredMembers
    }
    
    func newSendMessage(message:String){
        if isConnectedToNetwork() == false { return }
        
        if isConnectedToNetwork() && APP_DELEGATE.socketIOHandler?.isSocektConnected() == true{

            let dic = [
                "groupid":self.selectedGroupDetails.group_id,
                "senderid":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
                "group_members": self.selectedGroupDetails.members,
                "textmessage": message.base64Encoded ?? "",
                "messagetype": "-1",
                "mediaurl": "",
                "platform":PlatformName,
                "createddate": "",
                "isdeleted":"0",
                "isread":"0",
                "username" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
                "filtered_members" : self.getFilteredMembersForSendMessage(),
                "countrycode" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode).replacingOccurrences(of: "+", with: ""),
                "phonenumber" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)
                ]  as [String : Any]
            
            runInBackground {
                self.socketCall_SendMessage(objmessage: dic as NSDictionary)
            }
        }
    }
    
    func socketCall_SendMessage(objmessage:NSDictionary) {
        
        if(isConnectedToNetwork()) {
            if(APP_DELEGATE.socketIOHandler?.isSocektConnected() == true)
            {
                self.fire_eventSend_Messgae(objmsg: objmessage)
            }
            else
            {
                APP_DELEGATE.socketIOHandler?.connectWithSocket()
                showMessageWithRetry("Socket Connection Needed", 3, buttonTapHandler: { (UIButton) in
                    self.socketCall_SendMessage(objmessage: objmessage)
                })
            }
        }
        else
        {
            //showStatusbarMessage(InternetNotAvailable, 3)
        }
    }
    func fire_eventSend_Messgae(objmsg:NSDictionary)
    {
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck(keySendGroupMessage,objmsg).timingOut(after: 1000)
        {data in
            let data = data as Array
            if(data.count > 0)
            {
                if data[0] is String{
                    return
                }
                print(data)
                //CODE TO SAVE IN COREDB
                let msg = StructGroupChat.init(dictionary: data[0] as! [String:Any])
                _ = CoreDBManager.sharedDatabase.saveGroupMessageInLocalDB(objmessgae: msg)
            }
        }
    }
    
}

extension GroupInfoVC : ImagePickerDelegate {
    func pickImageComplete(_ imageData: UIImage, sender: String) {
        
        //Manage Image Crop
        let imageCropper = loadVC(strStoryboardId: SB_ASSET_PICKER, strVCId: idImageCropperVC) as! ImageCropperVC
        imageCropper.image = imageData
        imageCropper.delegate = self
        APP_DELEGATE.appNavigation?.pushViewController(imageCropper, animated: false)
        
        //api_UploadGroupPicture(image: imageData)
    }
}

extension GroupInfoVC : IGRPhotoTweakViewControllerDelegate {
    func photoTweaksController(_ controller: IGRPhotoTweakViewController, didFinishWithCroppedImage croppedImage: UIImage) {
        //Dismiss VC
        self.photoTweaksControllerDidCancel(controller)
        
        //Set Selected Crop Image
        self.imgGroup.image = croppedImage
        
        //Called  API
        api_UploadGroupPicture(image: croppedImage)
    }

func photoTweaksControllerDidCancel(_ controller: IGRPhotoTweakViewController) {
    APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
}

