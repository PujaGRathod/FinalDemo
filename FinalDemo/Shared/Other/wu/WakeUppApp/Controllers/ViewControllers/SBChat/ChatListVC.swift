//
//  ChatListVC.swift
//  HelpMe
//
//  Created by Admin on 10/03/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import Contacts
import QuartzCore

import SwiftyJSON
import Zip

class ChatListVC: UIViewController, ChatVC_Delegate, GroupChatVC_Delegate, BroadcastChatVC_Delegate {
    
    //MARK:- Outlet
    @IBOutlet weak var viewInitializing: UIView!
    @IBOutlet weak var imgInitializingProcess: UIImageView!
    
    @IBOutlet weak var btnvwterms: UIButton!
    @IBOutlet weak var blinkingView: UIImageView!
    @IBOutlet weak var vwnavbar: UIView!
    @IBOutlet var vwnodata: UIView!
    @IBOutlet var vwtabbar: UIView!
    @IBOutlet var btnSearch: UIButton!
    @IBOutlet var btnDND: UIButton!
    @IBOutlet weak var tbllist: UITableView!
    
    @IBOutlet weak var storyDot: UIImageView!
    
    @IBOutlet var heightsearchChatList: NSLayoutConstraint!
    @IBOutlet var searchChatList: UISearchBar!
    
    //MARK:- Variable
    var arrFriends = [StructChat]()
    var arrGroups = [StructGroupDetails]()
    var arrBroadcastLists = [StructBroadcastList]()
    var arrChatList = [StructChatList]()
    
    var filterChatList = [ StructChatList ] ()
    var searchclicked = false
    
    var hiddenChatsUnreadCount:Int{
        let unreadCountOfHiddenPersonalChats = CoreDBManager.sharedDatabase.getHiddenFriendList().map({Int($0.kunreadcount)!}).reduce(0, {$0 + $1})
        let unreadCountOfHiddenGroupChats = CoreDBManager.sharedDatabase.getHiddenGroupList().map({Int($0.unreadCount)!}).reduce(0, {$0 + $1})
        
        let unreadCountOfHiddenChats = unreadCountOfHiddenPersonalChats + unreadCountOfHiddenGroupChats
        return unreadCountOfHiddenChats
    }
    var blinkingTimer:Timer?
    
    var mergedarray = [StructChatList]()
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
               //Contact Sync
        ContactSync.shared.delegate = self
        ContactSync.shared.performSync()
        //APP_DELEGATE.isHiddenChatUnlocked = false //Manage Hidden chat hide/show on move to another screen and agin move this screen.
        
        APP_DELEGATE.socketIOHandler?.connectWithSocket()
        
        layoutUI()
        self.set_NotificationObserver()
        
        reloadTable()
        setStoryDot()
        
        searchChatList.delegate = self
        searchChatList.backgroundImage = UIImage()
        self.heightsearchChatList.constant = 0
        searchChatList.text = ""
        
        APP_DELEGATE.chatDotVisible = false
        
        if AppUpdater.isUpdateAvailable(){
            AppUpdater.showUpdateAlert(isForce: true)
        }
        let AnimationDuration = 1.40
        blinkingTimer = Timer.scheduledTimer(withTimeInterval: AnimationDuration, repeats: true, block: { (timer) in //PU (1.0-> 0.4) //Date : 01-07-2018
            if self.hiddenChatsUnreadCount == 0{
                self.blinkingView.alpha = 0
            }else{
                var newAlpha:CGFloat = 0
                if self.blinkingView.alpha == 0 { newAlpha = 1 }
            
                UIView.animate(withDuration: AnimationDuration, animations: {
                    self.blinkingView.alpha = newAlpha
                }, completion: { (finished) in
                })
            }
        })
        
        let arrChatListPersonalUniqueIDs = arrChatList.filter({$0.ChatType == .Personal}).map({$0.UniqueID})
        
        var arrAppUsers = [StructChatList]()
        let arr = UserDefaultManager.getCustomObjFromUserDefaults(key: kAppUsers) as! [User]
        for eachval in arr {
            var strDate = eachval.creationDatetime
            strDate = strDate?.replacingOccurrences(of: "T", with: " ").components(separatedBy: ".").first!
            let date = DateFormater.getMessageDate(givenDate: strDate!)
            let mdl = StructChat.init(dictionary:["id":"0",
                                                  "createddate":"",
                                                  "platform":"1",
                                                  "textmessage":"",
                                                  "receiverid":"",
                                                  "senderid":"",
                                                  "sendername":eachval.fullName!,
                                                  "isdeleted":"0",
                                                  "isread":"0",
                                                  "messagetype":"0",
                                                  "mediaurl":"",
                                                  "chatid":"",
                                                  "image":"",
                                                  "is_online":"0",
                                                  "last_login":"",
                                                  "username":eachval.fullName!,
                                                  "user_id":eachval.userId!,
                                                  "unreadcount":"0",
                                                  "muted_by_me":"0",
                                                  "country_code":eachval.countryCode!,
                                                  "phoneno":eachval.phoneno!,
                                                  "isstarred":"0",
                                                  "blocked_contacts":"0",
                                                  "parent_id":"0",
                                                  "ishidden":"0",
                                                  "ispinned":"0"])
            var nameval = eachval.fullName!
            let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: eachval.countryCode!, phoneNo: eachval.phoneno!)
            if objContactInfo.Name?.count == 0 {
                //print("NOT IN CONTACTS")
                nameval = "+\(eachval.countryCode!) \(eachval.phoneno!)"
            }
            else { nameval = objContactInfo.Name! }
            //print(nameval)
            let objChatList = StructChatList.init(
                UniqueID: eachval.userId!,
                Title: nameval,
                Message: eachval.bio!,
                strDate: eachval.creationDatetime!,
                Date: date,
                Photo: eachval.image!,
                IsRead: "0",
                IsPinned: "0",
                ChatType: .Personal,
                OriginalModel: mdl)
            
