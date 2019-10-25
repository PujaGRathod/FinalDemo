
//  AppDelegate.swift
//  WakeUppApp
//
//  Created by Payal Umraliya on 19/03/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import MapKit
import IQKeyboardManagerSwift
import PushKit
import CallKit
import TwilioVoice
import UserNotifications
import Alamofire
import UserNotifications
import UserNotificationsUI
import Fabric
import Crashlytics
/*
 //-------------------->
 Fabric Crashlytics
 Email : skyriseexim.web@gmail.com
 PWD: HariKrishna1
*/
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    //MARK:- Variable
    var socketIOHandler:SocketIOHandler?
    var window: UIWindow?
    var appNavigation:UINavigationController?
    var currentLocation = CLLocation()
    var voipRegistry:PKPushRegistry!
    var callInvite:TVOCallInvite?
    var call:TVOCall?
    var callKitCompletionCallback: ((Bool)->Swift.Void?)? = nil
    var callKitProvider:CXProvider!
    var callKitCallController:CXCallController!
    var name = ""
    var userphoto = ""
    var arrRequests = NSMutableArray()
    var isHiddenChatUnlocked = false{
        didSet{
            postNotification(with: NC_HiddenChatLockToggle)
        }
    }
    var chatDotVisible = false{
        didSet{
            postNotification(with: NC_ChatDotChanged)
        }
    }
    var storyDotVisible = false{
        didSet{
            postNotification(with: NC_StoryDotChanged)
        }
    }
    var pushdictreceive = NSDictionary()
    //MARK:-
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        createFolder_inDirectory()
        Fabric.with([Crashlytics.self])
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.disabledToolbarClasses = [ChatVC.self,GroupChatVC.self,BroadcastChatVC.self,StoryPreviewVC.self]
        IQKeyboardManager.shared.disabledTouchResignedClasses = [ChatVC.self,GroupChatVC.self,BroadcastChatVC.self,StoryPreviewVC.self]
        clearBadgeCount()
        clearDeliveredNotifications()
        self.setInitialVC()
        
        registerForRemoteNotification()
        let isPreviouslyAppUsers = UserDefaultManager.getBooleanFromUserDefaults(key: kPreviouslySavedAppUsers)
        if isPreviouslyAppUsers == false{
            UserDefaultManager.setCustomObjToUserDefaults(CustomeObj: [User]() as AnyObject, key: kAppUsers)
            UserDefaultManager.setBooleanToUserDefaults(value: true, key: kPreviouslySavedAppUsers)
        }
        if identity.count > 0{
            setVoIPRegistry()
        }
        TwilioVoice.logLevel = .verbose
        let configuration = CXProviderConfiguration(localizedName: "WakeUpp")
        configuration.maximumCallGroups = 1
        configuration.maximumCallsPerCallGroup = 1
        if let callKitIcon = UIImage(named: "iconMask80") {
            configuration.iconTemplateImageData = UIImagePNGRepresentation(callKitIcon)
        }
        callKitProvider = CXProvider(configuration: configuration)
        callKitCallController = CXCallController()
        callKitProvider.setDelegate(self, queue: nil)
        UIApplication.shared.statusBarView?.backgroundColor = themeWakeUppColor
        if UserDefaultManager.getBooleanFromUserDefaults(key: kIsChatFontCurrentSizeSet) == false{
            UserDefaultManager.setStringToUserDefaults(value: kChatFontSizeMedium, key: kChatFontCurrentSize)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(dndStatusChanged), name: NSNotification.Name.init(NC_DNDStatusChanged), object: nil)
        if let launchOptions = launchOptions{
            if launchOptions.keys.contains(UIApplicationLaunchOptionsKey.remoteNotification){
                let userInfo = launchOptions[UIApplicationLaunchOptionsKey.remoteNotification]
                pushNotificationResponse(userInfo: userInfo as! [String : AnyObject])
            }
        }
        if UserDefaultManager.getBooleanFromUserDefaults(key: kIsUserLocationSet) == false{
            UserDefaultManager.setStringToUserDefaults(value: "0.0-0.0", key: kUserLocation)
            UserDefaultManager.setBooleanToUserDefaults(value: true, key: kIsUserLocationSet)
        }
        LocationService.sharedInstance.startUpdatingLocation()
        return true
    }
    
    @objc func dndStatusChanged(){
        if isDNDActive{
            socketIOHandler?.disconnectSocket()
        }else{
            socketIOHandler = SocketIOHandler()
        }
    }
    
    func setVoIPRegistry(){
        voipRegistry = PKPushRegistry.init(queue: DispatchQueue.main)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = Set([PKPushType.voIP])
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        clearDeliveredNotifications()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        isHiddenChatUnlocked = false
        clearBadgeCount()
        clearDeliveredNotifications()
        changeMyOnlineStatus(status:"0")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        clearDeliveredNotifications()
        changeMyOnlineStatus(status:"1")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        clearBadgeCount()
        clearDeliveredNotifications()
        if UserDefaultManager.getBooleanFromUserDefaults(key: kIsLoggedIn) == true {
            ContactSync.shared.performSync()
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        isHiddenChatUnlocked = false
        clearDeliveredNotifications()
        changeMyOnlineStatus(status:"0")
    }
    
    func changeMyOnlineStatus(status:String){
        if UserDefaultManager.getBooleanFromUserDefaults(key: kIsLoggedIn){
            if UserDefaultManager.getBooleanFromUserDefaults(key: kIsLoggedIn){
                let dic = [
                    "user_id" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
                    "isonline" : status
                ]
                APP_DELEGATE.socketIOHandler?.socket?.emit("UpdateUserOnlineStatus", dic)
            }
        }
    }
    
    func fireLocalNotificationForVoiceCall(didStart:Bool){
        var title = "WakeUpp Incoming Call"
        var message = "Tap here to answer voice call"
        
        if didStart == false{
            title = "Call Missed"
            message = "You missed a voice call"
        }
        
        let center =  UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval:0.5, repeats: false)
        let request = UNNotificationRequest(identifier: "VoIPCallNotification", content: content, trigger: trigger)
        center.add(request) { (error) in
            if error != nil {
            }
        }
    }
    deinit {
        callKitProvider.invalidate()
    }
    
    //MARK:- Push Notification
    func registerForRemoteNotification()
    {
        UNUserNotificationCenter.current().delegate = self
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil {
                    self.manage_InteractivePushNotification()
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            self.manage_InteractivePushNotification()
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        UserDefaultManager.setStringToUserDefaults(value:deviceTokenString , key: kAppDeviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
   
    // Background and closed  push notifications handler
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
        if UserDefaultManager.getStringFromUserDefaults(key: "Badges") == "N/A" || UserDefaultManager.getStringFromUserDefaults(key: "Badges") == "" {UserDefaultManager.setStringToUserDefaults(value: "0", key: "Badges") }
        UIApplication.shared.applicationIconBadgeNumber = Int(UserDefaultManager.getStringFromUserDefaults(key: "Badges"))! + 1
        UserDefaultManager.setStringToUserDefaults(value: "\(UIApplication.shared.applicationIconBadgeNumber)", key: "Badges")
        if let userInfo = response.notification.request.content.userInfo as? [String : AnyObject] {
            pushNotificationResponse(userInfo: userInfo)
        }
        self.sendResponseMess_InteractivePushNotification(response: response)
        completionHandler()
    }
  
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any])
    {
        let state = UIApplication.shared.applicationState
        if state == .active {
        }
        else {
            pushNotificationResponse(userInfo: userInfo as! [String : AnyObject])
        }
    }

    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, withResponseInfo responseInfo: [NSObject : AnyObject], completionHandler: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            completionHandler()
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
       // let user_Info = userInfo as? NSDictionary
        pushNotificationResponse(userInfo: userInfo as! [String : AnyObject])
       
        
    }
  
    func pushNotificationResponse(userInfo:[String:AnyObject])
    {
       //let aps = userInfo["aps"] as? NSDictionary
//        let state = UIApplication.shared.applicationState
        if userInfo.keys.contains("userResult")
        {
            let messageResponse = userInfo["userResult"] as! [String:Any]
            if messageResponse.keys.contains("callerName") {
                let roomname = messageResponse["roomname"] as! String
                let callerId = messageResponse["callerId"] as! String
                let callerName = messageResponse["callerName"] as! String
                let callerPhoto = messageResponse["callerPhoto"] as! String
                openVideoCallScreen(roomname: roomname, callerId: callerId, callerName: callerName, callerPhoto: callerPhoto)
            }
            else if messageResponse.keys.contains("groupid")
            {
                APP_DELEGATE.socketIOHandler?.reloadFriendAndGroupList()
            }
            else if messageResponse.keys.contains("senderid")
            {
                var objData:StructChat = StructChat.init(dictionary:messageResponse)
//                let dict:NSDictionary = [
//                    "senderid" : objData.ksenderid,
//                    "receiverid" : objData.kreceiverid,
//                    "isread":"1",
//                    "chatid":objData.kid
//                ]
//                showMessage("Notify_PushMessage_Read")
//                APP_DELEGATE.socketIOHandler?.socket?.emit("Notify_PushMessage_Read",dict)
//                var strTitle : String = ""
//                let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: messageResponse["countrycode"]! as! String, phoneNo: messageResponse["phonenumber"]! as! String)
//
//                if objContactInfo.Name?.count == 0 { strTitle = "+\(messageResponse["countrycode"]!) \(messageResponse["phonenumber"]!)" }
//                else { strTitle = objContactInfo.Name! }
//
//                let convo = loadVC(strStoryboardId: SB_CHAT, strVCId:idChatVC ) as! ChatVC
//                //convo.delegate = self
//                convo.calledfrom = "messages"
//                //PV
//                //convo.selecteduserid = chatUser.ksenderid
//                convo.selecteduserid = objData.kuserid
//
//                convo.strTitle = strTitle
//                convo.username = objData.kusername
//                objData.kcountrycode = messageResponse["countrycode"]! as! String
//                objData.kphonenumber = messageResponse["phonenumber"]! as! String
//                convo.selectedUser = objData
//                APP_DELEGATE.appNavigation?.pushViewController(convo, animated: true)
//                let objData:StructChat = StructChat.init(dictionary:messageResponse)
//                if(objData.kreceiverid == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)) {
                   let dict = ["userid" : objData.ksenderid, "receiverid" : objData.kreceiverid, "chatid" : objData.kid]
                pushdictreceive = dict as NSDictionary
//                    if let isConnected = socketIOHandler?.isSocektConnected(){
//                        if isConnected == false {
//                        }
//                        else {
                          //  self.socketIOHandler?.socket?.emit("Update_ReceivedStatus",dict)
//                        }
//                    }
//                }
            }
        }
    }
    //MARK: Interactive Push Notification
    func manage_InteractivePushNotification() -> Void {
        let replyAction = UNTextInputNotificationAction( identifier: "ReplyToMessage1", title: "Reply on message", textInputButtonTitle: "Send", textInputPlaceholder: "Input message here")
        //rep
        let pushNotificationButtons = UNNotificationCategory(identifier: "ReplyToMessage", actions: [replyAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([pushNotificationButtons])
    }
    
    func sendResponseMess_InteractivePushNotification(response: UNNotificationResponse)
    {
        if let userInfo = response.notification.request.content.userInfo as? [String : AnyObject] {
            if userInfo.keys.contains("userResult") {
                let messageResponse = userInfo["userResult"] as! [String:Any]
                if messageResponse.keys.contains("groupid") {
                    if response.actionIdentifier == "ReplyToMessage1" {
                        if let textResponse = response as? UNTextInputNotificationResponse {
                            let sendText = textResponse.userText
                            let objGroupData:StructGroupChat = StructGroupChat.init(dictionary:messageResponse)
                            self.sendReponseMess_GroupChat(strMessage: sendText, objGroupData: objGroupData)
                        }
                    }
                }
                else if messageResponse.keys.contains("senderid")
                {
                    if response.actionIdentifier == "ReplyToMessage1" {
                        if let textResponse = response as? UNTextInputNotificationResponse {
                            let sendText = textResponse.userText
                            let objData:StructChat = StructChat.init(dictionary:messageResponse)
                            self.sendReponseMess_PersonalChat(strMessage: sendText, objData: objData)
                        }
                     }
                }
                else {
                    let aps = userInfo["aps"] as? NSDictionary
                    showMessage(aps?["alert"] as? String ?? "You have a new message")
                }
            }
            else {
                let aps = userInfo["aps"] as? NSDictionary
                showMessage(aps?["alert"] as? String ?? "You have a new message")
            }
        }
        else {
        }
    }
    
    func sendReponseMess_PersonalChat(strMessage:String, objData:StructChat) -> Void {
        if(objData.kreceiverid == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)) {
            let isConnected = socketIOHandler?.isSocektConnected()
            if isConnected == false {
                return
            }
            else {
            }
        }
        else {
            return
        }
        
        let textMessage = TRIM(string: strMessage)
        let dic = [
            "senderid":objData.kreceiverid,
            "receiverid":objData.ksenderid,
            "textmessage": textMessage.base64Encoded ?? "",
            "messagetype": "0",
            "mediaurl": "",
            "platform":PlatformName,
            "createddate": "",
            "isdeleted":"0",
            "isread":"0",
            "username" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
            "mutestatus" : CoreDBManager.sharedDatabase.amIMutedByUser(receiverId: objData.ksenderid) ? "1" : "0",
            "countrycode" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode).replacingOccurrences(of: "+", with: ""),
            "phonenumber" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)
            ]  as [String : Any]
        
        if isConnectedToNetwork() && (APP_DELEGATE.socketIOHandler?.isSocektConnected())! {
            APP_DELEGATE.socketIOHandler?.socket?.emitWithAck(keySendMessage,dic).timingOut(after: 30) { data in
                let data = data as Array
                
                if(data.count > 0) {
                    if data[0] is String { return }
                    let dicMsg = data[0] as! [String:Any]
                    let msg = StructChat.init(dictionary: dicMsg)
                }
            }
        }
        else {
        }
    }
    
    func sendReponseMess_GroupChat(strMessage:String, objGroupData:StructGroupChat) -> Void {
        let userID = UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)
        let members = objGroupData.receiverid.components(separatedBy: ",")
        if members.contains(userID) {
            let isConnected = socketIOHandler?.isSocektConnected()
            if isConnected == false {
                return
            }
            else {
            }
        }
        else {
            return
        }
        
        let objGroupInfo : StructGroupDetails = CoreDBManager.sharedDatabase.getGroupById(groupId: objGroupData.groupid)!
        let mutedIds = objGroupInfo.muted_by.components(separatedBy: ",")
        var allMembers = objGroupInfo.members.components(separatedBy: ",")
        for mutedId in mutedIds {
            let index = allMembers.index(of: mutedId)
            if let foundIndex = index { allMembers.remove(at: foundIndex) }
        }
        let filteredMembers = allMembers.joined(separator: ",")
        
        let textMessage = TRIM(string: strMessage)
        let dic = [
            "groupid":objGroupData.groupid,
            "senderid":objGroupData.receiverid,
            "group_members": objGroupData.receiverid,
            "textmessage": textMessage.base64Encoded ?? "",
            "messagetype": "0",
            "mediaurl": "",
            "platform":PlatformName,
            "createddate": DateFormater.getStringFromDate(givenDate: NSDate()),
            "isdeleted":"0",
            "isread":"0",
            "username" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
            "filtered_members" : filteredMembers,
            "countrycode" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode).replacingOccurrences(of: "+", with: ""),
            "phonenumber" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile),
            "parent_id" : "0",
            "groupname" : objGroupInfo.name,
            "groupicon" : objGroupInfo.icon
            ]  as [String : Any]
        
        if isConnectedToNetwork() && (APP_DELEGATE.socketIOHandler?.isSocektConnected())! {
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck(keySendGroupMessage,dic).timingOut(after: 30) { data in
            let data = data as Array
            if(data.count > 0) {
                if data[0] is String { return }
                let dicMsg = data[0] as! [String:Any]
                let msg = StructGroupChat.init(dictionary: dicMsg)
            }
        }
        }
    }
}

