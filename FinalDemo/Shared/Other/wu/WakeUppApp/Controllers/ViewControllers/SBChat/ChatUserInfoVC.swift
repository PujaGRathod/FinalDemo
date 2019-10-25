//
//  ChatUserInfoVC.swift
//  WakeUppApp
//
//  Created by C025 on 05/07/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import SDWebImage
import MediaBrowser

class ChatUserInfoVC: UIViewController {
    
    // MARK: - Outlet
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var viewUserProfilePhoto: UIView!
    @IBOutlet weak var lc_viewUserProfilePhoto_height: NSLayoutConstraint!
    @IBOutlet weak var imgUserProfilePhoto: UIImageView!
    @IBOutlet weak var lc_btnUserProfilePhoto_height: NSLayoutConstraint!
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblUserPhoneNo: UILabel!
    @IBOutlet weak var btnChat: UIButton!
    @IBOutlet weak var imgswitch: UIImageView!
    @IBOutlet weak var lblUserBio: UILabel!
    @IBOutlet weak var lblNoOfMediaContent: UILabel!
    @IBOutlet weak var lblGroupsInCommon: UILabel!
    
    @IBOutlet weak var viewBio: UIView!
    @IBOutlet weak var lc_viewBio_Height: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var viewMain_Content: UIView!
    @IBOutlet weak var viewManangeChat: UIView!
    //@IBOutlet weak var lc_viewManangeChat_height : NSLayoutConstraint!
    @IBOutlet weak var btnBlock: UIButton!
    
    // MARK: - Variable
    var strTitle : String = "" //Show title of titlebar
    var strUserID : String = ""
    var strPhotoURL : String = ""
    var strUserName : String = ""
    var strCountryCodeOfPhoneNo : String = "" // Get Particuler Contact No CountryCode
    var strUserPhoneNo : String = ""
    var strUserBio : String = ""
    
    var flag_showChatButton : Bool = false //For help for chat button of not, If user show profile in group profile scren, to show this button , otherwise default hide Chat button.
    
    //Manage ViewManageChat  Hide/Show time viewMain height manage.
    var height_UserBlockStatus_true : CGFloat = 0.0
    var height_UserBlockStatus_false : CGFloat = 0.0
    
    var photoBrowser:ChatAttachmentBrowser!
    var URL_CurrentDir : URL?
    
    var ismute : Bool = false //Manage Mute button status manage.
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*//Update Height of viewMain
        var frame_MainView : CGRect
        frame_MainView = self.viewMain.frame
        frame_MainView = CGRect(x: 0, y: 0, width: self.viewMain.width, height: frame_MainView.height)
        self.viewMain.frame = frame_MainView*/
        
        height_UserBlockStatus_true = self.viewMain.frame.height - self.viewManangeChat.frame.height
        height_UserBlockStatus_false = self.viewMain.frame.height
        
        //Fill Value if get UserID
        if (Int(self.strUserID) != 0) { self.fillValues() }
        self.set_NotificationObserver()
        
        //Manage hide-Show chat button
        self.btnChat.isHidden = self.flag_showChatButton == true ? false : true
        
