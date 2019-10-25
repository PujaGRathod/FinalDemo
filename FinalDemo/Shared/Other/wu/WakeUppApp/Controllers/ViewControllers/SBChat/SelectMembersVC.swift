//
//  SelectMembersVC.swift
//  WakeUppApp
//
//  Created by Admin on 14/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

//PV
enum enumSelectMember : Int {
    case enumSelectMember_None = 0
    case enumSelectMember_PersonalChat // Present on User personal chat, click cell to start chat.
    case enumSelectMember_GroupChat // Present on User group chat, click cell select memeber, set img and group name and done to create group.
    case enumSelectMember_BroadcastChat // Present on User Broadcast chat, click cell select memeber and done to create broadcast group chat.
    case enumSelectMember_AddMembersInGroup
    case enumSelectMember_AddMembersInBroadcast
    case enumSelectMember_StatusPrivacy
}

let title_NewGroup : String = "New group"
let title_NewBroadcast : String = "New Broadcast"
let title_InviteFriend : String = "Invite a Friend"

class SelectMembersVC: UIViewController {

    //MARK: - Outlet
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSelectedMembers: UILabel!
    @IBOutlet weak var lblSelectedMembersHeight: NSLayoutConstraint!
    @IBOutlet weak var btnSearchWidth: NSLayoutConstraint!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    
    @IBOutlet weak var collectionContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionContainer: UIView!
    @IBOutlet weak var lblNotice: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var textFieldContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var textFieldContainer: UIView!
    @IBOutlet weak var txtGroupName: UITextField!
    @IBOutlet weak var imgGroupIcon: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewEmptyTableview: UIView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnNewChat: UIButton!
    
    //View-Search
    @IBOutlet weak var viewSearch: UIView! //PV
    @IBOutlet weak var lc_viewSearch_Height: NSLayoutConstraint! //PV
    @IBOutlet weak var txtSearch: UISearchBar!
    
    //MARK: - Variable
    var objEnumSelectMember : enumSelectMember = .enumSelectMember_None //For manage hide/show content and perform action base on get value in Privious VC, current default //PV
    //var arrPersonalChat = [User]()
    //var arrGroupChat = [User]()
    
    //var forPersonalChat = falseforPersonalChat
    //var forGroupChat = false
    //var forAddMembersInGroup = false
    //var forBroadcastList = false
    //var forAddMembersInBroadcastList = false
    var pagetitle = ""
    var selectedGroupForAddMembers : StructGroupDetails!
    var selectedBroadcastListForAddMembers : StructBroadcastList!
    var selectedStatusMembers = ""
    
    var arrAllMembers = [User]()
    var arrSelectedMembers = [User]()
    
    var preSelectedUserIDs = [String]()
    
    var selectedGroupImage : UIImage?{
        didSet { imgGroupIcon.image = selectedGroupImage }
    }
    
    var selectedGroupImageName = ""
    
    //PV
    var arrSearchMemberList = [User] ()
    var searchClicked = false
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsetsMake(-30, 0, 0, 0); // Top Position of tablae set some padding remove, then write this code.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = false
        