extension AppDelegate {
    //MARK: Custom Methods
    func setInitialVC() {
        if UserDefaultManager.getBooleanFromUserDefaults(key: kIsLoggedIn) == false {
            APP_DELEGATE.appNavigation = UINavigationController(rootViewController: loadVC(strStoryboardId: SB_MAIN, strVCId: idLoginVC))
        }
        else {
            //Sync Contact
            ContactSync.shared.performSync()
            
            if isDNDActive == false {
                socketIOHandler = SocketIOHandler()
            }
            APP_DELEGATE.appNavigation = UINavigationController(rootViewController: loadVC(strStoryboardId: SB_CHAT, strVCId: idChatListVC))
        }
        APP_DELEGATE.appNavigation?.isNavigationBarHidden = true
        APP_DELEGATE.window?.rootViewController = APP_DELEGATE.appNavigation
        APP_DELEGATE.window?.makeKeyAndVisible()
    }
    
    func cancelAllDownloadRequest() {
        arrRequests.forEach({ (request) in
            (request as! DownloadRequest).cancel()
        })
    }
}

extension AppDelegate :LocationServiceDelegate {
    //MARK:- Location Service delegate
    func tracingLocation(_ currentLocation: CLLocation) {
        self.currentLocation = currentLocation
        UserDefaultManager.setBooleanToUserDefaults(value: true, key: kAppKnowLocation)
        LocationService.sharedInstance.stopUpdatingLocation()
    }
    
