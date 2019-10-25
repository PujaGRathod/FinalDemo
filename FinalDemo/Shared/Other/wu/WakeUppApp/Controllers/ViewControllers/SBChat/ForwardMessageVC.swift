//
//  ForwardMessageVC.swift
//  WakeUppApp
//
//  Created by Admin on 09/07/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class ForwardMessageVC: UIViewController {

    //MARK:- Outlet
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtSearch: UISearchBar!
    @IBOutlet weak var heightOfSearchBar: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnSend: UIButton!
    
    //MARK:- Variable
    var arrFriends = [StructChat]()
    var arrGroups = [StructGroupDetails]()
    var arrBroadcastLists = [StructBroadcastList]()
    var arrChatList = [StructChatList]()
    
    var filterChatList = [StructChatList] ()
    var searchclicked = false
    
    var arrSelectedChatIDs = [String]()
    var arrSelectedGroupIDs = [String]()
    var arrSelectedBroadcastListIDs = [String]()
    
    var arrMessagesForForward = [Any]() //ASSIGNED BY ChatVC / GroupChatVC
    
    var arrFinalMessages = [[String:String]]() // ASSIGNED BY btnSendClicked
    
    var arrFinalMessagesForPersonalChats = [[String:String]]()
    var arrFinalMessagesForGroupChats = [[String:String]]()
    var arrFinalMessagesForBroadcast = [[String:String]]()
    
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        heightOfSearchBar.constant = 0
        txtSearch.backgroundImage = UIImage()
        reloadTable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func reloadTable(){
        
        txtSearch.delegate = self
        
        arrFriends = CoreDBManager.sharedDatabase.getFriendList(includeHiddens: APP_DELEGATE.isHiddenChatUnlocked) as! [StructChat]
        arrGroups = CoreDBManager.sharedDatabase.getGroupsList(includeHiddens: APP_DELEGATE.isHiddenChatUnlocked) as! [StructGroupDetails]
        //arrBroadcastLists = CoreDBManager.sharedDatabase.getBroadcastLists() as! [StructBroadcastList]
        
        arrChatList = [StructChatList]()
        for friend in arrFriends{
            
            var strDate = friend.kcreateddate
            strDate = strDate.replacingOccurrences(of: "T", with: " ").components(separatedBy: ".").first!
            let date = DateFormater.getMessageDate(givenDate: strDate)
            
            let objChatList = StructChatList.init(
                UniqueID : friend.kuserid,
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
        
        for group in arrGroups{
            var strDate = group.lastMessageDate
            strDate = strDate.replacingOccurrences(of: "T", with: " ").components(separatedBy: ".").first!
            let date = DateFormater.getMessageDate(givenDate: strDate)
            
            let objChatList = StructChatList.init(
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
            arrChatList.append(objChatList)
        }
        
        for broadcastList in arrBroadcastLists{
            var strDate = broadcastList.lastMessageDate
            strDate = strDate.replacingOccurrences(of: "T", with: " ").components(separatedBy: ".").first!
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
        tableView.reloadData()
        
    }
    
    func layoutUI()
    {
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.contentInset = UIEdgeInsets.zero
        
        let footervw = UIView.init(frame: .zero)
        tableView.tableFooterView = footervw
    
        isStatusBarHidden = false
        
    }

    @IBAction func btnBackClicked(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSearchClicked(_ sender: Any) {
        txtSearch.text = ""
        if searchclicked == true
        {
            heightOfSearchBar.constant = 0
            txtSearch.resignFirstResponder()
            searchclicked = false
        }
        else
        {
            searchclicked = true
            heightOfSearchBar.constant = 56
            txtSearch.becomeFirstResponder()
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func btnSendClicked(_ sender: Any) {
        var arrSelectedPersonalChats = [StructChat]()
        for chatID in arrSelectedChatIDs{
            
            let allPersonalChats = arrChatList.filter({$0.ChatType == .Personal})
            let personalChat = allPersonalChats.first(where: {$0.UniqueID == chatID})!
            arrSelectedPersonalChats.append(personalChat.OriginalModel as! StructChat)
            
        }
        
        var arrSelectedGroupChats = [StructGroupDetails]()
        for groupID in arrSelectedGroupIDs{
            
            let allGroupChats = arrChatList.filter({$0.ChatType == .Group})
            let group = allGroupChats.first(where: {$0.UniqueID == groupID})!
            arrSelectedGroupChats.append(group.OriginalModel as! StructGroupDetails)
            
        }
        
        var arrSelectedBroadcastLists = [StructBroadcastList]()
        for broadcastListID in arrSelectedBroadcastListIDs{
            
            let allBroadcastChats = arrChatList.filter({$0.ChatType == .Broadcast})
            let broadcastList = allBroadcastChats.first(where: {$0.UniqueID == broadcastListID})!
            arrSelectedBroadcastLists.append(broadcastList.OriginalModel as! StructBroadcastList)
            
        }
        
        var arrMessages = [[String:String]]()
        
        if ((arrSelectedPersonalChats.count + arrSelectedGroupChats.count) > 0) && (arrMessagesForForward.count > 0){
            let isPersonalMessages = arrMessagesForForward.first! is StructChat
            
            let countryCode = UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode).replacingOccurrences(of: "+", with: "")
            let phoneNumber = UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)
            let username = UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName)
            let isdeleted = 0
            let isread = 0
            let platform = PlatformName
            let createddate = ""
            let senderid = UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)
            
            if isPersonalMessages{
                
                let arrMsgs = arrMessagesForForward as! [StructChat]
                for message in arrMsgs{
                    let chatMessage = message.kchatmessage
                    let mediaURL = message.kmediaurl
                    let messageType = message.kmessagetype
                    
                    let dic = [
                        "textmessage" : chatMessage,
                        "mediaurl" : mediaURL,
                        "messagetype" : messageType
                    ]
                    arrMessages.append(dic)
                }
                
            }else{
                
                let arrMsgs = arrMessagesForForward as! [StructGroupChat]
                for message in arrMsgs{
                    let chatMessage = message.textmessage
                    let mediaURL = message.mediaurl
                    let messageType = message.messagetype
                    
                    let dic = [
                        "textmessage" : chatMessage,
                        "mediaurl" : mediaURL,
                        "messagetype" : messageType
                    ]
                    arrMessages.append(dic)
                }
                
            }
            
            var arrGroupIDsAndMember = [String]()
            for group in arrSelectedGroupChats{
                
                let allMembers = group.members.components(separatedBy: ",")
                let mutedMembers = group.muted_by.components(separatedBy: ",")
                var nonMutedMembers = [String]()
                for memberID in allMembers{
                    if mutedMembers.contains(memberID) == false{
                        nonMutedMembers.append(memberID)
                    }
                }
                var nonMuteds = nonMutedMembers.joined(separator: ",")
                if nonMuteds == ","{
                    nonMuteds = "0"
                }
                
                arrGroupIDsAndMember.append("\(group.group_id)-\(group.members)-\(nonMuteds)")
            }
            let groupIDsAndMembers = arrGroupIDsAndMember.joined(separator: "|")
            
            arrFinalMessages = [[String:String]]()
            for dic in arrMessages{
                var finalDic = dic
                finalDic["senderid"] = senderid
                finalDic["platform"] = platform
                finalDic["createddate"] = createddate
                finalDic["isdeleted"] = "\(isdeleted)"
                finalDic["isread"] = "\(isread)"
                finalDic["username"] = username
                finalDic["countrycode"] = countryCode
                finalDic["phonenumber"] = phoneNumber
                finalDic["parent_id"] = "0"
                
                if arrSelectedPersonalChats.count > 0{
                    finalDic["receiverids"] = arrSelectedPersonalChats.map({$0.kuserid}).joined(separator:",")
                    finalDic["blockedByReceiver"] = "0"
                }
                
                if arrSelectedGroupChats.count > 0{
                    finalDic["group_members"] = groupIDsAndMembers
                }
                
                arrFinalMessages.append(finalDic)
            }
            
            if arrFinalMessages.count > 0{
                let firstDic = arrFinalMessages.first!
                if firstDic.keys.contains("receiverids"){
                    arrFinalMessagesForPersonalChats = Array(arrFinalMessages)
                }
                if firstDic.keys.contains("group_members"){
                    arrFinalMessagesForGroupChats = Array(arrFinalMessages)
                }
                //arrFinalMessagesForBroadcast = Array(arrFinalMessages)
            }
            
            showHUD()
            forwardMessagesToPersonalChat()
            
        }
        
    }
    
    func forwardMessagesToPersonalChat(){
        if let firstMessage = arrFinalMessagesForPersonalChats.first{
            
            hudText = "Message Sent to \(arrFinalMessages.count - arrFinalMessagesForPersonalChats.count)/\(arrFinalMessages.count) Chats"
            
            APP_DELEGATE.socketIOHandler?.socket?.emitWithAck("Forward_ToPersonalMessage", firstMessage).timingOut(after: 1, callback: { (data) in
                hideHUD()
                
                //print("\(data.first!)")
                
                if data[0] is String { return }
                
                self.arrFinalMessagesForPersonalChats.remove(at: 0)
                self.forwardMessagesToPersonalChat()
            })
        }else{
            forwardMessagesToGroupChat()
        }
    }
    
    func forwardMessagesToGroupChat(){
        if let firstMessage = arrFinalMessagesForGroupChats.first{
            
            hudText = "Message Sent to \(arrFinalMessages.count - arrFinalMessagesForGroupChats.count)/\(arrFinalMessages.count) Groups"
            
            APP_DELEGATE.socketIOHandler?.socket?.emitWithAck("Forward_ToGroupMessage", firstMessage).timingOut(after: 1, callback: { (data) in
                hideHUD()
                
                //print("\(data.first!)")
                if data[0] is String { return }
                
                self.arrFinalMessagesForGroupChats.remove(at: 0)
                self.forwardMessagesToGroupChat()
            })
        }else{
            hideHUD()
            self.btnBackClicked(UIButton())
        }
    }
    
}

extension ForwardMessageVC : UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForwardMessageCell", for: indexPath) as! ForwardMessageCell
        
        let chatListModel:StructChatList
        if checkSearchBarActive(searchbar: self.txtSearch){
            chatListModel = filterChatList[indexPath.row]
        }
        else{
            chatListModel = arrChatList[indexPath.row]
        }
        
        cell.lblName.text = chatListModel.Title
        
        cell.imgProfile.sd_setImage(with: chatListModel.Photo.toUrl) { (image, error, cacheType, url) in
            if error != nil{
                cell.imgProfile.image = #imageLiteral(resourceName: "channel_placeholder")
            }
        }
        
        if chatListModel.ChatType == .Personal{
            if arrSelectedChatIDs.contains(chatListModel.UniqueID){
                cell.imgCheck.image = #imageLiteral(resourceName: "checkbox_setting_checked")
            }else{
                cell.imgCheck.image = #imageLiteral(resourceName: "checkbox_setting")
            }
        }else if chatListModel.ChatType == .Group{
            if arrSelectedGroupIDs.contains(chatListModel.UniqueID){
                cell.imgCheck.image = #imageLiteral(resourceName: "checkbox_setting_checked")
            }else{
                cell.imgCheck.image = #imageLiteral(resourceName: "checkbox_setting")
            }
        }else{
            if arrSelectedBroadcastListIDs.contains(chatListModel.UniqueID){
                cell.imgCheck.image = #imageLiteral(resourceName: "checkbox_setting_checked")
            }else{
                cell.imgCheck.image = #imageLiteral(resourceName: "checkbox_setting")
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if checkSearchBarActive(searchbar: self.txtSearch)
        {
            return filterChatList.count
        }
        else
        {
            return arrChatList.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        let chatListModel:StructChatList
        if checkSearchBarActive(searchbar: self.txtSearch)
        {
            chatListModel = filterChatList[indexPath.row]
        }
        else
        {
            chatListModel = arrChatList[indexPath.row]
        }
        
        if chatListModel.ChatType == .Personal{
            if arrSelectedChatIDs.contains(chatListModel.UniqueID){
                arrSelectedChatIDs.remove(at: arrSelectedChatIDs.index(of: chatListModel.UniqueID)!)
            }else{
                arrSelectedChatIDs.append(chatListModel.UniqueID)
            }
        }
        else if chatListModel.ChatType == .Group{
            if arrSelectedGroupIDs.contains(chatListModel.UniqueID){
                arrSelectedGroupIDs.remove(at: arrSelectedGroupIDs.index(of: chatListModel.UniqueID)!)
            }else{
                arrSelectedGroupIDs.append(chatListModel.UniqueID)
            }
        }else{
            if arrSelectedBroadcastListIDs.contains(chatListModel.UniqueID){
                arrSelectedBroadcastListIDs.remove(at: arrSelectedBroadcastListIDs.index(of: chatListModel.UniqueID)!)
            }else{
                arrSelectedBroadcastListIDs.append(chatListModel.UniqueID)
            }
        }
        
        self.tableView.reloadRows(at: [indexPath], with: .none)
        
        manageTitleLabel()
    }

    func manageTitleLabel(){
        let totalSelectedCount = arrSelectedGroupIDs.count + arrSelectedChatIDs.count
        lblTitle.text = "\(totalSelectedCount) Selected"
        
        UIView.animate(withDuration: 0.3) {
            if totalSelectedCount == 0{
                self.btnSend.alpha = 0.0
            }else{
                self.btnSend.alpha = 1.0
            }
        }
    }
    
}

extension ForwardMessageVC: UISearchBarDelegate
{
    func filterChatListUser(_ searchText: String)
    {
        filterChatList = arrChatList.filter({(StructChatList ) -> Bool in
            if StructChatList.ChatType == .Personal
            {
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
        tableView.reloadData()
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
        txtSearch.text = ""
        heightOfSearchBar.constant = 0
        searchclicked = false
        tableView.reloadData()
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

/*
extension ForwardMessageVC: ShareExtentionDelegate {
    func ShareExtention_Share_Image(images : [UIImage])
    {
        
    }
}*/