        lblNotice.text = lblNotice.text?.replacingOccurrences(of: "(your number)", with: UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile))
        
        //PV
        textFieldContainer.isHidden = true
        collectionContainer.isHidden = true
        viewSearch.isHidden = true
        
        lc_viewSearch_Height.constant = 0
        collectionContainerHeight.constant = 0
        textFieldContainerHeight.constant = 0
        txtSearch.backgroundImage = UIImage()

        self.didFinish_ContactSyncProcess()
        self.set_NotificationObserver()
        self.manage_ShowContactData_base_On_SelectMember()
        
        //self.view.layoutIfNeeded() //PV
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:-
    func manage_ShowContactData_base_On_SelectMember() ->  Void {
        switch self.objEnumSelectMember {
        case .enumSelectMember_PersonalChat:
            self.manage_PeronalChat()
            break
            
        case .enumSelectMember_GroupChat:
            self.manage_GroupChat()
            break
            
        case .enumSelectMember_BroadcastChat:
            self.manage_BroadcastChat()
            break
            
        case .enumSelectMember_AddMembersInGroup:
            self.manage_AddMembersInGroup()
            break
            
        case .enumSelectMember_AddMembersInBroadcast:
            self.manage_AddMembersInBroadcast()
            break
            
        case .enumSelectMember_StatusPrivacy:
            self.manage_MembersForPrivacy()
            break
            
        default:
            break
        }
    }
    
    func get_AllAppUsers_inUserContacts() ->  [User] {
        var arrMembers = UserDefaultManager.getCustomObjFromUserDefaults(key: kAppUsers) as! [User]
        self.lblSelectedMembers.text = "\(arrMembers.count) Contact"
        
        //PV
        if arrMembers.count == 1
        {
                let user : User = arrMembers[0]
                let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: user.countryCode ?? "", phoneNo: user.phoneno ?? "")
                var contactName : String = ""
                if objContactInfo.Name?.count == 0 {
                    contactName = "+\(user.countryCode ?? "") \(user.phoneno ?? "")"
                }
                else {
                    contactName = objContactInfo.Name ?? ""
                }
                user.fullName = contactName
                arrMembers.remove(at: 0) //Remove Old
                arrMembers.insert(user, at: 0) //Add Updated
        }
        if arrMembers.count > 1
        {
        for i in 0...(arrMembers.count - 1) {
            let user : User = arrMembers[i]
            let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: user.countryCode ?? "", phoneNo: user.phoneno ?? "")
            var contactName : String = ""
            if objContactInfo.Name?.count == 0 {
                contactName = "+\(user.countryCode ?? "") \(user.phoneno ?? "")"
            }
            else { contactName = objContactInfo.Name ?? ""}
            
            //Update name
            user.fullName = contactName
            //user.username = contactName
            arrMembers.remove(at: i) //Remove Old
            arrMembers.insert(user, at: i) //Add Updated
        }
        }
        return arrMembers
    }
    
    func manage_PeronalChat () {
        lblTitle.text = "New Chat"
        lblSelectedMembers.text = ""
        lblSelectedMembers.text = "\(arrAllMembers.count) Contact"
        //lblSelectedMembers.isHidden = true
        lblSelectedMembersHeight.constant = 15
        btnNewChat.isHidden = false
        
        let arrMembers = self.get_AllAppUsers_inUserContacts()
        self.lblSelectedMembers.text = "\(arrMembers.count) Contact"
        
        if (arrMembers.count == 0) { /*return*/ }
        else {
            var arrHeader : [User] = []
            
            //Add New Group
            let objHeader_NewGroup : User = User.init(object: NSDictionary.init())
            objHeader_NewGroup.fullName = title_NewGroup
            arrHeader.append(objHeader_NewGroup)
            
            //Add New Broadcast
            let objHeader_NewBroadcast : User = User.init(object: NSDictionary.init())
            objHeader_NewBroadcast.fullName = title_NewBroadcast
            arrHeader.append(objHeader_NewBroadcast)
            
            //Add Footer
            let objFooter : User = User.init(object: NSDictionary.init())
            objFooter.fullName = title_InviteFriend
            
            self.arrAllMembers = arrHeader + arrMembers + [objFooter]
        }
        self.tableView.reloadData()
    }
    
    func manage_GroupChat () {
        textFieldContainer.isHidden = false
        textFieldContainerHeight.constant = 80
        lblTitle.text = "New Group"
        
        let arrMembers = self.get_AllAppUsers_inUserContacts()
        self.lblSelectedMembers.text = "\(arrAllMembers.count) Contact"
        
        if (arrMembers.count == 0) { /*return*/ }
        else { self.arrAllMembers = arrMembers }
        
        self.tableView.reloadData()
    }
    
    func manage_BroadcastChat() {
        collectionContainer.isHidden = false
        collectionContainerHeight.constant = 80
        lblTitle.text = "New Broadcast"
        
        let arrMembers = self.get_AllAppUsers_inUserContacts()
        self.lblSelectedMembers.text = "\(arrAllMembers.count) Contact"
        
        if (arrMembers.count == 0) { /*return*/ }
        else { self.arrAllMembers = arrMembers }
        
        self.tableView.reloadData()
    }
    
    func manage_AddMembersInGroup () {
        lblTitle.text = "Add Participants"
        
        let arrMembers = self.get_AllAppUsers_inUserContacts()
        self.lblSelectedMembers.text = "\(arrMembers.count) Contact"
        
        if (arrMembers.count == 0) { /*return*/ }
        else { self.arrAllMembers = arrMembers }
        
        preSelectedUserIDs = selectedGroupForAddMembers.members.components(separatedBy: ",")
        if preSelectedUserIDs.count > 0
        {
            for user in arrAllMembers {
                if preSelectedUserIDs.contains(user.userId!) { arrSelectedMembers.append(user) }
            }
        }
        
        reloadCollectionView()
        reloadTableView()
    }
    
    func manage_MembersForPrivacy ()
    {
        lblTitle.text = pagetitle
        let arrMembers = self.get_AllAppUsers_inUserContacts()
        self.lblSelectedMembers.text = "\(arrMembers.count) Contact"
        if (arrMembers.count == 0) { /*return*/ }
        else { self.arrAllMembers = arrMembers }
        if pagetitle.contains("Except")
        {
            selectedStatusMembers = UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_Status_Useridlist)
        }
        else
        {
            selectedStatusMembers = UserDefaultManager.getStringFromUserDefaults(key: kOnlySharewith_Useridlist)
        }
        preSelectedUserIDs = selectedStatusMembers.components(separatedBy: ",")
        if preSelectedUserIDs.count > 0
        {
            for user in arrAllMembers {
                if preSelectedUserIDs.contains(user.userId!) { arrSelectedMembers.append(user) }
            }
        }
        reloadCollectionView()
        reloadTableView()
    }
    
    func manage_AddMembersInBroadcast() {
        collectionContainer.isHidden = false
        collectionContainerHeight.constant = 80
        lblTitle.text = "Broadcast List"
        
        let arrMembers = self.get_AllAppUsers_inUserContacts()
        self.lblSelectedMembers.text = "\(arrMembers.count) Contact"
        
        if (arrMembers.count == 0) { /*return*/ }
        else { self.arrAllMembers = arrMembers }
        if preSelectedUserIDs.count > 0
        {
            for user in arrAllMembers {
                if preSelectedUserIDs.contains(user.userId!) { arrSelectedMembers.append(user) }
            }
        }
        
        reloadCollectionView()
        reloadTableView()
    }
    
    func manage_btnDoneClicked_GroupChat() {
        if txtGroupName.text!.count == 0{
            showMessage("Enter group name.")
        }
        else if txtGroupName.text!.count > 25{
            showMessage("Group name too long.")
        }
        else if arrSelectedMembers.count < 1{
            showMessage("Select group members.")
        }
        else if arrSelectedMembers.count > kMaxMembersInGroup{
            showMessage("Maximum \(kMaxMembersInGroup+1) members can be added in the group.")
        }
        else {
            btnDone.isUserInteractionEnabled = false
            showLoaderHUD(strMessage: "")
            
            //print("Creating group with \(arrSelectedMembers.count) members")
            
            if selectedGroupImage == nil { api_createGroup() }
            else { api_UploadGroupPicture() }
        }
    }
    
    func manage_btnDoneClicked_BroadcastChat() {
        //print("Create broadcast list of \(arrSelectedMembers.count) contacts")
        
        var arrMember : [String] = []
        for objUser : User in arrSelectedMembers {
            let strUserID : String = objUser.userId ?? "0"
            let strUserCountryCode : String = objUser.countryCode ?? "0"
            let strUserPhoneno : String = objUser.phoneno ?? "0"
            
            var strUserInfo : String = ""
            strUserInfo = strUserID + "_" + strUserCountryCode + "_" + strUserPhoneno
            
            arrMember.append(strUserInfo)
        }
        
        let dic = [
            "broadcastListID" : randomString(length: 20),
            "mediaurl": "",
            "textmessage": "",
            "createddate": "",
            "id": "0",
            "messagetype" : "0",
            "members": "\(arrMember.joined(separator: ",")))",
            "memberNames" : "\(arrSelectedMembers.map({$0.fullName!}).joined(separator: ","))",
            "memberPhotos" : "\(arrSelectedMembers.map({$0.imagePath!}).joined(separator: ","))",
            "name": "Participients: \(arrSelectedMembers.count)"
        ]
        let broadcastList = StructBroadcastList.init(dictionary: dic)
        //print("broadcastList : \(broadcastList)")
        
        if CoreDBManager.sharedDatabase.saveBroadcastListInDB(objBroadcastList: broadcastList){
            //print("Total Broadcast Lists : \(CoreDBManager.sharedDatabase.getBroadcastLists().map({($0 as! StructBroadcastList).name}))")
            let convo = loadVC(strStoryboardId: SB_CHAT, strVCId: idBroadcastChatVC) as! BroadcastChatVC
            convo.calledfrom = "messages"
            convo.selectedBroadcastListID = broadcastList.broadcastListID
            convo.broadcastListName = broadcastList.name
            APP_DELEGATE.appNavigation?.pushViewController(convo, animated: true)
        }
        
        //goBackToChatList()
        //APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    func manage_btnDoneClicked_AddMembersInGroup() {
        if arrSelectedMembers.count < 1 { showMessage("Select group members.") }
        else if arrSelectedMembers.count > kMaxMembersInGroup {
            showMessage("Maximum \(kMaxMembersInGroup + 1) members can be added in the group.")
        } else {
            btnDone.isUserInteractionEnabled = false
            showLoaderHUD(strMessage: "")
            
            var arrMembers = arrSelectedMembers.map({$0.userId!})
            arrMembers.insert(UserDefaultManager.getStringFromUserDefaults(key: kAppUserId), at: 0)
            let members = arrMembers.joined(separator: ",")
            
            var arrNewMembers = [String]()
            if preSelectedUserIDs.count > 0
            {
                for member in arrMembers {
                    if preSelectedUserIDs.contains(member) == false { arrNewMembers.append(member) }
                }
            }
            for newMemberId in arrNewMembers { arrAllMembers.filter({$0.userId == newMemberId}) }
            
            var newMembers = arrNewMembers.joined(separator: ",")
            if newMembers.count == 0 { newMembers = "0" }
            
            let arrPreviousAdmins = selectedGroupForAddMembers.admins.components(separatedBy: ",")
            var arrAdmins = [String]()
            for adminID in arrPreviousAdmins {
                if arrMembers.contains(adminID) { arrAdmins.append(adminID) }
            }
            let admins = arrAdmins.joined(separator: ",")
            
            let arrNewMobiles = arrSelectedMembers.filter({arrNewMembers.contains($0.userId!)}).map({($0.countryCode! + $0.phoneno!)})
            
            let dic = [
                "groupid":selectedGroupForAddMembers.group_id,
                "group_members":members,
                "username": UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
                "new_members" : newMembers,
                "admins" : admins,
                "ownerphone" : "\(UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode))\(UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile))",
                "mobilenolist" : arrNewMobiles.joined(separator: ","),
                "platform" : PlatformName,
                "removedid" : "0"
                ] as [String : Any]
            
            APP_DELEGATE.socketIOHandler?.socket?.emitWithAck("AddRemove_MembersInGroup",dic).timingOut(after: 30) { data in
                let data = data as Array
                if(data.count > 0) {
                    print(data.first!)
                    
                    hideLoaderHUD()
                    APP_DELEGATE.socketIOHandler?.reloadFriendAndGroupList()
                    //APP_DELEGATE.appNavigation?.popViewController(animated: true)
                    
                    self.goBackToChatList()
                }
            }
        }
    }
    
    func manage_btnDoneClicked_AddMembersInBroadcast() {
        //print("UPDATE MEMBERS, MEMBERPHOTOS, MEMBERNAMES FOR BROADCAST LIST ID : \(selectedBroadcastListForAddMembers.broadcastListID)")
        
        var arrMember : [String] = []
        for objUser : User in arrSelectedMembers {
            let strUserID : String = objUser.userId ?? "0"
            let strUserCountryCode : String = objUser.countryCode ?? "0"
            let strUserPhoneno : String = objUser.phoneno ?? "0"
            
            var strUserInfo : String = ""
            strUserInfo = strUserID + "_" + strUserCountryCode + "_" + strUserPhoneno
            
            arrMember.append(strUserInfo)
        }
        
        
        //let memberIDs = arrSelectedMembers.map({$0.userId!}).joined(separator: ",")
        let memberIDs = arrMember.joined(separator: ",")
        let memberPhotos = arrSelectedMembers.map({$0.imagePath!}).joined(separator: ",")
        let memberNames = arrSelectedMembers.map({$0.fullName!}).joined(separator: ",")
        
        selectedBroadcastListForAddMembers.memberNames = memberNames
        selectedBroadcastListForAddMembers.memberPhotos = memberPhotos
        selectedBroadcastListForAddMembers.members = memberIDs
        
        CoreDBManager.sharedDatabase.updateBroadcastListDetails(updatedBroadcastlist: selectedBroadcastListForAddMembers)
        goBackToChatList()
        //APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    func manage_btnDoneClicked_StatusPrivacy()
    {
        btnDone.isUserInteractionEnabled = false
        showLoaderHUD(strMessage: "")
        if pagetitle.contains("Except")
        {
            update_status_settings("3")
        }
        else
        {
            update_status_settings("4")
        }
    }
    func update_status_settings(_ vall:String)
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
       
        var arrMembers = arrSelectedMembers.map({$0.userId!})
        arrMembers.insert(UserDefaultManager.getStringFromUserDefaults(key: kAppUserId), at: 0)
        var members = arrMembers.joined(separator: ",")
        members = members.replacingOccurrences(of: ",,", with: ",")
        if members.count == 0
        {
            members = ""
        }
        UserDefaultManager.setStringToUserDefaults(value: "", key: kPrivacy_Status_Useridlist)
        if pagetitle.contains("Except")
        {
            UserDefaultManager.setStringToUserDefaults(value: members, key: kPrivacy_Status_Useridlist)
        }
        else
        {
            UserDefaultManager.setStringToUserDefaults(value: members, key: kOnlySharewith_Useridlist)
        }
        APP_DELEGATE.appNavigation?.backToViewController(viewController: PrivacyVC.self)
    }
    
    //MARK:- NotificationObserver
    func set_NotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(privacyChange_RefreshList(notification:)), name: NSNotification.Name(NC_PrivacyChange_Refresh_SelectMembersVC), object: nil)
    }
    
    //MARK: NotificationObserver Method
    @objc func privacyChange_RefreshList(notification : NSNotification) {
        if (notification.name.rawValue == NC_PrivacyChange_Refresh_SelectMembersVC) {
            self.tableView.reloadData()
        }
    }
    
    //MARK:- Button action
    @IBAction func btnBackClicked(_ sender: Any) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnSearchClicked(_ sender: Any) {
        //Manage Hide/Show Search View
        //viewTop.isHidden = viewTop.isHidden == true ? false : true
        
        viewSearch.isHidden = false
        if self.lc_viewSearch_Height.constant != 0 {
            self.lc_viewSearch_Height.constant = 0
            self.txtSearch.resignFirstResponder()
            searchClicked = false
        }
        else {
            self.lc_viewSearch_Height.constant = 56
            self.txtSearch.becomeFirstResponder()
            searchClicked = true
        }
        
        self.txtSearch.text = ""
        self.tableView.reloadData()
        
        //Manage hide/Show Animation
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func btnMenuClicked(_ sender: UIButton) {
        var arrMenus = ["Refresh"]
        
        switch self.objEnumSelectMember {
        case .enumSelectMember_PersonalChat:
            arrMenus.append("New Chat")
            arrMenus.append("Invite Friend")
            break
            
        default:
            break
        }
        
        openDropDown(From : sender, with: arrMenus, completion: { selectedMenuIndex in
            switch selectedMenuIndex {
            case 0:
                /*showHUD()
                ContactSync.shared.performSync()
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                    hideHUD()
                    self.arrSelectedMembers.removeAll()
                    self.tableView.reloadData()
                    self.manage_ShowContactData_base_On_SelectMember()
                })*/
                
                //Contact Sync
                ContactSync.shared.delegate = self
                ContactSync.shared.performSync()
                break
            case 1:
                self.btnNewChatClicked(sender)
                break
            case 2:
                inviteFriend()
                break
            default:
                break
            }
        })
    }
    
    @IBAction func btnGroupIconClicked(_ sender: Any) {
        ImagePicker.sharedInstance.delegate = self
        ImagePicker.sharedInstance.selectImage(sender: "GroupIcon")
    }
    
    @IBAction func btnNewChatClicked(_ sender: Any) {
        let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: "NewChatVC") as! NewChatVC
        let navigation = UINavigationController.init(rootViewController: vc)
        navigation.isNavigationBarHidden = true
        navigation.modalPresentationStyle = .overCurrentContext
        self.present(navigation, animated: true, completion: nil)
    }
    
    func getAppUsers() {
        arrAllMembers = UserDefaultManager.getCustomObjFromUserDefaults(key: kAppUsers) as! [User]
        self.lblSelectedMembers.text = "\(arrAllMembers.count) Contact"
        if (arrAllMembers.count == 0) { return } //PV
        
        //PV
        for i in 0...(arrAllMembers.count - 1)
        {
            let user : User = arrAllMembers[i]
            if user.userId != UserDefaultManager.getStringFromUserDefaults(key: kAppUserId) // // pu added 30oct
            {
                let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: user.countryCode ?? "", phoneNo: user.phoneno ?? "")
                var contactName : String = ""
                if objContactInfo.Name?.count == 0 {
                    contactName = "+\(user.countryCode ?? "") \(user.phoneno ?? "")"
                }
                else { contactName = objContactInfo.Name ?? ""}
                user.fullName = contactName
                self.arrAllMembers.remove(at: i)
                self.arrAllMembers.insert(user, at: i)
            }
        }
        reloadCollectionView()
        reloadTableView()
    }
}