    func tracingLocationDidFailWithError(_ error: NSError) {
        APP_DELEGATE.currentLocation = CLLocation.init(latitude: 0.0, longitude: 0.0)
        UserDefaultManager.setBooleanToUserDefaults(value: false, key: kAppKnowLocation)
        //print("tracingLocationDidFailWithError: \(error.description)")
    }
}

extension AppDelegate : PKPushRegistryDelegate {
    // MARK: PKPushRegistryDelegate
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        NSLog("pushRegistry:didUpdatePushCredentials:forType:")
        
        if (type != .voIP) {
            return
        }
        
        guard let accessToken = fetchAccessToken() else {
            return
        }
        
        let deviceToken = (credentials.token as NSData).description
        
        TwilioVoice.register(withAccessToken: accessToken, deviceToken: deviceToken) { (error) in
            if let error = error {
                NSLog("An error occurred while registering: \(error.localizedDescription)")
            }
            else {
                NSLog("Successfully registered for VoIP push notifications.")
            }
        }
        
        deviceTokenString = deviceToken
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        NSLog("pushRegistry:didInvalidatePushTokenForType:")
        
        if (type != .voIP) {
            return
        }
        
        guard let deviceToken = deviceTokenString, let accessToken = fetchAccessToken() else {
            return
        }
        