            if arrChatListPersonalUniqueIDs.contains(objChatList.UniqueID) == false{
                arrAppUsers.append(objChatList)
            }
        }
        
        let arr1 = arrAppUsers.map({$0.Title})
        
        let filtered = arrChatList.filter({ arr1.contains($0.Title) == false  })
        
        mergedarray = arrAppUsers + filtered
        
        //PV
        //let arrStatic = self.arrChatList
        self.socket_TypingReceived()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        APP_DELEGATE.appNavigation?.interactivePopGestureRecognizer?.isEnabled = true
        APP_DELEGATE.appNavigation?.interactivePopGestureRecognizer?.delegate = self
        reloadTable()
        
        //PV
        APP_DELEGATE.socketIOHandler?.reloadFriendAndGroupList()
    }
    @IBAction func btnagreeclicked(_ sender: Any) {
    }
    
    @IBAction func btnprivacyclicked(_ sender: Any) {
        guard let url = URL(string: URL_PrivacyPolicy) else { return }
        UIApplication.shared.open(url)
    }
    @IBAction func btntermsclicked(_ sender: UIButton) {
        guard let url = URL(string: URL_TermsOfUse) else { return }
        UIApplication.shared.open(url)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //  hideLoaderHUD()
        APP_DELEGATE.chatDotVisible = false
        APP_DELEGATE.pushdictreceive  = NSDictionary()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        APP_DELEGATE.isHiddenChatUnlocked = false //Manage Hidden chat hide/show on move to another screen and agin move this screen.
        
        //Reload Table
        runAfterTime(time: 0.50) {
            //self.reloadTable()
            self.tbllist.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:-
    
    @objc func blinkLogoW() {
        //---->
    }
 
    func layoutUI() {
        self.automaticallyAdjustsScrollViewInsets = false
        tbllist.contentInset = UIEdgeInsets.zero
        
        let footervw = UIView.init(frame: .zero)
        self.tbllist.tableFooterView = footervw
        tbllist.delegate = self
        tbllist.dataSource = self
        isStatusBarHidden = false
    }
    
    @objc func reloadTable() {
        let dicd = APP_DELEGATE.pushdictreceive as NSDictionary
        if APP_DELEGATE.pushdictreceive.allKeys.count > 0
        {
            let chatid = dicd.object(forKey: "chatid") as! String
            CoreDBManager.sharedDatabase.updateReadStatus(newReadStatus: "1", forChatIDs: [chatid])
            APP_DELEGATE.socketIOHandler?.socket?.emit("Update_ReceivedStatus",dicd)
            //showAlertMessage(dicd.allKeys.description)
            
        }
        print(APP_DELEGATE.isHiddenChatUnlocked)
        arrFriends = CoreDBManager.sharedDatabase.getFriendList(includeHiddens: APP_DELEGATE.isHiddenChatUnlocked) as! [StructChat]
        arrGroups = CoreDBManager.sharedDatabase.getGroupsList(includeHiddens: APP_DELEGATE.isHiddenChatUnlocked) as! [StructGroupDetails]
        arrBroadcastLists = CoreDBManager.sharedDatabase.getBroadcastLists() as! [StructBroadcastList]
        
        arrChatList = [StructChatList]()
        for friend in arrFriends{
            if friend.kphonenumber != UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile) {
                var strDate = friend.kcreateddate
                strDate = strDate.replacingOccurrences(of: "T", with: " ").components(separatedBy: ".").first!
                let date = DateFormater.getMessageDate(givenDate: strDate)
                
                let objChatList = StructChatList.init(UniqueID : friend.kuserid,
                                                      Title: friend.kusername,
                                                      Message: friend.kchatmessage.base64Decoded!,
                                                      strDate: friend.kcreateddate,
                                                      Date: date,
                                                      Photo: "\(Get_Profile_Pic_URL)\(friend.kuserprofile)",
                                                    IsRead: friend.kisread,
                                                    IsPinned: friend.ispinned,
                                                    ChatType: .Personal,
                                                    OriginalModel: friend)
                arrChatList.append(objChatList)
            }
            else {
                //print("Own number")
            }
        }
        
        for group in arrGroups{
            var strDate = group.lastMessageDate
            strDate = strDate.replacingOccurrences(of: "T", with: " ").components(separatedBy: ".").first!
            let date = DateFormater.getMessageDate(givenDate: strDate)
            
            var objChatList = StructChatList.init(
                UniqueID: group.group_id,
                Title: group.name,
                Message: group.lastMessage.base64Decoded!,
                strDate: group.lastMessageDate,
                Date: date,
                Photo: group.icon,
                IsRead: "0",
                IsPinned: group.ispinned,
                ChatType: .Group,
                OriginalModel: group)
            
            if group.lastMessageType == "-1"{
                let message = objChatList.Message
                
                var phoneNo1 = ""
                var arrPhoneNos = [""]
                var msg = ""
                if message.contains("created"){
                    var components = message.components(separatedBy: " ")
                    phoneNo1 = components.first!
                    components.remove(at: 0)
                    msg = components.joined(separator: " ")
                }else{
                    if message != "You were added"
                    {
                        var components = message.components(separatedBy: "|")
                        phoneNo1 = components.first!
                        components.removeFirst()
                        arrPhoneNos = components.last!.components(separatedBy: ",")
                        components.removeLast()
                        msg = components.joined(separator: " ")
                        //if components.contains("removed") || components.contains("added"){
                        msg = " " + msg + " "
                    }
                    else
                    {
                        msg = message
                    }
                    //}
                }
                
                let userPhone = UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode) + UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)
                
                if phoneNo1 == userPhone{
                    phoneNo1 = "You"
                }else{
                    let objContactInfo1 : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: "", phoneNo: phoneNo1)
                    if objContactInfo1.Name?.count == 0 {
                        //print("NOT IN CONTACTS")
                    }
                    else {
                        phoneNo1 = objContactInfo1.Name!
                    }
                }                
                
                msg = phoneNo1 + msg
                
                var arr2 = [String]()
                for phone2 in arrPhoneNos{
                    if phone2.isNumeric{
                        let objContactInfo2 : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: "", phoneNo: phone2)
                        if phone2.count > 0 && phone2.isNumeric{
                            var ph = phone2
                            if ph == userPhone{
                                ph = "You"
                            }else{
                                if objContactInfo2.Name?.count == 0 {
                                    //print("NOT IN CONTACTS")
                                }
                                else {
                                    //msg = msg + " " + objContactInfo2.Name!
                                    ph = objContactInfo2.Name!
                                }
                            }
                            arr2.append(ph)
                        }
                    }else{
                        arr2.append(phone2)
                    }
                }
                //msg = msg + " " + arr2.joined(separator: ", ")
                msg = msg + arr2.joined(separator: ", ")
                msg = msg.replacingOccurrences(of: "  ", with: " ")
                
                objChatList.Message = msg
            }
            arrChatList.append(objChatList)
        }
        
        for broadcastList in arrBroadcastLists{
            var strDate = broadcastList.lastMessageDate
            strDate = strDate.replacingOccurrences(of: "T", with: " ").components(separatedBy: ".").first!
            
            if strDate.count == 0
            {
                strDate = "2000-01-01 00:00:00"
            }
            
            let date = DateFormater.getMessageDate(givenDate: strDate)
            
            let objChatList = StructChatList.init(
                UniqueID: broadcastList.broadcastListID,
                Title: broadcastList.name,
                Message: broadcastList.lastMessage.base64Decoded!,
                strDate: broadcastList.lastMessageDate,
                Date: date,
                Photo: "",
                IsRead: "0",
                IsPinned: broadcastList.ispinned,
                ChatType: .Broadcast,
                OriginalModel: broadcastList)
            arrChatList.append(objChatList)
        }
        
        arrChatList.sort(by: { $0.Date.compare($1.Date) == .orderedDescending })
        
        let pinnedChats = arrChatList.filter({$0.IsPinned == "1"})
        let unPinnedChats = arrChatList.filter({$0.IsPinned == "0"})
        arrChatList = pinnedChats + unPinnedChats
        
        if arrChatList.count == 0{
            tbllist.isHidden = true
            vwnodata.isHidden = false
        }else{
            tbllist.isHidden = false
            vwnodata.isHidden = true
        }
      
       
          tbllist.reloadData()
        setDNDImage()
    }
    
    //MARK: Sync Process Initializing
    func manage_SyncProcessInitializing(showSyncProcess : Bool) -> Void {
        if (showSyncProcess == true)
        {
            self.viewInitializing.alpha = 1.0
            self.viewInitializing.isHidden = false
            
            //Sync Process Initializing
            self.imgInitializingProcess.removeSubviews()
            self.runSpinAnimationOnView(onLayer: self.imgInitializingProcess.layer, duration: 20.0, rotations: 0.075, repeatCount: 100)
        }
        else
        {
            self.viewInitializing.alpha = 1.0
            UIView.animate(withDuration: 0.30, animations: {
                self.viewInitializing.alpha = 0.0
            })
        }
    }
    
    func runSpinAnimationOnView(onLayer:CALayer, duration:Float, rotations:Float, repeatCount:Float) -> Void {
        let rotationAnimation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = NSNumber(value: .pi * 2.0 * rotations * duration)
        
        rotationAnimation.duration = CFTimeInterval(duration)
        //rotationAnimation.isCumulative = true
        rotationAnimation.autoreverses = false
        rotationAnimation.repeatCount = repeatCount
        
        onLayer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    //MARK:- NotificationObserver
    func set_NotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: NSNotification.Name(NC_NewMessage), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: NSNotification.Name(NC_UserListRefresh), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: NSNotification.Name(NC_NewGroupMessage), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: NSNotification.Name(NC_GroupListRefresh), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: NSNotification.Name(NC_HiddenChatLockToggle), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setStoryDot), name: NSNotification.Name(NC_StoryDotChanged), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(privacyChange_RefreshList(notification:)), name: NSNotification.Name(NC_PrivacyChange_Refresh_ChatListVC), object: nil)
    }
    
    func remove_NotificationObserver() {
        //--->
    }
    
    //MARK: NotificationObserver Method
    @objc func setStoryDot(){
        storyDot.isHidden = !APP_DELEGATE.storyDotVisible
    }
    
    @objc func privacyChange_RefreshList(notification : NSNotification) {
        if (notification.name.rawValue == NC_PrivacyChange_Refresh_ChatListVC) {
            self.reloadTable()
        }
    }
    
    //MARK:- Button action method
    @IBAction func btnchatclicked(_ sender: Any) {
        let storyvc = loadVC(strStoryboardId: SB_CHAT, strVCId: "chatlistvc") as! ChatListVC
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
    }
    
    @IBAction func btnstoryclicked(_ sender: Any) {
        APP_DELEGATE.appNavigation?.interactivePopGestureRecognizer?.isEnabled = false
        /*let storyvc = loadVC(strStoryboardId: SB_STORIES, strVCId: "storylistvc") as! StoryListVC
         APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)*/
        let storyvc = loadVC(strStoryboardId: SB_STORIES, strVCId: idStoriesVC)
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
    }
    
    @IBAction func btnpostclicked(_ sender: Any) {
        /* let storyvc = loadVC(strStoryboardId: SB_FEEDS, strVCId: "feedlistvc") as! FeedListVC
         APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)*/
        
        let feeds = loadVC(strStoryboardId: SB_FEEDS, strVCId: idFeedVC) as! FeedVC
        APP_DELEGATE.appNavigation?.pushViewController(feeds, animated: false)
    }
    
    @IBAction func btnchannelclicked(_ sender: Any) {
        let storyvc = loadVC(strStoryboardId: SB_CHANNEL, strVCId: idChannelListVC) as! ChannelListVC
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
    }
    
    @IBAction func btnuserclicked(_ sender: Any) {
        let storyvc = loadVC(strStoryboardId: SB_MAIN, strVCId: idProfileVC) as! ProfileVC
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
    }
    
    @IBAction func btnSearchClicked(_ sender: Any) {
        searchChatList.text = ""
        if searchclicked == true
        {
            self.heightsearchChatList.constant = 0
            self.searchChatList.resignFirstResponder()
            searchclicked = false
        }
        else
        {
            searchclicked = true
            self.heightsearchChatList.constant = 56
            self.searchChatList.becomeFirstResponder()
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func btnMoreClicked(_ sender: UIButton) {
        
        /*let appearance = DropDown.appearance()
         
         appearance.cellHeight = 60
         appearance.backgroundColor = .white// UIColor(white: 1, alpha: 1)
         appearance.selectionBackgroundColor = .white// UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
         //        appearance.separatorColor = UIColor(white: 0.7, alpha: 0.8)
         appearance.cornerRadius = 10
         appearance.shadowColor = UIColor(white: 0.6, alpha: 1)
         appearance.shadowOpacity = 0.9
         appearance.shadowRadius = 25
         appearance.animationduration = 0.25
         appearance.textColor = .darkGray
         appearance.textFont = UIFont.init(name: FT_Medium, size: 16)!
         
         let dropDown = DropDown()
         
         // The view to which the drop down will appear on
         dropDown.anchorView = sender // UIView or UIBarButtonItem
         
         // The list of items to display. Can be changed dynamically
         dropDown.dataSource = ["New Group", "New Broadcast", "Setting"]
         
         
         // Action triggered on selection
         dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
         //print("Selected item: \(item) at index: \(index)")
         }
         
         dropDown.DDwidth = 180
         
         dropDown.show()
         
         DropDown.startListeningToKeyboard()*/
        
        var arrMenus = ["New Group", "New Broadcast List", "Starred Messages","Call History", "Settings"]
        let strcount = CoreDBManager.sharedDatabase.getUnReadCountCall()
        if strcount == "0" {
            arrMenus = ["New Group", "New Broadcast List", "Starred Messages","Call History", "Settings"]
        }
        else {
            arrMenus = ["New Group", "New Broadcast List", "Starred Messages","Call History New", "Settings"]
        }
        
        openDropDown(From : sender, with: arrMenus, completion: { selectedMenuIndex in
              APP_DELEGATE.appNavigation?.interactivePopGestureRecognizer?.isEnabled = false
            switch selectedMenuIndex{
              
            case 0:
                let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: idSelectMembersVC) as! SelectMembersVC
                //vc.forGroupChat = true
                vc.objEnumSelectMember = .enumSelectMember_GroupChat
                APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
                break
            case 1:
                let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: idSelectMembersVC) as! SelectMembersVC
                //vc.forBroadcastList = true
                vc.objEnumSelectMember = .enumSelectMember_BroadcastChat
                APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
                break
            case 2:
                let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: "StarredMessagesVC") as! StarredMessagesVC
                APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
                break
            case 3:
                let objVC : CallHistoryVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idCallHistoryVC) as! CallHistoryVC
                APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
                break
            case 4:
                let objVC : ProfileSettingVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idProfileSettingVC) as! ProfileSettingVC
                APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
                break
            default:
                break
            }
        })
        
    }
    
    @IBAction func btnNewChatMessageClicked(_ sender: Any) {
        APP_DELEGATE.appNavigation?.interactivePopGestureRecognizer?.isEnabled = false
        let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: idSelectMembersVC) as! SelectMembersVC
        //vc.forPersonalChat = true
        vc.objEnumSelectMember = .enumSelectMember_PersonalChat            
        APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnHiddenChatClicked(_ sender: Any) {
        if APP_DELEGATE.isHiddenChatUnlocked {
            APP_DELEGATE.isHiddenChatUnlocked = false
            reloadTable()
        }else{
            let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: "HideChatPasscodeVC") as! HideChatPasscodeVC
            vc.modalPresentationStyle = .overCurrentContext
            APP_DELEGATE.appNavigation?.present(vc, animated: false, completion: nil)
        }
    }
    
    @IBAction func btnDNDClicked(_ sender: Any) {
        
        //-------------------------------------->
        UserDefaultManager.setBooleanToUserDefaults(value: false, key: kChatBackupRestore)
        //Check if user already upload backup on iCloud to show alert to restore chat.
        let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ImportExportProcessVC" ) as! ImportExportProcessVC
        objVC.strImgURL = ""
        objVC.strTitle = "Import chat"
        objVC.objEnumImpExpoAction = .Import_AppChat
        objVC.Popup_Show(onViewController: self)
        return
        //<--------------------------------------
        
        if isDNDActive == false{ //NOW TRYING TO ENABLR IT, SO ASK FIRST
            let alert = UIAlertController.init(title: "Enable DND Mode", message: "DNDMode - If enabled, you will not receive or send any messages until you disable it.", preferredStyle: .alert)
            
            let actionOk = UIAlertAction.init(title: "Ok", style: .default, handler: { (action) in
                UserDefaultManager.setBooleanToUserDefaults(value: !isDNDActive, key: kIsDNDActive)
                postNotification(with: NC_DNDStatusChanged)
                self.setDNDImage()
            })
            let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(actionOk)
            alert.addAction(actionCancel)
            present(alert, animated: true, completion: nil)
        }else{
            UserDefaultManager.setBooleanToUserDefaults(value: !isDNDActive, key: kIsDNDActive)
            postNotification(with: NC_DNDStatusChanged)
            setDNDImage()
        }
    }
    
    func setDNDImage(){
        if isDNDActive == true{
            btnDND.setImage(#imageLiteral(resourceName: "dnd_off"), for: .normal)
        }else{
            btnDND.setImage(#imageLiteral(resourceName: "dnd_on"), for: .normal)
        }
    }
    
    //MARK:- API
    func api_BlockUser(parameter : NSDictionary, loaderMess: String,userid:String) {
        self.view.endEditing(true)
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIUserFollow, parameters: parameter, keyname: "", message: loaderMess, showLoader: true, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            hideLoaderHUD() // Hide Loader
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_BlockUser(parameter: parameter, loaderMess: loaderMess,userid: userid)
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    
                    //Show Success message
                    /*var strMessage: String = ""
                     if (loaderMess.count == 0) { strMessage = responseDict!.object(forKey: kMessage) as! String }
                     else {  strMessage = "User \(self.strTitle) unblocked successfully."  }
                     showMessage(strMessage)*/
                    
                    let strMessage = responseDict!.object(forKey: kMessage) as! String
                    showMessage(strMessage)
                    
                    if strMessage.contains("unblock"){
                        APP_DELEGATE.RemoveUser_BlockContactList(strUserID: (userid))
                    }
                    
                    self.reloadTable()
                    
                    UIView.setAnimationsEnabled(false);
                    self.tbllist.beginUpdates()
                    self.tbllist.endUpdates()
                    UIView.setAnimationsEnabled(true)
                }
            }
        })
    }
    //MARK: Socket API
    func socket_TypingReceived() {
        APP_DELEGATE.socketIOHandler?.socket?.on("TypingReceived") {data, ack in
            if data.count > 0 {
                if let dicData = data.first as? [String:String]{
                    
                    //print("Type.....: \(dicData)")
                    let senderId = dicData["senderid"]!
                    //let recieverId = dicData["receiverid"]!
                    let isTyping = dicData["istyping"] ?? "0"
                    let isGroup = dicData["isgroup"]!
                    
                    if (self.arrChatList.count == 0) { return }
                    let count = self.arrChatList.count - 1
                    for i in 0...count {
                        let obj : StructChatList = self.arrChatList[i]
                        if obj.ChatType == .Personal {
                            var chatUser = obj.OriginalModel as! StructChat
                            if senderId == chatUser.ksenderid && isGroup == "0" {
                                if isTyping == "1" {
                                   // print("------------------------------------------------Called 1")
                                    chatUser.kchatmessage = chatUser.kchatmessage + " ___typing..."
                                }
                                else
                                {
                                    //print("------------------------------------------------Called 0")
                                    chatUser.kchatmessage = chatUser.kchatmessage.replacingOccurrences(of: " ___typing...", with: "")
                                }
                               // print("---------------------\(chatUser.kchatmessage)")
                                //Repl. obj
                                self.arrChatList.remove(at: i) //Remove
                                
                                //Create Repalce Obj.0
                                var objRepl : StructChatList = obj
                                objRepl.OriginalModel = chatUser
                                //Repl. obj in main array
                                self.arrChatList.insert(objRepl, at: i)
                                
                                //Reload Cell
                                if self.tbllist.numberOfRows(inSection: 0) != 0 {
                                    self.tbllist.reloadRows(at: [IndexPath.init(row: i, section: 0)], with: UITableViewRowAnimation.none)
                                }
                            }
                        }
                    }
                    //--------->
                }
            }
        }
    }
    
    //MARK:- Delegate Methods
    
    //MARK: ChatVC Delegate Methods
    func manage_HiddentChat_onChatVC(HideChatStatus: Bool?) {
        runAfterTime(time: 0.25) {
            APP_DELEGATE.isHiddenChatUnlocked = HideChatStatus!
        }
    }
    func typingStopped(_ dicval:NSDictionary)
    {
        if (self.arrChatList.count == 0) { return }
        let count = self.arrChatList.count - 1
        for i in 0...count {
            let obj : StructChatList = self.arrChatList[i]
            let senderId = "\(dicval["senderid"]!)"
            let isTyping = "\(dicval["istyping"]!)"
            let isGroup = "\(dicval["isgroup"]!)"
            if obj.ChatType == .Personal {
                var chatUser = obj.OriginalModel as! StructChat
                if senderId == chatUser.ksenderid && isGroup == "0"
                {
                    if isTyping == "1"
                    {
                        chatUser.kchatmessage = chatUser.kchatmessage + "___typing..."
                    }
                    else
                    {
                        chatUser.kchatmessage = chatUser.kchatmessage.replacingOccurrences(of: "___typing...", with: "")
                    }
                    self.arrChatList.remove(at: i)
                    var objRepl : StructChatList = obj
                    objRepl.OriginalModel = chatUser
                    self.arrChatList.insert(objRepl, at: i)
                    if self.tbllist.numberOfRows(inSection: 0) != 0 {
                        self.tbllist.reloadRows(at: [IndexPath.init(row: i, section: 0)], with: UITableViewRowAnimation.none)
                    }
                }
            }
        }
    }
    //MARK: GroupChatVC_Delegate Methods
    func manage_HiddentChat_onGroupChatVC(HideChatStatus: Bool?) {
        runAfterTime(time: 0.25) {
            APP_DELEGATE.isHiddenChatUnlocked = HideChatStatus!
        }
    }
    
    //MARK: BroadcastChatVC_Delegate Methods
    func manage_HiddentChat_onBroadcastChatVC(HideChatStatus: Bool?) {
        runAfterTime(time: 0.25) {
            APP_DELEGATE.isHiddenChatUnlocked = HideChatStatus!
        }
    }
}