        ismute = isMutedChat(userId:strUserID) ? true : false
        if ismute == true { imgswitch.image =  #imageLiteral(resourceName: "switch_on") }
        else { imgswitch.image =  #imageLiteral(resourceName: "switch_off") }
        
        //self.chatInfo = chatData.fetchChatData()
        
        //self.view.layoutIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Other function
    func fillValues() -> Void {
        //Title
        self.lblTitle.text = "\(self.strTitle.count == 0 ? "" : self.strTitle) info"
        
        //Profile Photo
        imgUserProfilePhoto.image = #imageLiteral(resourceName: "profile_pic_register")
        if (Privacy_ProfilePhoto_Show(userID: self.strUserID) == true) {
            let strFullPhotoURL : String = "\(Get_Profile_Pic_URL)\(self.strPhotoURL)"
            imgUserProfilePhoto.sd_setImage(with: strFullPhotoURL.url, placeholderImage: #imageLiteral(resourceName: "profile_pic_register.png"), options: [], completed: nil)
        }
        else { imgUserProfilePhoto.image = #imageLiteral(resourceName: "profile_pic_register.png") }
        
        let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: self.strCountryCodeOfPhoneNo, phoneNo: self.strUserPhoneNo)
        if objContactInfo.Name?.count == 0 {
            //User Name
            self.lblUserName.text = "+\(self.strCountryCodeOfPhoneNo) \(self.strUserPhoneNo)"
            
            //Phone No
            self.lblUserPhoneNo.text = self.strUserName
        }
        else {
            strUserName = objContactInfo.Name!
            //User Name
            self.lblUserName.text = objContactInfo.Name!
            
            //Phone No
            self.lblUserPhoneNo.text = "+\(objContactInfo.CountryCode ?? "") \(objContactInfo.PhoneNo ?? "")"
        }
        
        //Bio
        //self.lblUserBio.text = self.strUserBio.count == 0 ? "*** No bio ***" : self.strUserBio //PV
        if About_LastSeen_Show(userID: self.strUserID) == true {
            self.lblUserBio.text = self.strUserBio.count == 0 ? "*** No bio ***" : self.strUserBio
            self.lc_viewBio_Height.constant = 110
            self.viewBio.isHidden = false
        }
        else {
            self.lblUserBio.text = ""
            self.lc_viewBio_Height.constant = 0
            self.viewBio.isHidden = true
        }
        
        //No. Of Media Content
        self.lblNoOfMediaContent.text = "\(self.getData_NoOfMediaContent().count)"
        //self.lblNoOfMediaContent.text = ""
        
        lblGroupsInCommon.text = "\(CoreDBManager.sharedDatabase.getCommonGroupsListWithUserID(userId: strUserID).count)"
        
        //Manage hide-Show chat button
        self.btnChat.isHidden = self.flag_showChatButton == true ? false : true
        
        //------------------------------------------>
        //Manage Block Statis base viewMain Height and other content
        //let frame_MainView : CGRect
        if (APP_DELEGATE.User_Exists_inBlockContactList(strUserID: self.strUserID) == true) {
            //Manage ChatView Hide
            //self.lc_viewManangeChat_height.constant = 0
            //self.viewManangeChat.isHidden = true
            
            //Set viewMain Height
            //frame_MainView = CGRect(x: 0, y: 0, width: self.viewMain.width, height: height_UserBlockStatus_true)
            
            //Block Contact Title
            self.btnBlock.setTitle("Unblock Contact".localizedCapitalized, for: .normal)
        }
        else {
            //Manage ChatView Show
            //self.lc_viewManangeChat_height.constant = self.viewManangeChat.height
            //self.viewManangeChat.isHidden = false
            
            //Set viewMain Height
            //frame_MainView = CGRect(x: 0, y: 0, width: self.viewMain.width, height: height_UserBlockStatus_false)
            
            //Block Contact Title
            self.btnBlock.setTitle("Block Contact".localizedCapitalized, for: .normal)
        }
        //Update Height of viewMain
        //self.viewMain.frame = frame_MainView
        
        runAfterTime(time: 0.15) {
            UIView.animate(withDuration: 0.30, animations: {
                self.tableView.layoutIfNeeded()
                self.view.layoutIfNeeded()
                
                self.tableView.reloadData()
            })
        }
        
        runAfterTime(time: 0.10) {
            var frame_MainView : CGRect
            frame_MainView = CGRect(x: 0, y: 0, width: self.viewMain.width, height: self.viewMain.frame.height - self.lc_btnUserProfilePhoto_height.constant)
            
            self.lc_viewUserProfilePhoto_height.constant = self.view.bounds.width
            self.lc_btnUserProfilePhoto_height.constant = self.lc_viewUserProfilePhoto_height.constant
            
            if self.viewBio.isHidden == true {
                frame_MainView = CGRect(x: 0, y: 0, width: self.viewMain.width, height: (self.lc_btnUserProfilePhoto_height.constant + self.viewMain_Content.frame.height) - 110) // 110 == self.viewBio.frame.height
            }
            else {
                frame_MainView = CGRect(x: 0, y: 0, width: self.viewMain.width, height: self.lc_btnUserProfilePhoto_height.constant + self.viewMain_Content.frame.height)
            }
            
            //Update Height of viewMain
            self.viewMain.frame = frame_MainView
            
            self.tableView.layoutIfNeeded()
            self.view.layoutIfNeeded()
         }
    }
    
    func getData_NoOfMediaContent() -> [URL] {
        let URL_dirCurrentGroupChat : URL = getURL_ChatWithUser_Directory(countryCode: strCountryCodeOfPhoneNo, PhoneNo: strUserPhoneNo)
        let totalContent = getAllContent(inDirectoryURL: URL_dirCurrentGroupChat)
        
        var arrMediaURLs : [URL] = []
        for localURL in totalContent {
            if isPathForImage(path: localURL.absoluteString){ arrMediaURLs.append(localURL) }
            else if isPathForVideo(path: localURL.absoluteString){ arrMediaURLs.append(localURL) }
        }
        return arrMediaURLs
    }
    
    //MARK:- NotificationObserver
    func set_NotificationObserver() {
        
        //Privacy Change Manage
        NotificationCenter.default.addObserver(self, selector: #selector(privacyChange_RefreshList(notification:)), name: NSNotification.Name(NC_PrivacyChange_Refresh_ChatUserInfoVC), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(privacyChange_RefreshList(notification:)), name: NSNotification.Name(NC_PrivacyChange_About_Refresh_ChatUserInfoVC), object: nil)
    }
    //MARK: NotificationObserver Method
    @objc func privacyChange_RefreshList(notification : NSNotification) {
        if (notification.name.rawValue == NC_PrivacyChange_Refresh_ChatUserInfoVC) {
            self.fillValues()
        }
        else if (notification.name.rawValue == NC_PrivacyChange_About_Refresh_ChatUserInfoVC) {
            /*if About_LastSeen_Show(userID: self.strUserID) == true {
                self.lblUserBio.text = self.strUserBio.count == 0 ? "*** No bio ***" : self.strUserBio
            }
            else { self.lblUserBio.text = "" }*/
            self.fillValues()
        }
    }
    
    // MARK: - Button action Method
    @IBAction func btnBackClicked(_ sender: Any) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnMoreClicked(_ sender: Any) {
        /*let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
         
         let actionMedia = UIAlertAction.init(title: "Media", style: .default) { (action) in
         self.title = "   "
         self.photoBrowser = ChatAttachmentBrowser.init(userID: self.strUserID)
         self.photoBrowser.openBrowser()
         }
         alert.addAction(actionMedia)
         
         let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
         alert.addAction(actionCancel)
         
         present(alert, animated: true, completion: nil)*/
        
    }
    
    @IBAction func btnProfilePhotoClicked(_ sender: Any) {
        let configuration = ImageViewerConfiguration { config in
            config.imageView = self.imgUserProfilePhoto
        }
        let imageViewerController = ImageViewerController(configuration: configuration)
        present(imageViewerController, animated: true)
    }
    
    @IBAction func btnChatAction(_ sender: Any) {
        if (self.strUserID.count == 0) { return }
        
        let selectedUserInfo:StructChat = StructChat.init(dictionary: ["id":"1",
                                                                       "username":self.strUserName as Any,
                                                                       "user_id":self.strUserID as Any,
                                                                       "country_code":self.strCountryCodeOfPhoneNo as Any,
                                                                       "phoneno":self.strUserPhoneNo as Any,
                                                                       "image":self.strPhotoURL as Any])
        
        let convo = loadVC(strStoryboardId: SB_CHAT, strVCId:idChatVC ) as! ChatVC
        convo.calledfrom = "messages"
        convo.selecteduserid = self.strUserID
        convo.strTitle = strUserName
        convo.username = self.strUserName
        convo.selectedUser = selectedUserInfo
        APP_DELEGATE.appNavigation?.pushViewController(convo, animated: true)
    }
    
    @IBAction func switchclicked(_ sender: UIButton)
    {
        let currentlyMutedUsers = UserDefaultManager.getStringFromUserDefaults(key: kMutedByMe)
        var arrMutedUserIds = currentlyMutedUsers.components(separatedBy: ",") as? NSMutableArray
        if arrMutedUserIds == nil{
            arrMutedUserIds = NSMutableArray()
        }
        if (arrMutedUserIds?.contains(""))!{ arrMutedUserIds?.remove("") }
        if ismute == false {
            imgswitch.image =  #imageLiteral(resourceName: "switch_on")
            ismute = true
            arrMutedUserIds?.add(strUserID)
        }
        else {
            imgswitch.image =  #imageLiteral(resourceName: "switch_off")
            ismute = false
            arrMutedUserIds?.remove(strUserID)
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
    
    @IBAction func btnNoOfMediaContentAction(_ sender: Any) {
        
        let URL_dirCurrentChat : URL = getURL_ChatWithUser_Directory(countryCode: strCountryCodeOfPhoneNo, PhoneNo: strUserPhoneNo)
        let arrMediaURLInLocalDir = getAllContent(inDirectoryURL: URL_dirCurrentChat)
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
        //<-----
        
        //------------->
        //Docs -> Get and set Doc real name
        var arrDocument : [objDocumentInfo] = []
        for objURL in arrDocsURLs {
            let docsURL : URL = objURL.url!
        
            let objData = CoreDBManager.sharedDatabase.getDocumentForUser(userId: strUserID, filename: docsURL.lastPathComponent)
            var strDocName : String = objData.kchatmessage.base64Decoded ?? ""
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
                self.photoBrowser = ChatAttachmentBrowser.init(userID: self.strUserID, currentLocalDir: URL_dirCurrentChat)
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
                
                objVC.URL_CurrentDir = URL_dirCurrentChat
                APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
            })
            action.addAction(action_Docs)
        //}
        
        //Link --------------->
        let arrMsgs = CoreDBManager.sharedDatabase.getChatMessagesForUserID(userId: self.strUserID, includeDeleted: false)
        for obj in arrMsgs {
            if obj.kmessagetype == "4" { arrLinkURLs.append(obj.kmediaurl) }
        }
        //if (arrLinkURLs.count != 0) {
            let action_Links = UIAlertAction.init(title: "Links", style: .default, handler: { (action) in
                let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId: "ChatAttachMediaVC") as! ChatAttachMediaVC
                objVC.objEnumAttachMedia = .Links
                
                let objLinksInfo = LinksInfo.init(arrLinks: arrLinkURLs)
                objVC.objLinksInfo = objLinksInfo
                
                objVC.URL_CurrentDir = URL_dirCurrentChat
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
    
    @IBAction func btnCommonGroupsAction(_ sender: Any) {
        if (self.lblGroupsInCommon.text == "0" || self.lblGroupsInCommon.text == "00") { return }
        
        let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: "CommonGroupsVC") as! CommonGroupsVC
        vc.selectedUserID = strUserID
        APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnChatHistoryAction(_ sender: Any) {
        let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: "ChatHistoryVC") as! ChatHistoryVC
        vc.strUserID = strUserID
        vc.strTitle = strTitle
        vc.strCountryCodeOfPhoneNo = strCountryCodeOfPhoneNo
        vc.strUserPhoneNo = strUserPhoneNo
        vc.strProfilePhotoURL = "\(Get_Profile_Pic_URL)\(self.strPhotoURL)"
        APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnShareAction(_ sender: Any) {
        if (self.strUserID.count == 0) { return }
        
        var mess = "\(APPNAME) \n\nStart Chat me with \(APPNAME) app\n"
        mess += self.lblUserName.text! + "\n"
        mess += self.lblUserPhoneNo.text! + "\n"
        mess += self.lblUserBio.text!
        
        share(shareContent: [mess])
    }
    
    @IBAction func btnBlockAction(_ sender: Any) {
        if (self.strUserID.count == 0) { return }
        
        var strAlertTitle : String = ""
        var strMess : String = ""
        var strUserBlockStatus : String = "block"
        
        if (APP_DELEGATE.User_Exists_inBlockContactList(strUserID: self.strUserID) == false) {
            strAlertTitle = "Block \(self.strTitle)?"
            strMess = "Blocked contacts will no longer be able to call you or send messages."
        }
        else {
            strAlertTitle = "Unblock \(self.strTitle)?"
            strMess = "Are you sure you have unblock \(self.strTitle)"
            strUserBlockStatus = "unblock"
        }
        
        let confirmAlert = UIAlertController.init(title: strAlertTitle , message: strMess, preferredStyle: .actionSheet)
        let action_yes = UIAlertAction.init(title: strUserBlockStatus.localizedCapitalized, style: .destructive) { (action) in
            
            if (strUserBlockStatus.uppercased() == "block".uppercased()) {
                APP_DELEGATE.AddUser_BlockContactList(strUserID: self.strUserID)
                //self.viewManangeChat.isHidden = true
            }
            else {
                APP_DELEGATE.RemoveUser_BlockContactList(strUserID: self.strUserID)
                //self.viewManangeChat.isHidden = false
            }
            
            //Set parameter for Called WebService
            let parameter:NSDictionary = ["service":APIBlockUser,
                                          "request":["block_user_id":self.strUserID, "action":strUserBlockStatus],
                                          "auth" : getAuthForService()]
            self.api_BlockUser(parameter: parameter, loaderMess: "") //PV
        }
        confirmAlert.addAction(action_yes)
        
        let action_no = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        confirmAlert.addAction(action_no)
        
        present(confirmAlert, animated: true, completion: nil)
    }
    
    
    @IBAction func btnReportSpamAction(_ sender: Any) {
        if (self.strUserID.count == 0) { return }
        
        let confirm = UIAlertController.init(title: "Report spam and block this contacts?", message: "If you report and block, this chat's history will also be deleted.", preferredStyle: .actionSheet)
        
        let action_yes = UIAlertAction.init(title: "Report and block", style: .destructive) { (action) in
            
            //Block Contact
            APP_DELEGATE.AddUser_BlockContactList(strUserID: self.strUserID)
            let parameter_blockUser:NSDictionary = ["service":APIBlockUser,
                                                    "request":["block_user_id":self.strUserID, "action":"block"],
                                                    "auth" : getAuthForService()]
            self.api_BlockUser(parameter: parameter_blockUser, loaderMess: "")
            
            //Clear Chat mess.
            CoreDBManager.sharedDatabase.deleteAllChatMessagesWith(userId: self.strUserID)
            
            //Report Spam
            let parameter_spam:NSDictionary = ["service":APIReportSpam,
                                               "request":["spam_id":self.strUserID, "action":"user"],
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
        
        present(confirm, animated: true, completion: nil)
    }
    
    //MARK:- API
    func api_BlockUser(parameter : NSDictionary, loaderMess: String) {
        self.view.endEditing(true)
        if isConnectedToNetwork() == false { return }
        
        //PU //Date: 02-08-2018 03:44 pm
        //if (loaderMess.count != 0){ showHUD() }
        showHUD()
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIBlockUser, parameters: parameter, keyname: "", message: loaderMess, showLoader: true, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            hideLoaderHUD() // Hide Loader
            hideHUD()
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_BlockUser(parameter: parameter, loaderMess: loaderMess)
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    self.fillValues()
                    
                    //PV
                    //Show Success message
                    var strMessage: String = ""
                    if (loaderMess.count == 0) { strMessage = responseDict!.object(forKey: kMessage) as! String }
                    //else {  strMessage = "User \(self.strTitle) unblocked successfully."  } //PV
                    showMessage(strMessage)
                    
                    //Called Socket API
                    let dicData : [String : String] = parameter["request"] as! [String : String]
                    let strUserID : String = UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)
                    let strBlockUserID : String = dicData["block_user_id"]!
                    var strIsBlock : String = dicData["action"]!
                    //strIsBlock = strIsBlock == "block" ? "1" : "0"
                    
                    var objUserInfo : StructChat = CoreDBManager.sharedDatabase.getFriendById(userID: strBlockUserID)!
                    runAfterTime(time: 0.30, block: {
                        if objUserInfo == nil { return }
                        
                        var dicSend : [String : String] = [:]
                        if strIsBlock == "block" {
                            objUserInfo.lastseen_privacy = "0"
                            objUserInfo.photo_privacy = "0"
                            objUserInfo.about_privacy = "0"
                            objUserInfo.read_receipts_privacy = "0"
                            objUserInfo.status_privacy = "0"
                            
                            dicSend = ["userid":strUserID,
                                       "blockid":strBlockUserID,
                                       "isblock":strIsBlock,
                                       "lastseen_privacy" : "0",
                                       "photo_privacy" : "0",
                                       "about_privacy" : "0",
                                       "read_receipts_privacy" : "0",
                                       "status_privacy" : "0"]
                        }
                        else {
                            dicSend = ["userid":strUserID,
                                       "blockid":strBlockUserID,
                                       "isblock":strIsBlock,
                                       /*"lastseen_privacy" : objUserInfo.lastseen_privacy,
                                       "photo_privacy" : objUserInfo.photo_privacy,
                                       "about_privacy" : objUserInfo.about_privacy,
                                       "read_receipts_privacy" : objUserInfo.read_receipts_privacy,
                                       "status_privacy" : objUserInfo.status_privacy,*/
                                        "lastseen_privacy" : "1",
                                        "photo_privacy" : "1",
                                        "about_privacy" : "1",
                                        "read_receipts_privacy" : "1",
                                        "status_privacy" : "1"]
                        }
                        APP_DELEGATE.socketIOHandler?.socket?.emit(keyInform_BlockedUser, with: [dicSend as Any])
                    })
                }
            }
        })
    }
}