        TwilioVoice.unregister(withAccessToken: accessToken, deviceToken: deviceToken) { (error) in
            if let error = error {
                NSLog("An error occurred while unregistering: \(error.localizedDescription)")
            }
            else {
                NSLog("Successfully unregistered from VoIP push notifications.")
            }
        }
        
        deviceTokenString = nil
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        NSLog("pushRegistry:didReceiveIncomingPushWithPayload:forType:")
        print(payload)
        if (type == PKPushType.voIP) {
            TwilioVoice.handleNotification(payload.dictionaryPayload, delegate: self)
            
            pushKitPushReceivedWithPayload(payload: payload)
        }
    }
 
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        NSLog("pushRegistry:didReceiveIncomingPushWithPayload:forType:completion:")
        
        if (type == PKPushType.voIP) {
            TwilioVoice.handleNotification(payload.dictionaryPayload, delegate: self)
            
            pushKitPushReceivedWithPayload(payload: payload)
        }
        
        completion()
    }
    
    func pushKitPushReceivedWithPayload(payload: PKPushPayload){
        if UIApplication.shared.applicationState != .active{
            let msgType = payload.dictionaryPayload["twi_message_type"] as? String
            if let messageType = msgType{
                if messageType == "twilio.voice.call"{
                    fireLocalNotificationForVoiceCall(didStart: true)
                }else if messageType == "twilio.voice.cancel"{
                    fireLocalNotificationForVoiceCall(didStart: false)
                }
            }
        }
    }
}