extension ChatListVC: ContactSyncDelegate {
    //MARK: Sync Process Delegate method
    func didStart_ContactSyncProcess()
    {
        if (UserDefaultManager.getBooleanFromUserDefaults(key: "ContactSyncStatus") == false)
        {
            self.manage_SyncProcessInitializing(showSyncProcess: true)
        }
        else {
            self.viewInitializing.isHidden = true
        }
    }
    
    func didFinish_ContactSyncProcess() {
        self.manage_SyncProcessInitializing(showSyncProcess: false)
        UserDefaultManager.setBooleanToUserDefaults(value: true, key: "ContactSyncStatus")
    }
}

extension ChatListVC: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1//3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return arrChatList.count
        if checkSearchBarActive(searchbar: self.searchChatList) { return filterChatList.count }
        else { return arrChatList.count }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let chatListModel:StructChatList
        if checkSearchBarActive(searchbar: self.searchChatList) { chatListModel = filterChatList[indexPath.row] }
        else { chatListModel = arrChatList[indexPath.row] }
        
        //let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(self.longPressedCell(gestureRecognizer:)))
        
        if chatListModel.ChatType == .Personal {
            let cell : ChatListCell = self.manageCell_PersonalChat(tableView: tableView, indexPath: indexPath, chatListModel: chatListModel)
            return cell
        }else if chatListModel.ChatType == .Group {
            let cell : ChatListCell = self.manageCell_GroupChat(tableView: tableView, indexPath: indexPath, chatListModel: chatListModel)
            cell.widthgroupuser.constant = 0
            return cell
            
            /*
            //let chatGroup = chatListModel.OriginalModel as! StructGroupDetails
            cell.widthgroupuser.constant = 0
            cell.widthmsgtype.constant = 0
            cell.widthreadreceipt.constant = 0
            */
            
            
            //cell.widthmsgtype.constant = 0
            //cell.widthreadreceipt.constant = 0
            
        }else{
            //Broadcast Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell") as! ChatListCell
            
            cell.delegate = self
            cell.tag = indexPath.row
            cell.backgroundColor = UIColor.white
            cell.swipeBackgroundColor = UIColor.white
            
            let chatBroadcast = chatListModel.OriginalModel as! StructBroadcastList
            
            let dtvalr = chatBroadcast.lastMessageDate == "" ? "" : timeAgoSinceStrDate(strDate: chatBroadcast.lastMessageDate, numericDates: true)
            cell.lbltime.text = dtvalr
            
            cell.btnselected.isHidden = true
            cell.lblname.text = chatBroadcast.name
            cell.lblrecentmsg.text = chatBroadcast.lastMessage.base64Decoded
           
            cell.imgprofile.image = #imageLiteral(resourceName: "boradcast_profile")
            
            cell.widthgroupuser.constant = 0
            cell.widthmsgtype.constant = 0
            cell.widthreadreceipt.constant = 0
            
            cell.btncount.titleLabel?.text = ""
            cell.btncount.isHidden = true
            
            cell.lblrecentmsg.textColor = .darkGray
            
            cell.btncount.titleLabel?.textAlignment = .center
            cell.btncount.setTitle("", for: .normal)
            cell.btncount.isHidden = true
            
            switch chatBroadcast.lastMessageType {
            case "0":
                cell.widthmsgtype.constant = 0
                cell.leadingmsg.constant = -5
            case "1":
                cell.widthmsgtype.constant = 12
                cell.leadingmsg.constant = 5
                
                if isPathForImage(path: chatBroadcast.lastMediaURL){
                    cell.imgmsgtype.image = #imageLiteral(resourceName: "image_msg")
                    cell.lblrecentmsg.text = "Photo"
                }
                else if isPathForContact(path: chatBroadcast.lastMediaURL){
                    cell.imgmsgtype.image = #imageLiteral(resourceName: "contact_msg")
                    cell.lblrecentmsg.text = "Contact"
                }
                else if isPathForVideo(path: chatBroadcast.lastMediaURL){
                    cell.imgmsgtype.image = #imageLiteral(resourceName: "video_msg")
                    cell.lblrecentmsg.text = "Video"
                }else if isPathForAudio(path: chatBroadcast.lastMediaURL){
                    cell.imgmsgtype.image = #imageLiteral(resourceName: "voice_msg-1")
                    cell.lblrecentmsg.text = "Audio"
                }
                else{
                    cell.imgmsgtype.image = #imageLiteral(resourceName: "doc_msg")
                    cell.lblrecentmsg.text = getFileType(for: chatBroadcast.lastMediaURL)
                }
            case "2":
                cell.widthmsgtype.constant = 12
                cell.leadingmsg.constant = 5
                
                cell.imgmsgtype.image = #imageLiteral(resourceName: "location_msg")
                cell.lblrecentmsg.text = "Location"
            case "-1" :
                cell.widthmsgtype.constant = 0
                cell.leadingmsg.constant = -5
            case "4":
                cell.widthmsgtype.constant = 0
                cell.leadingmsg.constant = -5
            case "5":
                cell.imgmsgtype.image = #imageLiteral(resourceName: "contact_msg")
                cell.lblrecentmsg.text = "Contact"
            default:
                break
            }
            
            switch chatBroadcast.name { //CHANGE LOGIC HERE. CORRENTLY SWITCH CASE IS ON BROADCAST NAME.
            case "0":
                cell.imgreceipt.image = #imageLiteral(resourceName: "sent_msg")
            case "1":
                cell.imgreceipt.image = #imageLiteral(resourceName: "delivered_msg")
            case "2":
                cell.imgreceipt.image = #imageLiteral(resourceName: "read_msg")
            case "-1":
                cell.imgmsgtype.image = #imageLiteral(resourceName: "pending_msg")
            default:
                cell.imgreceipt.image = nil //WILL ALWAYS FALLBACK HERE, UNTIL IsRead IS MANAGED
                break;
            }
            
            cell.widthreadreceipt.constant = 0
            
            if isMutedGroupChat(groupId: chatBroadcast.broadcastListID){
                cell.imgsound.image = #imageLiteral(resourceName: "mute_msg")
                cell.soundWidth.constant = 18
            }else{
                cell.imgsound.image = nil
                cell.soundWidth.constant = 0
            }
            
            if chatBroadcast.ispinned == "1"{
                cell.imgPin.image = #imageLiteral(resourceName: "attachment_msg")
                cell.widthPin.constant = 18
            }else{
                cell.imgPin.image = nil
                cell.widthPin.constant = 0
            }
            
            cell.imgHiddenChat.image = nil
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatListModel:StructChatList
        if checkSearchBarActive(searchbar: self.searchChatList) { chatListModel = filterChatList[indexPath.row] }
        else { chatListModel = arrChatList[indexPath.row] }
        
        if chatListModel.ChatType == .Personal {
            let cell : ChatListCell = self.tbllist.cellForRow(at: indexPath) as! ChatListCell
            let chatUser = chatListModel.OriginalModel as! StructChat
            var strTitle : String = ""
            
            let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: chatUser.kcountrycode, phoneNo: chatUser.kphonenumber)
            
            if objContactInfo.Name?.count == 0 { strTitle = "+\(chatUser.kcountrycode) \(chatUser.kphonenumber)" }
            else { strTitle = objContactInfo.Name! }
            
            let convo = loadVC(strStoryboardId: SB_CHAT, strVCId:idChatVC ) as! ChatVC
            convo.delegate = self
            convo.calledfrom = "messages"
            //PV
            //convo.selecteduserid = chatUser.ksenderid
            convo.selecteduserid = chatUser.kuserid
            convo.lastmsgid = chatUser.kid.int!
//            if cell.btncount.isHidden == false
//            {
                 convo.lastmsgid = chatUser.kid.int!
//            }
//            else
//            {
//                 convo.lastmsgid = chatUser.kid.int! + 1
//            }
            convo.strTitle = strTitle
            convo.username = chatUser.kusername
            convo.selectedUser = chatUser
            convo.imgTitleProfilePhoto = cell.imgprofile.image ?? ProfilePlaceholderImage
            APP_DELEGATE.appNavigation?.pushViewController(convo, animated: true)
        }
        else if chatListModel.ChatType == .Group {
            let cell : ChatListCell = self.tbllist.cellForRow(at: indexPath) as! ChatListCell
            
            let convo = loadVC(strStoryboardId: SB_CHAT, strVCId: idGroupChatVC) as! GroupChatVC
            let groupDetails = chatListModel.OriginalModel as! StructGroupDetails
            convo.delegate = self
            convo.calledfrom = "messages"
            convo.lastgroupmsgid = groupDetails.lastMessageId.int!
            if cell.btncount.isHidden == false
            {
                 convo.lastgroupmsgid = groupDetails.lastMessageId.int!
            }
            else
            {
                let arr = CoreDBManager.sharedDatabase.getMessagesForGroupID(groupId: groupDetails.group_id, includeDeleted: true)
                if arr.count > 0
                {
                     convo.lastgroupmsgid = groupDetails.lastMessageId.int!
                }
                else
                {
                    cell.lblrecentmsg.text = ""
                    cell.widthmsgtype.constant = 0
                    convo.lastgroupmsgid = groupDetails.lastMessageId.int! + 1
                }
            }
            convo.selectedGroupId = groupDetails.group_id
            convo.groupName = groupDetails.name
            convo.imgTitleProfilePhoto = cell.imgprofile.image ?? GroupPlaceholderImage
            APP_DELEGATE.appNavigation?.pushViewController(convo, animated: true)
        }
        else {
            let cell : ChatListCell = self.tbllist.cellForRow(at: indexPath) as! ChatListCell
            
            let convo = loadVC(strStoryboardId: SB_CHAT, strVCId: idBroadcastChatVC) as! BroadcastChatVC
            let broadcastDetails = chatListModel.OriginalModel as! StructBroadcastList
            convo.delegate = self
            convo.calledfrom = "messages"
            convo.selectedBroadcastListID = broadcastDetails.broadcastListID
            convo.broadcastListName = broadcastDetails.name
            convo.imgTitleProfilePhoto = cell.imgprofile.image ?? #imageLiteral(resourceName: "boradcast_profile")
            APP_DELEGATE.appNavigation?.pushViewController(convo, animated: true)
        }
    }
    
    //MARK: Tableview Cell - Personal Chat Cell
    func manageCell_PersonalChat(tableView: UITableView, indexPath : IndexPath, chatListModel : StructChatList) ->  ChatListCell
    {
        let cell = self.tbllist.dequeueReusableCell(withIdentifier: "ChatListCell") as! ChatListCell
        cell.delegate = self
        cell.tag = indexPath.row
        //cell.layer.cornerRadius = 50
        cell.backgroundColor = UIColor.white
        //cell.clipsToBounds = true
        cell.swipeBackgroundColor = UIColor.white
        //cell.removeGestureRecognizers()
        //cell.addGestureRecognizer(longPress)
        
        //Get Value
        //---------------------------->
        let chatUser = chatListModel.OriginalModel as! StructChat
        
        let strPhotoURL : String = "\(Get_Profile_Pic_URL)\(chatUser.kuserprofile)"
        
        var strName : String = ""
        strName = chatUser.kusername
        let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: chatUser.kcountrycode, phoneNo: chatUser.kphonenumber)
        if objContactInfo.Name?.count == 0 { strName = "+\(chatUser.kcountrycode) \(chatUser.kphonenumber)" }
        else { strName = objContactInfo.Name ?? "*** no name ***" }
        
        let dtvalr = chatUser.kcreateddate == "" ? "" : timeAgoSinceStrDate(strDate: chatUser.kcreateddate, numericDates: true)
        
        let strRecentMessType : String = chatUser.kmessagetype
        var strRecentMess : String = ""
        if strRecentMessType == "3" {
            let arrDetails = chatUser.kchatmessage.base64Decoded!.components(separatedBy: kStoryMessageSeparator)
            strRecentMess = arrDetails[4]
        }
        else {
            if chatUser.kchatmessage.contains(" ___typing...")
            {
               strRecentMess = "typing..."
            }
            else
            {
                strRecentMess = chatUser.kchatmessage.base64Decoded  ?? ""
            }
        }
       
        //Set Value
        //---------------------------->
        /*cell.vwcontent.backgroundColor = themeBgColor
         cell.vwcontent.layer.borderWidth = 1
         cell.vwcontent.layer.borderColor = themeWakeUppColor.cgColor*/
        cell.btnselected.isHidden = true
        
        //Profile Photo
        if (Privacy_ProfilePhoto_Show(statusFlag: chatUser.photo_privacy) == true) {
            cell.imgprofile.sd_setImage(with: URL.init(string: strPhotoURL), placeholderImage: ProfilePlaceholderImage)
        }
        else { cell.imgprofile.image = ProfilePlaceholderImage }
        
        //Hide-Unhide
        if chatUser.ishidden == "1" { cell.imgHiddenChat.image = #imageLiteral(resourceName: "hidden_users") }
        else { cell.imgHiddenChat.image = nil }
        
        //Title Name
        cell.lblname.text = strName
        
        //Date
        cell.lbltime.text = dtvalr
        
        //Recent Mess.
        cell.lblrecentmsg.text = strRecentMess
        cell.lblrecentmsg.textColor = .darkGray
        if (strRecentMess == "typing...") { cell.lblrecentmsg.textColor = themeWakeUppColor }
        
        //Group User Info label
        cell.widthgroupuser.constant = 0
        //cell.widthmsgtype.constant = 0
        //cell.widthreadreceipt.constant = 0
        
        //Read Receipt
        cell.imgreceipt.image = UIImage.init()
        cell.widthreadreceipt.constant = 0
        if chatUser.ksenderid == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)
        {
            cell.widthreadreceipt.constant = 12
            
            switch chatUser.kisread {
            case "0":
                cell.imgreceipt.image = #imageLiteral(resourceName: "sent_msg")
            case "1":
                cell.imgreceipt.image = #imageLiteral(resourceName: "delivered_msg")
            case "2":
                let strReadReceipts : String = UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_ReadReceipts)
                if strReadReceipts == "1" { cell.imgreceipt.image = #imageLiteral(resourceName: "read_msg") }
                else { cell.imgreceipt.image =  #imageLiteral(resourceName: "delivered_msg") }
            case "-1":
                cell.widthreadreceipt.constant = 18
                cell.imgreceipt.image = #imageLiteral(resourceName: "pending_msg")
            default:
                cell.imgreceipt.image = UIImage.init() //PV
                break;
            }
        } else {
            cell.widthreadreceipt.constant = 0
        }
        
        //Mess Type
        cell.widthmsgtype.constant = 0
        cell.leadingmsg.constant = 0
        switch strRecentMessType {
        case "0":
            cell.widthmsgtype.constant = 0
            cell.leadingmsg.constant = -5
        case "1":
            cell.widthmsgtype.constant = 12
            cell.leadingmsg.constant = 5
            
            if isPathForImage(path: chatUser.kmediaurl){
                cell.imgmsgtype.image = #imageLiteral(resourceName: "image_msg")
                cell.lblrecentmsg.text = "Photo"
            }
            else if isPathForContact(path: chatUser.kmediaurl){
                cell.imgmsgtype.image = #imageLiteral(resourceName: "contact_msg")
                cell.lblrecentmsg.text = "Contact"
            }
            else if isPathForVideo(path: chatUser.kmediaurl){
                cell.imgmsgtype.image = #imageLiteral(resourceName: "video_msg")
                cell.lblrecentmsg.text = "Video"
            }else if isPathForAudio(path: chatUser.kmediaurl){
                cell.imgmsgtype.image = #imageLiteral(resourceName: "voice_msg-1")
                cell.lblrecentmsg.text = "Audio"
            }
            else{
                cell.imgmsgtype.image = #imageLiteral(resourceName: "doc_msg")
                cell.lblrecentmsg.text = getFileType(for: chatUser.kmediaurl)
            }
        case "2":
            cell.widthmsgtype.constant = 12
            cell.leadingmsg.constant = 5
            
            cell.imgmsgtype.image = #imageLiteral(resourceName: "location_msg")
            cell.lblrecentmsg.text = "Location"
        case "3" :
            if isPathForImage(path: chatUser.kmediaurl){
                cell.imgmsgtype.image = #imageLiteral(resourceName: "image_msg")
                cell.lblrecentmsg.text = "Photo"
                cell.widthmsgtype.constant = 12
                cell.leadingmsg.constant = 5
            }
            else if isPathForVideo(path: chatUser.kmediaurl){
                cell.imgmsgtype.image = #imageLiteral(resourceName: "video_msg")
                cell.lblrecentmsg.text = "Video"
                cell.widthmsgtype.constant = 12
                cell.leadingmsg.constant = 5
            }
            else
            {
                cell.lblrecentmsg.text =  "Reply"
                cell.widthmsgtype.constant = 0
                cell.leadingmsg.constant = -5
            }
        case "4":
            cell.widthmsgtype.constant = 0
            cell.leadingmsg.constant = -5
        case "5":
            cell.widthmsgtype.constant = 12
            cell.leadingmsg.constant = 5
            
            cell.imgmsgtype.image = #imageLiteral(resourceName: "contact_msg")
            cell.lblrecentmsg.text = "Contact"
        default:
            break
        }
     
        
        //Un-Read Count
        cell.btncount.titleLabel?.text = ""
        cell.btncount.isHidden = true
        if chatUser.kunreadcount.count > 0{
            let unreadCount = Int(chatUser.kunreadcount)!
            if unreadCount > 0 {
                cell.btncount.titleLabel?.textAlignment = .center
                if unreadCount > 99 { cell.btncount.setTitle("99+", for: .normal) }
                else { cell.btncount.setTitle("\(unreadCount)", for: .normal) }
                cell.btncount.isHidden = false
                
                cell.lblrecentmsg.textColor = themeWakeUppColor
            }
        }
        
        // Mute - UnMute
        cell.imgsound.image = nil
        cell.soundWidth.constant = 0
        if isMutedChat(userId: chatUser.kuserid) {
            cell.imgsound.image = #imageLiteral(resourceName: "mute_msg")
            cell.soundWidth.constant = 18
        }
        
        //Pin - UnPin
        cell.imgPin.image = nil
        cell.widthPin.constant = 0
        if chatUser.ispinned == "1" {
            cell.imgPin.image = #imageLiteral(resourceName: "attachment_msg")
            cell.widthPin.constant = 18
        }
        if cell.btncount.isHidden == false
        {
            
        }
        else
        {
//            let arr = CoreDBManager.sharedDatabase.getChatMessagesForUserID(userId: chatUser.kuserid, includeDeleted: true)
//            if arr.count > 0{
//            }
//            else
//            {
//                cell.lblrecentmsg.text = ""
//                cell.widthmsgtype.constant = 0
//                cell.leadingmsg.constant = -5
//                cell.widthreadreceipt.constant = 0
//            }
        }
        return cell
    }
    
    func manageCell_GroupChat(tableView: UITableView, indexPath : IndexPath, chatListModel : StructChatList) ->  ChatListCell
    {
        //Group Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell") as! ChatListCell
        cell.delegate = self
        cell.tag = indexPath.row
        cell.backgroundColor = UIColor.white
        cell.swipeBackgroundColor = UIColor.white
        
        
        //Get Value
        //---------------------------->
        let chatGroup = chatListModel.OriginalModel as! StructGroupDetails
        
        let strPhotoURL : String = "\(chatGroup.icon)"
        
        var strName : String = ""
        strName = chatGroup.name
        
        let dtvalr = chatGroup.lastMessageDate == "" ? "" : timeAgoSinceStrDate(strDate: chatGroup.lastMessageDate, numericDates: true)
        
        //let strRecentMessSender: String =
        
        let strRecentMessType : String = chatGroup.lastMessageType
        var strRecentMess : String = ""
        strRecentMess = chatListModel.Message
        strRecentMess = strRecentMess.replacingOccurrences(of: "youcreated", with: "You created")
        
        //Set Value
        //---------------------------->
        cell.btnselected.isHidden = true
        
        //Profile Photo
        cell.imgprofile.sd_setImage(with: URL.init(string: strPhotoURL), placeholderImage: GroupPlaceholderImage)
        
        //Hide-Unhide
        if chatGroup.ishidden == "1" { cell.imgHiddenChat.image = #imageLiteral(resourceName: "hidden_users") }
        else { cell.imgHiddenChat.image = nil }
        
        //Title Name
        cell.lblname.text = strName
        
        //Date
        cell.lbltime.text = dtvalr
        
        //Recent Mess.
        cell.lblrecentmsg.text = strRecentMess
        cell.lblrecentmsg.textColor = .darkGray
        //if (strRecentMess == "typing...") { cell.lblrecentmsg.textColor = themeWakeUppColor }
        
        cell.widthgroupuser.constant = 0
        //cell.widthmsgtype.constant = 0
        cell.widthreadreceipt.constant = 0
        
        //Read Receipt
        cell.imgreceipt.image = UIImage.init()
        cell.widthreadreceipt.constant = 0
        if chatGroup.lastMessageSenderId == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId){
            cell.widthreadreceipt.constant = 0 //12 : CURRENTLY 0 BCZ ISREAD IS NOT YET MANAGED FOR GROUPS
            
            switch chatGroup.name { //CHANGE LOGIC HERE. CORRENTLY SWITCH CASE IS ON GROUP NAME.
            case "0":
                cell.imgreceipt.image = #imageLiteral(resourceName: "sent_msg")
            case "1":
                cell.imgreceipt.image = #imageLiteral(resourceName: "delivered_msg")
            case "2":
                cell.imgreceipt.image = #imageLiteral(resourceName: "read_msg")
            case "-1":
                cell.imgmsgtype.image = #imageLiteral(resourceName: "pending_msg")
            default:
                cell.imgreceipt.image = nil //WILL ALWAYS FALLBACK HERE, UNTIL IsRead IS MANAGED
                break;
            }
        } else {
            cell.widthreadreceipt.constant = 0
        }
        
        //Mess Type
        cell.widthmsgtype.constant = 0
        cell.leadingmsg.constant = 0
        switch strRecentMessType {
        case "0":
            cell.widthmsgtype.constant = 0
            cell.leadingmsg.constant = -5
        case "1":
            cell.widthmsgtype.constant = 12
            cell.leadingmsg.constant = 5
            
            if isPathForImage(path: chatGroup.lastMediaURL){
                cell.imgmsgtype.image = #imageLiteral(resourceName: "image_msg")
                cell.lblrecentmsg.text = "Photo"
            }
            else if isPathForContact(path: chatGroup.lastMediaURL){
                cell.imgmsgtype.image = #imageLiteral(resourceName: "contact_msg")
                cell.lblrecentmsg.text = "Contact"
            }
            else if isPathForVideo(path: chatGroup.lastMediaURL){
                cell.imgmsgtype.image = #imageLiteral(resourceName: "video_msg")
                cell.lblrecentmsg.text = "Video"
            }else if isPathForAudio(path: chatGroup.lastMediaURL){
                cell.imgmsgtype.image = #imageLiteral(resourceName: "voice_msg-1")
                cell.lblrecentmsg.text = "Audio"
            }
            else{
                cell.imgmsgtype.image = #imageLiteral(resourceName: "doc_msg")
                cell.lblrecentmsg.text = getFileType(for: chatGroup.lastMediaURL)
            }
        case "2":
            cell.widthmsgtype.constant = 12
            cell.leadingmsg.constant = 5
            
            cell.imgmsgtype.image = #imageLiteral(resourceName: "location_msg")
            cell.lblrecentmsg.text = "Location"
        case "-1" :
            cell.widthmsgtype.constant = 0
            cell.leadingmsg.constant = -5
        case "4":
            cell.widthmsgtype.constant = 0
            cell.leadingmsg.constant = -5
        case "5":
            cell.widthmsgtype.constant = 12
            cell.leadingmsg.constant = 5
            cell.imgmsgtype.image = #imageLiteral(resourceName: "contact_msg")
            cell.lblrecentmsg.text = "Contact"
        default:
            break
        }

        
         //Un-Read Count
        cell.btncount.titleLabel?.text = ""
        cell.btncount.isHidden = true
        if chatGroup.unreadCount.count > 0{
            let unreadCount = Int(chatGroup.unreadCount)!
            if unreadCount > 0 {
                cell.lblrecentmsg.textColor = themeWakeUppColor
                if unreadCount > 99 { cell.btncount.setTitle("99", for: .normal) }
                else { cell.btncount .setTitle("\(unreadCount)", for: .normal) }
                cell.btncount.titleLabel?.textAlignment = .center
                
                cell.btncount.isHidden = false
            }
        }
        
        // Mute - UnMute
        if isMutedGroupChat(groupId: chatGroup.group_id){
            cell.imgsound.image = #imageLiteral(resourceName: "mute_msg")
            cell.soundWidth.constant = 18
        }else{
            cell.imgsound.image = nil
            cell.soundWidth.constant = 0
        }
        
        //Pin - UnPin
        if chatGroup.ispinned == "1"{
            cell.imgPin.image = #imageLiteral(resourceName: "attachment_msg")
            cell.widthPin.constant = 18
        }else{
            cell.imgPin.image = nil
            cell.widthPin.constant = 0
        }
        if cell.btncount.isHidden == false || strRecentMess.lowercased().contains("added")
        {
        }
        else{
            let arr = CoreDBManager.sharedDatabase.getMessagesForGroupID(groupId: chatGroup.group_id, includeDeleted: true)
            if arr.count > 0
            {
            }
            else
            {
                cell.lblrecentmsg.text = ""
                cell.widthmsgtype.constant = 0
            }
        }
      
        return cell
    }
}