extension SelectMembersVC: ContactSyncDelegate {
    //MARK: Sync Process Delegate method
    func didStart_ContactSyncProcess() {
        self.activityLoader.startAnimating()
        self.activityLoader.isHidden = false
    }
    
    func didFinish_ContactSyncProcess() {
        self.activityLoader.stopAnimating()
        self.activityLoader.isHidden = true
        
        //runAfterTime(time: 1.50, block: {
        self.manage_ShowContactData_base_On_SelectMember()
        //})
    }
}

//PV
extension SelectMembersVC: UISearchBarDelegate {
    func filterFindUser(_ searchText: String)
    {
        //print(arrAllMembers.map({$0.Title}))
        if (arrAllMembers.count == 0) { return }
        /*arrSearchMemberList = arrAllMembers.filter({(User) -> Bool in
            if (User.fullName?.count == 0 && User.username?.count == 0 && User.phoneno?.count == 0) {
                //return false
            }
            else {
            let value = ((User.fullName?.lowercased().contains(searchText.lowercased()))! ||
                (User.username?.lowercased().contains(searchText.lowercased()))! ||
                (User.phoneno?.lowercased().contains(searchText.lowercased()))!
            )
            return value
            }
            return false
        })*/
        
        /*arrSearchMemberList = arrAllMembers.filter { (User) -> Bool in
            let value = (User.fullName?.lowercased().contains(searchText.lowercased()))!
            return value
        }*/
        
        var tempArr = arrAllMembers
        switch self.objEnumSelectMember {
        case .enumSelectMember_PersonalChat:
            tempArr.removeFirst()
            tempArr.remove(at: 0)
            tempArr.removeLast()
            break
        
        default:
            break
        }
        
        arrSearchMemberList = tempArr.filter({(User) -> Bool in
            let value = ((User.fullName?.lowercased().contains(searchText.lowercased()))! ||
                (User.username?.lowercased().contains(searchText.lowercased()))! ||
                (User.phoneno?.lowercased().contains(searchText.lowercased()))!
            )
            return value
        })
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterFindUser(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.btnSearchClicked(UIButton.init())
    }
}

extension SelectMembersVC : ImagePickerDelegate {
    func pickImageComplete(_ imageData: UIImage, sender: String) {
        selectedGroupImage = imageData
    }
}

extension SelectMembersVC : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        //if forPersonalChat { return 2 }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var onOfRow : Int = 0
        if checkSearchBarActive(searchbar: self.txtSearch) { onOfRow = arrSearchMemberList.count }
        else { onOfRow = arrAllMembers.count }
        