extension AppDelegate : TVONotificationDelegate, TVOCallDelegate{
    // MARK: TVONotificaitonDelegate
    func callInviteReceived(_ callInvite: TVOCallInvite) {
        if (callInvite.state == .pending) {
            handleCallInviteReceived(callInvite)
        } else if (callInvite.state == .canceled) {
            handleCallInviteCanceled(callInvite)
        }
    }
    
    func handleCallInviteReceived(_ callInvite: TVOCallInvite) {
        NSLog("callInviteReceived:")
        
        if (self.callInvite != nil && self.callInvite?.state == .pending) {
            NSLog("Already a pending incoming call invite.");
            NSLog("  >> Ignoring call from %@", callInvite.from);
            return;
        } else if (self.call != nil) {
            NSLog("Already an active call.");
            NSLog("  >> Ignoring call from %@", callInvite.from);
            return;
        }
        
        self.callInvite = callInvite
        
        if callInvite.from.contains("__")
        {
            let nmval = callInvite.from.components(separatedBy: ":").last!
            if nmval.components(separatedBy: "__").count > 1
            {
                let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: (nmval.components(separatedBy: "__")[1]), phoneNo: (nmval.components(separatedBy: "__")[2]))
                print(objContactInfo)
                if objContactInfo.Name?.count != 0
                {
                    name = objContactInfo.Name!
                }
                else
                {
                    name = "+" + nmval.components(separatedBy: "__")[1] + " " + nmval.components(separatedBy: "__")[2]
                }
            }
            else
            {
                name = nmval.components(separatedBy: "__")[1]
            }
            let objUserInfo = CoreDBManager.sharedDatabase.get_UserInfo(userID: nmval.components(separatedBy: "__")[0])
            if objUserInfo != nil
            {
                userphoto = (objUserInfo?.kuserprofile)!
            }
            else
            {
                userphoto =  ""
            }
        }
        else
        {
            let nmval = callInvite.from.components(separatedBy: ":").last!
            name = nmval
            userphoto =  ""
        }
        //print("Server name :--->", name)
        let dictCall = [
            "image":"user_notification",
            "name":name,
            "status":"missed",
            "is_video_call":"0",
            "call_from":callInvite.from,
            "call_to":callInvite.to,
            "call_id":getUniquieNo(),
            "date":getCurrentTime(),
            ]  as [String : Any]
        
        storeCallLog(dictCall: dictCall)
        
        reportIncomingCall(from: name, uuid: callInvite.uuid)
    }
    
    func handleCallInviteCanceled(_ callInvite: TVOCallInvite) {
        NSLog("callInviteCanceled:")
        
        performEndCallAction(uuid: callInvite.uuid)
        
        self.callInvite = nil
    }
    
    func notificationError(_ error: Error) {
        NSLog("notificationError: \(error.localizedDescription)")
    }
    
    
    // MARK: TVOCallDelegate
    func callDidConnect(_ call: TVOCall) {
        NSLog("callDidConnect:")
        
        self.call = call
        self.callKitCompletionCallback!(true)
        self.callKitCompletionCallback = nil
        
        postNotification(with: NC_CallDidConnect)
    }
    
    func call(_ call: TVOCall, didFailToConnectWithError error: Error) {
        NSLog("Call failed to connect: \(error.localizedDescription)")
        
        if let completion = self.callKitCompletionCallback {
            completion(false)
        }
        
        performEndCallAction(uuid: call.uuid)
        callDisconnected()
    }
    
    func call(_ call: TVOCall, didDisconnectWithError error: Error?) {
        if let error = error {
            NSLog("Call failed: \(error.localizedDescription)")
        } else {
            NSLog("Call disconnected")
        }
        
        performEndCallAction(uuid: call.uuid)
        callDisconnected()
    }
    
    func callDisconnected() {
        self.call = nil
        self.callKitCompletionCallback = nil
        postNotification(with: NC_CallDidDisConnect)
    }
}

extension AppDelegate : CXProviderDelegate{
    // MARK: CXProviderDelegate
    func providerDidReset(_ provider: CXProvider) {
        NSLog("providerDidReset:")
        TwilioVoice.isAudioEnabled = true
    }
    