extension ChatListVC: UISearchBarDelegate {
    func filterChatListUser(_ searchText: String) {
        print(mergedarray.map({$0.Title}))
        
        filterChatList = mergedarray.filter({(StructChatList ) -> Bool in
            if StructChatList.ChatType == .Personal {
                let value = (StructChatList.Title.lowercased().contains(searchText.lowercased()) ||
                            (StructChatList.OriginalModel as! StructChat).kphonenumber.lowercased().contains(searchText.lowercased()) ||
                    (StructChatList.OriginalModel as! StructChat).kusername.lowercased().contains(searchText.lowercased()))
                return value
            }
            else if StructChatList.ChatType == .Group
            {
                let value =  (StructChatList.OriginalModel as! StructGroupDetails).name.lowercased().contains(searchText.lowercased())
                return value
            }else{
                let value =  (StructChatList.OriginalModel as! StructBroadcastList).name.lowercased().contains(searchText.lowercased())
                return value
            }
        })
        
        tbllist.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        self.filterChatListUser(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchChatList.text = ""
        self.heightsearchChatList.constant = 0
        searchclicked = false
        self.tbllist.reloadData()
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
extension ChatListVC :MGSwipeTableCellDelegate,UIActionSheetDelegate
{
    
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
        return true;
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]?
    {
        let model:StructChatList
        let index = cell.tag
        if checkSearchBarActive(searchbar: self.searchChatList){
            model = filterChatList[index]
        }
        else{
            model = arrChatList[index]
        }
        swipeSettings.transition = MGSwipeTransition.border;
        expansionSettings.buttonIndex = -1;
        if direction == MGSwipeDirection.leftToRight
        {
            expansionSettings.fillOnTrigger = false;
            expansionSettings.threshold = 2;
            if model.ChatType == .Personal
            {
                let chatuser = model.OriginalModel as! StructChat
                
                let sharec = MGSwipeButton(title: "Share", icon: UIImage.init(named: "share_swipe"), backgroundColor: Color_Hex(hex: "#1b4f72"), callback: { (cell) -> Bool in
                    self.personalChat_Share(chatuser: chatuser)
                    return false;
                });
                sharec.centerIconOverText(withSpacing: 10)
                
                let muteOrUnmute = isMutedChat(userId:chatuser.kuserid) ? "Unmute" : "Mute"
                let img = isMutedChat(userId:chatuser.kuserid) ? UIImage.init(named: "muteoff_swipe") : UIImage.init(named: "mute_swipe")
                let mute = MGSwipeButton(title: muteOrUnmute, icon: img, backgroundColor: Color_Hex(hex: "#f7a300"), callback: { (cell) -> Bool in
                    self.personalChat_UnmuteMute(chatuser: chatuser)
                    self.tbllist.reloadRows(at: [IndexPath.init(row: cell.tag, section: 0)], with: .none)
                    return false;
                });
                mute.centerIconOverText(withSpacing: 10)
                return [sharec,mute];
            }
            else if model.ChatType == .Group
            {
                let groupDetails = model.OriginalModel as! StructGroupDetails
                
                let muteOrUnmute = isMutedChat(userId: groupDetails.group_id) ? "Unmute" : "Mute"
                let img = isMutedChat(userId: groupDetails.group_id) ? UIImage.init(named: "muteoff_swipe") : UIImage.init(named: "mute_swipe")
                let mute = MGSwipeButton(title: muteOrUnmute, icon: img, backgroundColor: Color_Hex(hex: "#f7a300"), callback: { (cell) -> Bool in
                    
                    self.groupChat_UnmuteMute(groupDetails: groupDetails)
                    self.tbllist.reloadRows(at: [IndexPath.init(row: cell.tag, section: 0)], with: .none)
                    return false;
                });
                mute.centerIconOverText(withSpacing: 10)
                return [mute];
            }
            else {
                //let broadcastDetails = model.OriginalModel as! StructBroadcastList
                return [];
            }
        }
        else {
            expansionSettings.fillOnTrigger = false;
            expansionSettings.threshold = 1.1;
            let more = MGSwipeButton(title: "More", icon: UIImage.init(named: "more_swipe"), backgroundColor: Color_Hex(hex: "#93a0ad"), callback: { (cell) -> Bool in
                if model.ChatType == .Personal { self.personalChat_More(model: model) }
                else if model.ChatType == .Group { self.groupChat_More(model: model) }
                else { self.broadChat_More(model: model) }
                return false
            });
            more.centerIconOverText(withSpacing: 10)
            
            if model.ChatType == .Personal
            {
                let personalChat = model.OriginalModel as! StructChat
                
                let shouldHide = personalChat.ishidden == "0" ? true : false
                let hide = MGSwipeButton(title: shouldHide ? "Hide" : "Unhide", icon: UIImage.init(named: "hidden_swipe"), backgroundColor: Color_Hex(hex: "#dd3838"), callback: { (cell) -> Bool in
                    self.personalChat_HideUnhide(model: model)
                    return false;
                });
                hide.centerIconOverText(withSpacing: 10)
                
                let shouldPin = personalChat.ispinned == "0" ? true : false
                let pin = MGSwipeButton(title: shouldPin ? "Pin" : "Unpin", icon: shouldPin ? UIImage.init(named: "pin_swipe") : UIImage.init(named: "unpin_swipe"), backgroundColor: Color_Hex(hex: "#2295f7"), callback: { (cell) -> Bool in
                    CoreDBManager.sharedDatabase.pinUnpinPersonalChat(for: personalChat, shouldPin: shouldPin)
                    self.reloadTable()
                    return false
                });
                pin.centerIconOverText(withSpacing: 10)
                
                let isread = personalChat.kisread == "1" || personalChat.kisread == "0" ? true : false
                let reads = MGSwipeButton(title: isread ? "Read" : "Unread", icon: isread ? UIImage.init(named: "ic_read_msgs") : UIImage.init(named: "ic_unread_msgs"), backgroundColor: Color_Hex(hex: "#4ace44"), callback: { (cell) -> Bool in
                    self.personalChat_ReadUnread(model: model)
                    return false
                });
                reads.centerIconOverText(withSpacing: 10)
                
                return [more,hide,pin,reads];
            }
            else if model.ChatType == .Group {
                let group = model.OriginalModel as! StructGroupDetails
                
                let shouldHide = group.ishidden == "0" ? true : false
                let hide = MGSwipeButton(title: shouldHide ? "Hide" : "Unhide", icon: UIImage.init(named: "hidden_swipe"), backgroundColor: Color_Hex(hex: "#dd3838"), callback: { (cell) -> Bool in
                    self.groupChat_HideUnhide(model: model)
                    return false;
                });
                hide.centerIconOverText(withSpacing: 10)
                
                let shouldPin = group.ispinned == "0" ? true : false
                let pin = MGSwipeButton(title: shouldPin ? "Pin" : "Unpin", icon: shouldPin ? UIImage.init(named: "pin_swipe") : UIImage.init(named: "unpin_swipe"), backgroundColor: Color_Hex(hex: "#2295f7"), callback: { (cell) -> Bool in
                    CoreDBManager.sharedDatabase.pinUnpinGroupChat(for: group.group_id, shouldPin: shouldPin)
                    self.reloadTable()
                    return false;
                });
                pin.centerIconOverText(withSpacing: 10)
                
                return [more,hide,pin];
            }
            else {
                let broadcastList = model.OriginalModel as! StructBroadcastList
                let shouldPin = broadcastList.ispinned == "0" ? true : false
                let pin = MGSwipeButton(title: shouldPin ? "Pin" : "Unpin", icon: shouldPin ? UIImage.init(named: "pin_swipe") : UIImage.init(named: "unpin_swipe"), backgroundColor: Color_Hex(hex: "#2295f7"), callback: { (cell) -> Bool in
                    CoreDBManager.sharedDatabase.pinUnpinBroadcastList(for: broadcastList.broadcastListID, shouldPin: shouldPin)
                    self.reloadTable()
                    return false;
                });
                pin.centerIconOverText(withSpacing: 10)
                
                return [more,pin];
            }
        }
    }
    
    //MARK: swipeTableCell - button action
    func personalChat_Share(chatuser : StructChat) -> Void {
        var mess = "Check out \(APPNAME), I use it to message and call. Get it for free at \(liveAppUrl) to chat with for friends or family."
        mess += "Name - \(chatuser.kusername)" + "\n"
        mess += "Contact -  +\(chatuser.kcountrycode) \(chatuser.kphonenumber)" + "\n"
        
        share(shareContent: [mess])
    }
    
    func personalChat_UnmuteMute(chatuser : StructChat) -> Void {
        let currentlyMutedUsers = UserDefaultManager.getStringFromUserDefaults(key: kMutedByMe)
        var arrMutedUserIds = currentlyMutedUsers.components(separatedBy: ",") as? NSMutableArray
        
        if arrMutedUserIds == nil { arrMutedUserIds = NSMutableArray() }
        if (arrMutedUserIds?.contains(""))! { arrMutedUserIds?.remove("") }
        
        if isMutedChat(userId: chatuser.kuserid) { arrMutedUserIds?.remove(chatuser.kuserid) }
        else { arrMutedUserIds?.add(chatuser.kuserid) }
        
        var mutedIds = ""
        if (arrMutedUserIds?.count)! > 0 { mutedIds = (arrMutedUserIds?.componentsJoined(by: ","))! }
        
        let dict:NSDictionary = [
            "userid" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            "mutedids" : mutedIds
        ]
        APP_DELEGATE.socketIOHandler?.socket?.emit(keyChangeMuteStatus,dict)
        UserDefaultManager.setStringToUserDefaults(value: mutedIds, key: kMutedByMe)
    }
    
    func personalChat_More(model:StructChatList) -> Void {
        let chatuser = model.OriginalModel as! StructChat
        
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let cinfo = UIAlertAction.init(title: "Contact Info", style: .default, handler: { (action) in
            let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId: idChatUserInfoVC) as! ChatUserInfoVC
            let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: (chatuser.kcountrycode), phoneNo: (chatuser.kphonenumber))
            if objContactInfo.Name?.count != 0 {
                objVC.strTitle = objContactInfo.Name!.count == 0 ? "---" : objContactInfo.Name!
            }
            objVC.strUserID = chatuser.kuserid
            //objVC.strUserID = selectedUser!.kid
            //objVC.strPhotoURL = strFullPhotoURL
            objVC.strPhotoURL = chatuser.kuserprofile
            objVC.strUserName = chatuser.kusername
            objVC.strUserPhoneNo = chatuser.kphonenumber
            objVC.strCountryCodeOfPhoneNo = chatuser.kcountrycode
            objVC.strUserBio =  chatuser.bio
            objVC.flag_showChatButton = false
            APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
        })
        alert.addAction(cinfo)
        
        let exportchat = UIAlertAction.init(title: "Export Chat", style: .default, handler: { (action) in
            
            var strTitle = ""
            let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: (chatuser.kcountrycode), phoneNo: (chatuser.kphonenumber))
            if objContactInfo.Name?.count != 0 { strTitle = objContactInfo.Name!.count == 0 ? "---" : objContactInfo.Name! }
            else { strTitle = "+\(chatuser.kcountrycode) \(chatuser.kphonenumber)" }
            
            let confirmAlert = UIAlertController.init(title: "Export Chat" , message: "Attaching media will generate a larger chat archive.", preferredStyle: .actionSheet)
            let attWithMedia = UIAlertAction.init(title: "Attach Media", style: .default) { (action) in
                //self.manage_ExportChat(withMedia: true,chatuser: chatuser)
                
                let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ImportExportProcessVC" ) as! ImportExportProcessVC
                let objPersonalChatInfo = PersonalChatInfo.init(userID: chatuser.kuserid,
                                                                CountryCode: chatuser.kcountrycode,
                                                                PhoneNo: chatuser.kphonenumber,
                                                                ProfileImageURL: "\(Get_Profile_Pic_URL)\(chatuser.kuserprofile)",
                    DisplayNameOfTitle: strTitle)
                objVC.objPersonalChatInfo = objPersonalChatInfo
                objVC.objEnumImpExpoAction = .Export_PersonalChat_withContent
                objVC.Popup_Show(onViewController: self)
            }
            confirmAlert.addAction(attWithMedia)
            
            let attWithoutMedia = UIAlertAction.init(title: "Without Media", style: .default) { (action) in
                //self.manage_ExportChat(withMedia: false,chatuser: chatuser)
                
                let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ImportExportProcessVC" ) as! ImportExportProcessVC
                let objPersonalChatInfo = PersonalChatInfo.init(userID: chatuser.kuserid,
                                                                CountryCode: chatuser.kcountrycode,
                                                                PhoneNo: chatuser.kphonenumber,
                                                                ProfileImageURL: "\(Get_Profile_Pic_URL)\(chatuser.kuserprofile)",
                    DisplayNameOfTitle: strTitle)
                objVC.objPersonalChatInfo = objPersonalChatInfo
                objVC.objEnumImpExpoAction = .Export_PersonalChat
                objVC.Popup_Show(onViewController: self)
            }
            confirmAlert.addAction(attWithoutMedia)
            
            let action_no = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
            confirmAlert.addAction(action_no)
            
            self.present(confirmAlert, animated: true, completion: nil)
        })
        alert.addAction(exportchat)
        