        self.viewEmptyTableview.isHidden = true
        self.tableView.isHidden = true
        if (onOfRow == 0) { self.viewEmptyTableview.isHidden = false }
        else { self.tableView.isHidden = false }
        
        return onOfRow
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (arrAllMembers.count == 0) { return UITableViewCell.init() }
        
        switch self.objEnumSelectMember {
        case .enumSelectMember_PersonalChat:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectMemberCell", for: indexPath) as! SelectMemberCell
            
            var title :String = ""
            var subTitle :String = ""
           
            //var objUser : User = arrPersonalChat[indexPath.row]
            var objUser : User
            if checkSearchBarActive(searchbar: self.txtSearch) { objUser = arrSearchMemberList[indexPath.row] }
            else { objUser = arrAllMembers[indexPath.row] }
            
            title = objUser.fullName ?? "\(objUser.countryCode ?? "") \(objUser.phoneno ?? "")"
            subTitle = objUser.bio ?? "\(objUser.username ?? "")"
            
            if (title == title_NewGroup) {
                cell.lblName.text = title
                cell.lblName.textColor = themeWakeUppColor
                cell.lblBio.text = subTitle
                cell.imgUser.image = #imageLiteral(resourceName: "group_pic_dflt")
                cell.imgCheck.image = nil
                
            }
            else if (title == title_NewBroadcast) {
                cell.lblName.text = title
                cell.lblName.textColor = themeWakeUppColor
                cell.lblBio.text = subTitle
                cell.imgUser.image = #imageLiteral(resourceName: "group_pic_dflt")
                cell.imgCheck.image = nil
            }
            else if (title == title_InviteFriend) {
                cell.imgUser.image = #imageLiteral(resourceName: "share_channel")
                cell.lblName.text = title_InviteFriend
                cell.lblName.textColor = themeWakeUppColor
                cell.lblBio.text = subTitle
                cell.imgCheck.image = nil
            }
            else {
                cell.lblName.text = title
                cell.lblName.textColor = UIColor.black
                cell.lblBio.text = subTitle
                cell.imgUser.image = #imageLiteral(resourceName: "group_pic_dflt")
                cell.imgCheck.image = nil
                
                var userId :String = ""
                userId = objUser.userId!
                if arrSelectedMembers.contains(where: { $0.userId == userId }){
                    cell.containerView.borderColor = themeWakeUppColor
                    cell.imgCheck.image = #imageLiteral(resourceName: "check_mark_msg")
                }else{
                    cell.containerView.borderColor = Color_Hex(hex: "E2EEE9")
                    cell.imgCheck.image = nil
                }
                
                if (Privacy_ProfilePhoto_Show(userID: objUser.userId!) == true) {
                //if (Privacy_ProfilePhoto_Show(statusFlag: objUser.photoPrivacy ?? "") == true) {
                cell.imgUser.sd_setImage(with: URL.init(string: objUser.imagePath!)!, placeholderImage: ProfilePlaceholderImage, options: []) { (image, error, cacheType, url) in
                    if error != nil { cell.imgUser.image = UserPlaceholder }
                    }
                } else { cell.imgUser.image = UserPlaceholder }
            }
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectMemberCell", for: indexPath) as! SelectMemberCell
            
            var title :String = ""
            var subTitle :String = ""
            var objUser : User
            
            if checkSearchBarActive(searchbar: self.txtSearch) { objUser = arrSearchMemberList[indexPath.row] }
            else { objUser = arrAllMembers[indexPath.row] }
            
            title = objUser.fullName ?? "\(objUser.countryCode ?? "") \(objUser.phoneno ?? "")"
            subTitle = objUser.bio ?? "\(objUser.username ?? "")"
            
            if arrSelectedMembers.contains(where: { $0.userId == objUser.userId }){
                cell.containerView.borderColor = themeWakeUppColor
                cell.imgCheck.image = #imageLiteral(resourceName: "check_mark_msg")
            }else{
                cell.containerView.borderColor = Color_Hex(hex: "E2EEE9")
                cell.imgCheck.image = nil
            }
            
            cell.lblName.text = title
            cell.lblName.textColor = .black
            cell.lblBio.text = subTitle
            
            /*cell.imgUser.sd_setImage(with: URL.init(string: objUser.imagePath!)!, placeholderImage: ProfilePlaceholderImage, options: []) { (image, error, cacheType, url) in
                //--->
            }*/
            if (Privacy_ProfilePhoto_Show(userID: objUser.userId!) == true) {
                //if (Privacy_ProfilePhoto_Show(statusFlag: objUser.photoPrivacy ?? "") == true) {
                cell.imgUser.sd_setImage(with: URL.init(string: objUser.imagePath!)!, placeholderImage: ProfilePlaceholderImage, options: []) { (image, error, cacheType, url) in
                    if error != nil { cell.imgUser.image = UserPlaceholder }
                }
            } else { cell.imgUser.image = UserPlaceholder }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if (arrAllMembers.count == 0) { return }
        
        switch self.objEnumSelectMember {
        case .enumSelectMember_PersonalChat:
            var objUser : User
            if checkSearchBarActive(searchbar: self.txtSearch) { objUser = arrSearchMemberList[indexPath.row] }
            else { objUser = arrAllMembers[indexPath.row] }
            
            var title :String = ""
            title = objUser.fullName ?? "\(objUser.countryCode ?? "") \(objUser.phoneno ?? "")"
            
            if (title == title_NewGroup) {
                //print("NEW GROUP")
                let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: idSelectMembersVC) as! SelectMembersVC
                //vc.forGroupChat = true
                vc.objEnumSelectMember = .enumSelectMember_GroupChat
                APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
            }
            else if (title == title_NewBroadcast) {
                //print("NEW BROADCAST")
                let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: idSelectMembersVC) as! SelectMembersVC
                //vc.forBroadcastList = true
                vc.objEnumSelectMember = .enumSelectMember_BroadcastChat
                APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
            }
            else if (title == title_InviteFriend) { inviteFriend() }
            else {
                let convo = loadVC(strStoryboardId: SB_CHAT, strVCId:idChatVC ) as! ChatVC
                
                //let selectedUser = CoreDBManager.sharedDatabase.getFriendById(userID: objUser.userId!)
                //convo.selectedUser = selectedUser
                
                let selectedUser:StructChat = StructChat.init(dictionary: ["id" : "1",
                                                                           "username" : objUser.fullName ?? "",
                                                                           "user_id" : objUser.userId ?? "",
                                                                           "country_code" : objUser.countryCode ?? "",
                                                                           "phoneno" : objUser.phoneno ?? "",
                                                                           "image" : objUser.imagePath ?? "",
                                                                           /*"blocked_contacts" : objUser.blockedContacts as Any,
                                                                           "bio" : objUser.bio as Any,
                                                                           "muted_by_me" : objUser.mutedByMe as Any,
                                                                           "last_login" : objUser.lastLogin as Any,
                                                                           "is_online" : objUser.isOnline as Any,
                                                                           "sendername" : objUser.fullName as Any,
                                                                           "senderid" : objUser.userId as Any,
                                                                           "platform" : objUser.platform as Any,
                                                                           "createddate" : objUser.creationDatetime as Any*/])
                convo.selectedUser = selectedUser
                
                var strTitle : String = ""
                let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: objUser.countryCode ?? "", phoneNo: objUser.phoneno ?? "")
                if objContactInfo.Name?.count == 0 { strTitle = "+\(objUser.countryCode ?? "") \(objUser.phoneno ?? "")" }
                else { strTitle = objContactInfo.Name ?? "" }
                