    func providerDidBegin(_ provider: CXProvider) {
        NSLog("providerDidBegin")
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        NSLog("provider:didActivateAudioSession:")
        TwilioVoice.isAudioEnabled = true
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        NSLog("provider:didDeactivateAudioSession:")
        TwilioVoice.isAudioEnabled = false
    }
    
    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        NSLog("provider:timedOutPerformingAction:")
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        NSLog("provider:performStartCallAction:")
        
        postNotification(with: NC_StartCallAction)
        
        TwilioVoice.configureAudioSession()
        TwilioVoice.isAudioEnabled = false
        
        provider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: Date())
        
        self.performVoiceCall(uuid: action.callUUID, client: "") { (success) in
            if (success) {
                provider.reportOutgoingCall(with: action.callUUID, connectedAt: Date())
                action.fulfill()
            } else {
                action.fail()
            }
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        NSLog("provider:performAnswerCallAction:")
        
        let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: idVoiceCallVC) as! VoiceCallVC
        vc.callername = name //(objLastCall?.call_from)!
        vc.userPhoto = userphoto
        vc.redirectfrom = "Appdelegate"
        APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
        assert(action.callUUID == self.callInvite?.uuid)
        
        TwilioVoice.isAudioEnabled = false
        self.performAnswerVoiceCall(uuid: action.callUUID) { (success) in
            if (success)
            {
                action.fulfill()
               
            }
            else
            {
                action.fail()
            }
        }
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        NSLog("provider:performEndCallAction:")
        
        if (self.callInvite != nil && self.callInvite?.state == .pending) {
            self.callInvite?.reject()
            self.callInvite = nil
        } else if (self.call != nil) {
            self.call?.disconnect()
        }
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        NSLog("provider:performSetHeldAction:")
        if (self.call?.state == .connected) {
            self.call?.isOnHold = action.isOnHold
            action.fulfill()
        } else {
            action.fail()
        }
    }
}

extension AppDelegate {
    // MARK: Call Kit Actions
    func performStartCallAction(uuid: UUID, handle: String) {
        let callHandle = CXHandle(type: .generic, value: handle)
        let startCallAction = CXStartCallAction(call: uuid, handle: callHandle)
        let transaction = CXTransaction(action: startCallAction)
        
        callKitCallController.request(transaction)  { error in
            if let error = error {
                NSLog("StartCallAction transaction request failed: \(error.localizedDescription)")
                return
            }
            
            NSLog("StartCallAction transaction request successful")
            
            let callUpdate = CXCallUpdate()
            callUpdate.remoteHandle = callHandle
            callUpdate.supportsDTMF = true
            callUpdate.supportsHolding = true
            callUpdate.supportsGrouping = false
            callUpdate.supportsUngrouping = false
            callUpdate.hasVideo = false
            
            self.callKitProvider.reportCall(with: uuid, updated: callUpdate)
        }
    }
    
    func reportIncomingCall(from: String, uuid: UUID) {
        let callHandle = CXHandle(type: .generic, value: from)
        
        let callUpdate = CXCallUpdate()
        callUpdate.remoteHandle = callHandle
        callUpdate.supportsDTMF = true
        callUpdate.supportsHolding = true
        callUpdate.supportsGrouping = false
        callUpdate.supportsUngrouping = false
        callUpdate.hasVideo = false
        callUpdate.localizedCallerName = from
        
        callKitProvider.reportNewIncomingCall(with: uuid, update: callUpdate) { error in
            if let error = error {
                NSLog("Failed to report incoming call successfully: \(error.localizedDescription).")
                return
            }
            
            NSLog("Incoming call successfully reported.")
            
            // RCP: Workaround per https://forums.developer.apple.com/message/169511
            TwilioVoice.configureAudioSession()
        }
    }
    
    func performEndCallAction(uuid: UUID) {
        
        let endCallAction = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: endCallAction)
        
        callKitCallController.request(transaction) { error in
            if let error = error {
                NSLog("EndCallAction transaction request failed: \(error.localizedDescription).")
                return
            }
            
            NSLog("EndCallAction transaction request successful")
        }
    }
    
    func performVoiceCall(uuid: UUID, client: String?, completionHandler: @escaping (Bool) -> Swift.Void) {
        guard let accessToken = fetchAccessToken() else {
            completionHandler(false)
            return
        }
        
        let fromname = UserDefaultManager.getStringFromUserDefaults(key: kAppUserId) + "__" + UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode) + "__" + UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)
        
            //UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName).replacingOccurrences(of: " ", with: "_")
        
        call = TwilioVoice.call(accessToken, params: [twimlParamTo : outgoingName!, twimlParamFrom : fromname], uuid:uuid, delegate: self)
        self.callKitCompletionCallback = completionHandler
    }
    
    func performAnswerVoiceCall(uuid: UUID, completionHandler: @escaping (Bool) -> Swift.Void) {
        
        if let strId = UserDefaults.standard.object(forKey: "uniqueid") as? String {
            let objLastCall = CoreDBManager.sharedDatabase.getHistoryId(callId: strId)
            let dictCall = [
                "image":"user_notification",
                "name":objLastCall?.name ?? "",
                "status":"incoming",
                "is_video_call":"0",
                "call_from":objLastCall?.call_from ?? "",
                "call_to":objLastCall?.call_to ?? "",
                "call_id":strId,
                "date":objLastCall?.date ?? "",
                ]  as [String : Any]
            storeCallLog(dictCall: dictCall)
        }
        
        call = self.callInvite?.accept(with: self)
        self.callInvite = nil
        self.callKitCompletionCallback = completionHandler
        
    }
}