        //PV
        if APP_DELEGATE.User_Exists_inHiddenChat_UserList(strUserID: chatuser.kuserid) == true {
            let restoHiddChat = UIAlertAction.init(title: "Restore Chat", style: .default, handler: { (action) in
                let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ImportExportProcessVC" ) as! ImportExportProcessVC
                objVC.strImgURL = "\(Get_Profile_Pic_URL)\(chatuser.kuserprofile)"
                objVC.strTitle = "Restore Chat"
                objVC.objEnumImpExpoAction = .Import_HiddenChat
                objVC.Popup_Show(onViewController: self)
            })
            alert.addAction(restoHiddChat)
        }
        
        let clearchat = UIAlertAction.init(title: "Clear Chat", style: .default, handler: { (action) in
            self.personalChat_More_Clear(model: model)
        })
        alert.addAction(clearchat)
        
        let deletechat = UIAlertAction.init(title: "Delete Chat", style: .default, handler: { (action) in
            let personalChat = model.OriginalModel as! StructChat
            CoreDBManager.sharedDatabase.deleteAllChatMessagesWith(userId: personalChat.kuserid)
            CoreDBManager.sharedDatabase.deleteFriend(byFriendIds: [personalChat.kuserid])
            self.reloadTable()
            
            //Remove All content in ChatDir.
            let URL_dirCurrentChat : URL = getURL_ChatWithUser_Directory(countryCode: personalChat.kcountrycode, PhoneNo: personalChat.kphonenumber)
            runAfterTime(time: 0.10, block: {
                let arrContent = getAllContent(inDirectoryURL: URL_dirCurrentChat)
                //print("arr : \(arrContent.count)")
                for filePath : URL in arrContent {
                    //print("getAllContent_inDir - FilePath: \(filePath)")
                    removeFile_onURL(fileURL: filePath)
                }
            })
        })
        alert.addAction(deletechat)
        