                //------------->
                convo.calledfrom = "messages"
                convo.selecteduserid = objUser.userId
                convo.username = objUser.username!
                convo.strTitle = strTitle //"+\(objUser.countryCode ?? "") \(objUser.phoneno ?? "")"
                convo.imgTitleProfilePhoto = ProfilePlaceholderImage
                //convo.imgTitleProfilePhoto = cell.imgprofile.image ?? ProfilePlaceholderImage
                //------------->
                
                //convo.delegate = self
                APP_DELEGATE.appNavigation?.pushViewController(convo, animated: true)
            }
            break
            
        default:
            var user : User
            if checkSearchBarActive(searchbar: self.txtSearch) { user = self.arrSearchMemberList[indexPath.row] }
            else { user = arrAllMembers[indexPath.row] }
            
            if arrSelectedMembers.contains(where: { $0.userId == user.userId }) {
                arrSelectedMembers.remove(at: arrSelectedMembers.index(where: { $0.userId == user.userId })!)
            } else { arrSelectedMembers.append(user) }
            
            tableView.reloadRows(at: [indexPath], with: .none)
            reloadCollectionView()
            break
        }
    }
}

extension SelectMembersVC : UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewMemberCell", for: indexPath) as! NewMemberCell
        
        let user = arrSelectedMembers[indexPath.row]
        cell.lblName.text = user.fullName
        
        cell.imgUser.sd_setImage(with: URL.init(string: user.imagePath!)!, placeholderImage: ProfilePlaceholderImage, options: []) { (image, error, cacheType, url) in
            //print(url!)
        }
        cell.imgCheck.image = #imageLiteral(resourceName: "remove_mark")
        cell.btnCheck.tag = indexPath.row
        cell.btnCheck.addTarget(self, action: #selector(btnRemoveClicked), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrSelectedMembers.count
    }
    
    @objc func btnRemoveClicked(_ sender:UIButton){
        //print("remove clicked")
        let user = arrSelectedMembers[sender.tag]
        if arrSelectedMembers.contains(where: { $0.userId == user.userId }){
            arrSelectedMembers.remove(at: arrSelectedMembers.index(where: { $0.userId == user.userId })!)
        }
        reloadCollectionView()
        reloadTableView()
    }
    
    @IBAction func btnDoneClicked(_ sender:UIButton){
        switch self.objEnumSelectMember {
        case .enumSelectMember_GroupChat:
            self.manage_btnDoneClicked_GroupChat()
            break
            
        case .enumSelectMember_BroadcastChat:
            self.manage_btnDoneClicked_BroadcastChat()
            break
            
        case .enumSelectMember_AddMembersInGroup:
            self.manage_btnDoneClicked_AddMembersInGroup()
            break
        
        case .enumSelectMember_AddMembersInBroadcast:
            self.manage_btnDoneClicked_StatusPrivacy()
            break
            
        case .enumSelectMember_StatusPrivacy:
            self.manage_btnDoneClicked_StatusPrivacy()
            break
            
        default:
            break
        }
    }
    
    func reloadCollectionView() {
        collectionView.reloadData()
        
        switch self.objEnumSelectMember {
        case .enumSelectMember_PersonalChat:
            self.lblSelectedMembers.text = "\(arrAllMembers.count) contacts"
            break
            
        default:
             self.lblSelectedMembers.text = "\(arrSelectedMembers.count) of \(arrAllMembers.count) selected"
            break
        }
        
        /*if forPersonalChat { self.lblSelectedMembers.text = "\(arrAllMembers.count) contacts" }
        else { self.lblSelectedMembers.text = "\(arrSelectedMembers.count) of \(arrAllMembers.count) selected" }*/
        
        UIView.animate(withDuration: 0.3) {
            if self.arrSelectedMembers.count == 0{
                self.collectionView.alpha = 0
                self.btnDone.alpha = 0
                self.btnDone.isUserInteractionEnabled = false
            }else{
                self.collectionView.alpha = 1
                self.btnDone.alpha = 1
                self.btnDone.isUserInteractionEnabled = true
            }
        }
    }
    
    func reloadTableView(){
        tableView.reloadData()
    }
    
    func goBackToChatList(){
        APP_DELEGATE.appNavigation?.backToViewController(viewController: ChatListVC.self)
    }
    
}