extension AppDelegate{
    
    //MARK: Custom Function
    //MARK: Block Contact
    func get_BlockContactList() -> NSArray {
        let strBlockUser : String = UserDefaultManager.getStringFromUserDefaults(key: kBlockContact)
        let arrBlockUser : NSArray = strBlockUser.components(separatedBy: ",") as NSArray
        
        let arrMutBlockUser : NSMutableArray = arrBlockUser.mutableCopy() as! NSMutableArray
        arrMutBlockUser.remove("") //Remove Empty OR null object
        
        return arrMutBlockUser.mutableCopy() as! NSArray
    }
    
    func User_Exists_inBlockContactList(strUserID : String) -> Bool {
        if (strUserID.count == 0) { return false }
        
        let arrBlockUser : NSMutableArray = self.get_BlockContactList().mutableCopy() as! NSMutableArray
        let status_Exists : Bool = arrBlockUser.contains(strUserID) ? true : false
        return status_Exists
    }
    
    func AddUser_BlockContactList(strUserID : String) -> Void {
        if (strUserID.count == 0) { return }
        
        let arrBlockUser : NSMutableArray = self.get_BlockContactList().mutableCopy() as! NSMutableArray
        arrBlockUser.add(strUserID)
        
        let strBlockUser : String = arrBlockUser.componentsJoined(by: ",")
        UserDefaultManager.setStringToUserDefaults(value: strBlockUser, key: kBlockContact)
    }
    
    func RemoveUser_BlockContactList(strUserID : String) -> Void {
        if (strUserID.count == 0) { return }
        
        let arrBlockUser : NSMutableArray = self.get_BlockContactList().mutableCopy() as! NSMutableArray
        arrBlockUser.remove(strUserID)
        
        let strBlockUser : String = arrBlockUser.componentsJoined(by: ",")
        UserDefaultManager.setStringToUserDefaults(value: strBlockUser, key: kBlockContact)
    }
    //PV
    //MARK: Hidden chat-Personal
    func get_HiddenChat_UserList() -> NSArray {
        let strHiddenChat_UserList : String = UserDefaultManager.getStringFromUserDefaults(key: kHiddenChatUserList)
        let arrHiddenChat_UserList : NSArray = strHiddenChat_UserList.components(separatedBy: ",") as NSArray
        
        let arrMutHiddenChat_UserList : NSMutableArray = arrHiddenChat_UserList.mutableCopy() as! NSMutableArray
        arrMutHiddenChat_UserList.remove("") //Remove Empty OR null object
        
        return arrMutHiddenChat_UserList.mutableCopy() as! NSArray
    }
    
    func User_Exists_inHiddenChat_UserList(strUserID : String) -> Bool {
        if (strUserID.count == 0) { return false }
        let arrUser : NSMutableArray = self.get_HiddenChat_UserList().mutableCopy() as! NSMutableArray
        let status_Exists : Bool = arrUser.contains(strUserID) ? true : false
        return status_Exists
    }
    
    func AddUser_HiddenChat_UserList(strUserID : String) -> Void {
        if (strUserID.count == 0) { return }
        
        let arrUser : NSMutableArray = self.get_HiddenChat_UserList().mutableCopy() as! NSMutableArray
        arrUser.add(strUserID)
        
        let strUser : String = arrUser.componentsJoined(by: ",")
        UserDefaultManager.setStringToUserDefaults(value: strUser, key: kHiddenChatUserList)
    }
    func RemoveUser_HiddenChat_UserList(strUserID : String) -> Void {
        if (strUserID.count == 0) { return }
        
        let arrList : NSMutableArray = self.get_HiddenChat_UserList().mutableCopy() as! NSMutableArray
        arrList.remove(strUserID)
        
        let strList : String = arrList.componentsJoined(by: ",")
        UserDefaultManager.setStringToUserDefaults(value: strList, key: kBlockContact)
    }
    //PV
    //MARK: Hidden chat-Group
    func get_HiddenGroupChat_List() -> NSArray {
        let strList : String = UserDefaultManager.getStringFromUserDefaults(key: kHiddenGroupChatList)
        let arrList : NSArray = strList.components(separatedBy: ",") as NSArray
        
        let arrMutList : NSMutableArray = arrList.mutableCopy() as! NSMutableArray
        arrMutList.remove("") //Remove Empty OR null object
        
        return arrMutList.mutableCopy() as! NSArray
    }
    func Group_Exists_inHiddenGroupChat_List(strGroupID : String) -> Bool {
        if (strGroupID.count == 0) { return false }
        let arrList : NSMutableArray = self.get_HiddenGroupChat_List().mutableCopy() as! NSMutableArray
        let status_Exists : Bool = arrList.contains(strGroupID) ? true : false
        return status_Exists
    }
    func AddGroup_HiddenGroupChat_List(strGroupID : String) -> Void {
        if (strGroupID.count == 0) { return }
        
        let arrList : NSMutableArray = self.get_HiddenGroupChat_List().mutableCopy() as! NSMutableArray
        arrList.add(strGroupID)
        
        let strList : String = arrList.componentsJoined(by: ",")
        UserDefaultManager.setStringToUserDefaults(value: strList, key: kHiddenGroupChatList)
    }
    func RemoveGroup_HiddenGroupChat_UserList(strGroupID : String) -> Void {
        if (strGroupID.count == 0) { return }
        
        let arrList : NSMutableArray = self.get_HiddenGroupChat_List().mutableCopy() as! NSMutableArray
        arrList.remove(strGroupID)
        
        let strList : String = arrList.componentsJoined(by: ",")
        UserDefaultManager.setStringToUserDefaults(value: strList, key: kHiddenGroupChatList)
    }
    