        let isblock = APP_DELEGATE.User_Exists_inBlockContactList(strUserID: chatuser.kuserid) == false ? "Block Contact" : "Unblock Contact"
        let blockcontct = UIAlertAction.init(title: isblock, style: .default, handler: { (action) in
            var strAlertTitle : String = ""
            var strMess : String = ""
            var strUserBlockStatus : String = "block"
            if (APP_DELEGATE.User_Exists_inBlockContactList(strUserID: chatuser.kuserid) == false) {
                strAlertTitle = "Block \(model.Title)?"
                strMess = "Blocked contacts will no longer be able to call you or send messages."
            }
            else {
                strAlertTitle = "Unblock \(model.Title)?"
                strMess = "Are you sure you have unblock \(model.Title)"
                strUserBlockStatus = "unblock"
            }
            
            let confirmAlert = UIAlertController.init(title: strAlertTitle , message: strMess, preferredStyle: .actionSheet)
            let action_yes = UIAlertAction.init(title: strUserBlockStatus.localizedCapitalized, style: .destructive) { (action) in
                
                if (strUserBlockStatus.uppercased() == "block".uppercased()) {
                    APP_DELEGATE.AddUser_BlockContactList(strUserID: chatuser.kuserid)
                    //self.viewManangeChat.isHidden = true
                }
                else {
                    APP_DELEGATE.RemoveUser_BlockContactList(strUserID: chatuser.kuserid)
                    //self.viewManangeChat.isHidden = false
                }
                
                //Set parameter for Called WebService
                let parameter:NSDictionary = ["service":APIBlockUser,
                                              "request":["block_user_id":chatuser.kuserid, "action":strUserBlockStatus],
                                              "auth" : getAuthForService()]
                self.api_BlockUser(parameter: parameter, loaderMess: "",userid:chatuser.kuserid)
            }
            confirmAlert.addAction(action_yes)
            
            let action_no = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
            confirmAlert.addAction(action_no)
            
            self.present(confirmAlert, animated: true, completion: nil)
        })
        alert.addAction(blockcontct)
        let reportsp = UIAlertAction.init(title: "Report Spam", style: .default, handler: { (action) in
            let confirm = UIAlertController.init(title: "Report spam and block this contacts?", message: "If you report and block, this chat's history will also be deleted.", preferredStyle: .actionSheet)
            
            let action_yes = UIAlertAction.init(title: "Report and block", style: .destructive) { (action) in
                
                //Block Contact
                APP_DELEGATE.AddUser_BlockContactList(strUserID: chatuser.kuserid)
                let parameter_blockUser:NSDictionary = ["service":APIBlockUser,
                                                        "request":["block_user_id":chatuser.kuserid, "action":"block"],
                                                        "auth" : getAuthForService()]
                self.api_BlockUser(parameter: parameter_blockUser, loaderMess: "",userid:chatuser.kuserid)
                
                //Clear Chat mess.
                CoreDBManager.sharedDatabase.deleteAllChatMessagesWith(userId: chatuser.kuserid)
                
                //Report Spam
                let parameter_spam:NSDictionary = ["service":APIReportSpam,
                                                   "request":["spam_id":chatuser.kuserid, "action":"user"],
                                                   "auth" : getAuthForService()]
                APP_DELEGATE.api_SpamReport(parameter: parameter_spam, successMess: "Report spam successfully.")
                
                //Move to Home
                runAfterTime(time: 0.45, block: {
                    APP_DELEGATE.appNavigation?.popToRootViewController(animated: true)
                })
            }
            confirm.addAction(action_yes)
            
            let action_no = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
            confirm.addAction(action_no)
            
            self.present(confirm, animated: true, completion: nil)
        })
        alert.addAction(reportsp)
        
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func personalChat_More_Clear(model:StructChatList) -> Void {
        /*
        //Old Code
        let confirm = UIAlertController.init(title: nil, message: "Clear all messages of \(model.Title)?", preferredStyle: .alert)
        let actionYes = UIAlertAction.init(title: "Yes", style: .destructive, handler: { (action) in
         
            //Delete All Chat in Core data.
            let personalChat = model.OriginalModel as! StructChat
            CoreDBManager.sharedDatabase.deleteAllChatMessagesWith(userId: personalChat.kuserid)
         
            self.reloadTable()
        })
        confirm.addAction(actionYes)
        
        let actionNo = UIAlertAction.init(title: "No", style: .cancel, handler:nil)
        confirm.addAction(actionNo)
        self.present(confirm, animated: true, completion: nil)*/
        
        let action = UIAlertController.init(title: nil, message: "Delete Messages", preferredStyle: .actionSheet)
        let action_ClearAllExceptStarred = UIAlertAction.init(title: "Clear all except starred", style: .default, handler: { (action) in
            let personalChat = model.OriginalModel as! StructChat
            
            let URL_dirCurrentChat : URL = getURL_ChatWithUser_Directory(countryCode: personalChat.kcountrycode, PhoneNo: personalChat.kphonenumber)
            let arrContent = getAllContent(inDirectoryURL: URL_dirCurrentChat)
            let arrContentName : NSMutableArray = NSMutableArray.init()
            for objURL in arrContent { arrContentName.add(objURL.lastPathComponent) }
            
            var arrMess : [StructChat] = CoreDBManager.sharedDatabase.personalChat_Get_StarredChatMessages_with(userId: personalChat.kuserid)
            arrMess = arrMess.filter({$0.kmessagetype == "1"})
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
            
            CoreDBManager.sharedDatabase.personalChat_Delete_AllChatMessages_ExceptStarred_with(userId: personalChat.kuserid)
            self.reloadTable()
        })
        action.addAction(action_ClearAllExceptStarred)
        
        let action_ClearAll = UIAlertAction.init(title: "Clear all messages", style: .destructive, handler: { (action) in
            //Delete All Chat in Core data.
            let personalChat = model.OriginalModel as! StructChat
            CoreDBManager.sharedDatabase.deleteAllChatMessagesWith(userId: personalChat.kuserid)
            self.reloadTable()
            
            //Remove All content in ChatDir.
            let URL_dirCurrentChat : URL = getURL_ChatWithUser_Directory(countryCode: personalChat.kcountrycode, PhoneNo: personalChat.kphonenumber)
            runAfterTime(time: 0.10, block: {
                let arrContent = getAllContent(inDirectoryURL: URL_dirCurrentChat)
                //print("arr : \(arrContent.count)")
                for filePath : URL in arrContent {
                    //print("getAllContent_inDir - FilePath: \(filePath)")
                    removeFile_onURL(fileURL: filePath)
                }
            })
        })
        action.addAction(action_ClearAll)
        
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        action.addAction(actionCancel)
        self.present(action, animated: true, completion: nil)
    }
    
