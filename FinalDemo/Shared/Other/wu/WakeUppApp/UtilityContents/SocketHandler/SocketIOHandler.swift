//
//  SocketIOHandler.swift
//  WakeUppApp
//
//  Created by Admin on 20/04/18.
//  Copyright © 2018 el. All rights reserved.
//

import SocketIO
import SwiftyJSON

class SocketIOHandler: NSObject {
    
    var manager:SocketManager?
    var socket : SocketIOClient?
    var isHandlerAdded:Bool = false
    
    override init()
    {
        super.init()
        
        connectWithSocket()
    }
    
    //MARK: - Sonnect with scoket
    func connectWithSocket()
    {
        if(!self.isSocektConnected())
        {
            if isDNDActive == false{
                manager = SocketManager(socketURL: URL(string: SocketServerURL)!, config: [.log(false), .compress])
                
                socket = manager?.defaultSocket
                socket?.on(clientEvent: .connect) {data, ack in
                    self.reloadFriendAndGroupList()
                    
                    postNotification(with: NC_SocketConnected)
                }
                socket!.connect()
                print("Socket Connected : \(SocketServerURL)")
            }
        }
    }
    
    func reloadFriendAndGroupList() {
        if(self.isSocektConnected() && UserDefaultManager.getBooleanFromUserDefaults(key: kIsLoggedIn) == true) {
            self.callJoinSocket()
        }
        
        let msgDictionary = [
            "user_id":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)
            ] as [String : Any]
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck(keyGetMyGroups,msgDictionary).timingOut(after: 120)
        {data in
            let data = data as Array
            if(data.count > 0)
            {
                if data[0] is String { return }
                
                let dic = data[0] as! NSArray//data[0] as! NSDictionary
                let obj = dic
               
               
                for dicData in obj
                {
                    let objData:StructGroupDetails = StructGroupDetails.init(dictionary: dicData as! [String : Any])
                    //print("Get_MyGroups - data: \(objData)")
                   
                    _ = CoreDBManager.sharedDatabase.saveGroupListInDB(objGroup: objData)
                }
                postNotification(with: NC_GroupListRefresh)
            }
        }
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck(keyGetChatUsers,msgDictionary).timingOut(after: 120)
        {data in
            let data = data as Array
            if(data.count > 0) {
                if data[0] is String { return }
                
                let dic = data[0] as! NSArray//data[0] as! NSDictionary
                let obj = dic as! [[String : Any]]
                for dicData in obj {
                    let objData:StructChat = StructChat.init(dictionary: dicData)
                    //print("Get_ChatUsers - data: \(objData)")
                    _ = CoreDBManager.sharedDatabase.saveFriendInLocalDB(objFriend: objData)                  
                }
                
                //print("Get_ChatUsers : postNotification -> NC_UserListRefresh")
                postNotification(with: NC_UserListRefresh)
            }
        }
    }
    
    func isSocektConnected() -> Bool {
        if ((self.socket?.status == .connected) || (self.socket?.status == .connecting)) { return true }
        else
        {
            return false
        }
    }
    
    func disconnectSocket(){
        isHandlerAdded = false
        socket?.removeAllHandlers()
        socket?.disconnect()
    }
    
    func inBackgroundSocket() {
        if UserDefaultManager.getBooleanFromUserDefaults(key: kIsLoggedIn) && self.isSocektConnected() == true {
            //let socket_dict:NSDictionary = ["userID": APP_DELEGATE.APP_USER.userId!]
            let dict:NSDictionary = NSDictionary()
            self.socket?.emit(keyinBackground, dict)
        }
    }
    
    func inForegroundSocket() {
        if UserDefaultManager.getBooleanFromUserDefaults(key: kIsLoggedIn) && self.isSocektConnected() == true {
            //            let socket_dict:NSDictionary = ["userID": APP_DELEGATE.APP_USER.userId!]
            
            let dict:NSDictionary = NSDictionary()
            self.socket?.emit(keyinForeground, dict)
        }
    }
    
    func addHandlers()
    {
        socket?.on(keyJoinSocket){data, ack in
            //print(data)
        }
        
        socket?.on(keyNewMessage) {data, ack in
            //print("addHandlers : NewMessage : \(data)")
            self.respondsToNewMessage(data: data)
        }
        
        socket?.on(keyGroupMessage) {data, ack in
            //self.respondsToNewGroupMessage(data: data)
            self.respondsToNewGroupMessage(data: data)
        }
        
        socket?.on("Broadcast_Message"){data, ack in
            //print(data)
            self.respondsToNewBroadcastMessage(data: data)
        }
        
        socket?.on("Forward_Group_Message"){data, ack in
            self.respondsToNewGroupMessage(data: data)
        }
        
        socket?.on(keyGroupCreated) {data, ack in
            showMessage("\(keyGroupCreated) : \(UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName))")
            //print(data)
        }
        
        socket?.on("RefreshUserBioProfileUpdate") {data, ack in
            //print("addHandlers : RefreshUserBioProfileUpdate : \(data)")
            
            if data.count > 0{
                let dict = data.first as! NSDictionary
                let userID : String = dict.object(forKey: "userid") as! String
                let strImagename : String = dict.object(forKey: "imagename") as! String
                let strBio : String = dict.object(forKey: "bio") as! String
                let strFullname : String = dict.object(forKey: "fullname") as! String
                //let strBirthdate : String = dict.object(forKey: "birthdate") as! String
                
                let userList_ID = CoreDBManager.sharedDatabase.getFriendIdList_ID()
                if userList_ID.contains(userID) == true {
                    var objUser : StructChat = CoreDBManager.sharedDatabase.getFriendById(userID: userID)!
                    runAfterTime(time: 0.25, block: {
                        if objUser != nil {
                            objUser.kuserprofile = strImagename
                            objUser.bio = strBio
                            objUser.kusername = strFullname
                            
                            CoreDBManager.sharedDatabase.updateFriend(for: objUser)
                        }
                    })
                }
            }
        }
        
        socket?.on("Group_Created"){data, ack in
            //print("addHandlers : Group_Created : \(data)")
            //self.reloadFriendAndGroupList()
            
            for dicData in data {
                let dic : [String : Any] = dicData as! [String : Any]
                var objGroupInfo:StructGroupDetails = StructGroupDetails.init(dictionary: dicData as! [String : Any])
                objGroupInfo.group_id = "\(dic["groupid"] ?? "")"
                objGroupInfo.name = "\(dic["name"] ?? "")"
                objGroupInfo.icon = "\(dic["icon"] ?? "")"
                objGroupInfo.members = "\(dic["members"] ?? "")"
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
                //print("getData : \(objData)")
                _ = CoreDBManager.sharedDatabase.saveGroupListInDB(objGroup: objGroupInfo)
            }
            postNotification(with: NC_GroupListRefresh)
        }
        
        socket?.on("GroupIconNameUpdate"){data, ack in
            //print(data.first!)
            self.reloadFriendAndGroupList()
        }
        
        socket?.on("Group_Member_Update"){data, ack in
            //print(data.first!)
            self.reloadFriendAndGroupList()
            //self.postNewGroupMessageNotification(with: data.first as! NSDictionary)
            self.respondsToNewGroupMessage(data: data)
        }
        
        socket?.on("Friend_Received", callback: { (data, ack) in
            //print(data)
            //self.reloadFriendAndGroupList()
            if data.count > 0{
            let dict = data.first as! NSDictionary
                let isread = dict.object(forKey: "isread") as! String
                let receiveid = dict.object(forKey: "receiveid") as! String
                let senderid = dict.object(forKey: "senderid") as! String
                CoreDBManager.sharedDatabase.updateReadStatusForFriendList(senderId: senderid, receiverId: receiveid, newReadStatus: isread)
                //print("Friend_Received : postNotification -> NC_UserListRefresh")
                postNotification(with: NC_UserListRefresh)

                postNotification(with: NC_ReadReceiptUpdate, andUserInfo: ["sid":senderid,"rid":receiveid])                
            }
        })
//        socket?.on("RefreshPushReadStatus", callback: { (data, ack) in
//            
//            showMessage("I am called")
//            if data.count > 0{
//                let dict = data.first as! NSDictionary
////                let isread = dict.object(forKey: "isread") as! String
////                let receiveid = dict.object(forKey: "receiveid") as! String
//                 let chatid = dict.object(forKey: "chatid") as! String
////                let senderid = dict.object(forKey: "senderid") as! String
//                CoreDBManager.sharedDatabase.updateReadStatus(newReadStatus: "1", forChatIDs: [chatid])
////                CoreDBManager.sharedDatabase.updateReadStatusForFriendList(senderId: senderid, receiverId: receiveid, newReadStatus: isread)
////                postNotification(with: NC_UserListRefresh)
////                postNotification(with: NC_ReadReceiptUpdate, andUserInfo: ["sid":senderid,"rid":receiveid])
//            }
//        })
//        socket?.on("UpdateLocalDBReadStatus", callback: { (data, ack) in
//            //print(data)
//            //self.reloadFriendAndGroupList()
//            if data.count > 0{
//                let dict = data.first as! NSDictionary
//                let isread = dict.object(forKey: "isread") as! String
//                let receiveid = dict.object(forKey: "receiveid") as! String
//                let senderid = dict.object(forKey: "senderid") as! String
//                let readtm = dict.object(forKey: "readtime") as! String
//                CoreDBManager.sharedDatabase.updateReadTimeForFriendList(senderId: senderid, receiverId: receiveid, newReadStatus: isread,readtime: readtm)
//            }
//        })
//        socket?.on("UpdateLocalDBRecievedStatus", callback: { (data, ack) in
//            //print(data)
//            //self.reloadFriendAndGroupList()
//            if data.count > 0{
//                let dict = data.first as! NSDictionary
//                let isread = dict.object(forKey: "isread") as! String
//                let receiveid = dict.object(forKey: "receiveid") as! String
//                let senderid = dict.object(forKey: "senderid") as! String
//                let readtm = dict.object(forKey: "receivetime") as! String
//                CoreDBManager.sharedDatabase.updateReadTimeForFriendList(senderId: senderid, receiverId: receiveid, newReadStatus: isread,readtime: readtm)
//            }
//        })
        
        socket?.on("Friend_ReceivedById", callback: { (data, ack) in
            //print(data)
            //self.reloadFriendAndGroupList()
            if data.count > 0{
                let dict = data.first as! NSDictionary
                let isread = dict.object(forKey: "isread") as! String
                let receiveid = dict.object(forKey: "receiveid") as! String
                let senderid = dict.object(forKey: "senderid") as! String
                let chatidval = dict.object(forKey: "chatid") as! String
                CoreDBManager.sharedDatabase.updateReadStatusForFriendListByChatId(senderid, receiveid, isread,chatid: chatidval)
                //print("Friend_ReceivedById : postNotification -> NC_UserListRefresh")
                postNotification(with: NC_UserListRefresh)
            }
        })
        
        socket?.on("ReloadOnlineStatus", callback: { (data, ack) in
            postNotification(with: NC_OnlineStatusRefresh)
        })
        
        socket?.on("Friend_Viewed", callback: { (data, ack) in
            //print(data)
            if data.count > 0
            {
                let dict = data.first as! NSDictionary
                //  let userid = dict.object(forKey: "user_id") as! String
                let storyid = "\(dict.object(forKey: "status_id") as! String)"
                let url2 = "\(Get_Profile_Pic_URL)\(dict["viewer_pic"] as? String ?? "".lowercased())"
                /*let vwid = "\(dict.object(forKey: "viewer_id") as! String)"
                let vname = "\(dict.object(forKey: "viewer_name") as! String)"
                let vdate = "\(dict.object(forKey: "view_date") as! String)"
                let vpic = url2*/
                //_ = CoreDBManager.sharedDatabase.saveMyViewer(sid: storyid, vid: vwid, prof: vpic, nm: vname, tm: vdate)
                
                let viewer = StructStoryViewers.init(
                    storyID: storyid,
                    userID: "\(dict.object(forKey: "viewer_id") as! String)",
                    createdDate: "\(dict.object(forKey: "view_date") as! String)",
                    profileURL: "\(Get_Profile_Pic_URL)\(dict["viewer_pic"] as? String ?? "".lowercased())",
                    userName: "\(dict.object(forKey: "viewer_name") as! String)",
                    countrycode: "\(dict.object(forKey: "country_code") as? String ?? "")",
                    phoneno:  "\(dict.object(forKey: "phoneno") as? String ?? "")")
                CoreDBManager.sharedDatabase.saveViewersInLocalDB(ForStoryID: storyid, viewers: [viewer])
            }
        }) 
        
        
        //WHENEVER A STORY IS DELETED
        socket?.on("Story_Deleted", callback: { (data, ack) in
            //print(data)
            let dict = data.first as! NSDictionary
            let strStoryIDs = dict.value(forKey: "Data") as! String
            let arrStoryIDs = strStoryIDs.components(separatedBy: ",")
            //_ = CoreDBManager.sharedDatabase.deleteMultipleStoryById(list: arrStoryIDs)
            CoreDBManager.sharedDatabase.deleteStories(byStoryIDs: arrStoryIDs)
            //postNotification(with: NC_RefreshAfterDelete, andUserInfo:nil)
            postNotification(with: NC_FriendStoryRefresh)
        })
        
        //WHENEVER NEW STORIES ARE ADDED
        socket?.on("Story_Added", callback: { (data, ack) in
            //print(data)
            //self.reloadFriendAndGroupList()
            if data.count > 0 {
                let dict = data.first as! NSDictionary
                let arr = dict.value(forKey: "Data") as? NSArray
                var userid = ""
                for dic in arr! {
                    /*var objdata = StructStoryData.init(dictionary: dicData as! [String:Any])
                    objdata.kisviewed = "0"
                    userid = objdata.kuid
                    _ = CoreDBManager.sharedDatabase.saveStoryInLocalDB(objstory: objdata)*/
                    
                    let dicData = dic as! [String:Any]
                    
                    let mediaName =  dicData["image"] as? String ?? ""
                    
                    var friendStory = StructStatusStory.init(
                        storyID: "\(dicData["status_id"] ?? "")",
                        createdDate: dicData["creation_datetime"] as? String ?? "",
                        storyType: mediaName.contains("jpg") || mediaName.contains("png") ?  "1" : "0",
                        mediaURL: "\(Get_Status_URL)/\(mediaName)",
                        isViewedByMe: "0",
                        userID: "\(dicData["storyownerid"] ?? "")",
                        duration: "\(dicData["storyduration"] ?? "5")",
                        profileURL: "\(dicData["userprofile"] as? String ?? "")",
                        userName: dicData["username"] as? String ?? "",
                        allowCopy: "\(dicData["allowcopy"] ?? "0")",
                        caption: dicData["storycaption"] as? String ?? "0",
                        statusprivacy: "\(dicData["status_privacy"] ?? "2")",
                        countrycode:"\(dicData["country_code"] ?? "91")",
                        phoneno:"\(dicData["phoneno"] ?? "0")",
                         statusviewprivacy: "\(dicData["statusviewprivacy"] ?? "1")",
                        markedusers: "\(dicData["markedusers"] ?? "0")"
                    )
                    var nameval = friendStory.userName
                    let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: friendStory.countrycode, phoneNo: friendStory.phoneno)
                    if objContactInfo.Name?.count == 0
                    {
                        nameval = "+\(friendStory.countrycode) \(friendStory.phoneno)"
                    }
                    else
                    {
                        nameval = objContactInfo.Name!
                        friendStory.userName = nameval
                        CoreDBManager.sharedDatabase.saveStoriesInLocalDB(stories: [friendStory])
                    }
                   // CoreDBManager.sharedDatabase.saveStoriesInLocalDB(stories: [friendStory])
                }
                //postNotification(with: NC_AddStoryToList, andUserInfo: ["uid":userid])
                APP_DELEGATE.storyDotVisible = true
                postNotification(with: NC_FriendStoryRefresh)
            }
        })
        
        socket?.on(keyUpdateStatusPrivacy, callback: { (data, ack) in
            //print(data)
            let dict = data.first as! NSDictionary
            let strStoryID = dict.value(forKey: "status_id") as! String
            CoreDBManager.sharedDatabase.udpateStoryCopyflag(strStoryID,dict.value(forKey: "allowcopy") as! String)
            postNotification(with: NC_FriendStoryRefresh)
        }) 
       
        socket?.on("Update_Muted_User_List", callback: {(data, ack) in
            if data.count > 0{
                let dic = data.first as! [String:Any]
                let groupid = dic["groupid"] as! String
                let mutedids = dic["mutedids"] as! String
                CoreDBManager.sharedDatabase.updateMuteIDsForGroup(muteIDs: mutedids, groupID: groupid)
            }
        })
        
        socket?.on("SetRoomNameForVideoCall", callback: {(data, ack) in
            if data.count > 0{
                let dic = data.first as! [String:Any]
                //let callToId = dic["callToId"] as! String
                //let callToName = dic["callToName"] as! String
                let roomname = dic["roomname"] as! String
                let callerId = dic["callerId"] as! String
                let callerName = dic["callerName"] as! String
                let callerPhoto = dic["callerPhoto"] as! String
                
                openVideoCallScreen(roomname: roomname, callerId: callerId, callerName: callerName, callerPhoto: callerPhoto)
            }
        })
        
        socket?.on("DeleteChatMessage", callback: { (data, ack) in
            if data.count > 0{
                let dicData = data.first as! [String:Any]
                let chatIDs = dicData["chatid"] as! String
                CoreDBManager.sharedDatabase.deleteForEveryoneChatMessage(chatIDs: chatIDs.components(separatedBy: ","))
                self.perform(#selector(self.postLoadMessageFromServerNotification), with: data[0], afterDelay: 0.5)
            }
        })
        
        socket?.on("DeleteGroupChatMessage", callback: { (data, ack) in
            if data.count > 0{
                let dicData = data.first as! [String:Any]
                let chatIDs = dicData["chatid"] as! String
                CoreDBManager.sharedDatabase.deleteForEveryoneGroupChatMessage(groupChatIDs: chatIDs.components(separatedBy: ","))
                self.perform(#selector(self.postLoadMessageFromServerNotification), with: data[0], afterDelay: 0.5)
            }
        })
        
        socket?.on("UserOnlineStatusChanged", callback: { (data, ack) in
            if data.count > 0{
                let dicData = data.first as! [String:Any]
                let userId = dicData["user_id"] as! String
                let notificationName = "\(NC_UserOnlineStatusChanged)_\(userId)"
                postNotification(with: notificationName)
            }
        })
        
        /*socket?.onAny({ (event) in
            print(event.event)
            print(event.items)
        })*/
        
        //------------------------>
        //Manage Privacy Setting changes effect handel
        //Handel Privacy - status_privacy
        socket?.on("RefreshStatus", callback: { (data, ack) in
            postNotification(with: NC_FriendStoryRefresh)
        })
        
        //Get Block User Info
        socket?.on("Blocked_User", callback: { (data, ack) in
            
            if data.count > 0 {
                let dic = data.first as! [String:Any]
                if dic.count == 0 { return }
                
                //print("Update_UserInfo respo.: \(dic)")
                //if dic.count == 3 { return }
                
                //let strUserID : String = dic["userid"] as! String
                let strUserBlockID : String = dic["blockid"] as! String
                let strIsBlock : String = dic["isblock"] as! String
                
                //Get UserInfo
                var objUserInfo : StructChat = CoreDBManager.sharedDatabase.getFriendById(userID: strUserBlockID)!
                
                runAfterTime(time: 0.30, block: {
                    //if objUserInfo == StructChat.init(dictionary: [:]) { return }
                
                    //{ return }
                    
                    if strIsBlock == "block" {
                        objUserInfo.lastseen_privacy = "0"
                        objUserInfo.photo_privacy = "0"
                        objUserInfo.about_privacy = "0"
                        objUserInfo.read_receipts_privacy = "0"
                        objUserInfo.status_privacy = "0"
                    }
                    else {
                        objUserInfo.lastseen_privacy = dic["lastseen_privacy"] as? String ?? "1"
                        objUserInfo.photo_privacy = dic["photo_privacy"] as? String ?? "1"
                        objUserInfo.about_privacy = dic["about_privacy"] as? String ?? "1"
                        objUserInfo.read_receipts_privacy = dic["read_receipts_privacy"] as? String ?? "1"
                        objUserInfo.status_privacy = dic["status_privacy"] as? String ?? "1"
                    }
                    CoreDBManager.sharedDatabase.updateFriend(for: objUserInfo) //Update UserInfo
                    
                    runAfterTime(time: 0.20, block: {
                        postNotification(with: NC_PrivacyChange_Refresh_ChatListVC) //ChatListVC
                        postNotification(with: NC_PrivacyChange_Refresh_ChatVC) //ChatVC
                        postNotification(with: NC_PrivacyChange_Refresh_ChatUserInfoVC) //ChatUserInfoVC
                        postNotification(with: NC_PrivacyChange_Refresh_ReadInfoVC) //ReadInfoVC
                        postNotification(with: NC_PrivacyChange_Refresh_GroupInfoVC) //GroupInfoVC
                        postNotification(with: NC_PrivacyChange_Refresh_SelectMembersVC) //SelectMembersVC
                    })
                })
            }
        })
        
        //Handel Privacy - lastseen_privacy, photo_privacy, about_privacy, read_receipts_privacy
        socket?.on("Update_PrivacySetting", callback: { (data, ack) in
            if data.count > 0 {
                let dic = data.first as! [String:Any]
                if dic.count == 0 { return }
                //let userID = dic["userid"] as! String
                
                //print("Update_PrivacySetting respo.: \(dic)")
                let strUserID : String = dic["userid"] as! String
                
                //Get UserInfo
                let arrAppUserInMyContact = CoreDBManager.sharedDatabase.getFriendIdList_ID()
                if (arrAppUserInMyContact.contains(strUserID) == false) { return }
                else {
                    var objUserInfo : StructChat = CoreDBManager.sharedDatabase.get_UserInfo(userID: strUserID)!
                runAfterTime(time: 0.30, block: {
                if objUserInfo == nil { return }
                
                if objUserInfo.kuserid == strUserID {
                    
                    let strAction : String = dic["action"] as! String
                    let strActionValue : String = dic["value"] as! String
                    
                    if strAction.uppercased() == "lastseen_privacy".uppercased() {
                        objUserInfo.lastseen_privacy = strActionValue
                        CoreDBManager.sharedDatabase.updateFriend(for: objUserInfo) //Update UserInfo
                        
                        runAfterTime(time: 0.20, block: {
                            postNotification(with: NC_PrivacyChange_LastSeen_Refresh_ChatVC) //ChatVC
                        })
                        return
                    }
                    else if strAction.uppercased() == "photo_privacy".uppercased() {
                        objUserInfo.photo_privacy = strActionValue
                        CoreDBManager.sharedDatabase.updateFriend(for: objUserInfo) //Update UserInfo
                        
                        runAfterTime(time: 0.20, block: {
                            postNotification(with: NC_PrivacyChange_Refresh_ChatListVC) //ChatListVC
                            postNotification(with: NC_PrivacyChange_Refresh_ChatVC) //ChatVC
                            postNotification(with: NC_PrivacyChange_Refresh_ChatUserInfoVC) //ChatUserInfoVC
                            postNotification(with: NC_PrivacyChange_Refresh_ReadInfoVC) //ReadInfoVC
                            postNotification(with: NC_PrivacyChange_Refresh_GroupInfoVC) //GroupInfoVC
                            postNotification(with: NC_PrivacyChange_Refresh_SelectMembersVC) //SelectMembersVC
                        })
                        return
                    }
                    else if strAction.uppercased() == "about_privacy".uppercased() {
                        objUserInfo.about_privacy = strActionValue
                        CoreDBManager.sharedDatabase.updateFriend(for: objUserInfo) //Update UserInfo
                        
                        runAfterTime(time: 0.20, block: {
                            postNotification(with: NC_PrivacyChange_About_Refresh_ChatUserInfoVC) //ChatUserInfoVC
                        })
                        return
                    }
                    else if strAction.uppercased() == "read_receipts_privacy".uppercased() {
                        objUserInfo.read_receipts_privacy = strActionValue
                    }
                    CoreDBManager.sharedDatabase.updateFriend(for: objUserInfo) //Update UserInfo
                }
                })
                }
            }
        })
    }
    
    func respondsToNewMessage(data:Array<Any>) {
        //print(data)
        if(data.count > 0) {
            let data = data as Array
            if(data.count > 0) {
                self.reloadFriendAndGroupList()

                if data[0] is String { return }
                //print(data)
                //CODE TO SAVE IN COREDB
                let objData:StructChat = StructChat.init(dictionary:data[0] as! [String : Any])
                if(objData.kreceiverid == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)) {
                    
                    //Manage Block Contact
                    //If Block Contact User message received, not perform any option.
                    if APP_DELEGATE.User_Exists_inBlockContactList(strUserID: objData.ksenderid) { return }
                    
                    CoreDBManager.sharedDatabase.increaseUnreadCount(for: objData)
                    
                    let dict = ["userid" : objData.ksenderid, "receiverid" : objData.kreceiverid, "chatid" : objData.kid]
                    self.socket?.emit("Update_ReceivedStatus",dict)
                    
                    self.perform(#selector(postNewMessageNotification), with: data[0], afterDelay: 0.5)
                    
                    APP_DELEGATE.chatDotVisible = true
                    
                    let chatUser = CoreDBManager.sharedDatabase.getFriendById(userID: objData.kuserid)
                    if let chatUser = chatUser{
                        if chatUser.ishidden == "1" { showMessage("You have a new message") }
                    }
                }
            }
        }
    }
    
    func respondsToNewGroupMessage(data:Array<Any>) {
        //print(data)
        if(data.count > 0) {
            let data = data as Array
            if(data.count > 0) {
                self.reloadFriendAndGroupList()
                if data[0] is String { return }
                //print(data)
                //CODE TO SAVE IN COREDB
                let objData:StructGroupChat = StructGroupChat.init(dictionary:data[0] as! [String : Any])
                
                let receiverIDs = objData.receiverid.components(separatedBy: ",")
                let userId = UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)
                let index = receiverIDs.index(of: userId)
                if index != nil {
                    CoreDBManager.sharedDatabase.increaseUnreadCountForGroup(for: objData)
                    
                    let dtDate = DateFormater.getDateFromStringInLocalTimeZone(givenDate: DateFormater.getStringFromDate(givenDate: NSDate()))
                    let strDate = DateFormater.getStringFromDate(givenDate: dtDate)
                    
                    let dict = [
                        "receivetime" : strDate,
                        "groupchatid" : objData.id,
                        "userid" : userId
                    ]
                    self.socket?.emit("Save_GroupMsgReceivedStatus",dict)
                    self.perform(#selector(postNewGroupMessageNotification), with: data[0], afterDelay: 0.5)
                    APP_DELEGATE.chatDotVisible = true
                    
                    if let group = CoreDBManager.sharedDatabase.getGroupById(groupId: objData.groupid){
                        if group.ishidden == "1"{
                            showMessage("You have a new message")
                        }
                    }
                    
                }
            }
            
        }
    }
    
    func respondsToNewBroadcastMessage(data: Array<Any>){
        //print(data)
        if(data.count > 0) {
            let data = data as Array
            if(data.count > 0) {
                if data[0] is String { return }
                //print("respondsToNewBroadcastMessage: \(data)")
                
                let objData:StructBroadcastMessage = StructBroadcastMessage.init(dictionary:data[0] as! [String : Any])
                let receiverIDs = objData.receiverid.components(separatedBy: ",")
                
                let userId = UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)
                let index = receiverIDs.index(of: userId)
                if index != nil{
                    self.reloadFriendAndGroupList()
                    var objData:StructChat = StructChat.init(dictionary: data[0] as! [String : Any])
                    objData.kreceiverid = UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)
                    objData.kuserid = UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)
                    CoreDBManager.sharedDatabase.increaseUnreadCount(for: objData)
                    self.perform(#selector(postLoadMessageFromServerNotification), with: data[0], afterDelay: 0.5)
                    APP_DELEGATE.chatDotVisible = true
                }
                
            }
            
        }
    }
    
    @objc func postNewMessageNotification(with UserInfo:Any){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NC_NewMessage), object: nil, userInfo: UserInfo as! [String : Any])
    }
    
    @objc func postNewGroupMessageNotification(with UserInfo:Any){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NC_NewGroupMessage), object: nil, userInfo: UserInfo as! [String : Any])
    }
    
    @objc func postLoadMessageFromServerNotification(with UserInfo:Any){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NC_LoadMessageFromServer), object: nil, userInfo: UserInfo as! [String : Any])
    }
    
    func removeHandlers()
    {
        socket?.removeAllHandlers()
    }
    
    //MARK: - Socket Join to know online users
    func callJoinSocket()
    {
        if(!isHandlerAdded)
        {
            isHandlerAdded = true
            addHandlers()
        }
        //self.socket?.emit(keyUsername, UserDefaultManager.getStringFromUserDefaults(key: kAppUserId))
        
        //print("User ID : \(UserDefaultManager.getStringFromUserDefaults(key: kAppUserId))")
        //print("TokenID : \(UserDefaultManager.getStringFromUserDefaults(key: kToken))")
        
        let dict:NSDictionary = [
            "user_id" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            "device_id" : UserDefaultManager.getStringFromUserDefaults(key: kAppDeviceToken),
            "platform" : PlatformName
        ]
        self.socket?.emit(keyJoinSocket,dict)
        /*self.socket?.emitWithAck(keyJoinSocket, [:]).timingOut(after: 1000, callback: { (data) in
         
         })*/
    }
    
}