extension SelectMembersVC {
    func api_UploadGroupPicture(){
        showLoaderHUD(strMessage: "Uploading Group Image")
        let parameter :NSMutableDictionary = ["token_id":UserDefaultManager.getStringFromUserDefaults(key: kToken)]
        let imageData:Data = UIImageJPEGRepresentation(selectedGroupImage!, uploadImageCompression)!
        parameter.setObject(imageData, forKey: ("image" as NSString))
        
        HttpRequestManager.sharedInstance.requestWithPostMultipartParam(endpointurl: UploadGroupIcon, isImage: true, parameters: parameter) {(data, error, message, responseDict) -> Void in
            hideLoaderHUD()
            
            if error != nil
            {
                hideLoaderHUD()
                showMessageWithRetry(RetryMessage, 3, buttonTapHandler: { _ in
                    hideBanner()
                    self.api_UploadGroupPicture()
                })
                return
            }
            else if let data = data
            {
                let thedata = data as? NSDictionary
                if(thedata != nil)
                {
                    print(thedata!)
                    if (thedata?.count)! > 0 {
                        self.selectedGroupImageName = thedata!.object(forKey: kData) as! String
                        self.api_createGroup()
                    }
                }
            }
        }
    }
    
    func api_createGroup(){
        var arrMembers = arrSelectedMembers.map({$0.userId!})
        arrMembers.insert(UserDefaultManager.getStringFromUserDefaults(key: kAppUserId), at: 0)
        let members = arrMembers.joined(separator: ",")
        
        let arrMobiles = arrSelectedMembers.map({($0.countryCode! + $0.phoneno!)})
        let membersPhoneNo = arrMobiles.joined(separator: ",")
        
        //CREATE GROUP
        let dic = [
            "group_name":txtGroupName.text!,
            "group_icon":selectedGroupImageName,
            "group_members":members,
            "group_created_by": UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            "platform" : PlatformName,
            "username" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
            "ownerphone" : "\(UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode))\(UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile))",
            "mobilenolist" : membersPhoneNo
            ] as [String : Any]
        //print("CreateGroup : param : \(dic)")
        
        showLoaderHUD(strMessage: "Create group")
        showHUD()
        
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck(keyCreateGroup,dic).timingOut(after: 30) { data in
            hideHUD()
            hideLoaderHUD()
            
            let objData = data as Array
            //print("CreateGroup : respo. : \(data)")
            if(objData.count > 0) {
                if objData[0] is String {
                    showMessage("\(SomethingWrongMessage). \(PleaseTryAgainMessage)")
                    self.goBackToChatList()
                    return 
                }
                
                hideLoaderHUD()
                //APP_DELEGATE.socketIOHandler?.reloadFriendAndGroupList()
                
                for dicData in objData {
                    let dic : [String : Any] = dicData as! [String : Any]
                    var objGroupInfo:StructGroupDetails = StructGroupDetails.init(dictionary: dicData as! [String : Any])
                    objGroupInfo.group_id = "\(dic["groupid"] ?? "")"
                    objGroupInfo.name = "\(dic["name"] ?? "")"
                    objGroupInfo.icon = "\(dic["icon"] ?? "")"
                    objGroupInfo.members = members
                    //objGroupInfo.muted_by = "\(dic[""]"")"
                    objGroupInfo.createdby = UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)
                    objGroupInfo.admins = "\(dic["admins"] ?? "")"
                    objGroupInfo.isalladmin = "\(dic["isalladmin"] ?? "")"
                    objGroupInfo.isdelete = "\(dic["isdeleted"] ?? "")"
                    objGroupInfo.lastMessageId = "\(dic["id"] ?? "")"
                    objGroupInfo.lastMediaURL = "\(dic["mediaurl"] ?? "")"
                    objGroupInfo.lastMessage = "\(dic["textmessage"] ?? "")"
                    objGroupInfo.lastMessageType = "\(dic["messagetype"] ?? "")"
                    objGroupInfo.lastMessageDate = "\(dic["createddate"] ?? "")"
                    objGroupInfo.lastMessageSenderId = "\(dic["senderid"] ?? "")"
                    objGroupInfo.lastMessageReceiverIds = "\(dic["receiverid"] ?? "")"
                    objGroupInfo.unreadCount = "0"
                    objGroupInfo.ishidden = "0"
                    //objGroupInfo.ispinned = "\(dic[""] ?? "0")"
                    //objGroupInfo.edit_permission = "\(dic[""] ?? "0")"
                    //objGroupInfo.msg_permission = "\(dic[""] ?? "0")"
                    if objGroupInfo.icon.count > 0 && objGroupInfo.icon.hasPrefix("http") == false{
                        objGroupInfo.icon = Get_Group_Icon_URL + objGroupInfo.icon
                    }
                    _ = CoreDBManager.sharedDatabase.saveGroupListInDB(objGroup: objGroupInfo)
                }
                postNotification(with: NC_GroupListRefresh)
                
                self.goBackToChatList()
            }
        }
    }
}