    func personalChat_HideUnhide(model:StructChatList) -> Void {
        let personalChat = model.OriginalModel as! StructChat
        let shouldHide = personalChat.ishidden == "0" ? true : false
        
        let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: "HideChatPasscodeVC") as! HideChatPasscodeVC
        vc.modalPresentationStyle = .overCurrentContext
        vc.isJustForSecurityPurpose = true
        APP_DELEGATE.appNavigation?.present(vc, animated: false, completion: nil)
        vc.validateHandler = {success in
            if success{
                if UserDefaultManager.getBooleanFromUserDefaults(key: kHiddenChatSetupDone) == false{
                    self.btnHiddenChatClicked(UIButton())
                    
                    //Remove UserID in as HiddenChat in UserDefault
                    APP_DELEGATE.RemoveUser_HiddenChat_UserList(strUserID: personalChat.kuserid)
                }else{
                    CoreDBManager.sharedDatabase.hideUnhidePersonalChat(for: personalChat, shouldHide: shouldHide)
                    
                    //Add UserID in as HiddenChat in UserDefault
                    APP_DELEGATE.AddUser_HiddenChat_UserList(strUserID: personalChat.kuserid)
                }
                self.reloadTable()
            }
        }
    }
    
    func personalChat_ReadUnread(model:StructChatList) -> Void {
        let personalChat = model.OriginalModel as! StructChat
        let isread = personalChat.kisread == "1" || personalChat.kisread == "0" ? true : false
        
        let msgDictionary = [
            "receiverid":personalChat.kreceiverid,
            "senderid" : personalChat.ksenderid,
            "isread" : isread ? "1" : "2",
            "chatid":personalChat.kid] as [String:Any]
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck("Update_IsReadManually",msgDictionary).timingOut(after: 30)
        {data in
            print(data)
            
            let data = data as Array
            if(data.count > 0) {
                if data[0] is String { return }
                let dic = data[0] as! NSDictionary
                let obj = dic.object(forKey: "success") as! String
                if obj == "1" {
                    CoreDBManager.sharedDatabase.readUnreadPersonalChat(for: personalChat, shouldread: isread)
                    self.reloadTable()
                }
                else {
                    //---> None
                }
            }
        }
        self.reloadTable()
    }
    
    func groupChat_More(model:StructChatList) -> Void {
        
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let cinfo = UIAlertAction.init(title: "Group Info", style: .default, handler: { (action) in
            let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: idGroupInfoVC) as! GroupInfoVC
            vc.selectedGroupDetails = model.OriginalModel as! StructGroupDetails
            APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
        })
        alert.addAction(cinfo)
        
        let exportchat = UIAlertAction.init(title: "Export Chat", style: .default, handler: { (action) in
            //PV
            let selectedGroupDetails = model.OriginalModel as! StructGroupDetails
            
            let confirmAlert = UIAlertController.init(title: "Export Chat" , message: "Attaching media will generate a larger chat archive.", preferredStyle: .actionSheet)
            let attWithMedia = UIAlertAction.init(title: "Attach Media", style: .default) { (action) in
                let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ImportExportProcessVC" ) as! ImportExportProcessVC
                let objGroupInfo = GroupChatInfo.init(GroupID: selectedGroupDetails.group_id,
                                                      GroupImageURL: selectedGroupDetails.icon,
                                                      DisplayNameOfTitle: selectedGroupDetails.name,
                                                      userID: UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
                                                      CountryCode: UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode),
                                                      PhoneNo: UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile))
                objVC.objGroupChatInfo = objGroupInfo
                objVC.objEnumImpExpoAction = .Export_GroupChat_withContent
                objVC.Popup_Show(onViewController: self)
            }
            confirmAlert.addAction(attWithMedia)
            
            let attWithoutMedia = UIAlertAction.init(title: "Without Media", style: .default) { (action) in
                let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ImportExportProcessVC" ) as! ImportExportProcessVC
                let objGroupInfo = GroupChatInfo.init(GroupID: selectedGroupDetails.group_id,
                                                      GroupImageURL: selectedGroupDetails.icon,
                                                      DisplayNameOfTitle: selectedGroupDetails.name,
                                                      userID: UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
                                                      CountryCode: UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode),
                                                      PhoneNo: UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile))
                objVC.objGroupChatInfo = objGroupInfo
                objVC.objEnumImpExpoAction = .Export_GroupChat
                objVC.Popup_Show(onViewController: self)
            }
            confirmAlert.addAction(attWithoutMedia)
            
            let action_no = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
            confirmAlert.addAction(action_no)
            
            self.present(confirmAlert, animated: true, completion: nil)
        })
        alert.addAction(exportchat)
        
        //PV
        let selectedGroupDetails = model.OriginalModel as! StructGroupDetails
        if APP_DELEGATE.Group_Exists_inHiddenGroupChat_List(strGroupID: selectedGroupDetails.group_id) == true {
            let restoHiddChat = UIAlertAction.init(title: "Restore Chat", style: .default, handler: { (action) in
                let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ImportExportProcessVC" ) as! ImportExportProcessVC
                objVC.strImgURL = selectedGroupDetails.icon
                objVC.strTitle = selectedGroupDetails.name
                objVC.objEnumImpExpoAction = .Import_HiddenChat
                objVC.Popup_Show(onViewController: self)
            })
            alert.addAction(restoHiddChat)
        }
        
        let clearchat = UIAlertAction.init(title: "Clear Chat", style: .default, handler: { (action) in
            self.groupChat_More_Clear(model: model)
        })
        alert.addAction(clearchat)
        let deletechat = UIAlertAction.init(title: "Delete Chat", style: .default, handler: { (action) in
            let group = model.OriginalModel as! StructGroupDetails
            
            //Remove All content in ChatDir.
            let URL_dirCurrentChat : URL = getURL_GroupChat_Directory(groupID: group.group_id)
            runAfterTime(time: 0.10, block: {
                let arrContent = getAllContent(inDirectoryURL: URL_dirCurrentChat)
                //print("arr : \(arrContent.count)")
                for filePath : URL in arrContent {
                    //print("getAllContent_inDir - FilePath: \(filePath)")
                    removeFile_onURL(fileURL: filePath)
                }
            })
            
            CoreDBManager.sharedDatabase.deleteAllGroupChatMessagesOf(groupId: group.group_id)
            self.reloadTable()
        })
        alert.addAction(deletechat)
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func groupChat_More_Clear(model:StructChatList) -> Void {
        /*let confirm = UIAlertController.init(title: nil, message: "Clear all messages of \(model.Title)?", preferredStyle: .alert)
        let actionYes = UIAlertAction.init(title: "Yes", style: .destructive, handler: { (action) in
         
            let group = model.OriginalModel as! StructGroupDetails
            CoreDBManager.sharedDatabase.deleteAllGroupChatMessagesOf(groupId: group.group_id)
         
            self.reloadTable()
        })
        confirm.addAction(actionYes)
        let actionNo = UIAlertAction.init(title: "No", style: .cancel, handler:nil)
        confirm.addAction(actionNo)
        self.present(confirm, animated: true, completion: nil)
        */
        let action = UIAlertController.init(title: nil, message: "Delete Messages", preferredStyle: .actionSheet)
        let action_ClearAllExceptStarred = UIAlertAction.init(title: "Clear all except starred", style: .default, handler: { (action) in
            let group = model.OriginalModel as! StructGroupDetails
            
            let URL_dirCurrentChat : URL = getURL_GroupChat_Directory(groupID: group.group_id)
            var arrMess : [StructGroupChat] = CoreDBManager.sharedDatabase.GroupChat_Get_StarredChatMessages_with(GroupId: group.group_id)
            arrMess = arrMess.filter({$0.messagetype == "1"})
            
            runAfterTime(time: 0.10, block: {
                let arrContent = getAllContent(inDirectoryURL: URL_dirCurrentChat)
                let arrContentName : NSMutableArray = NSMutableArray.init()
                for objURL in arrContent { arrContentName.add(objURL.lastPathComponent) }
                
                for objURL in arrMess {
                    let strFileName : String = objURL.mediaurl.lastPathComponent
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
            
            CoreDBManager.sharedDatabase.GroupChat_Delete_AllChatMessages_ExceptStarred_with(groupId: group.group_id)
            self.reloadTable()
        })
        action.addAction(action_ClearAllExceptStarred)
        
        let action_ClearAll = UIAlertAction.init(title: "Clear all messages", style: .destructive, handler: { (action) in
            let group = model.OriginalModel as! StructGroupDetails
            
            //Remove All content in ChatDir.
            let URL_dirCurrentChat : URL = getURL_GroupChat_Directory(groupID: group.group_id)
            runAfterTime(time: 0.10, block: {
                let arrContent = getAllContent(inDirectoryURL: URL_dirCurrentChat)
                //print("arr : \(arrContent.count)")
                for filePath : URL in arrContent {
                    //print("getAllContent_inDir - FilePath: \(filePath)")
                    removeFile_onURL(fileURL: filePath)
                }
            })
            
            CoreDBManager.sharedDatabase.deleteAllGroupChatMessagesOf(groupId: group.group_id)
            self.reloadTable()
        })
        action.addAction(action_ClearAll)
        
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        action.addAction(actionCancel)
        self.present(action, animated: true, completion: nil)
    }
    
    func groupChat_HideUnhide(model:StructChatList) -> Void {
        let group = model.OriginalModel as! StructGroupDetails
        let shouldHide = group.ishidden == "0" ? true : false
        
        let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: "HideChatPasscodeVC") as! HideChatPasscodeVC
        vc.modalPresentationStyle = .overCurrentContext
        vc.isJustForSecurityPurpose = true
        APP_DELEGATE.appNavigation?.present(vc, animated: false, completion: nil)
        vc.validateHandler = {success in
            if success{
                if UserDefaultManager.getBooleanFromUserDefaults(key: kHiddenChatSetupDone) == false{
                    self.btnHiddenChatClicked(UIButton())
                    
                    //Remove GroupID in as HiddenChat in UserDefault
                    APP_DELEGATE.RemoveGroup_HiddenGroupChat_UserList(strGroupID: group.group_id)
                    
                }else{
                    CoreDBManager.sharedDatabase.hideUnhideGroupChat(for: group.group_id, shouldHide: shouldHide)
                    
                    //Add GroupID in as HiddenChat in UserDefault
                    APP_DELEGATE.AddGroup_HiddenGroupChat_List(strGroupID: group.group_id)
                }
                self.reloadTable()
            }
        }
    }
    
    
    func groupChat_UnmuteMute(groupDetails : StructGroupDetails) -> Void {
        let currentlyMutedUsers = UserDefaultManager.getStringFromUserDefaults(key: kMutedByMe)
        var arrMutedUserIds = currentlyMutedUsers.components(separatedBy: ",") as? NSMutableArray
        if arrMutedUserIds == nil{
            arrMutedUserIds = NSMutableArray()
        }
        if (arrMutedUserIds?.contains(""))!{ arrMutedUserIds?.remove("") }
        
        if isMutedChat(userId: groupDetails.group_id) {
            //isMutedGroup
            arrMutedUserIds?.remove(groupDetails.group_id)
        } else {
            arrMutedUserIds?.add(groupDetails.group_id)
        }
        
        var mutedIds = ""
        if (arrMutedUserIds?.count)! > 0{
            mutedIds = (arrMutedUserIds?.componentsJoined(by: ","))!
        }
        let dict:NSDictionary = [
            "userid" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            "mutedids" : mutedIds
        ]
        APP_DELEGATE.socketIOHandler?.socket?.emit(keyChangeMuteStatus,dict)
        UserDefaultManager.setStringToUserDefaults(value: mutedIds, key: kMutedByMe)
    }
    
    func broadChat_More(model:StructChatList) -> Void {
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let clearchat = UIAlertAction.init(title: "Clear Chat", style: .default, handler: { (action) in
            self.broadChat_More_Clear(model: model)
        })
        alert.addAction(clearchat)
        let deletechat = UIAlertAction.init(title: "Delete Chat", style: .default, handler: { (action) in
            let broadcast = model.OriginalModel as! StructBroadcastList
            CoreDBManager.sharedDatabase.deleteAllMessagesOf(broadcastListId: broadcast.broadcastListID)
            self.reloadTable()
        })
        alert.addAction(deletechat)
        let exportchat = UIAlertAction.init(title: "Export Chat", style: .default, handler: { (action) in
            
            //PV
            let selectedBroadcastListDetails = model.OriginalModel as! StructBroadcastList
            
            let confirmAlert = UIAlertController.init(title: "Export Chat" , message: "Attaching media will generate a larger chat archive.", preferredStyle: .actionSheet)
            let attWithMedia = UIAlertAction.init(title: "Attach Media", style: .default) { (action) in
                //self.manage_ExportChat(withMedia: true)
                
                let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ImportExportProcessVC" ) as! ImportExportProcessVC
                let objBroadcastInfo = BroadcastChatInfo.init(BroadcastID: selectedBroadcastListDetails.broadcastListID,
                                                              BroadcastImageURL: "",
                                                              DisplayNameOfTitle: selectedBroadcastListDetails.name,
                                                              userID: UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
                                                              CountryCode: UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode),
                                                              PhoneNo: UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile))
                objVC.objBroadcastChatInfo = objBroadcastInfo
                objVC.objEnumImpExpoAction = .Export_Broadcast_withContent
                objVC.Popup_Show(onViewController: self)
            }
            confirmAlert.addAction(attWithMedia)
            
            let attWithoutMedia = UIAlertAction.init(title: "Without Media", style: .default) { (action) in
                //self.manage_ExportChat(withMedia: false)
                
                let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ImportExportProcessVC" ) as! ImportExportProcessVC
                let objBroadcastInfo = BroadcastChatInfo.init(BroadcastID: selectedBroadcastListDetails.broadcastListID,
                                                              BroadcastImageURL: "",
                                                              DisplayNameOfTitle: selectedBroadcastListDetails.name,
                                                              userID: UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
                                                              CountryCode: UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode),
                                                              PhoneNo: UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile))
                objVC.objBroadcastChatInfo = objBroadcastInfo
                objVC.objEnumImpExpoAction = .Export_Broadcast
                objVC.Popup_Show(onViewController: self)
            }
            confirmAlert.addAction(attWithoutMedia)
            
            let action_no = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
            confirmAlert.addAction(action_no)
            
            self.present(confirmAlert, animated: true, completion: nil)
        })
        alert.addAction(exportchat)
        
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func broadChat_More_Clear(model:StructChatList) -> Void {
        let broadcast = model.OriginalModel as! StructBroadcastList
        CoreDBManager.sharedDatabase.deleteAllMessagesOf(broadcastListId: broadcast.broadcastListID)
        self.reloadTable()
        /*let confirm = UIAlertController.init(title: nil, message: "Clear all messages of \(model.Title)?", preferredStyle: .alert)
        let actionYes = UIAlertAction.init(title: "Yes", style: .destructive, handler: { (action) in
            let broadcast = model.OriginalModel as! StructBroadcastList
            CoreDBManager.sharedDatabase.deleteAllMessagesOf(broadcastListId: broadcast.broadcastListID)
            self.reloadTable()
        })
        confirm.addAction(actionYes)
        let actionNo = UIAlertAction.init(title: "No", style: .cancel, handler:nil)
        confirm.addAction(actionNo)
        self.present(confirm, animated: true, completion: nil)*/
        
        /*
        //1st Implement Starred code in Broadcast chat after unhide this code.
        let action = UIAlertController.init(title: nil, message: "Delete Messages", preferredStyle: .actionSheet)
        let action_ClearAllExceptStarred = UIAlertAction.init(title: "Clear all except starred", style: .default, handler: { (action) in
            //let group = model.OriginalModel as! StructGroupDetails
            //CoreDBManager.sharedDatabase.GroupChat_Delete_AllChatMessages_ExceptStarred_with(groupId: group.group_id)
            //self.reloadTable()
        })
        action.addAction(action_ClearAllExceptStarred)
        
        let action_ClearAll = UIAlertAction.init(title: "Clear all messages", style: .destructive, handler: { (action) in
            let broadcast = model.OriginalModel as! StructBroadcastList
            CoreDBManager.sharedDatabase.deleteAllMessagesOf(broadcastListId: broadcast.broadcastListID)
            self.reloadTable()
        })
        action.addAction(action_ClearAll)
        
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        action.addAction(actionCancel)
        
        self.present(action, animated: true, completion: nil)*/
    }
}
extension ChatListVC:UIGestureRecognizerDelegate
{
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer.isEqual(self.navigationController?.interactivePopGestureRecognizer) else{ return true }
        let pointofTouch = gestureRecognizer.location(in: self.view)
        let isTouchInBottomHalf = (pointofTouch.y >= self.view.bounds.height / 2)
        return !isTouchInBottomHalf
    }
}