    //MARK: API
    func api_UpdateUserSettings(parameter : NSDictionary) {
        //self.view.endEditing(true)
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIUpdateUserSettings, parameters: parameter, keyname: "", message: "", showLoader: false, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            hideLoaderHUD() //Hide Loader
            hideMessage() //Hide Show Message Popup
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_UpdateUserSettings(parameter: parameter)
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    //let strMessage: String = responseDict!.object(forKey: kMessage) as! String
                    //showMessage(strMessage)
                    //print("Message: \(strMessage)")
                    //Get Update Privacy base manage called Socket
                    let strUpdateSetting : String = UserDefaultManager.getStringFromUserDefaults(key: "UpdateUserSettings")
                    let dicData = [parameter.value(forKey: "request")!]
                    
                    if (strUpdateSetting.uppercased() == "lastseen_privacy".uppercased()) {
                        APP_DELEGATE.socketIOHandler?.socket?.emit(keyEditPrivacy, with: dicData)
                    }
                    else if (strUpdateSetting.uppercased() == "photo_privacy".uppercased()) {
                        APP_DELEGATE.socketIOHandler?.socket?.emit(keyEditPrivacy, with: dicData)
                    }
                    else if (strUpdateSetting.uppercased() == "about_privacy".uppercased()) {
                        APP_DELEGATE.socketIOHandler?.socket?.emit(keyEditPrivacy, with: dicData)
                    }
                    else if (strUpdateSetting.uppercased() == "status_privacy".uppercased()) {
                      APP_DELEGATE.socketIOHandler?.socket?.emit(keyPrivacyChange_Status, with: dicData)
                    }
                    else if (strUpdateSetting.uppercased() == "read_receipts_privacy".uppercased()) {
                        APP_DELEGATE.socketIOHandler?.socket?.emit(keyEditPrivacy, with: dicData)
                    }
                    
                    //Reset UserDefault
                    UserDefaultManager.setStringToUserDefaults(value: "", key: "UpdateUserSettings")
                    //<-----------
                }
            }
        })
    }
    
    func api_SpamReport(parameter : NSDictionary, successMess : String) {
        
        if isConnectedToNetwork() == false { return }
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIReportSpam, parameters: parameter, keyname: "", message: "Processing...", showLoader: true, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            hideLoaderHUD() //Hide Loader
            hideMessage() //Hide Show Message Popup
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_SpamReport(parameter: parameter, successMess: successMess)
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    
                    var strMessage: String = ""
                    if (successMess.count == 0) { strMessage = responseDict!.object(forKey: kMessage) as! String}
                    else { strMessage = successMess }
                    showMessage(strMessage)
                    
                    //print("Message: \(strMessage)")
                }
            }
        })
    }
}

extension UIApplication {
    var statusBarView: UIView? {
        if responds(to: Selector(("statusBar"))) {
            return value(forKey: "statusBar") as? UIView
        }
        return nil
    }
}

extension AppDelegate {
    func clearBadgeCount(){
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    func clearDeliveredNotifications(){
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}

extension AppDelegate {
    func storeCallLog(dictCall: [String : Any]) {
        let obj = StructCallHistory.init(dictionary: dictCall)
        _ = CoreDBManager.sharedDatabase.saveCallHistoryInLocalDB(objcall: obj)
    }
    
    func getUniquieNo() -> String {
        if let strId = UserDefaults.standard.object(forKey: "uniqueid") as? String {
            let oldID = strId
            let newID = "\(Int(oldID)! + 1)"
            UserDefaults.standard.set(newID, forKey: "uniqueid")
            UserDefaults.standard.synchronize()
            return newID
        } else {
            UserDefaults.standard.set("1", forKey: "uniqueid")
            UserDefaults.standard.synchronize()
            return "1"
        }
    }
    
    func getCurrentTime() -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}
