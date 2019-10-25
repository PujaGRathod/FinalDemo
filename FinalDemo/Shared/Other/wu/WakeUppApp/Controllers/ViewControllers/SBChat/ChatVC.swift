//
//  ConversationVC.swift
//  LetsTalk
//
//  Created by Admin on 02/02/18.
//  Copyright © 2018 Vishwkarma. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
//import SimpleImageViewer
import SwiftyJSON
import AVKit
import AVFoundation
import MobileCoreServices
import ContactsUI
import SDWebImage

import Contacts
import ContactsUI

import IGRPhotoTweaks

import SwiftLinkPreview

import CoreLocation
import AudioToolbox //PV
import Alamofire
import SwiftyJSON

protocol ChatVC_Delegate : AnyObject {
    func manage_HiddentChat_onChatVC(HideChatStatus: Bool?) -> Void
    func typingStopped(_ dicval:NSDictionary) -> Void
}

class ChatVC: UIViewController, AVAudioRecorderDelegate
{
    weak var delegate: ChatVC_Delegate?
    
    @IBOutlet weak var lblistyping: UILabel!
    //MARK:- Outlet
    @IBOutlet var vwnavbar: UIView!
    @IBOutlet var btnnavigate: UIButton!
    @IBOutlet var imgTitlePhoto: UIImageView!
    @IBOutlet var lblusername: UILabel!
    @IBOutlet var lblisonline: UILabel!
    @IBOutlet weak var lblIsOnlineHeight: NSLayoutConstraint!
    @IBOutlet var btnvideo: UIButton!
    @IBOutlet var btncall: UIButton!
    @IBOutlet var btnmenu: UIButton!
    
    @IBOutlet var vwattach: UIView!
    @IBOutlet var heightattach: NSLayoutConstraint!
    @IBOutlet var btncontact: UILabel!
    @IBOutlet var btnlocation: UILabel!
    @IBOutlet var btndoc: UIButton!
    @IBOutlet var btncamera: UIButton!
    @IBOutlet var btngallery: UIButton!
    @IBOutlet var btnaudio: UIButton!
    
    @IBOutlet weak var tblchat: UITableView!
    @IBOutlet weak var imgWallpaper: UIImageView!
    @IBOutlet weak var inputvalues: Inputbar!
    
    @IBOutlet weak var soundRecordBar: UIView!
    @IBOutlet weak var lblRecordingTimer: UILabel!
    @IBOutlet weak var btnCancelRecording: UIButton!
    @IBOutlet weak var btnSendRecording: UIButton!
    
    @IBOutlet weak var vwEditingNavBar: UIView!
    @IBOutlet weak var vwEditingTitle: UILabel!
    @IBOutlet weak var btnReplyWidth: NSLayoutConstraint!
    @IBOutlet weak var btnDeleteWidth: NSLayoutConstraint!
    @IBOutlet weak var btnCopyWidth: NSLayoutConstraint!
    @IBOutlet weak var btnStarWidth: NSLayoutConstraint!
    @IBOutlet weak var btnForwardWidth: NSLayoutConstraint!
    
    @IBOutlet weak var vwReply: UIView!
    @IBOutlet weak var lblReplySender: UILabel!
    @IBOutlet weak var lblReplyMessage: UILabel!
    @IBOutlet weak var imgReply: UIImageView!
    
    @IBOutlet weak var imgLinkPreview: UIImageView!
    @IBOutlet weak var widthOfImgLinkPreview: NSLayoutConstraint!
    @IBOutlet weak var lblLinkTitle: UILabel!
    @IBOutlet weak var lblLinkDescription: UILabel!
    @IBOutlet weak var lblLinkURL: UILabel!
    @IBOutlet weak var heightOfLinkPreviewView: NSLayoutConstraint!
     //let keyboardObserver = ALKeyboardObservingView()
    //MARK:- Variable
    var recordingTimer : Timer?
    var recordingDurationInSeconds:Int = 0 {
        didSet{
            lblRecordingTimer.text = timeFormatted(recordingDurationInSeconds)
        }
    }
//    override var inputAccessoryView: UIView? {
//        get {
//            return keyboardObserver
//        }
//    }
    var audioRecorder: AVAudioRecorder!
    var isAudioRecordingGranted: Bool!
    var lastmsgid = 0
    var recordingFileName = "audioRecording.m4a"
    
    var audioPlayer: AVAudioPlayer?
    var audioPlayerProgressTimer : Timer?
    var currentPlayingAudioCellIndex : IndexPath?
    
    var documentInteraction = UIDocumentInteractionController()
    
    var imagePicker = UIImagePickerController() // FOR CAMERA CAPTURE
    
    var arrMsgs = [StructChat]()
    //var arrAssortedMsgs = [AssortedMsgs]()
    
    var calledfrom = String()
    
    var username = String()
    var strTitle : String = "" //Show title of titlebar
    var imgTitleProfilePhoto : UIImage = ProfilePlaceholderImage
    
    var selecteduserid:String!
    var selectedUser:StructChat?
    
    var clickedattach = false
    
    var vcfPersonName = ""
    
    var isDownloading : Bool = false {
        didSet{
            if isDownloading{
                showLoaderHUD(strMessage: "")
            }else{
                hideLoaderHUD()
            }
        }
    }
    var istypingmsg = false

    var arrDownloadURLs = Array<URL>()
    
    var arrSelectedIndexes = [Int]()
    
    var tapTable : UITapGestureRecognizer!
    
    let interactor = Interactor()
    
    var selectedMessageForReply : StructChat?
    
    var photoBrowser:ChatAttachmentBrowser!
    
    let slp = SwiftLinkPreview(session: URLSession.shared,
                               workQueue: SwiftLinkPreview.defaultWorkQueue,
                               responseQueue: DispatchQueue.main,
                               cache: DisabledCache.instance)
    var linkPreview : Cancellable?
    
    var linkPreviewDetails : SwiftLinkPreview.Response?{
        didSet{
            if let result = linkPreviewDetails {
                _ = result[.url] as! URL
                _ = result[.finalUrl] as! URL
                let canonicalUrl = result[.canonicalUrl] as! String
                let title = result[.title] as? String
                let description = result[.description] as? String
                _ = result[.images] as? [String]
                let image = result[.image] as? String
                let icon = result[.icon] as? String
                
                //print("Url : \(url)")
                //print("Final Url : \(finalUrl)")
                //print("canonical Url : \(canonicalUrl)")
                //print("Title : \(title ?? "")")
                //print("Description : \(description ?? "")")
                //print("Images : \(images ?? [])")
                //print("Image : \(image ?? "")")
                //print("Icon : \(icon ?? "")")
                
                if let linkimage = image{
                    self.imgLinkPreview.contentMode = .scaleAspectFit
                    var imgURL = linkimage
                    if imgURL.contains("data:image"){
                        if let img = icon{
                            imgURL = img
                            linkPreviewDetails![.image] = imgURL
                        }
                    }
                    self.imgLinkPreview.sd_setImage(with: imgURL.toUrl, completed: { (image, error, cacheType, url) in
                        if error == nil{
                            self.widthOfImgLinkPreview.constant = 55
                        }else{
                            self.widthOfImgLinkPreview.constant = 0
                        }
                    })
                }else{
                    self.widthOfImgLinkPreview.constant = 0
                }
                
                self.lblLinkTitle.text = title
                self.lblLinkDescription.text = description
                self.lblLinkURL.text = canonicalUrl
                self.heightOfLinkPreviewView.constant = 71
            }else{
                hideLinkPreviewView()
            }
        }
    }
    
    var currentlySendingMessageID = ""
    var URL_dirCurrentChat : URL?
    
    //PV
    //var strUploadProcess : String = "0 %"
    var currentlyCell = -1
    var uploadprogress = "0 %"
    var swipeleft1 = UISwipeGestureRecognizer.init(target: self, action: #selector(swipeleft(sender:)))
    
    let scrollbottombtn:UIButton = UIButton(frame: CGRect(x: -5,y: Int(SCREENHEIGHT()) - 150, width:  50, height:  45))

   
    //MARK:-
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.lblistyping.isHidden = true
       swipeleft1.direction = .left
       self.tblchat.addGestureRecognizer(swipeleft1)
        layoutUI()
        
        //tblchat.keyboardDismissMode = .interactive
        checkForMicrophonePermission()
        self.set_NotificationObserver()
        hideSoundRecordingBar()
        hideReplyView(nil)
        hideLinkPreviewView()
        hideEditingNavBar()
        if self.selectedUser == nil {
        }
        else {
        }
        self.URL_dirCurrentChat = getURL_ChatWithUser_Directory(countryCode: (selectedUser?.kcountrycode)!, PhoneNo: (selectedUser?.kphonenumber)!)
        self.perform(#selector(reloadMessageReadStatus), with: nil, afterDelay: 2.0)
        perform(#selector(checkNavigationStackForMemberSelectVC), with: nil, afterDelay: 1.0)
        perform(#selector(setChatWallpaperImage), with: nil, afterDelay: 0.0)
        self.manage_TypingReceived()
        self.fill_HeaderValues()
        sendPendingMessages()
    }
    
    override func viewDidDisappear(_ animated:Bool) {
        IQKeyboardManager.shared.enable = true
        super.viewDidDisappear(animated)
        self.lblistyping.isHidden = true
        self.view.removeKeyboardControl()
        setAllMessagesToRead() //BECAUSE THE NEW MESSAGES THAT ARRIVE WHILE ON THE CHATVC WILL BE CONSIDERED AS UNREAD
    }
    
    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(animated)
        //hideEditingNavBar()
        self.managekeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Hide Navigationbar | Save contact adter move on this screen for hide the navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        /*self.selectedUser = CoreDBManager.sharedDatabase.getFriendById(userID: self.selecteduserid ?? "")
        if self.selectedUser == nil {
            //print("self.selecteduserid Missing")
            return
        }
        else {
            //print("self.selecteduserid Done")
        }*/
        
        /*
        //Contact Sync | Get latest contact list saved in Device for help show added new contact.
        //ContactSync.shared.performSync() //Comment by Payal | 14-09-2018 | | Add new memeber in contact after view this screen, perform this method for show updated names.
        runAfterTime(time: 0.50) {
            //Fill Data
            let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: (self.selectedUser?.kcountrycode)!, phoneNo: (self.selectedUser?.kphonenumber)!)
            if objContactInfo.Name?.count != 0 {
                self.strTitle = objContactInfo.Name!
                self.lblusername.text = self.strTitle.count == 0 ? "---" : self.strTitle
            }
        }*/
        
        //Set BG Wallpaper
        self.setChatWallpaperImage()
    }
    @objc func swipeleft(sender: UISwipeGestureRecognizer)
    {
        if self.delegate != nil
        {
            if APP_DELEGATE.isHiddenChatUnlocked != false
            {
                self.delegate?.manage_HiddentChat_onChatVC(HideChatStatus: true)
            }
            else
            {
                self.delegate?.manage_HiddentChat_onChatVC(HideChatStatus: false)
            }
            //self.delegate?.manage_HiddentChat_onChatVC(HideChatStatus: false)
        }
        self.remove_NotificationObserver()
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        audioRecorder = nil
    }
    
    //MARK:- Other function
    //MARK: Manage ChatDir dataContent
    func get_URL_inChatDir() -> URL {
        let URL_dirCurrentChat : URL = getURL_ChatWithUser_Directory(countryCode: (selectedUser?.kcountrycode)!, PhoneNo: (selectedUser?.kphonenumber)!)
        //print("URL_dirCurrentChat : \(URL_dirCurrentChat)")
        
        return URL_dirCurrentChat
    }
    
    func downloadContent_audio(contentURL : URL) -> Void {
        Downloader.download(url: contentURL, completion: { (success, url) in
            if success {
                //print("downloadContentURL: \(url)")
                
                //Copy download file in ChatDir.
                //let downloadContentLocalURL : URL = self.save_MediaContent_inChatDir(contentURL: url, withName: url.lastPathComponent)!
//                let downloadContentLocalURL : URL = save_Content(contentURL: url, withName: url.lastPathComponent, inDirectory: self.get_URL_inChatDir())!
                //print("downloadContentLocalURL: \(downloadContentLocalURL)")
            }
            else {
                showStatusBarMessage("Download failed. Try again.")
            }
            
            //Remove Old File
            removeFile_onURL(fileURL: url)
        })
    }
    
    func layoutUI()
    {
        tblchat.contentInset = UIEdgeInsets.init(top: -32, left: 0, bottom: -20, right: 0)
        
        self.vwattach.accessibilityValue = "\(self.inputvalues.frame.origin.y)"
        self.vwattach.isHidden = true
        
        IQKeyboardManager.shared.enable = false
        tblchat.register(UINib(nibName: "ChatReceiverAttachCell", bundle: nil), forCellReuseIdentifier: "ChatReceiverAttachCell")
        tblchat.register(UINib(nibName: "ChatSenderAttachCell", bundle: nil), forCellReuseIdentifier: "ChatSenderAttachCell")
        
        tblchat.register(UINib(nibName: "ChatReceiverCell", bundle: nil), forCellReuseIdentifier: "ChatReceiverCell")
        tblchat.register(UINib(nibName: "ChatSenderCell", bundle: nil), forCellReuseIdentifier: "ChatSenderCell")
        
        tblchat.register(UINib(nibName: "ChatContactReceiverCell", bundle: nil), forCellReuseIdentifier: "ChatContactReceiverCell")
        tblchat.register(UINib(nibName: "ChatContactSenderCell", bundle: nil), forCellReuseIdentifier: "ChatContactSenderCell")
        
        tblchat.register(UINib(nibName: "ChatReceiverDocumentCell", bundle: nil), forCellReuseIdentifier: "ChatReceiverDocumentCell")
        tblchat.register(UINib(nibName: "ChatSenderDocumentCell", bundle: nil), forCellReuseIdentifier: "ChatSenderDocumentCell")
        
        tblchat.register(UINib(nibName: "ChatReceiverAudioCell", bundle: nil), forCellReuseIdentifier: "ChatReceiverAudioCell")
        tblchat.register(UINib(nibName: "ChatSenderAudioCell", bundle: nil), forCellReuseIdentifier: "ChatSenderAudioCell")
        
        tblchat.register(UINib(nibName: "ChatStoryReplyReceiverCell", bundle: nil), forCellReuseIdentifier: "ChatStoryReplyReceiverCell")
        tblchat.register(UINib(nibName: "ChatStoryReplySenderCell", bundle: nil), forCellReuseIdentifier: "ChatStoryReplySenderCell")
        
        tblchat.register(UINib(nibName: "ChatLinkPreviewReceiverCell", bundle: nil), forCellReuseIdentifier: "ChatLinkPreviewReceiverCell")
        tblchat.register(UINib(nibName: "ChatLinkPreviewSenderCell", bundle: nil), forCellReuseIdentifier: "ChatLinkPreviewSenderCell")
        
        let footervw = UIView.init(frame: .zero)
        self.tblchat.tableFooterView = footervw
        
        tapTable = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
        self.tblchat.addGestureRecognizer(tapTable)
        
        tblchat.delegate = self
        tblchat.dataSource = self
        tblchat.bounces = false
        self.set_ScrollToBottomButton()
        
        reloadTable()
        fire_event_getmessaged()
        self.setInputbar()
    }
    
    @objc func fill_HeaderValues() -> Void {
        self.imgTitlePhoto.image = self.imgTitleProfilePhoto
        self.lblusername.text = self.strTitle.count == 0 ? "---" : self.strTitle
       
        let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: (self.selectedUser?.kcountrycode)!, phoneNo: (self.selectedUser?.kphonenumber)!)
        if objContactInfo.Name?.count != 0 {
            self.strTitle = objContactInfo.Name!
            self.lblusername.text = self.strTitle.count == 0 ? "---" : self.strTitle
        }
        else {
            lblusername.text = "+\(selectedUser!.kcountrycode) \(selectedUser!.kphonenumber)"
        }
        
        //Photo
        if (Privacy_ProfilePhoto_Show(statusFlag: selectedUser?.photo_privacy ?? "") == true) {
            self.imgTitlePhoto.sd_setImage(with: URL.init(string: "\(Get_Profile_Pic_URL)\(selectedUser?.kuserprofile ?? "")"), placeholderImage: ProfilePlaceholderImage)
        }
        else { self.imgTitlePhoto.image = ProfilePlaceholderImage }
        
        //Status
        self.lblisonline.text = ""
        self.lblIsOnlineHeight.constant = 0
        loadOnlineStatus()
    }
    
    func set_ScrollToBottomButton() -> Void {
        scrollbottombtn.backgroundColor = UIColor.white
        scrollbottombtn.setTitle("^", for: .normal)
        scrollbottombtn.addTarget(self, action:#selector(self.scrollbottombtnClicked), for: .touchUpInside)
        scrollbottombtn.layer.cornerRadius = 5
        scrollbottombtn.clipsToBounds = true
        scrollbottombtn .setImage(#imageLiteral(resourceName: "scrolldownarrow"), for: .normal)
        self.view.addSubview(scrollbottombtn)
        scrollbottombtn.alpha = 0
    }
    
    @objc func checkNavigationStackForMemberSelectVC(){
        var VCs = APP_DELEGATE.appNavigation?.viewControllers
        let index = VCs?.index(where: {$0 is SelectMembersVC})
        if let foundIndex = index {
            VCs?.remove(at: foundIndex)
            APP_DELEGATE.appNavigation?.viewControllers = VCs!
        }
    }
    
    func checkForMicrophonePermission(){
        switch AVAudioSession.sharedInstance().recordPermission() {
        case .granted:
            isAudioRecordingGranted = true
        case .denied:
            isAudioRecordingGranted = false
            let alert = UIAlertController(title: nil, message: "'\(APPNAME)' requires access to microphone to proceed.\n Would you like to open settings and grant permission to microphone?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { action in
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
            })
            self.present(alert, animated: true, completion: nil)
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.isAudioRecordingGranted = true
                    } else {
                        self.isAudioRecordingGranted = false
                    }
                }
            }
        }
    }
    
    @objc func newMessageReceived(_ notification: Notification)
    {
        let obj = StructChat.init(dictionary: notification.userInfo as! [String : Any])
        _ = CoreDBManager.sharedDatabase.saveMessageInLocalDB(objmessgae: obj)
        
        if obj.ksenderid != selecteduserid{
            return
        }
        
        self.arrMsgs.append(obj)
        self.tblchat.beginUpdates()
        self.tblchat.insertRows(at: [IndexPath(row: (self.arrMsgs.count)-1, section: 0)], with: .none)
        self.tblchat.endUpdates()
        self.tblchat.scrollToRow(at: (IndexPath(row:(self.arrMsgs.count)-1, section:0)) as IndexPath, at:.bottom, animated:true)
        
        self.tableViewScrollToBottomAnimated(animated: false)
        
        doUpdateReadStatus()
        reloadMessageReadStatus()
    }
    
    func saveCallInLocalDB(isVideoCall:String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let dictCall = [
            "image":"\(Get_Profile_Pic_URL)\(selectedUser!.kuserprofile)",
            "name":selectedUser!.kusername,
            "status":"outgoing",
            "is_video_call":isVideoCall,
            "call_from":"From chat call",
            "call_to":selectedUser!.kphonenumber,
            "call_id":appDelegate.getUniquieNo(),
            "date":appDelegate.getCurrentTime(),
            ]  as [String : Any]
        
        appDelegate.storeCallLog(dictCall: dictCall)
    }
    
    @IBAction func btnReplyClicked(_ sender: Any) {
        if arrSelectedIndexes.count == 1{
            
            let model = arrMsgs[arrSelectedIndexes.first!]
            
            selectedMessageForReply = model
            inputvalues.textView.becomeFirstResponder()
            
            imgReply.image = nil
            
            if model.ksenderid == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId){
                lblReplySender.text = "You"
            }else{
                lblReplySender.text = selectedUser?.kusername
            }
            
            let msgType = Int(model.kmessagetype)!
            if msgType == 0 || msgType == 4{
                lblReplyMessage.text = model.kchatmessage.base64Decoded
            }else if msgType == 1{
                if isPathForContact(path: model.kmediaurl){
                    lblReplyMessage.text = model.kchatmessage.base64Decoded
                    imgReply.image = #imageLiteral(resourceName: "profile_pic_register")
                    //imgReplyWidth.constant = 48
                }else{
                    
                    if isPathForImage(path: model.kmediaurl){
                        lblReplyMessage.text = "Image"
                        imgReply.sd_setImage(with: model.kmediaurl.toUrl!, completed: { (image, error, cacheType, url) in
                            //self.imgReplyWidth.constant = 48
                        })
                    }
                    else{
                        lblReplyMessage.text = getFileType(for: model.kmediaurl)
                        imgReply.image = getFileIcon(for: model.kmediaurl)
                    }
                }
            }else if msgType == 2{
                lblReplyMessage.text = "Location"
                imgReply.image = #imageLiteral(resourceName: "img_map")
            }else if msgType == 3{
                let arrDetails = model.kchatmessage.base64Decoded!.components(separatedBy: kStoryMessageSeparator)
                lblReplyMessage.text = arrDetails[4]
            }
            else if msgType == 5 {
                lblReplyMessage.text = get_ContactName(strMess: model.kchatmessage)
            }
            vwReply.isHidden = false
            vwReply.frame = CGRect.init(x: vwReply.frame.origin.x, y: self.inputvalues.frame.origin.y-49, width: SCREENWIDTH(), height: 49)
            hideEditingNavBar()
        }
    }
    
    @IBAction func btnDeleteClicked(_ sender: Any) {
        if arrSelectedIndexes.count > 0{
            
            var isAllNonDeleted = true
            var isAllSentByMe = true
            
            var arrIDs = [String]()
            for index in arrSelectedIndexes{
                
                let model = arrMsgs[index]
                arrIDs.append(model.kid)
                if isAllSentByMe{
                    if model.ksenderid != UserDefaultManager.getStringFromUserDefaults(key: kAppUserId){
                        isAllSentByMe = false
                    }
                }
                if isAllNonDeleted{
                    if model.kisdeleted == "1"{
                        isAllNonDeleted = false
                    }
                }
                
            }
            
            let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let actionDeleteForMe = UIAlertAction.init(title: "Delete For Me", style: .destructive, handler: { (action) in
                CoreDBManager.sharedDatabase.deleteForMeChatMessage(chatIDs: arrIDs)
                self.hideEditingNavBar()
                self.reloadTable()
                
                if self.arrMsgs.count > 0{
                    //TO UPDATE LAST MESSAGE IN CHATLISTVC
                    let lastMessage = self.arrMsgs.last
                    CoreDBManager.sharedDatabase.updateFriend(for: lastMessage!)
                }
            })
            alert.addAction(actionDeleteForMe)
            
            if isAllSentByMe && isAllNonDeleted{
                let actionDeleteForEveryone = UIAlertAction.init(title: "Delete For Everyone", style: .destructive, handler: { (action) in
                    
                    let dict = [
                        "chatids" : arrIDs.joined(separator: ","),
                        "receiver_id" : self.selecteduserid,
                        "sender_id" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)] as [String : Any]
                    if let isConnected = APP_DELEGATE.socketIOHandler?.isSocektConnected(){
                        if isConnected{
                            APP_DELEGATE.socketIOHandler?.socket?.emit("DeleteMessageForEveryone",dict)
                            
                            CoreDBManager.sharedDatabase.deleteForEveryoneChatMessage(chatIDs: arrIDs)
                            self.hideEditingNavBar()
                            self.reloadTable()
                        }
                    }
                })
                alert.addAction(actionDeleteForEveryone)
            }
            
            let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(actionCancel)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnCopyClicked(_ sender: Any) {
        if arrSelectedIndexes.count > 0{
            var arrMessages = [String]()
            for index in arrSelectedIndexes{
                let model = arrMsgs[index]
                var strMsg = model.kchatmessage.base64Decoded!
                var name = ""
                if model.ksenderid == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId){
                    name = "\(UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName))"
                }else{
                    name = "\(selectedUser!.kusername)"
                }
                strMsg = "[\(model.kcreateddate.components(separatedBy: "T").first!) \(name)] \(strMsg)"
                arrMessages.append(strMsg)
            }
            let str = arrMessages.joined(separator: "\n")
            UIPasteboard.general.string = str
        }
        hideEditingNavBar()
    }
    
    @IBAction func btnStarClicked(_ sender: Any) {
        var isAllStarred = true
        var arrIDs = [String]()
        for index in arrSelectedIndexes{
            let model = arrMsgs[index]
            arrIDs.append(model.kid)
            if isAllStarred == true{
                if model.isstarred == "0"{
                    isAllStarred = false
                }
            }
        }
        
        CoreDBManager.sharedDatabase.starUnstarChatMessage(chatIDs: arrIDs, shouldStar: !isAllStarred)
        hideEditingNavBar()
        reloadTable()
    }
    
    @IBAction func btnForwardClicked(_ sender: Any) {
        if arrSelectedIndexes.count > 0{
            
            var selectedMsgs = [StructChat]()
            for index in arrSelectedIndexes{
                selectedMsgs.append(arrMsgs[index])
            }
            
            //PASS SELECTED MESSAGES' ARRAY TO SELECT MEMBER VC
            let vc = loadVC(strStoryboardId: SB_CHAT, strVCId:"ForwardMessageVC") as! ForwardMessageVC
            vc.arrMessagesForForward = selectedMsgs
            mostTopViewController?.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnCancelNavBarEditing(_ sender: Any) {
        hideEditingNavBar()
    }
    
    func showEditingNavBar(){
        tapTable.isEnabled = false
        vwEditingNavBar.isHidden = false
        vwnavbar.isHidden = true
        tblchat.setEditing(true, animated: true)
    }
    
    func hideEditingNavBar(){
        tapTable.isEnabled = true
        vwEditingNavBar.isHidden = true
        vwnavbar.isHidden = false
        tblchat.setEditing(false, animated: true)
        arrSelectedIndexes.removeAll()
    }
    
    
    func managekeyboard()
    {
        IQKeyboardManager.shared.enable = false
        self.view.keyboardTriggerOffset = self.inputvalues.frame.size.height
        self.view.addKeyboardNonpanning(){[unowned self](keyboardFrameInView:CGRect, opening:Bool, closing:Bool) in
            var toolBarFrame = self.inputvalues.frame
            var tableViewFrame = self.tblchat.frame
            if UIScreen.main.bounds.height >= 812
            {
                tableViewFrame.size.height = toolBarFrame.origin.y - 95
                if #available(iOS 11.0, *)
                {
                    if keyboardFrameInView.origin.y == SCREENHEIGHT()
                    {
                        toolBarFrame.origin.y = keyboardFrameInView.origin.y  - toolBarFrame.size.height -  (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!
                    }
                    else {
                        toolBarFrame.origin.y = keyboardFrameInView.origin.y  - toolBarFrame.size.height
                    }
                }
                else {
                    toolBarFrame.origin.y = keyboardFrameInView.origin.y  - toolBarFrame.size.height
                }
                self.inputvalues.frame = toolBarFrame
            }
            else {
                tableViewFrame.size.height = toolBarFrame.origin.y - 75
                toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height
                self.inputvalues.frame = toolBarFrame
            }
            self.setupReplyView()
            self.tblchat.frame = tableViewFrame
            if keyboardFrameInView.origin.y != SCREENHEIGHT() {
                self.tableViewScrollToBottomAnimated(animated: false)
            }
        }
    }
    
    func setupReplyView(){
        if self.selectedMessageForReply != nil{
            self.vwReply.isHidden = false
            self.vwReply.frame = CGRect.init(x: self.vwReply.frame.origin.x, y: self.inputvalues.frame.origin.y-54, width: SCREENWIDTH(), height: 49)
        }
    }
    
    func setInputbar()
    {
        self.inputvalues.placeholder = "Type a message..."
        self.inputvalues.rightButtonImage =  #imageLiteral(resourceName: "voice_msg")
        self.inputvalues.inputDelegate = self
        self.inputvalues.leftButtonImage = UIImage(named:"add_media")
        //self.inputvalues.leftButtonImage1 = UIImage(named:"emoji_textbox")
    }
    
    @objc func tableTapped(tap:UITapGestureRecognizer)
    {
        self.inputvalues.inputResignFirstResponder()
       closeAttachmentView(completion: {})
    }
    
    func doUpdateReadStatus() {
        //Update_ReadStatus -> OF ALL MESSAGES
        //let dict = [ "senderid" : obj.ksenderid, "receiverid" : obj.kreceiverid]
       
        let dict = [ "senderid" : self.selecteduserid, "receiverid" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserId) ]
        APP_DELEGATE.socketIOHandler?.socket?.emit("Update_ReadStatus", dict)
        
        //print("UPDATE READ STATUS")
    }
    
    @objc func reloadTable() {
        arrMsgs = CoreDBManager.sharedDatabase.getChatMessagesForUserID(userId: self.selecteduserid, includeDeleted: false).sorted(by: { Float($0.kid)! < Float($1.kid)! }) //----> Old
        
        let sentMsgs = arrMsgs.filter({ $0.kid.contains(".") == false })
        let pendingMsgs = arrMsgs.filter({$0.kid.contains(".")})
        
        arrMsgs = sentMsgs + pendingMsgs
        //print("arrMsgs - \(arrMsgs.count)")
        
        if arrMsgs.count > 0 { setAllMessagesToRead() }
        
        refreshTable() //---->
        //tableViewScrollToBottomAnimated(animated: false)
    }
    
    @objc func refreshTable() {
        tblchat.reloadData()
    }
    
    func setAllMessagesToRead() {
        if arrMsgs.count > 0 {
            CoreDBManager.sharedDatabase.setUnreadCount(To: 0, forChatMessage: arrMsgs[0])
        }
    }
    
    @objc func reloadMessageReadStatus() {
        let msgs = CoreDBManager.sharedDatabase.getChatMessagesForUserID(userId: self.selecteduserid, includeDeleted: true)
        
        if msgs.count > 0 {
            
            let userID : String = UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)
            let chatIds = msgs.filter({($0.kisread == "0" || $0.kisread == "1") && $0.kreceiverid ==  userID }).map({ $0.kid })
            //self.showAlertMessage(chatIds.joined(separator: ","))
            if chatIds.count > 0{
                 APP_DELEGATE.socketIOHandler?.connectWithSocket()
                APP_DELEGATE.socketIOHandler?.socket?.emitWithAck("GetReadStatusByChatIds", ["chatids":chatIds.joined(separator: ",")]).timingOut(after: 60, callback: { (data) in
                    
                    if data[0] is String {
                        //self.showAlertMessage("No ACK")
                        return }
                    let arrData = data[0] as! Array<NSDictionary>
                    
                    let Read1 = arrData.filter({$0["isread"] as! Int == 1})
                    let Read2 = arrData.filter({$0["isread"] as! Int == 2})
                   //  self.showAlertMessage("\(data)")
                    if Read1.count > 0{
                        //self.showAlertMessage("Update Read 1")
                        CoreDBManager.sharedDatabase.updateReadStatus(newReadStatus: "1", forChatIDs: Read1.map({ String($0["id"] as! Int) }))
                    }
                    if Read2.count > 0{
                      //   self.showAlertMessage("Update Read 2")
                        CoreDBManager.sharedDatabase.updateReadStatus(newReadStatus: "2", forChatIDs: Read2.map({ String($0["id"] as! Int) }))
                    }
                    self.arrMsgs = CoreDBManager.sharedDatabase.getChatMessagesForUserID(userId: self.selecteduserid, includeDeleted: false).sorted(by: { Float($0.kid)! < Float($1.kid)! })
                    
                    let sentMsgs = self.arrMsgs.filter({ $0.kid.contains(".") == false })
                    let pendingMsgs = self.arrMsgs.filter({$0.kid.contains(".")})
                    
                    self.arrMsgs = sentMsgs + pendingMsgs
                    
                    if self.arrMsgs.count > 0{
                        self.setAllMessagesToRead()
                    }
 
                    
                    UIView.performWithoutAnimation {
                        self.tblchat.reloadRows(at:self.tblchat.indexPathsForVisibleRows!, with: .none)
                    }
                    
                    //self.reloadTable()
                    self.tableViewScrollToBottomAnimated(animated: false)
                })
            }
            else
            {
                
            }
        }
    }
    /*
     let chatIds = msgs.filter({($0.kisread == "0" || $0.kisread == "1") && $0.kreceiverid != userID }).map({ $0.kid })
     if chatIds.count > 0{
     
     APP_DELEGATE.socketIOHandler?.socket?.emitWithAck("GetReadStatusByChatIds", ["chatids":chatIds.joined(separator: ",")]).timingOut(after: 60, callback: { (data) in
     
     if data[0] is String {
     //self.showAlertMessage("No ACK")
     return }
     let arrData = data[0] as! Array<NSDictionary>
     let Read0 = arrData.filter({$0["isread"] as! Int == 0})
     let Read1 = arrData.filter({$0["isread"] as! Int == 1})
     let Read2 = arrData.filter({$0["isread"] as! Int == 2})
     //self.showAlertMessage("\(data)")
     if Read0.count > 0{
     CoreDBManager.sharedDatabase.updateReadStatus(newReadStatus: "1", forChatIDs: Read0.map({ String($0["id"] as! Int) }))
     }
     if Read1.count > 0{
     CoreDBManager.sharedDatabase.updateReadStatus(newReadStatus: "1", forChatIDs: Read1.map({ String($0["id"] as! Int) }))
     }
     if Read2.count > 0{
     CoreDBManager.sharedDatabase.updateReadStatus(newReadStatus: "2", forChatIDs: Read2.map({ String($0["id"] as! Int) }))
     }
     self.arrMsgs = CoreDBManager.sharedDatabase.getChatMessagesForUserID(userId: self.selecteduserid, includeDeleted: false).sorted(by: { Float($0.kid)! < Float($1.kid)! })
     let sentMsgs = self.arrMsgs.filter({ $0.kid.contains(".") == false })
     let pendingMsgs = self.arrMsgs.filter({$0.kid.contains(".")})
     self.arrMsgs = sentMsgs + pendingMsgs
     if self.arrMsgs.count > 0{
     self.setAllMessagesToRead()
     }
     UIView.performWithoutAnimation {
     self.tblchat.reloadRows(at:self.tblchat.indexPathsForVisibleRows!, with: .none)
     }
     self.tableViewScrollToBottomAnimated(animated: false)
     })
     }
 */
    @objc func setChatWallpaperImage(){
        if UserDefaultManager.getBooleanFromUserDefaults(key: kIsChatWallpaperSet){
            let image = UIImage.init(data: getLocallySavedFileData(With: kChatWallpaper)!)
            /*let imageView = UIImageView.init(image: image)
             imageView.contentMode = .scaleAspectFill
             imageView.frame = CGRect.init(origin: CGPoint.zero, size: tblchat.frame.size)
             tblchat.backgroundView = imageView*/
            imgWallpaper.image = image
        }else{
            /*tblchat.backgroundView = nil*/
            imgWallpaper.image = nil
        }
    }
    
    func getBuubleType(_ objChat:StructChat,complete:(_ strType:String,_ needToRefresh:Bool) -> ())  {
        var prevobj:StructChat? = nil
        var prevprevobj:StructChat? = nil
        prevobj = arrMsgs.count > 0  ? arrMsgs.last : nil
        prevprevobj = arrMsgs.count > 1  ? arrMsgs[arrMsgs.count - 2] : nil
        
        if(prevobj == nil) { complete("1",false) }
        else {
            if(prevprevobj == nil) {
                if objChat.kuserid == prevobj?.kuserid { complete("3",false) }
                else { complete("1",false) }
            }
            else {
                if objChat.kuserid == prevobj?.kuserid && objChat.kuserid == prevprevobj?.kuserid {
                    //Update last with 2 and  new message with below bubble type
                    //prevobj?.kbubbletype = "2"
                    arrMsgs.removeLast()
                    arrMsgs.append(prevobj!)
                    complete("3",true)
                }
                else  if objChat.kuserid == prevobj?.kuserid { complete("3",false) }
                else { complete("1",false) }
            }
        }
    }
    
    func getBubbleImage(objChat:StructChat) -> String{
        
        var thisMessageIndex = 0
        if let foo = arrMsgs.enumerated().first(where: {$0.element.kid == objChat.kid}){
            thisMessageIndex = foo.offset
        }
        
        if thisMessageIndex == 0{ return "1" }
        if thisMessageIndex == (arrMsgs.count - 1) { return "3" }
        
        let previousMessage = arrMsgs[thisMessageIndex-1]
        let nextMessage = arrMsgs[thisMessageIndex+1]
        
        let previousSender = previousMessage.ksenderid
        let nextSender = nextMessage.ksenderid
        let meAsSender = UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)
        
        let previousReceiver = previousMessage.kreceiverid
        let nextReceiver = nextMessage.kreceiverid
        let meAsReceiver = objChat.kreceiverid
        
        if objChat.kreceiverid != UserDefaultManager.getStringFromUserDefaults(key: kAppUserId){
            if previousSender != meAsSender { return "1" }
            if nextSender != meAsSender { return "3" }
            if previousSender == meAsSender && nextSender == meAsSender { return "2" }
        }
        else {
            if previousReceiver != meAsReceiver { return "1" }
            if nextReceiver != meAsReceiver { return "3" }
            if previousReceiver == meAsReceiver && nextReceiver == meAsReceiver { return "2" }
        }
        return "2" //SHOULD NEVER FALLBACK HERE
    }
    
    //MARK: LinkPreviewView
    @IBAction func btnHideLinkPreviewClicked(){
        linkPreviewDetails = nil
    }
    
    func hideLinkPreviewView(){
        if heightOfLinkPreviewView.constant > 0{
            heightOfLinkPreviewView.constant = 0
            imgLinkPreview.image = nil
            lblLinkTitle.text = ""
            lblLinkDescription.text = ""
            lblLinkURL.text = ""
        }
    }
    
    //MARK:- NotificationObserver
    func set_NotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: NSNotification.Name(NC_ReadReceiptUpdate), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newMessageReceived), name: NSNotification.Name(rawValue: NC_NewMessage), object: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: NSNotification.Name(NC_UserListRefresh), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadOnlineStatus), name: NSNotification.Name(NC_OnlineStatusRefresh), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(fire_event_getmessaged), name: NSNotification.Name(NC_LoadMessageFromServer), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: NSNotification.Name(NC_ChatAttachmentDownloaded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: NSNotification.Name(NC_ChatAttachmentDownloadFailed), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadOnlineStatus), name: NSNotification.Name("\(NC_UserOnlineStatusChanged)_\(selecteduserid!)"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sendPendingMessages), name: NSNotification.Name(NC_SocketConnected), object: nil)
        
        //Manange Privacy Change
        NotificationCenter.default.addObserver(self, selector: #selector(privacyChange_RefreshList(notification:)), name: NSNotification.Name(NC_PrivacyChange_Refresh_ChatVC), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(privacyChange_RefreshList(notification:)), name: NSNotification.Name(NC_PrivacyChange_LastSeen_Refresh_ChatVC), object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanged(notification:)), name: NSNotification.Name(rawValue: ALKeyboardFrameDidChangeNotification), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func remove_NotificationObserver()
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NC_NewMessage), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NC_UserListRefresh), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NC_OnlineStatusRefresh), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NC_LoadMessageFromServer), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "\(NC_UserOnlineStatusChanged)_\(selecteduserid!)"), object: nil)
        
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ALKeyboardFrameDidChangeNotification), object: nil)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func puKeyboardHeightManager(_ frame:CGRect)
    {
        var toolBarFrame = self.inputvalues.frame
        var tableViewFrame = self.tblchat.frame
        if UIScreen.main.bounds.height >= 812
        {
            tableViewFrame.size.height = toolBarFrame.origin.y - 95
            if #available(iOS 11.0, *)
            {
                if frame.origin.y == SCREENHEIGHT()
                {
                    toolBarFrame.origin.y = frame.origin.y  - toolBarFrame.size.height -  (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!
                }
                else {
                    toolBarFrame.origin.y = frame.origin.y  - toolBarFrame.size.height
                }
            }
            else {
                toolBarFrame.origin.y = frame.origin.y  - toolBarFrame.size.height
            }
            self.inputvalues.frame = toolBarFrame
        }
        else {
            tableViewFrame.size.height = toolBarFrame.origin.y - 75
            toolBarFrame.origin.y = frame.origin.y - toolBarFrame.size.height
            self.inputvalues.frame = toolBarFrame
        }
        self.setupReplyView()
        self.tblchat.frame = tableViewFrame
        if frame.origin.y != SCREENHEIGHT() {
            self.tableViewScrollToBottomAnimated(animated: false)
        }
    }
    
//    @objc func keyboardFrameChanged(notification: NSNotification) {
//        if let userInfo = notification.userInfo {
//            let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
//            //inputvalues.frame.origin.y = frame.origin.y
//            puKeyboardHeightManager(frame)
//        }
//    }
//
//    @objc func keyboardWillShow(notification: NSNotification) {
//        if let userInfo = notification.userInfo {
//            let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
//            //inputvalues.frame.origin.y = frame.origin.y
//            puKeyboardHeightManager(frame)
//        }
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        if let userInfo = notification.userInfo {
//            let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
//            //inputvalues.frame.origin.y = frame.origin.y
//            puKeyboardHeightManager(frame)
//        }
//    }
    //MARK: NotificationObserver Method
    @objc func privacyChange_RefreshList(notification : NSNotification) {
        
        if (notification.name.rawValue == NC_PrivacyChange_Refresh_ChatVC) {
            self.fill_HeaderValues()
            self.reloadTable()
        }
        else if (notification.name.rawValue == NC_PrivacyChange_LastSeen_Refresh_ChatVC) {
            self.loadOnlineStatus()
        }
    }
    
    //MARK:- Button action Method
    @objc func scrollbottombtnClicked() {
        self.tableViewScrollToBottomAnimated(animated: true)
    }
    
    //MARK: Titlebar button click
    @IBAction func btnbackclicked(_ sender: Any) {
        if self.delegate != nil
        {
            if APP_DELEGATE.isHiddenChatUnlocked != false
            {
                 self.delegate?.manage_HiddentChat_onChatVC(HideChatStatus: true)
            }
           else
            {
                 self.delegate?.manage_HiddentChat_onChatVC(HideChatStatus: false)
            }
        }
        self.remove_NotificationObserver()
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnProfileClicked(_ sender: Any) {
        if selectedUser == nil { return }
        
        let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId: idChatUserInfoVC) as! ChatUserInfoVC
        objVC.strUserID = selectedUser!.kuserid
        objVC.strTitle = self.lblusername.text!
        //objVC.strUserID = selectedUser!.kid
        //objVC.strPhotoURL = strFullPhotoURL
        objVC.strPhotoURL = selectedUser!.kuserprofile
        objVC.strUserName =  self.username
        objVC.strUserPhoneNo = selectedUser!.kphonenumber
        objVC.strCountryCodeOfPhoneNo = selectedUser!.kcountrycode
        objVC.strUserBio = selectedUser!.bio
        objVC.flag_showChatButton = false
        objVC.URL_CurrentDir = self.get_URL_inChatDir()
        APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
    }
    
    @IBAction func btnVideoCallClicked(_ sender: Any) {
        saveCallInLocalDB(isVideoCall: "1")
        let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: idVideoCallVC) as! VideoCallVC
        vc.userID = selectedUser!.kuserid
        vc.userName = selectedUser!.kusername
        vc.userPhoto = selectedUser!.kuserprofile
        vc.isReceivedCall = false
        APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnVoiceCallClicked(_ sender: Any) {
        
        saveCallInLocalDB(isVideoCall: "0")
        let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: idVoiceCallVC) as! VoiceCallVC
        vc.userID = selectedUser!.kuserid
        vc.userName = selectedUser!.kusername
        vc.userPhoto = selectedUser!.kuserprofile
        vc.userMobile = selectedUser!.kphonenumber
        vc.usercountry = selectedUser!.kcountrycode
        APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnMenuClicked(_ sender: Any) {
        let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let muteOrUnmute = isMutedChat(userId: selecteduserid) ? "Unmute" : "Mute"
        let actionMuteUnMute = UIAlertAction.init(title: muteOrUnmute, style: .default) { (action) in
            let currentlyMutedUsers = UserDefaultManager.getStringFromUserDefaults(key: kMutedByMe)
            var arrMutedUserIds = currentlyMutedUsers.components(separatedBy: ",") as? NSMutableArray
            if arrMutedUserIds == nil{
                arrMutedUserIds = NSMutableArray()
            }
            if (arrMutedUserIds?.contains(""))!{ arrMutedUserIds?.remove("") }
            
            if isMutedChat(userId: self.selecteduserid){
                arrMutedUserIds?.remove(self.selecteduserid)
            }else{
                arrMutedUserIds?.add(self.selecteduserid)
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
        
        let actionWallpaper = UIAlertAction.init(title: "Wallpaper", style: .default) { (action) in
            
            let alert = UIAlertController.init(title: nil, message: "Wallpaper", preferredStyle: .alert)
            
            let actionPhotos = UIAlertAction.init(title: "Gallery", style: .default, handler: { (action) in
                ImagePicker.sharedInstance.delegate = self
                ImagePicker.sharedInstance.selectImage(sender: "Wallpaper")
            })
            
            let actionNoWallpaper = UIAlertAction.init(title: "No Wallpaper", style: .default, handler: { (action) in
                UserDefaultManager.setBooleanToUserDefaults(value: false, key: kIsChatWallpaperSet)
                self.setChatWallpaperImage()
            })
            
            let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(actionPhotos)
            alert.addAction(actionNoWallpaper)
            alert.addAction(actionCancel)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: (self.selectedUser?.kcountrycode)!, phoneNo: (self.selectedUser?.kphonenumber)!)
        if objContactInfo.Name?.count == 0 {
            let actionAddContact = UIAlertAction.init(title: "Add to Contact", style: .default) { (action) in
                self.addToContacts()
            }
            actionSheet.addAction(actionAddContact)
        }
        
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(actionMuteUnMute)
        actionSheet.addAction(actionWallpaper)
        actionSheet.addAction(actionCancel)
        
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    //MARK: Attachment Button Clicks
    @IBAction func btnCameraClicked(_ sender: Any) {
        closeAttachmentView(completion: {})
        
        /*let assetVC = loadVC(strStoryboardId: SB_ASSET_PICKER, strVCId: idAssetPickerVC) as! AssetPickerVC
         assetVC.delegate = self
         assetVC.initallyCameraSelected = true
         APP_DELEGATE.appNavigation?.pushViewController(assetVC, animated: true)*/
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.videoQuality = .typeLow
        present(imagePicker, animated: true, completion: nil)
        
        /*let chatAttach = loadVC(strStoryboardId: SB_CHAT, strVCId: idChatAttachVC) as! ChatAttachVC
         chatAttach.selectedTab = 0
         chatAttach.attachDelegate = self
         APP_DELEGATE.appNavigation?.pushViewController(chatAttach, animated: true)*/
    }
    
    @IBAction func btnGalleryClicked(_ sender: Any) {
        closeAttachmentView(completion: {})
        
        let assetVC = loadVC(strStoryboardId: SB_ASSET_PICKER, strVCId: idAssetPickerVC) as! AssetPickerVC
        assetVC.delegate = self
        APP_DELEGATE.appNavigation?.pushViewController(assetVC, animated: true)
        
        /*let chatAttach = loadVC(strStoryboardId: SB_CHAT, strVCId: idChatAttachVC) as! ChatAttachVC
         chatAttach.selectedTab = 1
         chatAttach.attachDelegate = self
         APP_DELEGATE.appNavigation?.pushViewController(chatAttach, animated: true)*/
    }
    
    @IBAction func btnAudioClicked(_ sender: Any) {
        
        closeAttachmentView(completion: {
            
            /*let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
             
             let actionRecord = UIAlertAction.init(title: "Record", style: .default) { (action) in
             self.btnStartRecordingClicked(action)
             }
             
             let actionSelect = UIAlertAction.init(title: "Select", style: .default) { (action) in
             //SELECT AUDIO FILE FROM iCloud
             self.openDocumentsPickerForAudio(forAudio: true)
             }
             
             let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
             
             alert.addAction(actionRecord)
             alert.addAction(actionSelect)
             alert.addAction(actionCancel)
             
             self.present(alert, animated: true, completion: nil)*/
            self.openDocumentsPickerForAudio(forAudio: true)
        })
    }
    
    @IBAction func btnDocumentClicked(_ sender: Any) {
        closeAttachmentView(completion: {})
        openDocumentsPickerForAudio(forAudio: false)
    }
    
    @IBAction func btnLocationClicked(_ sender: Any) {
        closeAttachmentView(completion: {})
        
        if isConnectedToNetwork() == false || APP_DELEGATE.socketIOHandler!.isSocektConnected() == false{
            let alert = UIAlertController.init(title: nil, message: "You are offline. Would you like to send your current location?", preferredStyle: .alert)
            
            let actionYes = UIAlertAction.init(title: "Yes", style: .default, handler: { (action) in
                
                let location = UserDefaultManager.getStringFromUserDefaults(key: kUserLocation)
                let latitude = location.components(separatedBy: "-").first!
                let longitude = location.components(separatedBy: "-").last!
                
                let lastLocation = CLLocation.init(latitude: CLLocationDegrees.init(latitude)!, longitude: CLLocationDegrees.init(longitude)!)
                if lastLocation.coordinate.longitude == 0 || lastLocation.coordinate.latitude == 0{
                    self.showAlertMessage("Your location could not be determined", okButtonTitle: "Ok")
                }else{
                    let dic = self.getLocationMessageDicWith(location: lastLocation)
                    self.newSendMessageWithDic(dic: dic)
                }
                
            })
            alert.addAction(actionYes)
            
            let actionNo = UIAlertAction.init(title: "No", style: .cancel, handler: nil)
            alert.addAction(actionNo)
            
            present(alert, animated: true, completion: nil)
        }else{
            
            let locationPicker = LocationPickerViewController()
            
            locationPicker.showCurrentLocationButton = true
            locationPicker.useCurrentLocationAsHint = true
            locationPicker.selectCurrentLocationInitially = true
            locationPicker.mapType = .standard
            locationPicker.completion = { (location) in
                let dic = self.getLocationMessageDicWith(location: location!.location)
                self.newSendMessageWithDic(dic: dic)
            }
            
            let nav = UINavigationController.init(rootViewController: locationPicker)
            mostTopViewController?.present(nav, animated: true, completion: nil)
        }
    }
    
    func getLocationMessageDicWith(location:CLLocation)->[String:Any]{
        let dic = [
            "senderid":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            "receiverid":self.selecteduserid ,
            "textmessage": "\(location.coordinate.latitude),\(location.coordinate.longitude)".base64Encoded!,
            "messagetype": "2",
            "mediaurl": "",
            "platform":PlatformName,
            "createddate": "",
            "isdeleted":"0",
            "isread":"0",
            "username" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
            "mutestatus" : CoreDBManager.sharedDatabase.amIMutedByUser(receiverId: self.selecteduserid) ? "1" : "0",
            "countrycode" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode).replacingOccurrences(of: "+", with: ""),
            "phonenumber" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)]  as [String : Any]
        return dic
    }
    
    @IBAction func btnContactClicked(_ sender: Any) {
        closeAttachmentView(completion: {})
        let contactPicker = CNContactPickerViewController()
        
        contactPicker.delegate = self
        //contactPicker.displayedPropertyKeys = [CNContactGivenNameKey, CNContactImageDataAvailableKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey, CNContactIdentifierKey]
        present(contactPicker, animated: true, completion: nil)
    }
    
    func openDocumentsPickerForAudio(forAudio:Bool){
        var arrDocTypes = [String]()
        if forAudio{
            arrDocTypes = [kUTTypeMP3 as String, kUTTypeMPEG4Audio as String, kUTTypeWaveformAudio as String]
        }else{
            arrDocTypes = [kUTTypePDF as String, "com.microsoft.word.doc", "org.openxmlformats.wordprocessingml.document", "com.microsoft.excel.xls", kUTTypeSpreadsheet as String, kUTTypeText as String, kUTTypeRTF as String]
        }
        let documentPicker = UIDocumentPickerViewController.init(documentTypes: arrDocTypes, in: .import)
        documentPicker.delegate = self
        mostTopViewController?.present(documentPicker, animated: true, completion: nil)
    }
    
    //MARK:- Sound Recording
    
    @objc func btnStartRecordingClicked(_ sender:Any){
        
        if isAudioRecordingGranted {
            
            //Create the session.
            let session = AVAudioSession.sharedInstance()
            
            do {
                //Configure the session for recording and playback.
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
                try session.setActive(true)
                //Set up a high-quality recording session.
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
                
                //Create audio file name URL
                recordingFileName = "\(get_fileName_asCurretDateTime()).m4a"
                
                let audioFilename = save_Content(withContentName: recordingFileName, inDirectory: self.get_URL_inChatDir())
                
                //Create the audio recording, and assign ourselves as the delegate
                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.record()
                
                soundRecordBar.isHidden = false
                soundRecordBar.isUserInteractionEnabled = true
                recordingTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateRecordingLabel), userInfo: nil, repeats: true)
            }
            catch _ {
                //print("Error for start audio recording: \(error.localizedDescription)")
            }
        }else{
            checkForMicrophonePermission()
        }
    }
    
    @IBAction func btnCancelRecordingClicked(_ sender: Any) {
        hideSoundRecordingBar()
        
        //Delete Record Autod File
        removeFile(fileName: recordingFileName, inDirectory: self.get_URL_inChatDir())
    }
    
    @IBAction func btnSendRecordingClicked(_ sender: Any) {
        finishAudioRecording(success: true)
    }
    
    @objc func updateRecordingLabel(){
        recordingDurationInSeconds += 1
    }
    
    func hideSoundRecordingBar(){
        recordingTimer?.invalidate()
        recordingDurationInSeconds = 0
        soundRecordBar.isHidden = true
        soundRecordBar.isUserInteractionEnabled = false
        
    }
    
    func finishAudioRecording(success: Bool) {
        
        hideSoundRecordingBar()
        
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            //print("Recording finished successfully.")
            
            let localURL = save_Content(contentURL: self.get_URL_inChatDir().appendingPathComponent(recordingFileName), withName: "\(getNewPendingMessageID()).m4a", inDirectory: self.get_URL_inChatDir())
            removeFile_onURL(fileURL: self.get_URL_inChatDir().appendingPathComponent(recordingFileName))
            sendMediaMessage(forLocalURL: localURL!)
            //uploadChatAttachment(attachment: self.get_URL_inChatDir().appendingPathComponent(recordingFileName))
            
        } else {
            //print("Recording failed :(")
        }
    }
    
    //MARK:- Audio recoder delegate methods
    internal func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishAudioRecording(success: false)
        }
    }
    
    //MARK:- ReplyView
    @IBAction func hideReplyView(_ sender:Any?){
        
        DispatchQueue.main.async {
            
            self.selectedMessageForReply = nil
            
            self.vwReply.isHidden = true
            
            self.lblReplyMessage.text = ""
            self.lblReplySender.text = ""
            self.imgReply.image = nil
            
            self.inputvalues.inputResignFirstResponder()
            
        }
    }
 
    //MARK:- Socket API
    @objc func manage_TypingReceived() {
        APP_DELEGATE.socketIOHandler?.socket?.on("TypingReceived") {data, ack in
            if data.count > 0{
                if let dicData = data.first as? [String:String]{
                    
                    let senderId = dicData["senderid"]!
                    let isTyping = dicData["istyping"]!
                    let isGroup = dicData["isgroup"]!
                    
                    if senderId == self.selecteduserid && isGroup == "0"{
                        if isTyping == "1"{
                               // self.lblisonline.text = "typing.."
                            self.lblisonline.isHidden = true
                            self.lblistyping.isHidden = false
                        }else{
                           // self.lblisonline.text = "Online"
                            self.lblisonline.isHidden = false
                            self.lblistyping.isHidden = true
                        }
                    }
                   // self.view.endEditing(true)
                }
            }
        }
    }
    
   
    @objc func stopTyping() {
        
        let dic = [
            "senderid" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            "receiverid" : selecteduserid,
            "istyping" : "0",
            "countrycode" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode),
            "phoneno" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile),
            "isgroup" : "0"
        ]
        
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck("TypingSent",dic).timingOut(after: 1000)
        { data in
            
            if self.delegate != nil
            {
                (self.delegate?.typingStopped(dic as NSDictionary))!
            }
        }
    }
    
    @objc func loadOnlineStatus()
    {
        let msgDictionary = ["user_id":selecteduserid]
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck("UserOnlineStatus",msgDictionary).timingOut(after: 30)
        {data in
            let data = data as Array
            if(data.count > 0) {
                if data[0] is String { return }
                
                //PV
                if let dicObj : NSArray = data[0] as? NSArray {
                    //print("Get Empty Obj. check")
                    if(dicObj.count == 0) {
                        //print("Get Empty Dic")
                        return
                    }
                }
                
                let dic = data[0] as! NSDictionary
                let is_online = dic["is_online"] as! Int
                let seenprivacy = "\(dic["lastseen_privacy"] ?? "0")"
                let seendate = "\(dic["last_login"] ?? "")"
                
                if is_online == 0 {
                    if seenprivacy == "0" {
                        self.lblisonline.text = ""
                        self.lblIsOnlineHeight.constant = 0
                    }
                    else {
                        if seendate.contains("null") || seendate.count == 0 {
                            self.lblisonline.text = "--"
                            self.lblIsOnlineHeight.constant = 0
                            //---->
                        } else {
                            if Privacy_LastSeen_Show(userID: self.selecteduserid) == true {
                                let lastseentext = seendate == "" ? "" : timeAgoSinceStrDate(strDate: seendate, numericDates: true)
                                
                                //PV
                                if lastseentext.uppercased() == "now".uppercased() {
                                    self.lblisonline.text = "Last seen " + lastseentext
                                }
                                else {
                                    self.lblisonline.text = "Last seen " + lastseentext + " ago"
                                }
                                
                                self.lblIsOnlineHeight.constant = 15
                            } else {
                                self.lblisonline.text = ""
                                self.lblIsOnlineHeight.constant = 0
                            }
                        }
                    }
                }
                else {
                    if Privacy_LastSeen_Show(userID: self.selecteduserid) == true {
                        self.lblisonline.text = "Online"
                        self.lblIsOnlineHeight.constant = 15
                    } else {
                        self.lblisonline.text = ""
                        self.lblIsOnlineHeight.constant = 0
                    }
                }
                
            }
        }
    }
    
    @objc func fire_event_getmessaged()
    {
        var maxChatId:Float = 0
        let arr = CoreDBManager.sharedDatabase.getChatMessagesForUserID(userId: selecteduserid, includeDeleted: true)
        if arr.count > 0{
            let chatIds = arr.map({Float($0.kid)!})
            maxChatId = chatIds.max()!.rounded(.down)
        }
        if maxChatId == 0
        {
            maxChatId = Float(lastmsgid - 1)
        }
        let msgDictionary = [
            "receiverid":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            "senderid" : selecteduserid,
            "chatid" : String(maxChatId)
            ] as [String:Any]
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck(keyGet_ChatMessagesByDate,msgDictionary).timingOut(after: 30)
        {data in
            //print("Get_ChatMessagesByLastId - Data: \(data)")
            
            let data = data as Array
            if(data.count > 0) {
                if data[0] is String { return }
                
                let dic = data[0] as! NSArray
                let obj = dic// dic["userResult"] as! NSArray
                for dicData in obj {
                    let objData:StructChat = StructChat.init(dictionary: dicData as! [String : Any])
                    _ = CoreDBManager.sharedDatabase.saveMessageInLocalDB(objmessgae: objData)
                    //self.arrMsgs.append(objData)
                }
                
                self.reloadTable()
                self.tableViewScrollToBottomAnimated(animated: false)
                //self.reloadMessageReadStatus()
                //self.doUpdateReadStatus() //READ RECEIPT ISSUE
            }
        }
        doUpdateReadStatus() //READ RECEIPT ISSUE
    }
    
    //MARK:- API
    func api_BlockUser(parameter : NSDictionary, loaderMess: String) {
        self.view.endEditing(true)
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIUserFollow, parameters: parameter, keyname: "", message: loaderMess, showLoader: true, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            hideLoaderHUD() // Hide Loader
            
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
                    
                    //Show Success message
                    /*var strMessage: String = ""
                     if (loaderMess.count == 0) { strMessage = responseDict!.object(forKey: kMessage) as! String }
                     else {  strMessage = "User \(self.strTitle) unblocked successfully."  }
                     showMessage(strMessage)*/
                    
                    let strMessage = responseDict!.object(forKey: kMessage) as! String
                    showMessage(strMessage)
                    
                    if strMessage.contains("unblock"){
                        APP_DELEGATE.RemoveUser_BlockContactList(strUserID: (self.selectedUser?.kuserid)!)
                    }
                    
                    self.reloadTable()
                    
                    UIView.setAnimationsEnabled(false);
                    self.tblchat.beginUpdates()
                    self.tblchat.endUpdates()
                    UIView.setAnimationsEnabled(true)
                }
            }
        })
    }
}

//MARK: -
extension ChatVC : InputbarDelegate {
    //MARK: InputbarDelegate | Text Mess. Send
    func inputbarDidPressRightButton(inputbar:Inputbar)  {
        
        let textMessage = inputbar.text.trimmingCharacters(in: .whitespacesAndNewlines)
        var dic = [
            //"uniqueid" : "\(getNewPendingMessageID())", //PV | Id not set app will be crash, if not found : "uniqueid"
            "senderid":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            "receiverid":selecteduserid ,
            "textmessage": textMessage.base64Encoded ?? "",
            "messagetype": "0",
            "mediaurl": "",
            "platform":PlatformName,
            "createddate": "",
            "isdeleted":"0",
            "isread":"0",
            "username" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
            "mutestatus" : CoreDBManager.sharedDatabase.amIMutedByUser(receiverId: selecteduserid) ? "1" : "0",
            "countrycode" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode).replacingOccurrences(of: "+", with: ""),
            "phonenumber" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)]  as [String : Any]
        
        if let linkDetails = linkPreviewDetails{
            let mediaURL = "\(linkDetails[.canonicalUrl] ?? "-")\(kLinkMessageSeparator)\(linkDetails[.image] ?? "-")\(kLinkMessageSeparator)\(linkDetails[.title] ?? "-")\(kLinkMessageSeparator)\(linkDetails[.description] ?? "-")"
            dic["messagetype"] = "4"
            dic["mediaurl"] = mediaURL
            
            linkPreviewDetails = nil
            linkPreview?.cancel()
        }
        self.view.endEditing(true)
        newSendMessageWithDic(dic: dic)
    }
    
    func inputbarDidPressLeft2Button(inputbar: Inputbar) {
        //emoji button
    }
    
    func inputbarDidPressLeftButton(inputbar:Inputbar) {
        self.inputvalues.inputResignFirstResponder()
        if self.clickedattach == false { openAttachmentView() }
        else { closeAttachmentView(completion: {}) }
    }
    
    func inputbarDidPressVoiceButton(inputbar: Inputbar) {
        if inputbar.textView.isFirstResponder(){
            self.view.endEditing(true)
            self.perform(#selector(btnStartRecordingClicked), with: inputbar, afterDelay: 0.4)
        }else{
            btnStartRecordingClicked(inputbar)
        }
        //btnStartRecordingClicked(inputbar)
    }
    
    func inputBarTextDidChange(inputbar: Inputbar) {
        
        if inputbar.text.count > 0
        {
            if istypingmsg != true
            {
                let dic = [
                    "senderid" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
                    "receiverid" : selecteduserid,
                    "istyping" : "1",
                    "countrycode" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode),
                    "phoneno" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile),
                    "isgroup" : "0"
                ]
                
                APP_DELEGATE.socketIOHandler?.socket?.emitWithAck("TypingSent",dic).timingOut(after: 1000)
                {data in
                    let data = data as Array
                    if(data.count > 0) {
                        if data[0] is String { return }
                        self.istypingmsg = true
                    }
                }
            }
        }
        else
        {
            self.istypingmsg = false
            NSObject.cancelPreviousPerformRequests(
                        withTarget: self,
                        selector: #selector(ChatVC.stopTyping),
                        object: nil)
            self.perform(
                #selector(ChatVC.stopTyping),
                with: nil,
                afterDelay:0.5)
        }
        
        
        if inputbar.text.count > 0 {
            if linkPreview != nil { linkPreview?.cancel() }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.linkPreview = self.slp.preview(
                    inputbar.text,
                    onSuccess: { result in
                        //print("\(result)")
                        self.linkPreviewDetails = result
                }, onError: {error in
                    //print("\(error)")
                    self.hideLinkPreviewView()
                    self.linkPreviewDetails = nil
                })
            })
        }
    }
}

//MARK: -
extension ChatVC : CNContactViewControllerDelegate
{
    //MARK: Add Contact Delegate Method
    func addToContacts(){
        let contact = ContactSync.shared.get_ContactObject(strCountryCode: self.selectedUser?.kcountrycode ?? "", strPhoneNo: self.selectedUser?.kphonenumber ?? "")
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
            self.fill_HeaderValues()
        }
        APP_DELEGATE.appNavigation?.popViewController(animated: false)
    }
    
    func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        return true
    }
}
extension ChatVC : UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate, CNContactPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ContactsSendVC_Delegate {
    internal func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        let newUrls = [url].flatMap { (url: URL) -> URL? in
            // Create file URL to temporary folder
            var tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
            // Apend filename (name+extension) to URL
            let lastPathComponent = url.lastPathComponent.replacingOccurrences(of: " ", with: "_")
            tempURL.appendPathComponent(lastPathComponent)
            do {
                // If file with same name exists remove it (replace file with new one)
                if FileManager.default.fileExists(atPath: tempURL.path) {
                    try FileManager.default.removeItem(atPath: tempURL.path)
                }
                // Move file from app_id-Inbox to tmp/filename
                try FileManager.default.moveItem(atPath: url.path, toPath: tempURL.path)
                
                self.vcfPersonName = lastPathComponent.base64Encoded!
                return tempURL
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
        
        //IF VCF FILE SELECTED FROM iCloud DRIVE THEN GET PERSON NAME FROM VCF FILE
        let extensionOfFile = newUrls.first!.lastPathComponent.components(separatedBy: ".").last!.lowercased()
        if extensionOfFile == "vcf" {
            do{
                let contactData = try Data.init(contentsOf: newUrls.first!)
                let contact = try CNContactVCardSerialization.contacts(with: contactData).first!
                self.vcfPersonName = (contact.givenName + " " + contact.familyName).base64Encoded!
            }catch{
                print(error.localizedDescription)
            }
        }
        
        let fileName = "\(getNewPendingMessageID())" + "." + newUrls.first!.pathExtension
        let localURL = save_Content(contentURL: newUrls.first!, withName: fileName, inDirectory: self.get_URL_inChatDir())
        sendMediaMessage(forLocalURL: localURL!)
        //removeFile_onURL(fileURL: self.get_URL_inChatDir().appendingPathComponent(recordingFileName))
        //uploadChatAttachment(attachment: newUrls.first!)
    }
    
    internal func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return mostTopViewController!
    }
    
    //PV
    //Select Multipul Contact in ContactPicker.
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        NSLog("Total Selected Contact : \(contacts.count)");
        
        self.manage_ContactArrayDictionary(contacts: contacts)
        return
    
        if contacts.count > 1 {
            runAfterTime(time: 0.20, block: {
                let alert = UIAlertController.init(title: "Are you sure you went to send multiple contacts", message: nil, preferredStyle: .alert)
                
                let action_no = UIAlertAction.init(title: "No", style: .cancel, handler: nil)
                alert.addAction(action_no)
                
                let action_yes = UIAlertAction.init(title: "Yes, Send now", style: .default, handler: { (action) in
                    for contact : CNContact in contacts {
                        self.contactPicker(picker, didSelect: contact)
                    }
                })
                alert.addAction(action_yes)
                self.present(alert, animated: true, completion: nil)
            })
        }
        else {
            for contact : CNContact in contacts {
                self.contactPicker(picker, didSelect: contact)
            }
        }
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        //NSLog(@"Contact : %@",contact);
        NSLog("Selected Contact : \(contact.givenName) - \(contact.familyName)");
        
        self.manage_ContactArrayDictionary(contacts: [contact])
        return
        
        do{
            let data = try CNContactVCardSerialization.data(with: [contact])
            let s = String(data: data, encoding: String.Encoding.utf8)
            print(s ?? "Empty String")
            
            if let directoryURL = getDocumentsDirectoryURL() {
                let fileURL = directoryURL.appendingPathComponent("Contact").appendingPathExtension("vcf")
                try data.write(to:fileURL, options: [.atomicWrite])
                
                vcfPersonName = (contact.givenName + " " + contact.familyName).base64Encoded!
                
                let fileName = "\(getNewPendingMessageID())" + "." + fileURL.pathExtension
                let localURL = save_Content(contentURL: fileURL, withName: fileName, inDirectory: self.get_URL_inChatDir())
                sendMediaMessage(forLocalURL: localURL!)
                
                //MIGHT NEED TO REMOVE FILE FROM DOCS HERE
                
                //uploadChatAttachment(attachment: fileURL)
            }
        }
        catch{
            print(error.localizedDescription)
        }
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        //NSLog(@"Cancelled");
    }
    
    func manage_ContactArrayDictionary(contacts: [CNContact]) {
        let objVC : ContactsSendVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ContactsSendVC" ) as! ContactsSendVC
        objVC.delegate = self
        objVC.arrContact = contacts
        objVC.objEnumContact = .contact_Send
        APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
    }
   
    func get_SendContactData_inContactsSendVC(dicContact: NSDictionary) {
        var strJSONString : String = ""
        strJSONString = convertDictionaryToJSONString(dic: dicContact)!
        strJSONString = strJSONString.base64Encoded!
        
        let dic = [
            //"uniqueid" : "\(getNewPendingMessageID())", //PV | Id not set app will be crash, if not found : "uniqueid"
            "senderid":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            "receiverid":selecteduserid ,
            "textmessage": strJSONString,
            "messagetype": "5",
            "mediaurl": "",
            "platform":PlatformName,
            "createddate": "",
            "isdeleted":"0",
            "isread":"0",
            "username" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
            "mutestatus" : CoreDBManager.sharedDatabase.amIMutedByUser(receiverId: selecteduserid) ? "1" : "0",
            "countrycode" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode).replacingOccurrences(of: "+", with: ""),
            "phonenumber" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)]  as [String : Any]
        //print("Send Contact Dic.: \(dic)")
        newSendMessageWithDic(dic: dic)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let tempImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let reduceImgData = UIImageJPEGRepresentation(tempImage, 0.25)
        let reduceImg = UIImage.init(data: reduceImgData!)
        let imgView : UIImageView = UIImageView.init(image: reduceImg)
        imgView.image = reduceImg?.resizeImage(targetSize: CGSize.init(width: imgView.frame.width * 0.45, height: imgView.frame.height * 0.45))
        
        dismiss(animated: true) {
            let localURL = save_Content(image: imgView.image!, imageName: "\(self.getNewPendingMessageID()).png", inDirectory: self.get_URL_inChatDir())
            self.sendMediaMessage(forLocalURL: localURL!)
            //self.uploadChatAttachment(attachment: tempImage)
        }
    }
}

extension ChatVC : AssetPickerDelegate {
    
    func assetPickerDidFinishSelectingAssets(withFilterAssetModels filterAssetModels: [FilterAssetModel]) {
        
        DispatchQueue.main.async {
            let viewControllers: [UIViewController] = APP_DELEGATE.appNavigation!.viewControllers as [UIViewController]
            APP_DELEGATE.appNavigation!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for filterModel in filterAssetModels{
                //let filterModel = filterAssetModels.first!
                if filterModel.originalPHAsset.mediaType == .image{
                    let localURL = save_Content(image: filterModel.originalPHAsset.getOriginalImage(), imageName: "\(self.getNewPendingMessageID()).png", inDirectory: self.get_URL_inChatDir())
                    self.sendMediaMessage(forLocalURL: localURL!)
                    //self.uploadChatAttachment(attachment: filterModel.originalPHAsset.getOriginalImage())
                }else{
                    let fileName = "\(self.getNewPendingMessageID())" + "." + filterModel.exportedFileURL!.pathExtension
                    let localURL = save_Content(contentURL: filterModel.exportedFileURL!, withName: fileName, inDirectory: self.get_URL_inChatDir())
                    self.sendMediaMessage(forLocalURL: localURL!)
                    //self.uploadChatAttachment(attachment: filterModel.exportedFileURL!)
                }
            }
        }
        
    }
    
    func assetPickerDidCancelSelectingAssets() {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    func sendMediaMessage(forLocalURL localURL:URL){
        let sizeoffile = fileSize(url: localURL);
        
        let dic = [
            "iospkid" : "\(getNewPendingMessageID())",
            "senderid":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            "receiverid":self.selecteduserid ,
            "textmessage": self.vcfPersonName,
            "messagetype": "1",
            "mediaurl": localURL.path,
            "platform":PlatformName,
            "createddate": "",
            "isdeleted":"0",
            "isread":"0",
            "username" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
            "mutestatus" : CoreDBManager.sharedDatabase.amIMutedByUser(receiverId: self.selecteduserid) ? "1" : "0",
            "countrycode" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode).replacingOccurrences(of: "+", with: ""),
            "phonenumber" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile),
            "mediasize":sizeoffile]  as [String : Any]
        
        newSendMessageWithDic(dic: dic)
    }
    
    func uploadChatAttachment(attachment:Any) {
        //showLoaderHUD(strMessage: "Uploading Attachment")
        let parameter :NSMutableDictionary = ["token_id":UserDefaultManager.getStringFromUserDefaults(key: kToken)]
        
        if attachment is UIImage{
            let imageData:Data = UIImageJPEGRepresentation(attachment as! UIImage, uploadImageCompression)!
            parameter.setObject([imageData], forKey: ("image[]" as NSString))
        }
        else if attachment is URL{
            parameter.setObject([attachment], forKey: ("image[]" as NSString))
        }
        
        HttpRequestManager.sharedInstance.delegate = self; HttpRequestManager.sharedInstance.requestWithPostMultipartParam(endpointurl: Upload_Chat_Attachment, isImage: true, parameters: parameter) {(data, error, message, responseDict) -> Void in
            
            if error != nil
            {
                hideLoaderHUD()
                showMessageWithRetry(RetryMessage, 3, buttonTapHandler: { _ in
                    hideBanner()
                    self.uploadChatAttachment(attachment: attachment)
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
                        let strMediaURL = "\(Get_Chat_Attachment_URL)\(thedata!.object(forKey: "data")!)"
                        //print("\(strMediaURL)")
                        
                        if isPathForImage(path: strMediaURL){
                            var section = self.tblchat.numberOfSections - 1
                            if section < 0 { section = 0 }
                            var row = self.tblchat.numberOfRows(inSection: section) - 1
                            if row < 0 { row = 0 }
                            SDWebImageManager.shared().saveImage(toCache: attachment as? UIImage, for: strMediaURL.toUrl)
                            //self.downloadImage(url: strMediaURL,reloadCellAt:row, and: section)
                            
                            /*
                             //Image
                             //------------------>
                             let img : UIImage = (attachment as? UIImage)!
                             var imgName : String = "\(get_fileName_asCurretDateTime())\(get_RandomNo(noOfDigit: 2)).jpg"
                             imgName = strMediaURL.url?.lastPathComponent ?? imgName
                             let imgURL : URL = self.save_MediaContent_inChatDir(image: img, imageName: imgName)!
                             //print("imgURL: \(imgURL)")
                             //------------------>*/
                            
                        }
                        
                        //--------------------------------------------->
                        if isPathForImage(path: strMediaURL) {
                            let img : UIImage = (attachment as? UIImage)!
                            var imgName : String = "\(get_fileName_asCurretDateTime())\(get_RandomNo(noOfDigit: 2)).jpg"
                            imgName = strMediaURL.url?.lastPathComponent ?? imgName
                            
                            let imgURL : URL = save_Content(image: img, imageName: imgName, inDirectory: self.get_URL_inChatDir())!
                            //print("imgURL: \(imgURL)")
                        }
                            //Video
                        else if isPathForVideo(path: strMediaURL) {
                            var videoName : String = "\(get_fileName_asCurretDateTime())\(get_RandomNo(noOfDigit: 2)).mp4"
                            videoName = strMediaURL.url?.lastPathComponent ?? videoName
                            
                            let videoURL : URL = save_Content(contentURL: attachment as! URL, withName: videoName, inDirectory: self.get_URL_inChatDir())!
                            //print("videoURL: \(videoURL)")
                        }
                            //Audio
                        else if isPathForAudio(path: strMediaURL) {
                            var audioFileName : String = "\(get_fileName_asCurretDateTime())\(get_RandomNo(noOfDigit: 2)).m4a"
                            audioFileName = strMediaURL.url?.lastPathComponent ?? audioFileName
                            
                            let audioFileURL : URL = save_Content(contentURL: attachment as! URL, withName: audioFileName, inDirectory: self.get_URL_inChatDir())!
                            //print("audioFileURL: \(audioFileURL)")
                            
                            //Remove temp. taken file
                            removeFile_onURL(fileURL: attachment as! URL)
                        }
                            //Contact
                        else if isPathForContact(path: strMediaURL) {
                            var contactFileName : String = "\(get_fileName_asCurretDateTime())\(get_RandomNo(noOfDigit: 2)).vcf"
                            contactFileName = strMediaURL.url?.lastPathComponent ?? contactFileName
                            
                            let contactFileURL : URL = save_Content(contentURL: attachment as! URL, withName: contactFileName, inDirectory: self.get_URL_inChatDir())!
                            //print("contactFileURL: \(contactFileURL)")
                            
                            //Remove temp. taken file
                            removeFile_onURL(fileURL: attachment as! URL)
                        }
                            //OtherFile/Document
                        else {
                            let documentFileName : String = (strMediaURL.url?.lastPathComponent)!
                            
                            
                            let documentFileURL : URL = save_Content(contentURL: attachment as! URL, withName: documentFileName, inDirectory: self.get_URL_inChatDir())!
                            //print("documentFileURL: \(documentFileURL)")
                            
                            //Remove temp. taken file
                            removeFile_onURL(fileURL: attachment as! URL)
                        }
                        //--------------------------------------------->
                        
                        let dic = [
                            "senderid":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
                            "receiverid":self.selecteduserid ,
                            "textmessage": self.vcfPersonName,
                            "messagetype": "1",
                            "mediaurl": strMediaURL,
                            "platform":PlatformName,
                            "createddate": "",
                            "isdeleted":"0",
                            "isread":"0",
                            "username" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
                            "mutestatus" : CoreDBManager.sharedDatabase.amIMutedByUser(receiverId: self.selecteduserid) ? "1" : "0",
                            "countrycode" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode).replacingOccurrences(of: "+", with: ""),
                            "phonenumber" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)]  as [String : Any]
                        
                        self.newSendMessageWithDic(dic: dic)
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
            HttpRequestManager.sharedInstance.delegate = nil;
        }
    }
}

extension ChatVC:UploadProgressDelegate {
    func didReceivedProgress(progress: Float)
    {
        self.uploadprogress = "\(Int(floor(progress*98)))%"
        //Pu | 22-08-2018
        /*DispatchQueue.main.async {
         if let trackCell = self.tblchat.cellForRow(at: IndexPath(row: self.currentlyCell,
         section: 0)) as? ChatReceiverAttachCell
         {
         //String(format: "%.1f%% of %@", progress * 100, totalSize)
         trackCell.updateDisplay(progress: Float(Int(floor(progress*98))), totalSize: "upload")
         }
         }*/
    }
}

extension ChatVC:UITableViewDelegate,UITableViewDataSource, UIScrollViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 //arrAssortedMsgs.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMsgs.count
        /*let assortedMsgs = arrAssortedMsgs[section]
         return assortedMsgs.Msgs.count*/
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let obj = arrMsgs[indexPath.row]
        /*let assortedMsgs = arrAssortedMsgs[indexPath.section]
         let obj = assortedMsgs.Msgs[indexPath.row] as! StructChat*/
        
        let parentMessage = arrMsgs.first(where: {$0.kid == obj.parentid} )
        var nameReply:String? = "You"
        if parentMessage?.ksenderid != UserDefaultManager.getStringFromUserDefaults(key: kAppUserId){
            nameReply = selectedUser?.kusername
        }
        var messageReply:String? = ""
        if parentMessage != nil{
            messageReply = parentMessage!.kchatmessage.base64Decoded
            if messageReply!.count == 0 {
                if parentMessage!.kmediaurl.count > 0{
                    messageReply = getFileType(for: parentMessage!.kmediaurl)
                }
            }
            
            if parentMessage?.kmessagetype == "2" { messageReply = "Location" }
            else if parentMessage?.kmessagetype == "5" { messageReply = get_ContactName(strMess: (parentMessage?.kchatmessage)!) }
        }
        
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(cellLongPressed(sender:)))
        longPress.accessibilityLabel = "\(indexPath.row)"
        
        //PV
        //var dtvalr = obj.kcreateddate == "" ? "" : timeAgoSinceStrDate(strDate: obj.kcreateddate, numericDates: true)
        var dtvalr = obj.kcreateddate == "" ? "" : timeAgoSinceStrDate(strDate: obj.kcreateddate, numericDates: false)
        
        if obj.isstarred == "1" { dtvalr = "★ \(dtvalr)" }
        
        var bubble = getBubbleImage(objChat: obj)
        var bubbleImg:UIImage? = UIImage()
        //MARK: - RECEIVER Left Side
        if obj.kreceiverid == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId) //leftside
        {
            bubble = "left\(bubble)"
            bubbleImg = UIImage(named:bubble)
            
            if Int(obj.kmessagetype)! > 0
            {
                //MARK: - ChatStoryReplySenderCell
                if obj.kmessagetype == "3"{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatStoryReplySenderCell") as! ChatStoryReplySenderCell
                    
                    let arrDetails = obj.kchatmessage.base64Decoded!.components(separatedBy: kStoryMessageSeparator)
                    
                    cell.lblStatus.text = "Your Status"
                    let storyURL = URL.init(string: arrDetails[1])!
                    if isPathForImage(path: storyURL.path){
                         cell.imgstoryThumbnail.sd_setImage(with: storyURL, placeholderImage: SquarePlaceHolderImage_Chat)
                    }else{
                        DispatchQueue.global().async {
                            let asset = AVAsset(url: storyURL)
                            let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
                            assetImgGenerate.appliesPreferredTrackTransform = true
                            let time = CMTimeMake(1, 2)
                            let img = try? assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                            if img != nil {
                                let frameImg  = UIImage(cgImage: img!)
                                DispatchQueue.main.async(execute: {
                                    cell.imgstoryThumbnail.image = frameImg
                                })
                            }
                        }
                    }
                    
                    cell.replyImageHeight.constant = 0
                    if obj.kmediaurl.count > 0{
                        let tap = UITapGestureRecognizer.init(target: self, action: #selector(storyReplyClicked(_:)))
                        cell.replyImage.addGestureRecognizer(tap)
                        
                        if isPathForImage(path: obj.kmediaurl){
                            cell.replyImageHeight.constant = 169
                            cell.replyImage.sd_setImage(with: obj.kmediaurl.toUrl, placeholderImage: #imageLiteral(resourceName: "imageplaceholder"))
                        }
                    }
                    
                    cell.lblmsg.text = arrDetails[4]
                    cell.lbltime.text = dtvalr //obj.kcreateddate
                    cell.lblmsg.numberOfLines = 0
                    cell.lblmsg.sizeToFit()
                    cell.imgbubble.image = bubbleImg
                    cell.btnView.tag = indexPath.row
                    cell.btnView.accessibilityLabel = "\(indexPath.section)"
                    cell.chatSenderStoryReplyCellDelegate = self
                    
                    cell.selectionStyle = .blue
                    cell.removeGestureRecognizers()
                    cell.addGestureRecognizer(longPress)
                    
                    clickOnReplyButtonInCell(frame: cell.contentView.bounds, view: cell.contentView)
                    
                    return cell;
                }
                //MARK:-  ChatLinkPreviewSenderCell
                if obj.kmessagetype == "4"{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatLinkPreviewSenderCell") as! ChatLinkPreviewSenderCell
                    
                    let arrMedia = obj.kmediaurl.components(separatedBy: kLinkMessageSeparator)
                    let linkURL = arrMedia[0]
                    let linkImage = arrMedia[1]
                    let linkTitle = arrMedia[2]
                    var linkDesc = "-"
                    if arrMedia.count > 3 { linkDesc = arrMedia[3] }
                    
                    cell.imgLinkPreview.contentMode = .scaleAspectFit
                    cell.imgLinkPreview.sd_setImage(with: linkImage.toUrl, completed: { (image, error, cacheType, url) in
                        if error == nil{
                            cell.widthImgLinkPreview.constant = 40
                        }else{
                            cell.widthImgLinkPreview.constant = 0
                        }
                    })
                    
                    cell.btnLink.tag = indexPath.row
                    cell.btnLink.accessibilityLabel = "\(indexPath.section)"
                    cell.chatLinkPreviewSenderCellDelegate = self
                    
                    cell.lblLinkTitle.text = linkTitle
                    cell.lblLinkDescription.text = linkDesc
                    cell.lblLinkUrl.text = linkURL
                    
                    cell.lblmsg.text = obj.kchatmessage.base64Decoded
                    cell.lbltime.text = dtvalr //obj.kcreateddate
                    cell.lblmsg.numberOfLines = 0
                    //cell.lblmsg.sizeToFit()
                    cell.lblmsg.layoutIfNeeded()
                    cell.imgbubble.image = bubbleImg
                    //cell.imgreceipt.image = imgReadReceipt
                    
                    cell.selectionStyle = .blue
                    cell.removeGestureRecognizers()
                    cell.addGestureRecognizer(longPress)
                    
                    if parentMessage != nil {
                        cell.heightReplyView.constant = 48
                        cell.lblMessageReply.text = messageReply
                        cell.lblNameReply.text = nameReply
                    }else{
                        cell.lblMessageReply.text = ""
                        cell.lblNameReply.text = ""
                        cell.heightReplyView.constant = 0
                    }
                    
                    clickOnReplyButtonInCell(frame: cell.contentView.bounds, view: cell.contentView)
                    
                    return cell
                }
                else if obj.kmessagetype == "5" {
                    //MARK:-   Conatct
                    let cell : ChatContactSenderCell = self.manage_ContactCell_Sender(tableView: tableView, indexPath: indexPath)
                    return cell
                }
                
                if isPathForImage(path: obj.kmediaurl) ||  isPathForVideo(path: obj.kmediaurl) || obj.kmessagetype == "2"{
                    //MARK: -  ChatSenderAttachCell
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatSenderAttachCell") as! ChatSenderAttachCell
                    cell.lbltime.text = dtvalr// obj.kcreateddate
                    cell.chatSenderAttachCellDelegate = self
                    cell.btnAttach.tag = indexPath.row
                    cell.btnAttach.accessibilityLabel = "\(indexPath.section)"
                    if isPathForVideo(path: obj.kmediaurl) {
                        cell.imgreceived.image = UIImage.init(color: .black)
                        cell.imgBlurImage_Received.isHidden = true
                        
                        let fileName = obj.kmediaurl.lastPathComponent
                        let replacedFileName = fileName.components(separatedBy: ".").first! + "_thumb.jpg"
                        var strThumbURL = obj.kmediaurl.replacingOccurrences(of: fileName, with: replacedFileName)
                        
                        if strThumbURL.contains("http") == false{
                            strThumbURL = Get_Chat_Attachment_URL + replacedFileName
                        }
                        cell.imgreceived.sd_setImage(with: strThumbURL.toUrl, placeholderImage: PlaceholderImage)
                        
                        //SHOW PLAY ICON ON CELL
                        cell.imgPlayVideo.isHidden = false
                        
                        if ChatAttachmentDownloader.sharedInstance.isDownloading(remoteURL: obj.kmediaurl.toUrl!){
                            cell.lblDownload.text = "Downloading.."
                            cell.heightOfvwDownload.constant = 35
                            cell.downloadIndicator.startAnimating()
                            addBlurAboveImage(cell.imgreceived, 0.9)
                            cell.imgBlurImage_Received.isHidden = false
                            
                            //cell.lbltime.text = self.strUploadProcess //PV
                        }else{
                            if isFileLocallyExist(fileName: obj.kmediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inChatDir()){
                                cell.lblDownload.text = ""
                                cell.heightOfvwDownload.constant = 0
                                cell.downloadIndicator.stopAnimating()
                                cell.imgBlurImage_Received.isHidden = true
                                removeBlurAboveImage(cell.imgreceived)
                            }else{
                                //cell.lblDownload.text = "Download"
                                cell.lblDownload.text = "\(obj.mediasize)"
                                cell.heightOfvwDownload.constant = 35
                                cell.downloadIndicator.stopAnimating()
                                addBlurAboveImage(cell.imgreceived, 0.9)
                            }
                        }
                        
                        if cell.heightOfvwDownload.constant == 0
                        {
                            cell.vwloader.isHidden = true
                            cell.imgloaderbg.isHidden = false
                        }
                        else
                        {
                            if cell.lblDownload.text != ""
                            {
                                cell.vwloader.isHidden = true
                                cell.imgloaderbg.isHidden = false
                            }
                            else
                            {
                                cell.vwloader.isHidden = false
                                cell.imgloaderbg.isHidden = true
                            }
                        }
                        
                    }else if isPathForImage(path: obj.kmediaurl){
                        cell.imgBlurImage_Received.sd_setImage(with: obj.kmediaurl.url, placeholderImage: SquarePlaceHolderImage_Chat)
                        addBlurAboveImage(cell.imgBlurImage_Received, 0.9)
                        cell.imgPlayVideo.isHidden = true
                        cell.imgreceived.image = nil
                        cell.imgreceived.image = SquarePlaceHolderImage_Chat
                        
                        let strURL = obj.kmediaurl
                        let URL = strURL.isValidUrl == true ? strURL.url : "https://".url
                        if ChatAttachmentDownloader.sharedInstance.isDownloading(remoteURL: URL!) {
                            cell.lblDownload.text = "Downloading.."
                            cell.heightOfvwDownload.constant = 35
                            cell.downloadIndicator.startAnimating()
                            cell.imgBlurImage_Received.isHidden = false
                        }else{
                            if isFileLocallyExist(fileName: obj.kmediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inChatDir()) {
                                cell.lblDownload.text = ""
                                cell.heightOfvwDownload.constant = 0
                                cell.downloadIndicator.stopAnimating()
                                
                                let url = getURL_LocallyFileExist(fileName: obj.kmediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inChatDir())
                                do{
                                    let data = try Data.init(contentsOf: url)
                                    let img = UIImage.init(data: data)
                                    cell.imgreceived.image = img
                                    //removeBlurAboveImage(cell.imgreceived)
                                    cell.imgBlurImage_Received.isHidden = true
                                }catch{
                                    print(error.localizedDescription)
                                }
                            }else{
                                //cell.lblDownload.text = "Download"
                                cell.lblDownload.text = "\(obj.mediasize)"
                                cell.heightOfvwDownload.constant = 35
                                cell.downloadIndicator.stopAnimating()
                                cell.imgBlurImage_Received.isHidden = false
                            }
                        }
                        
                        if cell.heightOfvwDownload.constant == 0
                        {
                            cell.vwloader.isHidden = true
                            cell.imgloaderbg.isHidden = false
                        }
                        else
                        {
                            if cell.lblDownload.text != ""
                            {
                                cell.vwloader.isHidden = true
                                cell.imgloaderbg.isHidden = false
                            }
                            else
                            {
                                cell.vwloader.isHidden = false
                                cell.imgloaderbg.isHidden = true
                            }
                        }
                        removeBlurAboveImage(cell.imgreceived)
                        
                        cell.imgreceived.backgroundColor = .clear
                        cell.imgreceived.backgroundColor = SquarePlaceHolderImage_ChatBG
                    }else if obj.kmessagetype == "2"{
                         removeBlurAboveImage(cell.imgreceived)
                        cell.imgPlayVideo.isHidden = true
                        cell.imgreceived.image = #imageLiteral(resourceName: "img_map")
                        cell.imgreceived.isHidden = false
                        cell.imgBlurImage_Received.isHidden = true //-->
                        cell.heightOfvwDownload.constant = 0
                    }
                    
                    //cell.imgBubble.image = bubbleImg
                    
                    cell.selectionStyle = .blue                    
                    cell.removeGestureRecognizers()
                    cell.addGestureRecognizer(longPress)
                    
                    if parentMessage != nil {
                        cell.heightReplyView.constant = 48
                        cell.lblMessageReply.text = messageReply
                        cell.lblNameReply.text = nameReply
                    }else{
                        cell.lblMessageReply.text = ""
                        cell.lblNameReply.text = ""
                        cell.heightReplyView.constant = 0
                    }
                    
                    clickOnReplyButtonInCell(frame: cell.contentView.bounds, view: cell.contentView)
                    
                    return cell;
                }
                else if isPathForContact(path: obj.kmediaurl){
                     //MARK: - ChatContactSenderCell
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatContactSenderCell") as!
                    ChatContactSenderCell
                    cell.lblContact.text = obj.kchatmessage.base64Decoded
                    //cell.imgContact.image = #imageLiteral(resourceName: "profile_pic_register")
                    cell.chatSenderContactCellDelegate = self
                    cell.btnContact.tag = indexPath.row
                    cell.btnContact.accessibilityLabel = "\(indexPath.section)"
                    cell.Lbltime.text = dtvalr
                    cell.imgbubble.image = bubbleImg
                    
                    cell.selectionStyle = .blue
                    cell.removeGestureRecognizers()
                    cell.addGestureRecognizer(longPress)
                    
                    if parentMessage != nil {
                        cell.heightReplyView.constant = 48
                        cell.lblMessageReply.text = messageReply
                        cell.lblNameReply.text = nameReply
                    }else{
                        cell.lblMessageReply.text = ""
                        cell.lblNameReply.text = ""
                        cell.heightReplyView.constant = 0
                    }
                    
                    if ChatAttachmentDownloader.sharedInstance.isDownloading(remoteURL: obj.kmediaurl.toUrl!){
                        cell.btnContact.setTitle("Downloading", for: .normal)
                        cell.downloadIndicator.startAnimating()
                    }else{
                        if isFileLocallyExist(fileName: obj.kmediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inChatDir()){
                            cell.btnContact.setTitle("Add to Contacts", for: .normal)
                            cell.downloadIndicator.stopAnimating()
                        }else{
                            cell.btnContact.setTitle("Download", for: .normal)
                            cell.downloadIndicator.stopAnimating()
                        }
                    }
                    
                    clickOnReplyButtonInCell(frame: cell.contentView.bounds, view: cell.contentView)
                    
                    return cell
                }
                else {
                    //MARK:-  ChatSenderDocumentCell
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatSenderDocumentCell") as! ChatSenderDocumentCell
                    
                    cell.lbltime.text = dtvalr
                    
                    cell.chatSenderDocumentCellDelegate = self
                    cell.btnSenderDocument.tag = indexPath.row
                    cell.btnSenderDocument.accessibilityLabel = "\(indexPath.section)"
                    
                    cell.lblFileType.text = getFileType(for: obj.kmediaurl)
                    cell.imgsent.image = getFileIcon(for: obj.kmediaurl)
                    
                    //*************************
                    cell.lblFileType.text = obj.kchatmessage.base64Decoded?.count != 0 ? obj.kchatmessage.base64Decoded : obj.kmediaurl.lastPathComponent
                    cell.lblFileType.numberOfLines = 2
                    
                    cell.imgbubble.image = bubbleImg
                    
                    cell.selectionStyle = .blue
                    cell.removeGestureRecognizers()
                    cell.addGestureRecognizer(longPress)
                    
                    if parentMessage != nil {
                        cell.heightReplyView.constant = 48
                        cell.lblMessageReply.text = messageReply
                        cell.lblNameReply.text = nameReply
                    }else{
                        cell.lblMessageReply.text = ""
                        cell.lblNameReply.text = ""
                        cell.heightReplyView.constant = 0
                    }
                    if obj.kmediaurl != ""
                    {
                        if ChatAttachmentDownloader.sharedInstance.isDownloading(remoteURL: obj.kmediaurl.toUrl!){
                            cell.downloadIndicator.startAnimating()
                        }else{
                            if isFileLocallyExist(fileName: obj.kmediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inChatDir()){
                                cell.downloadIndicator.stopAnimating()
                            }else{
                                cell.downloadIndicator.stopAnimating()
                            }
                        }
                    }
                    else
                    {
                        cell.downloadIndicator.stopAnimating()
                    }
                    clickOnReplyButtonInCell(frame: cell.contentView.bounds, view: cell.contentView)
                    return cell
                }
            }
            else
            {
                //MARK: - ChatSenderCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatSenderCell") as! ChatSenderCell
                cell.lblmsg.text = obj.kchatmessage.base64Decoded
                cell.lbltime.text = dtvalr //obj.kcreateddate
                cell.lblmsg.numberOfLines = 0
                //cell.lblmsg.sizeToFit()
                cell.lblmsg.layoutIfNeeded()
                cell.imgbubble.image = bubbleImg
                
                cell.selectionStyle = .blue
                cell.removeGestureRecognizers()
                cell.addGestureRecognizer(longPress)
                
                if parentMessage != nil {
                    cell.heightReplyView.constant = 48
                    cell.lblMessageReply.text = messageReply
                    cell.lblNameReply.text = nameReply
                }else{
                    cell.lblMessageReply.text = ""
                    cell.lblNameReply.text = ""
                    cell.heightReplyView.constant = 0
                }
                
                clickOnReplyButtonInCell(frame: cell.contentView.bounds, view: cell.contentView)
                
                return cell;
            }
        }
        else
        {
            //MARK: - SENDER Right Side
            bubble = "right\(bubble)"
            bubbleImg = UIImage(named:bubble)
            
            var imgReadReceipt:UIImage? = #imageLiteral(resourceName: "pending_msg")
            switch obj.kisread {
            case "-1":
                imgReadReceipt = #imageLiteral(resourceName: "pending_msg")
            case "0":
                imgReadReceipt = #imageLiteral(resourceName: "sent_msg")
            case "1":
                imgReadReceipt = #imageLiteral(resourceName: "delivered_msg")
            case "2":
                //imgReadReceipt = #imageLiteral(resourceName: "read_msg")
                let strReadReceipts : String = UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_ReadReceipts)
                if strReadReceipts == "1" { imgReadReceipt =  #imageLiteral(resourceName: "read_msg") }
                else { imgReadReceipt =  #imageLiteral(resourceName: "delivered_msg") }
                
            default:
                break;
            }
            
            //IF THE SELECTED USER HAS BLOCKED THE LOGGED-IN USER THEN DON'T SHOW READ-RECEIPT 
            if (selectedUser?.blocked_contacts.components(separatedBy: ",").contains(UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)))!{
                imgReadReceipt = nil
            }
            
            if Int(obj.kmessagetype)! > 0 {
                if obj.kmessagetype == "3" {
                     //MARK: - ChatStoryReplyReceiverCell
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatStoryReplyReceiverCell") as! ChatStoryReplyReceiverCell
                    
                    let arrDetails = obj.kchatmessage.base64Decoded!.components(separatedBy: kStoryMessageSeparator)
                    
                    cell.lblmsg.text = arrDetails[4]
                    cell.lbltime.text = dtvalr //obj.kcreateddate
                    cell.lblmsg.numberOfLines = 0
                    cell.lblmsg.sizeToFit()
                    cell.imgbubble.image = bubbleImg
                    cell.btnView.tag = indexPath.row
                    cell.btnView.accessibilityLabel = "\(indexPath.section)"
                    cell.chatReceiverStoryReplyCellDelegate = self
                    
                    //cell.lblStatus.text = "\(selectedUser!.kusername) - Status"
                    var strUsername : String = ""
                    strUsername = selectedUser!.kusername
                    let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: selectedUser?.kcountrycode ?? "", phoneNo: selectedUser?.kphonenumber ?? "")
                    if objContactInfo.Name?.count == 0 {
                        strUsername = "+\(selectedUser?.kcountrycode ?? "") \(selectedUser?.kphonenumber ?? "")"
                    }
                    else { strUsername = "\(objContactInfo.Name ?? selectedUser!.kusername)" }
                    cell.lblStatus.text = "\(strUsername) - Status"
                    
                    let storyURL = URL.init(string: arrDetails[1])!
                    if isPathForImage(path: storyURL.path){
                        cell.imgstoryThumbnail.sd_setImage(with: storyURL, placeholderImage: SquarePlaceHolderImage_Chat)
                    }else{
                        DispatchQueue.global().async {
                            let asset = AVAsset(url: storyURL)
                            let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
                            assetImgGenerate.appliesPreferredTrackTransform = true
                            let time = CMTimeMake(1, 2)
                            let img = try? assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                            if img != nil {
                                let frameImg  = UIImage(cgImage: img!)
                                DispatchQueue.main.async(execute: {
                                    cell.imgstoryThumbnail.image = frameImg
                                })
                            }
                        }
                    }
                    
                    cell.replyImageHeight.constant = 0
                    if obj.kmediaurl.count > 0{
                        let tap = UITapGestureRecognizer.init(target: self, action: #selector(storyReplyClicked(_:)))
                        cell.replyImage.addGestureRecognizer(tap)
                        
                        if isPathForImage(path: obj.kmediaurl){
                            cell.replyImageHeight.constant = 169
                             cell.replyImage.sd_setImage(with: obj.kmediaurl.toUrl, placeholderImage: #imageLiteral(resourceName: "imageplaceholder"))
                        }
                    }
                    
                    cell.selectionStyle = .blue
                    cell.removeGestureRecognizers()
                    cell.addGestureRecognizer(longPress)
                    
                    cell.imgreceipt.image = imgReadReceipt
                    
                    clickOnReplyButtonInCell(frame: cell.contentView.bounds, view: cell.contentView)
                    
                    return cell;
                }
                    
                else if obj.kmessagetype == "4"{
                     //MARK: - ChatLinkPreviewReceiverCell
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatLinkPreviewReceiverCell") as! ChatLinkPreviewReceiverCell
                    
                    let arrMedia = obj.kmediaurl.components(separatedBy: kLinkMessageSeparator)
                    let linkURL = arrMedia[0]
                    let linkImage = arrMedia[1]
                    let linkTitle = arrMedia[2]
                    var linkDesc = "-"
                    if arrMedia.count > 3{
                        linkDesc = arrMedia[3]
                    }
                    
                    cell.imgLinkPreview.contentMode = .scaleAspectFit
                    cell.imgLinkPreview.sd_setImage(with: linkImage.toUrl, completed: { (image, error, cacheType, url) in
                        if error == nil{
                            cell.widthImgLinkPreview.constant = 40
                        }else{
                            cell.widthImgLinkPreview.constant = 0
                        }
                    })
                    
                    cell.btnLink.tag = indexPath.row
                    cell.btnLink.accessibilityLabel = "\(indexPath.section)"
                    cell.chatLinkPreviewReceiverCellDelegate = self
                    
                    cell.lblLinkTitle.text = linkTitle
                    cell.lblLinkDescription.text = linkDesc
                    cell.lblLinkUrl.text = linkURL
                    
                    cell.lblmsg.text = obj.kchatmessage.base64Decoded
                    cell.lbltime.text = dtvalr //obj.kcreateddate
                    cell.lblmsg.numberOfLines = 0
                    //cell.lblmsg.sizeToFit()
                    cell.lblmsg.layoutIfNeeded()
                    cell.imgbubble.image = bubbleImg
                    cell.imgreceipt.image = imgReadReceipt
                    
                    cell.selectionStyle = .blue
                    cell.removeGestureRecognizers()
                    cell.addGestureRecognizer(longPress)
                    
                    if parentMessage != nil {
                        cell.heightReplyView.constant = 48
                        cell.lblMessageReply.text = messageReply
                        cell.lblNameReply.text = nameReply
                    }else{
                        cell.lblMessageReply.text = ""
                        cell.lblNameReply.text = ""
                        cell.heightReplyView.constant = 0
                    }
                    
                    clickOnReplyButtonInCell(frame: cell.contentView.bounds, view: cell.contentView)
                    
                    return cell
                }
                else if obj.kmessagetype == "5"{
                    let cell  = self.manage_ContactCell_Receiver(tableView: tableView, indexPath: indexPath)
                    return cell
                }
                
                if isPathForImage(path: obj.kmediaurl) ||  isPathForVideo(path: obj.kmediaurl) || obj.kmessagetype == "2"{
                     //MARK: - ChatReceiverAttachCell
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatReceiverAttachCell") as! ChatReceiverAttachCell
                    cell.lbltime.text = dtvalr //obj.kcreateddate
                    //cell.imgsent.image = obj.kmediaImage
                    cell.chatReceiverAttachCellDelegate = self
                    cell.btnAttach.tag = indexPath.row
                    cell.btnAttach.accessibilityLabel = "\(indexPath.section)"
                    cell.imgsent.image = nil
                    if isPathForVideo(path: obj.kmediaurl)
                    {
                        cell.imgsent.image = UIImage.init(color: .black)
                        
                        let fileName = obj.kmediaurl.lastPathComponent
                        let replacedFileName = fileName.components(separatedBy: ".").first! + "_thumb.jpg"
                        var strThumbURL = obj.kmediaurl.replacingOccurrences(of: fileName, with: replacedFileName)
                        
                        if strThumbURL.contains("http") == false{
                            strThumbURL = Get_Chat_Attachment_URL + replacedFileName
                        }
                        cell.imgsent.sd_setImage(with: strThumbURL.toUrl, placeholderImage: PlaceholderImage)
                        
                        //SHOW PLAY ICON ON CELL
                        cell.imgPlayVideo.isHidden = false
                        
                        if obj.kisread == "-1"{
                            cell.heightOfvwDownload.constant = 35
                            if obj.kid == currentlySendingMessageID{
                                cell.downloadIndicator.startAnimating()
                                cell.lblDownload.text = uploadprogress
                            }else{
                                cell.lblDownload.text = "QUEUED"
                            }
                            //cell.lbltime.text = self.strUploadProcess //PV
                        }else{
                            if ChatAttachmentDownloader.sharedInstance.isDownloading(remoteURL: obj.kmediaurl.toUrl!){
                                cell.lblDownload.text = "Downloading.."
                                cell.heightOfvwDownload.constant = 35
                                cell.downloadIndicator.startAnimating()
                                addBlurAboveImage(cell.imgsent, 0.9)
                                
                                //cell.lbltime.text = self.strUploadProcess //PV
                            }else{
                                if isFileLocallyExist(fileName: obj.kmediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inChatDir()){
                                    cell.lblDownload.text = ""
                                    cell.heightOfvwDownload.constant = 0
                                    cell.downloadIndicator.stopAnimating()
                                    removeBlurAboveImage(cell.imgsent)
                                }else{
                                    //cell.lblDownload.text = "Download"
                                    cell.lblDownload.text = "\(obj.mediasize)"
                                    cell.heightOfvwDownload.constant = 35
                                    cell.downloadIndicator.stopAnimating()
                                    addBlurAboveImage(cell.imgsent, 0.9)
                                }
                                //cell.lbltime.text = self.strUploadProcess //PV
                            }
                        }
                    }
                    else if isPathForImage(path: obj.kmediaurl)
                    {
                        //HIDE PLAY ICON
                        cell.imgPlayVideo.isHidden = true
                        
                        //Set Blur Image
                        print(obj.kmediaurl);
                        cell.imgBlurImage_Send.sd_setImage(with: URL.init(string: obj.kmediaurl), placeholderImage: SquarePlaceHolderImage_Chat)
                      
                        if isFileLocallyExist(fileName: obj.kmediaurl.toUrl!.lastPathComponent, inDirectory: self.URL_dirCurrentChat!)
                        {
                            let url = getURL_LocallyFileExist(fileName: obj.kmediaurl.toUrl!.lastPathComponent, inDirectory: self.URL_dirCurrentChat!)
                            do{
                                let data = try Data.init(contentsOf: url)
                                let img = UIImage.init(data: data)
                                cell.imgBlurImage_Send.image = img
                            }catch{
                                print(error.localizedDescription)
                            }
                        }
                        addBlurAboveImage(cell.imgBlurImage_Send, 0.9)
                        cell.imgsent.image = nil
                        cell.imgsent.image = SquarePlaceHolderImage_Chat
                        
                        //PU
                        if isFileLocallyExist(fileName: obj.kmediaurl.toUrl!.lastPathComponent, inDirectory: self.URL_dirCurrentChat!)
                        {
                            cell.vwDownload.isHidden = true
                            let url = getURL_LocallyFileExist(fileName: obj.kmediaurl.toUrl!.lastPathComponent, inDirectory: self.URL_dirCurrentChat!)
                            do{
                                let data = try Data.init(contentsOf: url)
                                let img = UIImage.init(data: data)
                                cell.imgsent.image = img
                            }catch{
                                print(error.localizedDescription)
                            }
                        }
                        else
                        {
                            cell.vwDownload.isHidden = false
                        }
                        
                        //---> PU
                        
                        if obj.kisread == "-1"{
                            if obj.kid == currentlySendingMessageID{
                                cell.downloadIndicator.startAnimating()
                                cell.lblDownload.text = uploadprogress
                            }else{
                                cell.lblDownload.text = "QUEUED"
                            }
                        }else{
                            if ChatAttachmentDownloader.sharedInstance.isDownloading(remoteURL: obj.kmediaurl.toUrl!){
                                cell.lblDownload.text = "Downloading.."
                                cell.heightOfvwDownload.constant = 35
                                cell.downloadIndicator.startAnimating()
                                cell.imgBlurImage_Send.isHidden = false
                                
                            }else{
                                if isFileLocallyExist(fileName: obj.kmediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inChatDir()){
                                    cell.lblDownload.text = ""
                                    cell.heightOfvwDownload.constant = 0
                                    cell.downloadIndicator.stopAnimating()
                                    
                                    let url = getURL_LocallyFileExist(fileName: obj.kmediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inChatDir())
                                    do{
                                        let data = try Data.init(contentsOf: url)
                                        let img = UIImage.init(data: data)
                                        cell.imgsent.image = img
                                        cell.imgBlurImage_Send.isHidden = true
                                    }catch{
                                        print(error.localizedDescription)
                                    }
                                    
                                }else{
                                    //cell.lblDownload.text = "Download"
                                    cell.lblDownload.text = "\(obj.mediasize)"
                                    cell.heightOfvwDownload.constant = 35
                                    cell.downloadIndicator.stopAnimating()
                                    cell.imgBlurImage_Send.isHidden = false
                                }
                            }
                        }
                        removeBlurAboveImage(cell.imgsent)
                        
                        cell.imgsent.backgroundColor = .clear
                        cell.imgsent.backgroundColor = SquarePlaceHolderImage_ChatBG
                    }else if obj.kmessagetype == "2"{
                          removeBlurAboveImage(cell.imgsent)
                        cell.imgPlayVideo.isHidden = true
                        cell.imgsent.image = #imageLiteral(resourceName: "img_map")
                        cell.imgsent.isHidden = false
                        cell.imgBlurImage_Send.isHidden = true //-->
                        cell.heightOfvwDownload.constant = 0
                        if obj.kisread == "-1"{
                            if obj.kid == currentlySendingMessageID{
                                cell.downloadIndicator.startAnimating()
                            }
                        }else{
                            cell.downloadIndicator.stopAnimating()
                        }
                    }
                    
                    cell.imgreceipt.image = imgReadReceipt
                    //cell.imgBubble.image = bubbleImg
                    
                    cell.selectionStyle = .blue
                    cell.removeGestureRecognizers()
                    cell.addGestureRecognizer(longPress)
                    
                    if parentMessage != nil {
                        cell.heightReplyView.constant = 48
                        cell.lblMessageReply.text = messageReply
                        cell.lblNameReply.text = nameReply
                    }else{
                        cell.lblMessageReply.text = ""
                        cell.lblNameReply.text = ""
                        cell.heightReplyView.constant = 0
                    }
                    
                    clickOnReplyButtonInCell(frame: cell.contentView.bounds, view: cell.contentView)
                    
                    return cell;
                    
                }
                else if isPathForContact(path: obj.kmediaurl){
                    //MARK: - ChatContactReceiverCell
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatContactReceiverCell") as!
                    ChatContactReceiverCell
                    cell.lblContact.text = obj.kchatmessage.base64Decoded
                    //cell.imgContact.image = #imageLiteral(resourceName: "profile_pic_register")
                    cell.chatReceiverContactCellDelegate = self
                    cell.btnContact.tag = indexPath.row
                    cell.btnContact.accessibilityLabel = "\(indexPath.section)"
                    cell.Lbltime.text = dtvalr
                    
                    cell.imgreceipt.image = imgReadReceipt
                    cell.imgbubble.image = bubbleImg
                    
                    cell.selectionStyle = .blue
                    cell.removeGestureRecognizers()
                    cell.addGestureRecognizer(longPress)
                    
                    if parentMessage != nil {
                        cell.heightReplyView.constant = 48
                        cell.lblMessageReply.text = messageReply
                        cell.lblNameReply.text = nameReply
                    }else{
                        cell.lblMessageReply.text = ""
                        cell.lblNameReply.text = ""
                        cell.heightReplyView.constant = 0
                    }
                    
                    if obj.kisread == "-1"{
                        if obj.kid == currentlySendingMessageID{
                            cell.downloadIndicator.startAnimating()
                        }
                    }else{
                        if ChatAttachmentDownloader.sharedInstance.isDownloading(remoteURL: obj.kmediaurl.toUrl!){
                            cell.btnContact.setTitle("Downloading", for: .normal)
                            cell.downloadIndicator.startAnimating()
                        }else{
                            if isFileLocallyExist(fileName: obj.kmediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inChatDir()){
                                cell.btnContact.setTitle("View Contact", for: .normal)
                                cell.downloadIndicator.stopAnimating()
                            }else{
                                cell.btnContact.setTitle("Download", for: .normal)
                                cell.downloadIndicator.stopAnimating()
                            }
                        }
                    }
                    
                    clickOnReplyButtonInCell(frame: cell.contentView.bounds, view: cell.contentView)
                    
                    return cell
                }
                else{
                    //MARK: - ChatReceiverDocumentCell
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatReceiverDocumentCell") as! ChatReceiverDocumentCell
                    
                    cell.lbltime.text = dtvalr
                    
                    cell.chatReceiverDocumentCellDelegate = self
                    cell.btnReceiverDocument.tag = indexPath.row
                    cell.btnReceiverDocument.accessibilityLabel = "\(indexPath.section)"
                    
                    cell.lblFileType.text = getFileType(for: obj.kmediaurl)
                    cell.imgsent.image = getFileIcon(for: obj.kmediaurl)
                    
                    //*************************
                    cell.lblFileType.text = obj.kchatmessage.base64Decoded?.count != 0 ? obj.kchatmessage.base64Decoded : obj.kmediaurl.lastPathComponent
                    cell.lblFileType.numberOfLines = 2
                    
                    cell.imgreceipt.image = imgReadReceipt
                    cell.imgbubble.image = bubbleImg
                    
                    cell.selectionStyle = .blue
                    cell.removeGestureRecognizers()
                    cell.addGestureRecognizer(longPress)
                    
                    if parentMessage != nil {
                        cell.heightReplyView.constant = 48
                        cell.lblMessageReply.text = messageReply
                        cell.lblNameReply.text = nameReply
                    }else{
                        cell.lblMessageReply.text = ""
                        cell.lblNameReply.text = ""
                        cell.heightReplyView.constant = 0
                    }
                    
                    if obj.kisread == "-1"{
                        if obj.kid == currentlySendingMessageID{
                            cell.downloadIndicator.startAnimating()
                        }
                    }else{
                        if obj.kmediaurl != "" {
                            if ChatAttachmentDownloader.sharedInstance.isDownloading(remoteURL: obj.kmediaurl.toUrl!){
                                cell.downloadIndicator.startAnimating()
                            }else{
                                if isFileLocallyExist(fileName: obj.kmediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inChatDir()){
                                    cell.downloadIndicator.stopAnimating()
                                }else{
                                    cell.downloadIndicator.stopAnimating()
                                }
                            }}
                    }
                    clickOnReplyButtonInCell(frame: cell.contentView.bounds, view: cell.contentView)
                    
                    return cell
                }
            }
            else
            {
                 //MARK: - ChatReceiverDocumentCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatReceiverCell") as! ChatReceiverCell
                
                cell.lblmsg.text = obj.kchatmessage.base64Decoded
                cell.lbltime.text = dtvalr //obj.kcreateddate
                cell.lblmsg.numberOfLines = 0
                //cell.lblmsg.sizeToFit()
                cell.lblmsg.layoutIfNeeded()
                cell.imgbubble.image = bubbleImg
                cell.imgreceipt.image = imgReadReceipt
                
                cell.selectionStyle = .blue
                cell.removeGestureRecognizers()
                cell.addGestureRecognizer(longPress)
                
                if parentMessage != nil {
                    cell.heightReplyView.constant = 48
                    cell.lblMessageReply.text = messageReply
                    cell.lblNameReply.text = nameReply
                }else{
                    cell.lblMessageReply.text = ""
                    cell.lblNameReply.text = ""
                    cell.heightReplyView.constant = 0
                }
                
                clickOnReplyButtonInCell(frame: cell.contentView.bounds, view: cell.contentView)
                
                return cell;
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let intTotalrow = tableView.numberOfRows(inSection:indexPath.section)//first get total rows in that section by current indexPath.
        //get last last row of tablview
        //        if intTotalrow > 5
        //        {
        if indexPath.row == intTotalrow - 1 { scrollbottombtn.alpha = 0 }
        else { scrollbottombtn.alpha = 1 }
        //        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let obj = arrMsgs[indexPath.row]
        /*let assortedMsgs = arrAssortedMsgs[indexPath.section]
        let obj = assortedMsgs.Msgs[indexPath.row] as! StructChat*/
        
        let parentMessage = arrMsgs.first(where: {$0.kid == obj.parentid} )
        
        if Int(obj.kmessagetype)! > 0 {
            if obj.kmessagetype == "3" || obj.kmessagetype == "4" {
                return UITableViewAutomaticDimension
            }
            
            if obj.kmessagetype == "5" {
                if (obj.parentid != "0") { return 172 }
                else { return 124 }
            }
            
            if isPathForImage(path: obj.kmediaurl) ||  isPathForVideo(path: obj.kmediaurl) || obj.kmessagetype == "2"{
                if parentMessage != nil {
                    return 222
                }else{
                    return 167
                }
                //return 230//175
            }else if isPathForContact(path: obj.kmediaurl){
                if parentMessage != nil {
                    return 172
                }else{
                    return 124
                }
                //return 117//51
            }
            else{
                if parentMessage != nil {
                    return 128
                }else{
                    return 80
                }
                //return 142 //68 //DOCUMENT
            }
        }
        else
        {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectOrDeselectCell(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectOrDeselectCell(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if selectedUser != nil{
            if ContactSync.shared.isUserInContacts(chatUser: selectedUser!) == false{
                if didISendAnyMessageToThisChat(){
                    return nil
                }
                let footerView = UIView.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: tableView.frame.width, height: 150)))
                
                let width = footerView.frame.width - 10
                
                let label = UILabel.init(frame: CGRect.init(origin: CGPoint.init(x: 10, y: 9), size: CGSize.init(width: width, height: 12)))
                label.font = UIFont.init(name: FT_Light, size: 11)
                label.textColor = .gray
                label.text = "This sender is not in your contact list."
                
                let buttonFont = UIFont.init(name: FT_Bold, size: 13)
                
                let btnReportSpamFrame = CGRect.init(origin: CGPoint.init(x: 10, y:(label.frame.origin.y + label.frame.height)), size: CGSize.init(width: width, height: 43))
                let btnBlockFrame = CGRect.init(origin: CGPoint.init(x: 10, y: (btnReportSpamFrame.origin.y + btnReportSpamFrame.height)), size: CGSize.init(width: width, height: 43))
                let btnAddContactFrame = CGRect.init(origin: CGPoint.init(x: 10, y: (btnBlockFrame.origin.y + btnReportSpamFrame.height)), size: CGSize.init(width: width, height: 43))
                
                let btnReportSpam = UIButton.init(frame: btnReportSpamFrame)
                btnReportSpam.setTitle("   REPORT SPAM", for: .normal)
                btnReportSpam.setTitleColor(themeWakeUppColor, for: .normal)
                btnReportSpam.titleLabel?.font = buttonFont
                btnReportSpam.contentHorizontalAlignment = .left
                btnReportSpam.setImage(#imageLiteral(resourceName: "reposrtspam"), for: .normal)
                btnReportSpam.addTarget(self, action: #selector(btnReportSpamClicked(_:)), for: .touchUpInside)
                
                let btnBlock = UIButton.init(frame: btnBlockFrame)
                btnBlock.setTitle("   BLOCK", for: .normal)
                btnBlock.setTitleColor(themeWakeUppColor, for: .normal)
                btnBlock.titleLabel?.font = buttonFont
                btnBlock.contentHorizontalAlignment = .left
                btnBlock.setImage(#imageLiteral(resourceName: "blockuser"), for: .normal)
                btnBlock.addTarget(self, action: #selector(btnBlockClicked(_:)), for: .touchUpInside)
                if (APP_DELEGATE.User_Exists_inBlockContactList(strUserID: self.selecteduserid) == true) {
                    btnBlock.setTitle("   UNBLOCK", for: .normal)
                }
                
                let btnAddContact = UIButton.init(frame: btnAddContactFrame)
                btnAddContact.setTitle("   ADD TO CONTACTS", for: .normal)
                btnAddContact.setTitleColor(themeWakeUppColor, for: .normal)
                btnAddContact.titleLabel?.font = buttonFont
                btnAddContact.contentHorizontalAlignment = .left
                btnAddContact.setImage(#imageLiteral(resourceName: "addtocontact"), for: .normal)
                btnAddContact.addTarget(self, action: #selector(btnAddToContactsClicked(_:)), for: .touchUpInside)
                
                footerView.addSubviews([label, btnReportSpam, btnBlock, btnAddContact])
                
                return footerView
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if selectedUser != nil{
            if ContactSync.shared.isUserInContacts(chatUser: selectedUser!) == false{
                if didISendAnyMessageToThisChat(){
                    return 0
                }
                return 150
            }
        }
        return 0
    }
    
    func didISendAnyMessageToThisChat()->Bool{
        let arrSenderIDs = arrMsgs.map({$0.ksenderid})
        let loggedInUserID = UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)
        if arrSenderIDs.contains(loggedInUserID){
            return true
        }
        return false
    }
    
    func selectOrDeselectCell(at indexPath:IndexPath){
        if tblchat.isEditing{
            if arrSelectedIndexes.contains(indexPath.row){
                arrSelectedIndexes.remove(at: arrSelectedIndexes.index(of: indexPath.row)!)
            }else{
                arrSelectedIndexes.append(indexPath.row)
                
                //PV
                //AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate)) //Vibrate the device
            }
            vwEditingTitle.text = "\(arrSelectedIndexes.count)"
            
            if arrSelectedIndexes.count == 1{
                btnReplyWidth.constant = 35
            }else{
                btnReplyWidth.constant = 0
            }
            
            var isAnyMediaMessage = false
            for index in arrSelectedIndexes{
                let model = arrMsgs[index]
                if Int(model.kmessagetype)! > 0{
                    isAnyMediaMessage = true
                    break
                }
            }
            if isAnyMediaMessage{
                btnCopyWidth.constant = 0
            }else{
                btnCopyWidth.constant = 35
            }
            self.view.endEditing(true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle(rawValue: 3)!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle:   UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if (editingStyle == .delete)
        {
        }
    }
    
    @objc func cellLongPressed(sender:UILongPressGestureRecognizer) {
        //showEditingNavBar()
        
        let index = Int(sender.accessibilityLabel!)!
        let model = arrMsgs[index]
        //print("Message : \(model.kchatmessage.base64Decoded!)")
        
        if model.ksenderid == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId) {
            let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let actionInfo = UIAlertAction.init(title: "Info", style: .default, handler: { (action) in
                let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: "ReadInfoVC") as! ReadInfoVC
                vc.selectedChatID = model.kid
                vc.objEnumReadInfo = .ReadInfo_PersonalChat
                APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
            })
            alert.addAction(actionInfo)
            
            let actionMore = UIAlertAction.init(title: "More", style: .default, handler: { (action) in
                self.showEditingNavBar()
            })
            alert.addAction(actionMore)
            
            let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(actionCancel)
            
            present(alert, animated: true, completion: nil)
        }
        else { showEditingNavBar() }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let frame = CGRect(x:3,y: 3,width: tableView.frame.size.width-3,height: 35)
        let view = UIView(frame:frame)
        view.backgroundColor = UIColor.clear
        view.autoresizingMask = .flexibleWidth
        let label = UILabel.init(frame: CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: CGSize.init(width: view.width - 85, height: view.height - 5)))
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        
        /*let assortedMsgs = arrAssortedMsgs[section]
         
         var strDate = assortedMsgs.Date
         strDate = DateFormater.convertDateForChatMessage(givenDate: strDate)
         
         label.text = strDate*/
        label.text = "🔒 Messages to this chat are secured with end-to-end encryption."
        label.textAlignment = .center
        label.sizeToFit()
        label.center = view.center
        label.backgroundColor = Color_RGBA(238, 233, 230, 1)
        label.textColor = UIColor.darkGray
        label.font = UIFont.init(name: FT_Regular, size: 13)
        label.layer.cornerRadius = 3
        label.layer.masksToBounds = true
        label.autoresizingMask = []
        view.addSubview(label)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapChatHeader))
        view.addGestureRecognizer(tap)
        
        return view
    }
    
    func tableViewScrollToBottomAnimated(animated:Bool)
    {
        /*if(self.arrMsgs.count > 0)
         {
         self.tblchat.scrollToRow(at: IndexPath(item:self.arrMsgs.count-1, section: 0), at: .bottom, animated: animated)
         //            self.tblchat.setContentOffset(CGPoint(x: 0, y: (self.tblchat.contentSize.height - self.tblchat.frame.height)), animated: animated)
         }*/
        
        // First figure out how many sections there are
        let lastSectionIndex = self.tblchat!.numberOfSections - 1
        
        if lastSectionIndex >= 0{
            // Then grab the number of rows in the last section
            let lastRowIndex = self.tblchat!.numberOfRows(inSection: lastSectionIndex) - 1
            
            if lastRowIndex >= 0{
                // Now just construct the index path
                let pathToLastRow = IndexPath(row: lastRowIndex, section: lastSectionIndex)
                
                // Make the last row visible
                //self.tblchat.scrollToRow(at: pathToLastRow, at: .bottom, animated: animated)
                UIView.performWithoutAnimation {
                    self.tblchat.scrollToRow(at: pathToLastRow, at: .bottom, animated: animated)
                    self.scrollbottombtn.alpha = 0
                }
            }
        }
    }
    
    func tableViewScrollToTopAnimated(animated:Bool){
        if tblchat.numberOfRows(inSection: 0) > 0 {
            let pathToLastRow = IndexPath(row: 0, section: 0)
            self.tblchat.scrollToRow(at: pathToLastRow, at: .top, animated: animated)
        }
    }
    
    @objc func updateAudioCellProgressView(timer:Timer){
        if audioPlayer?.isPlaying != nil && (audioPlayer?.isPlaying)!
        {
            let userInfo = timer.userInfo as! [String:Any]
            let cell = userInfo["cell"]
            if cell is ChatReceiverAudioCell{
                let audioCell = cell as! ChatReceiverAudioCell
                audioCell.audioSlider.setValue(Float(audioPlayer!.currentTime/audioPlayer!.duration), animated: true)
            }else{
                let audioCell = cell as! ChatSenderAudioCell
                audioCell.audioSlider.setValue(Float(audioPlayer!.currentTime/audioPlayer!.duration), animated: true)
            }
        }
    }
    
    @objc func tapChatHeader(){
        let alert = UIAlertController.init(title: nil, message: "Messages to this chat are now secured with end-to-end encryption.", preferredStyle: .alert)
        
        let actionLearnMore = UIAlertAction.init(title: "Learn More", style: .default) { (action) in
            
        }
        alert.addAction(actionLearnMore)
        
        let actionOk = UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(actionOk)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func btnReportSpamClicked(_ sender:UIButton){
        let confirm = UIAlertController.init(title: "Report spam and block this contacts?", message: "If you report and block, this chat's history will also be deleted.", preferredStyle: .actionSheet)
        
        let action_yes = UIAlertAction.init(title: "Report and block", style: .destructive) { (action) in
            
            //Block Contact
            APP_DELEGATE.AddUser_BlockContactList(strUserID: self.selecteduserid)
            let parameter_blockUser:NSDictionary = ["service":APIBlockUser,
                                                    "request":["block_user_id":self.selecteduserid, "action":"block"],
                                                    "auth" : getAuthForService()]
            self.api_BlockUser(parameter: parameter_blockUser, loaderMess: "")
            
            //Clear Chat mess.
            CoreDBManager.sharedDatabase.deleteAllChatMessagesWith(userId: self.selecteduserid)
            
            //Report Spam
            let parameter_spam:NSDictionary = ["service":APIReportSpam,
                                               "request":["spam_id":self.selecteduserid, "action":"user"],
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
    
    @objc func btnBlockClicked(_ sender:UIButton){
        var strAlertTitle : String = ""
        var strMess : String = ""
        var strUserBlockStatus : String = "block"
        
        if (APP_DELEGATE.User_Exists_inBlockContactList(strUserID: self.selecteduserid) == false) {
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
                APP_DELEGATE.AddUser_BlockContactList(strUserID: self.selecteduserid)
                //self.viewManangeChat.isHidden = true
            }
            else {
                APP_DELEGATE.RemoveUser_BlockContactList(strUserID: self.selecteduserid)
                //self.viewManangeChat.isHidden = false
            }
            
            //Set parameter for Called WebService
            let parameter:NSDictionary = ["service":APIBlockUser,
                                          "request":["block_user_id":self.selecteduserid, "action":strUserBlockStatus],
                                          "auth" : getAuthForService()]
            self.api_BlockUser(parameter: parameter, loaderMess: "")
        }
        confirmAlert.addAction(action_yes)
        
        let action_no = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        confirmAlert.addAction(action_no)
        
        present(confirmAlert, animated: true, completion: nil)
    }
    
    func getReadStatus(strStatus : String) ->  UIImage {
        var imgReadReceipt:UIImage? = #imageLiteral(resourceName: "pending_msg")
        switch strStatus {
        case "-1":
            imgReadReceipt = #imageLiteral(resourceName: "pending_msg")
        case "0":
            imgReadReceipt = #imageLiteral(resourceName: "sent_msg")
        case "1":
            imgReadReceipt = #imageLiteral(resourceName: "delivered_msg")
        case "2":
            //imgReadReceipt = #imageLiteral(resourceName: "read_msg")
            let strReadReceipts : String = UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_ReadReceipts)
            if strReadReceipts == "1" { imgReadReceipt =  #imageLiteral(resourceName: "read_msg") }
            else { imgReadReceipt =  #imageLiteral(resourceName: "delivered_msg") }
        default:
            break;
        }
        return imgReadReceipt!
    }
    
    //MARK: Tableview Cell Button action method
    @objc func btnAddToContactsClicked(_ sender:UIButton){
        addToContacts()
    }
    
    //MARK: Tableview Cell - Contact
    @objc func manage_ContactCell_Sender(tableView: UITableView,  indexPath : IndexPath) ->  ChatContactSenderCell{
        let obj = arrMsgs[indexPath.row]
        let dataValue = obj.kcreateddate == "" ? "" : timeAgoSinceStrDate(strDate: obj.kcreateddate, numericDates: false)
        
        var bubble = getBubbleImage(objChat: obj)
        var bubbleImg:UIImage? = UIImage()
        //bubble = "right\(bubble)"
        bubble = "left\(bubble)"
        bubbleImg = UIImage(named:bubble)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatContactSenderCell") as! ChatContactSenderCell
        cell.chatSenderContactCellDelegate = self
        
        //cell.imgContact.image = #imageLiteral(resourceName: "profile_pic_register")
        cell.imgbubble.image = bubbleImg
        
        cell.lblContact.text = get_ContactName(strMess: obj.kchatmessage)
        
        cell.btnContact.tag = indexPath.row
        cell.btnContact.accessibilityLabel = "\(indexPath.section)"
        cell.btnContact.setTitle("View", for: .normal)
        var strButtonTitle : String = get_ContactButtonTitle(strMess: obj.kchatmessage)
        if strButtonTitle.uppercased() == "Message".uppercased() { strButtonTitle = "Save Contact" }
        cell.btnContact.setTitle(strButtonTitle, for: .normal)
        
        cell.Lbltime.text = dataValue
        
        //---------------------->
        if (obj.parentid == "0") {
            cell.heightReplyView.constant = 0
            
            cell.lblMessageReply.text = ""
            cell.lblNameReply.text = ""
        } else {
            let parentMessage = arrMsgs.first(where: {$0.kid == obj.parentid} )
            var nameReply:String? = ""
            var messageReply:String? = ""
            
            if parentMessage != nil{
                //NameReply
                if parentMessage?.ksenderid != UserDefaultManager.getStringFromUserDefaults(key: kAppUserId) { nameReply = selectedUser?.kusername }
                else { nameReply = "You" }
                
                //Message Reply
                if parentMessage?.kmessagetype == "2" { messageReply = "Location" }
                else if parentMessage?.kmessagetype == "5" { messageReply = get_ContactName(strMess: (parentMessage?.kchatmessage)!) }
                else { messageReply = parentMessage!.kchatmessage.base64Decoded }
                
                if messageReply!.count == 0 {
                    if parentMessage!.kmediaurl.count > 0 { messageReply = getFileType(for: parentMessage!.kmediaurl) }
                }
            }
            
            cell.heightReplyView.constant = 48
            cell.lblMessageReply.text = messageReply
            cell.lblNameReply.text = nameReply
        }
        
        /*if ChatAttachmentDownloader.sharedInstance.isDownloading(remoteURL: obj.kmediaurl.toUrl!){
         cell.btnContact.setTitle("Downloading", for: .normal)
         cell.downloadIndicator.startAnimating()
         }else{
         if isFileLocallyExist(fileName: obj.kmediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inChatDir()){
         cell.btnContact.setTitle("Add to Contacts", for: .normal)
         cell.downloadIndicator.stopAnimating()
         }else{
         cell.btnContact.setTitle("Download", for: .normal)
         cell.downloadIndicator.stopAnimating()
         }
         }*/
        
        cell.selectionStyle = .blue
        cell.removeGestureRecognizers()
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(cellLongPressed(sender:)))
        longPress.accessibilityLabel = "\(indexPath.row)"
        cell.addGestureRecognizer(longPress)
        
        clickOnReplyButtonInCell(frame: cell.contentView.bounds, view: cell.contentView)
        
        return cell
    }
    
    @objc func manage_ContactCell_Receiver(tableView: UITableView,  indexPath : IndexPath) -> ChatContactReceiverCell {
        let obj = arrMsgs[indexPath.row]
        let dateValue = obj.kcreateddate == "" ? "" : timeAgoSinceStrDate(strDate: obj.kcreateddate, numericDates: false)
        
        var bubble = getBubbleImage(objChat: obj)
        var bubbleImg:UIImage? = UIImage()
        //bubble = "left\(bubble)"
        bubble = "right\(bubble)"
        bubbleImg = UIImage(named:bubble)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatContactReceiverCell") as! ChatContactReceiverCell
        cell.chatReceiverContactCellDelegate = self
        
        //cell.imgContact.image = #imageLiteral(resourceName: "profile_pic_register")
        //cell.imgreceipt.image = imgReadReceipt
        cell.imgbubble.image = bubbleImg
        
        cell.lblContact.text = get_ContactName(strMess: obj.kchatmessage)
        
        cell.btnContact.tag = indexPath.row
        cell.btnContact.accessibilityLabel = "\(indexPath.section)"
        cell.btnContact.setTitle("View", for: .normal)
        var strButtonTitle : String = get_ContactButtonTitle(strMess: obj.kchatmessage)
        if strButtonTitle.uppercased() == "Message".uppercased() { strButtonTitle = "View Contact" }
        cell.btnContact.setTitle(strButtonTitle, for: .normal)
        
        cell.Lbltime.text = dateValue
        
        cell.imgreceipt.image = self.getReadStatus(strStatus: obj.kisread)
        if obj.kisread == "-1" {
            if obj.kid == currentlySendingMessageID { cell.downloadIndicator.startAnimating() }
            else {  cell.downloadIndicator.stopAnimating() }
        }
        
        ///---------------------->
        if (obj.parentid == "0") {
            cell.heightReplyView.constant = 0
            cell.lblMessageReply.text = ""
            cell.lblNameReply.text = ""
        }
        else {
            let parentMessage = arrMsgs.first(where: {$0.kid == obj.parentid} )
            var nameReply:String? = ""
            var messageReply:String? = ""
            
            if parentMessage != nil{
                //NameReply
                if parentMessage?.ksenderid != UserDefaultManager.getStringFromUserDefaults(key: kAppUserId) {
                    nameReply = selectedUser?.kusername
                }
                else { nameReply = "You" }
                
                //Message Reply
                if parentMessage?.kmessagetype == "2" { messageReply = "Location" }
                else if parentMessage?.kmessagetype == "5" { messageReply = get_ContactName(strMess: (parentMessage?.kchatmessage)!) }
                else { messageReply = parentMessage!.kchatmessage.base64Decoded }
                
                if messageReply!.count == 0 {
                    if parentMessage!.kmediaurl.count > 0 { messageReply = getFileType(for: parentMessage!.kmediaurl) }
                }
            }
            cell.heightReplyView.constant = 48
            cell.lblMessageReply.text = messageReply
            cell.lblNameReply.text = nameReply
        }
        //-------------->
        
        cell.selectionStyle = .blue
        cell.removeGestureRecognizers()
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(cellLongPressed(sender:)))
        longPress.accessibilityLabel = "\(indexPath.row)"
        cell.addGestureRecognizer(longPress)
        
        clickOnReplyButtonInCell(frame: cell.contentView.bounds, view: cell.contentView)
        
        return cell
    }
    
    func btnSenderContactClicked(_ sender: UIButton) {
        let obj = arrMsgs[sender.tag]
        
        if isPathForContact(path: obj.kmediaurl) {
            let section = Int(sender.accessibilityLabel!)!
            self.openAttachment(atRow: sender.tag, inSection: section)
            return
        }
            
        var strButtonTitle : String = get_ContactButtonTitle(strMess: obj.kchatmessage)
        if strButtonTitle.uppercased() == "Message".uppercased() { strButtonTitle = "Save Contact" }
        if strButtonTitle.uppercased() == "Message".uppercased() {
            /*let arrPhoneNo = get_Contact_PhoneNoList(strMess: obj.textmessage)
             if arrPhoneNo.count > 0 {
             var strPhoneNo : String = arrPhoneNo[0]
             //if strPhoneNo.contains("+") { strPhoneNo = strPhoneNo.replacingCharacters(in: "+", with: "") }
             //self.apiCheckUser_andStartChat(strContactNo: , strPhoneNo: <#T##String#>)
             return
             }
             //show
             return*/
        }
        else if strButtonTitle.uppercased() == "Save Contact".uppercased() {
            let contact = get_ContactObj(strMess: obj.kchatmessage)
            let controller = CNContactViewController(forNewContact: contact[0])
            controller.delegate = self
            controller.allowsActions = false
            
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.navigationBar.backgroundColor = UIColor.white
            self.navigationController?.navigationBar.topItem?.title = "Back"
            APP_DELEGATE.appNavigation?.pushViewController(controller, animated: true)
            return
        }
        let contact = get_ContactObj(strMess: obj.kchatmessage)
        
        let objVC : ContactsSendVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ContactsSendVC" ) as! ContactsSendVC
        objVC.delegate = self
        objVC.arrContact = contact
        
        objVC.objEnumContact = .contact_View
        APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
    }
    
    func btnReceiverContactClicked(_ sender: UIButton) {
        //You send Contact
        let obj = arrMsgs[sender.tag]
        if isPathForContact(path: obj.kmediaurl) {
            let section = Int(sender.accessibilityLabel!)!
            self.openAttachment(atRow: sender.tag, inSection: section)
            return
        }
        
        let contact = get_ContactObj(strMess: obj.kchatmessage)
        
        /*let strButtonTitle : String = get_ContactButtonTitle(strMess: obj.textmessage)
         if strButtonTitle.uppercased() == "Message".uppercased() {
         let arrPhoneNo = get_Contact_PhoneNoList(strMess: obj.textmessage)
         if arrPhoneNo.count > 0 {
         let strPhoneNo : String = arrPhoneNo[0]
         let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: "", phoneNo: strPhoneNo)
         
         if objContactInfo.CountryCode_PhoneNo == strPhoneNo {
         var objUser = CoreDBManager.sharedDatabase.getFriendList(includeHiddens: false) as! [StructChat]
         objUser = objUser.filter({$0.ishidden == "1"})
         }
         //let objContactData : StructChat = CoreDBManager.sharedDatabase.getFriendById(userID: <#T##String#>)
         }
         //self.start_PersonalChat(user: user)
         return
         }*/
        
        let objVC : ContactsSendVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ContactsSendVC" ) as! ContactsSendVC
        objVC.delegate = self
        objVC.arrContact = contact
        objVC.objEnumContact = .contact_View
        objVC.redirrectfrom = "ChatContactReceiverCell"
        APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
    }
}

extension ChatVC
{
    func saveSendMessage(messageDic:[String:String]){
        
    }
    
    func openAttachmentView(){
        if isDNDActive == true{
            return
        }
        self.clickedattach = true
        if selectedMessageForReply == nil{
            self.vwattach.accessibilityValue = "\(self.inputvalues.frame.origin.y - self.vwattach.frame.size.height)"
        }else{
            self.vwattach.accessibilityValue = "\(self.inputvalues.frame.origin.y - self.vwattach.frame.size.height - 49)"
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.inputvalues.leftButton.transform = CGAffineTransform.init(rotationAngle:  (.pi/2))
            self.vwattach.viewSlideIn()
        }) { (done) in
            
        }
    }
    
    func closeAttachmentView( completion: @escaping () -> () ){
        self.clickedattach = false
        if selectedMessageForReply == nil{
            self.vwattach.accessibilityValue = "\(self.inputvalues.frame.origin.y)"
        }else{
            self.vwattach.accessibilityValue = "\(self.inputvalues.frame.origin.y + 49)"
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.inputvalues.leftButton.transform = CGAffineTransform.init(rotationAngle:  0)
            self.vwattach.viewDismiss()
        }) { (done) in
            completion()
        }
    }
    
    func inputbarDidBecomeFirstResponder(inputbar:Inputbar)
    {
        
    }
    func inputbarDidChangeHeight(newHeight:CGFloat)
    {
        self.view.keyboardTriggerOffset = newHeight
        setupReplyView()
    }
    
    func newSendMessageWithDic(dic:[String:Any]) {
        //if self.selectedUser == nil { return }
        
        if (APP_DELEGATE.User_Exists_inBlockContactList(strUserID: self.selectedUser?.kuserid ?? "") == true) {
            let confirm = UIAlertController.init(title: "Unblock \(self.strTitle) to send a message.", message: nil, preferredStyle: .alert)
            
            let actionYes = UIAlertAction.init(title: "Unblock", style: .destructive, handler: { (action) in
                //Set parameter for Called WebService
                let mess_APILoader = "Unblock \(self.strTitle)"
                let parameter:NSDictionary = ["service":APIBlockUser,
                                              "request":["block_user_id":self.selectedUser?.kuserid, "action":"unblock"],
                                              "auth" : getAuthForService()]
                self.api_BlockUser(parameter: parameter, loaderMess: mess_APILoader)
            })
            confirm.addAction(actionYes)
            
            let actionNo = UIAlertAction.init(title: "Cancel", style: .cancel, handler:nil)
            confirm.addAction(actionNo)
            
            self.present(confirm, animated: true, completion: nil)
            return
        }
        
        var dic = dic
        dic["parent_id"] = selectedMessageForReply?.kid ?? "0"
        dic["blockedByReceiver"] = selectedUser?.blocked_contacts
        hideEditingNavBar()
        if isConnectedToNetwork() && APP_DELEGATE.socketIOHandler?.isSocektConnected() == true{
        }
        fire_eventSend_Messgae(objmsg: dic as NSDictionary)
        tableViewScrollToBottomAnimated(animated: true)
    }
    
    func fire_eventSend_Messgae(objmsg:NSDictionary) {
        if selectedMessageForReply != nil {
            hideReplyView(nil)
        }
        
        let offlineMessageId = getNewPendingMessageID()
        
        var dictionary = [String:Any]()
        dictionary["id"] = String(offlineMessageId)
        dictionary["createddate"] = DateFormater.getStringFromDate(givenDate: NSDate())
        dictionary["platform"] = PlatformName
        dictionary["textmessage"] = objmsg["textmessage"]
        dictionary["receiverid"] = objmsg["receiverid"]
        dictionary["senderid"] = objmsg["senderid"]
        dictionary["sendername"] = UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName)
        dictionary["isdeleted"] = "0"
        dictionary["isread"] = "-1"
        dictionary["mediaurl"] = objmsg["mediaurl"]
        dictionary["messagetype"] = objmsg["messagetype"]
        dictionary["chatid"] = dictionary["id"]
        dictionary["image"] = ""
        dictionary["is_online"] = "0"
        dictionary["last_login"] = ""
        dictionary["username"] = ""
        dictionary["user_id"] = ""
        dictionary["muted_by_me"] = CoreDBManager.sharedDatabase.amIMutedByUser(receiverId: selecteduserid) ? "1" : "0"
        dictionary["country_code"] = UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode).replacingOccurrences(of: "+", with: "")
        dictionary["phoneno"]  = UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)
        dictionary["blocked_contacts"] = selectedUser?.blocked_contacts
        dictionary["parent_id"] = selectedMessageForReply?.kid ?? "0"
        
        let chatMessage = StructChat.init(dictionary: dictionary)
        print(chatMessage)
        _ = CoreDBManager.sharedDatabase.saveMessageInLocalDB(objmessgae: chatMessage)
        
        //reloadTable()
        arrMsgs = CoreDBManager.sharedDatabase.getChatMessagesForUserID(userId: self.selecteduserid, includeDeleted: false).sorted(by: { Float($0.kid)! < Float($1.kid)! }) //----> Old
        
        let sentMsgs = arrMsgs.filter({ $0.kid.contains(".") == false })
        let pendingMsgs = arrMsgs.filter({$0.kid.contains(".")})
        arrMsgs = sentMsgs + pendingMsgs
        
        if arrMsgs.count > 0 { setAllMessagesToRead() }

        
        UIView.setAnimationsEnabled(false)
        self.tblchat.beginUpdates()
        self.tblchat.insertRows(at: [IndexPath(row: (self.arrMsgs.count)-1, section: 0)], with: .none)
        self.tblchat.endUpdates()
        
        UIView.performWithoutAnimation {
            self.tblchat.scrollToRow(at: (IndexPath(row:(self.arrMsgs.count)-1, section:0)) as IndexPath, at:.bottom, animated:false)
        }
        
        UIView.setAnimationsEnabled(true)
        
        //Pu | 22-08-2018
        //let idx =  arrMsgs.index(where: { $0.kid == objmsg["uniqueid"] as! String})
        //currentlyCell = idx!
        
        sendPendingMessages()
    }
    
    @objc func sendPendingMessages(){
        
        if isConnectedToNetwork() && APP_DELEGATE.socketIOHandler!.isSocektConnected(){
            
            let pendingMessages = self.arrMsgs.filter({$0.kisread == "-1"})
            
            if pendingMessages.count == 0 || currentlySendingMessageID.count > 0 { return }
            
            let message = pendingMessages.first!
            let objmsg = [
                "iospkid" : message.kid,
                "senderid":message.ksenderid,
                "receiverid":message.kreceiverid ,
                "textmessage": message.kchatmessage,
                "messagetype": message.kmessagetype,
                "mediaurl": message.kmediaurl,
                "platform":PlatformName,
                "createddate": message.kcreateddate,
                "isdeleted":"0",
                "isread":"0",
                "username" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
                "mutestatus" : CoreDBManager.sharedDatabase.amIMutedByUser(receiverId: selecteduserid) ? "1" : "0",
                "countrycode" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode).replacingOccurrences(of: "+", with: ""),
                "phonenumber" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile),
                "mediasize":fileSize(url: message.kmediaurl.toUrl),
                "parent_id" : message.parentid
            ]
            
            currentlySendingMessageID = objmsg["iospkid"]!
            
            //Pu | 22-08-2018
            //let idx =  arrMsgs.index(where: { $0.kid == objmsg["uniqueid"]!})
            //currentlyCell = idx!
            
            if objmsg["messagetype"] == "1"{
                uploadAttachmentAndSendMessageThroughSocket(objmsg:objmsg)
            }else{
                sendMessageThroughSocket(objmsg:objmsg)
            }
            //}
        }
    }
    
    func sendMessageThroughSocket(objmsg:[String:Any]){
        //print(objmsg)
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck(keySendMessage,objmsg).timingOut(after: 1000)
        {data in
            let data = data as Array
            if(data.count > 0)
            {
                if data[0] is String { return }
                print(data)
                //CODE TO SAVE IN COREDB
                let dicMsg = data[0] as! [String:Any]
                let msg = StructChat.init(dictionary: dicMsg)
                //_ = CoreDBManager.sharedDatabase.saveMessageInLocalDB(objmessgae: msg)
                
                CoreDBManager.sharedDatabase.replaceMessageInLocalDB(objmessgae: msg, with: dicMsg["iospkid"] as! String)
                
                //self.reloadTable()
                //self.tableViewScrollToBottomAnimated(animated: true)
                
                self.arrMsgs = CoreDBManager.sharedDatabase.getChatMessagesForUserID(userId: self.selecteduserid, includeDeleted: false).sorted(by: { Float($0.kid)! < Float($1.kid)! })
                
                let sentMsgs = self.arrMsgs.filter({ $0.kid.contains(".") == false })
                let pendingMsgs = self.arrMsgs.filter({$0.kid.contains(".")})
                
                self.arrMsgs = sentMsgs + pendingMsgs
                
                if self.arrMsgs.count > 0{
                    self.setAllMessagesToRead()
                }
 
                
                UIView.setAnimationsEnabled(false)
                UIView.performWithoutAnimation {
                    self.tblchat.reloadRows(at:[IndexPath(row: (self.arrMsgs.count)-1, section: 0)], with: .none)
                }
                UIView.setAnimationsEnabled(true)
                
                //APP_DELEGATE.socketIOHandler?.reloadFriendAndGroupList() //PV //-------------------------------> // Reason Why all time send new message success after get All Friends and Group List.
                self.perform(#selector(self.reloadMessageReadStatus), with: nil, afterDelay: 2.0)
                
                ////Pu | 22-08-2018
                //self.currentlyCell = -1
                
                self.currentlySendingMessageID = ""
                self.sendPendingMessages()
            }
        }
    }
    
    func uploadAttachmentAndSendMessageThroughSocket(objmsg:[String:Any]){
        
        var objmsg = objmsg
        
        let parameter :NSMutableDictionary = ["token_id":UserDefaultManager.getStringFromUserDefaults(key: kToken)]
        
        let localURL = URL.init(fileURLWithPath: (objmsg["mediaurl"] as! String))
        parameter.setObject([localURL], forKey: ("image[]" as NSString))
        
        HttpRequestManager.sharedInstance.delegate = self;
        HttpRequestManager.sharedInstance.requestWithPostMultipartParam(endpointurl: Upload_Chat_Attachment, isImage: true, parameters: parameter) {(data, error, message, responseDict) -> Void in
            
            if error != nil
            {
                hideLoaderHUD()
                /*showMessageWithRetry(RetryMessage, 3, buttonTapHandler: { _ in
                 hideBanner()
                 self.uploadChatAttachment(attachment: attachment)
                 })*/
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
                        let strMediaURL = "\(Get_Chat_Attachment_URL)\(thedata!.object(forKey: "data")!)"
                        //print("\(strMediaURL)")
                        renameFile(At: URL.init(fileURLWithPath: objmsg["mediaurl"] as! String), withNewName: thedata!.object(forKey: "data")! as! String)
                        objmsg["mediaurl"] = strMediaURL
                        self.sendMessageThroughSocket(objmsg: objmsg)
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
                
                //Put this code is fix | static : find the way of why stop uploading 98% ?
                objmsg["mediaurl"] = URL_ServerSidePlaceHolder
                self.sendMessageThroughSocket(objmsg: objmsg)
            }
            HttpRequestManager.sharedInstance.delegate = nil;
        }
    }
    
    func getNewPendingMessageID()->Float{
        var offlineMessageId:Float = 0
        if let lastMessage = arrMsgs.last{
            offlineMessageId = Float(lastMessage.kid)!
        }
        offlineMessageId = offlineMessageId + 0.1
        return offlineMessageId
    }
    
}

extension ChatVC : ImagePickerDelegate {
    func pickImageComplete(_ imageData: UIImage, sender: String) {
        if sender == "Wallpaper"{
            let imageCropper = loadVC(strStoryboardId: SB_ASSET_PICKER, strVCId: idImageCropperVC) as! ImageCropperVC
            imageCropper.shouldSquare = false
            imageCropper.shouldBackgroundOfChat = true //PV
            imageCropper.image = imageData
            imageCropper.delegate = self
            APP_DELEGATE.appNavigation?.pushViewController(imageCropper, animated: false)
        }
    }
}

extension ChatVC : IGRPhotoTweakViewControllerDelegate{
    //MARK: CropImg Delegate Method
    func photoTweaksController(_ controller: IGRPhotoTweakViewController, didFinishWithCroppedImage croppedImage: UIImage) {
        /*if saveFileDataLocally(data: UIImageJPEGRepresentation(croppedImage, 1.0)!, with: kChatWallpaper) {
            UserDefaultManager.setBooleanToUserDefaults(value: true, key: kIsChatWallpaperSet)
            setChatWallpaperImage()
        }
        //Dismiss VC
        self.photoTweaksControllerDidCancel(controller)*/
        
        let objVC : ChatWallpaperSetVC = loadVC(strStoryboardId: SB_CHAT, strVCId: "ChatWallpaperSetVC") as! ChatWallpaperSetVC
        objVC.setBGImage = croppedImage
        APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: false)
    }
    
    func photoTweaksControllerDidCancel(_ controller: IGRPhotoTweakViewController) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
}

extension ChatVC : ChatSenderAttachCellDelegate, ChatReceiverAttachCellDelegate, ChatSenderDocumentCellDelegate, ChatReceiverDocumentCellDelegate, ChatSenderContactCellDelegate, ChatReceiverContactCellDelegate, ChatSenderAudioCellDelegate, ChatReceiverAudioCellDelegate, ChatReceiverStoryReplyCellDelegate, ChatSenderStoryReplyCellDelegate, ChatLinkPreviewReceiverCellDelegate, ChatLinkPreviewSenderCellDelegate, AVAudioPlayerDelegate
{
    
    func btnZoomClicked(_ sender: UIButton) {
        let section = Int(sender.accessibilityLabel!)!
        openAttachment(atRow: sender.tag, inSection: section)
    }
    
    func btnZoomMineClicked(_ sender: UIButton){
        let section = Int(sender.accessibilityLabel!)!
        openAttachment(atRow: sender.tag, inSection: section)
    }
    
    func btnDocZoomClicked(_ sender: UIButton) {
        let section = Int(sender.accessibilityLabel!)!
        openAttachment(atRow: sender.tag, inSection: section)
    }
    
    func btnDocZoomMineClicked(_ sender: UIButton) {
        let section = Int(sender.accessibilityLabel!)!
        openAttachment(atRow: sender.tag, inSection: section)
    }
 
    
    func btnPlayAudioMineClicked(_ sender: UIButton) {
        
        if audioPlayer != nil{
            audioPlayerDidFinishPlaying(audioPlayer!, successfully: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            
            let section = Int(sender.accessibilityLabel!)!
            self.currentPlayingAudioCellIndex = IndexPath.init(row: sender.tag, section: section)
            self.openAttachment(atRow: sender.tag, inSection: section)
            
        })
    }
    
    func btnPlayAudioClicked(_ sender: UIButton) {
        
        if audioPlayer != nil{
            audioPlayerDidFinishPlaying(audioPlayer!, successfully: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            
            let section = Int(sender.accessibilityLabel!)!
            self.currentPlayingAudioCellIndex = IndexPath.init(row: sender.tag, section: section)
            self.openAttachment(atRow: sender.tag, inSection: section)
            
        })
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayerProgressTimer?.invalidate()
        audioPlayer?.stop()
        audioPlayer = nil
        UIView.performWithoutAnimation {
            let loc = tblchat.contentOffset
            tblchat.reloadRows(at: [currentPlayingAudioCellIndex!], with: .none)
            tblchat.contentOffset = loc
        }
        currentPlayingAudioCellIndex = nil
    }
    
    func btnStoryClicked(_ sender: UIButton){
        let section = Int(sender.accessibilityLabel!)!
        openAttachment(atRow: sender.tag, inSection: section)
    }
    
    @objc func storyReplyClicked(_ sender: UITapGestureRecognizer)
    {
        
        let configuration = ImageViewerConfiguration { config in
            config.imageView = sender.view as? UIImageView
        }
        let imageViewerController = ImageViewerController(configuration: configuration)
        APP_DELEGATE.appNavigation?.present(imageViewerController, animated: false, completion: nil)
    }
    
    
    func btnStoryMineClicked(_ sender: UIButton){
        let section = Int(sender.accessibilityLabel!)!
        openAttachment(atRow: sender.tag, inSection: section)
    }
    
    func btnLinkMineClicked(_ sender: UIButton) {
        let section = Int(sender.accessibilityLabel!)!
        let row = sender.tag
        openLinkAt(section: section, row: row)
    }
    
    func btnLinkClicked(_ sender: UIButton) {
        let section = Int(sender.accessibilityLabel!)!
        let row = sender.tag
        openLinkAt(section: section, row: row)
    }
    
    func openLinkAt(section:Int, row:Int){
        let obj = arrMsgs[row]
        let arrMedia = obj.kmediaurl.components(separatedBy: kLinkMessageSeparator)
        var linkURL = arrMedia[0]
        if linkURL.hasPrefix("http") == false{
            linkURL = "http://" + linkURL
        }
        if let url = linkURL.toUrl{
            UIApplication.shared.open(url, options: [:],
                                      completionHandler: {
                                        (success) in
                                        //print("Open : \(success)")
            })
        }
    }
    
}

extension ChatVC{
    
    func openAttachment(atRow row:Int, inSection section:Int){
        
        let obj = arrMsgs[row]
        /*let assortedMsgs = arrAssortedMsgs[section]
         let obj = assortedMsgs.Msgs[row] as! StructChat*/
        
        if Int(obj.kmessagetype)! > 0
        {
            //let cell = tblchat.cellForRow(at: IndexPath.init(row: row, section: section))!
            if Int(obj.kmessagetype)! == 3
            {
                let arrDetails = obj.kchatmessage.base64Decoded!.components(separatedBy: kStoryMessageSeparator)
                let arrMyStories = CoreDBManager.sharedDatabase.getStoriesById(ForFriends: false, storyId:arrDetails[0])
                if arrMyStories.count > 0
                {
                    let vc = loadVC(strStoryboardId: SB_STORIES, strVCId: idStoryNavigatorVC) as! StoryNavigatorVC
                    vc.transitioningDelegate = self
                    vc.interactor = interactor
                    vc.redirectFrom = "FriendStory"
                    vc.selectedRow = 0
                    //PV
                    if (obj.kreceiverid.uppercased() == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)) {
                        var imgName = UserDefaultManager.getStringFromUserDefaults(key: kAppUserProfile)
                        //if imgName != "" { imgName = (imgName.url?.lastPathComponent)! }
                        //else { imgName = "" }
                        
                        let model = StoryListModel.init(
                            userID: UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
                            userName: UserDefaultManager.getStringFromUserDefaults(key: kUsername),
                            //profileURL: obj.kuserprofile,
                            profileURL: imgName,
                            arrStories: arrMyStories)
                        vc.arrStory = [model]
                        vc.isMyStory = true
                    }
                    else {
                        var imgName = self.selectedUser?.kuserprofile
                        if imgName! != "" { imgName = (imgName?.url?.lastPathComponent)! }
                        else { imgName = "" }
                        
                        let model = StoryListModel.init(
                            userID: UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
                            userName: "\(selectedUser!.kusername)",
                            //profileURL: obj.kuserprofile,
                            profileURL: imgName!,
                            arrStories: arrMyStories)
                        vc.arrStory = [model]
                        vc.isMyStory = false
                    }
                    APP_DELEGATE.appNavigation?.present(vc, animated: true, completion: nil)
                }
            }
            else if isPathForImage(path: obj.kmediaurl){
                let doesExist = isFileLocallyExist(fileName: obj.kmediaurl.lastPathComponent, inDirectory: self.get_URL_inChatDir())
                if doesExist{
                    /*let configuration = ImageViewerConfiguration { config in
                     config.imageView = cell.viewWithTag(15) as? UIImageView
                     }
                     let imageViewerController = ImageViewerController(configuration: configuration)
                     self.present(imageViewerController, animated: true)*/
                    
                    self.photoBrowser = ChatAttachmentBrowser.init(userID: self.selecteduserid, startingFromMediaURL:obj.kmediaurl, currentLocalDir:self.get_URL_inChatDir())
                    self.photoBrowser.startFromGrid = false
                    self.photoBrowser.currentLocalDirectory = self.get_URL_inChatDir()
                    self.photoBrowser.openBrowser()
                }else{
                    //self.downloadImage(url: obj.kmediaurl, reloadCellAt: row, and: section)
                    //self.downloadAndOpenAttachment(url: obj.kmediaurl.toUrl!)
                    self.downloadAndOpenAttachment(url: obj.kmediaurl.toUrl!,row,section,obj.ksenderid)
                    tblchat.reloadRows(at: [IndexPath.init(row: row, section: section)], with: .none)
                }
                /*SDWebImageManager.shared().cachedImageExists(for: obj.kmediaurl.toUrl, completion: { (doesExist) in
                 
                 })*/
                
            }else if Int(obj.kmessagetype)! == 2{
                //print("//OPEN LOCATION")
                
                let arrLocation = obj.kchatmessage.base64Decoded!.components(separatedBy: ",")
                let latitude = arrLocation.first
                let longitude = arrLocation.last
                if latitude != nil && longitude != nil {
                    //Abrimos Google Maps...
                    if let aString = URL(string: "comgooglemaps://") {
                        if UIApplication.shared.canOpenURL(aString) {
                            if let aValue = URL(string: String(format: "comgooglemaps://?q=%.6f,%.6f&center=%.6f,%.6f&zoom=15&views=traffic", Double(latitude ?? "0")!, Double(longitude ?? "0")!, Double(latitude ?? "0")!, Double(longitude ?? "0")!)) {
                                //UIApplication.shared.openURL(aValue)
                                UIApplication.shared.open(aValue, options: [:], completionHandler: { (success) in
                                    //print("Open GMaps App : \(success ? "SUCCESS" : "FAILURE")")
                                })
                            }
                        } else {
                            if let aValue = URL(string: String(format: "https://maps.google.com/maps?&z=15&q=%.6f+%.6f&ll=%.6f+%.6f", Double(latitude ?? "0")!, Double(longitude ?? "0")!, Double(latitude ?? "0")!, Double(longitude ?? "0")!)) {
                                //UIApplication.shared.openURL(aValue)
                                UIApplication.shared.open(aValue, options: [:], completionHandler: { (success) in
                                    //print("Open GMaps App : \(success ? "SUCCESS" : "FAILURE")")
                                })
                            }
                        }
                    }
                }
            }
            else {
                if isPathForAudio(path: obj.kmediaurl){
                    
                    if isFileLocallyExist(fileName: obj.kmediaurl.lastPathComponent, inDirectory: self.get_URL_inChatDir()) == false {
                        //print("Audio download now.")
                        self.downloadContent_audio(contentURL: obj.kmediaurl.url!)
                        //return
                    }
                    
                    let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: "ChatAudioPlayerVC") as! ChatAudioPlayerVC
                    vc.modalPresentationStyle = .overCurrentContext
                    vc.audioURL = obj.kmediaurl
                    vc.URL_CurrentDir = self.get_URL_inChatDir()
                    present(vc, animated: true, completion: nil)
                }
                else{
                    //downloadAndOpenAttachment(url: URL.init(string: obj.kmediaurl)!)
                    downloadAndOpenAttachment(url: URL.init(string: obj.kmediaurl)!,row,section,obj.ksenderid)
                    
                    tblchat.reloadRows(at: [IndexPath.init(row: row, section: section)], with: .none)
                }
            }
        }
    }
    
    //PV
    //func downloadAndOpenAttachment(url:URL) {
    //func downloadAndOpenAttachment(url:URL,_ rows:Int = -1,_ sections:Int = -1,_ userid:String = "0") {
    func downloadAndOpenAttachment(url:URL,_ rows:Int,_ sections:Int,_ userid:String) {
        
        if isFileLocallyExist(fileName: url.lastPathComponent, inDirectory: self.get_URL_inChatDir()) == true {
            
            let localURL = getURL_LocallyFileExist(fileName: url.lastPathComponent, inDirectory: get_URL_inChatDir())
            
            if isPathForVideo(path: localURL.path) {
                self.photoBrowser = ChatAttachmentBrowser.init(userID: self.selecteduserid, startingFromMediaURL:url.absoluteString, currentLocalDir:self.get_URL_inChatDir())
                self.photoBrowser.startFromGrid = false
                self.photoBrowser.openBrowser()
            } else {
                /*
                //PV
                //Get Contact Info.
                 do {
                 let contactData = try Data.init(contentsOf: url)
                 let contact = try CNContactVCardSerialization.contacts(with: contactData)
                 for objContact in contact {
                 //print("Given Name - familyName : \(objContact.givenName) - \(objContact.familyName)")
                 //print("Contact No. : \(objContact.phoneNumbers)")
                 let phoneNo : CNLabeledValue<CNPhoneNumber>  = objContact.phoneNumbers.first!
                 
                 //CNPhoneNumber
                 //print("Contact No. : \(phoneNo.stringValue)")
                 //print("Contact No. : \(phoneNo.value.stringValue)")
                 //print("Country code. : \(phoneNo.value)")
                 }
                 } catch {
                 //print("Error: \(error.localizedDescription)")
                 }*/
                
                let objData : StructChat = self.arrMsgs[rows]
                
                documentInteraction = UIDocumentInteractionController.init(url: localURL)
                documentInteraction.delegate = self
                documentInteraction.name = objData.kchatmessage.base64Encoded?.count != 0 ? objData.kchatmessage.base64Decoded : objData.kmediaurl.lastPathComponent
                let success = documentInteraction.presentPreview(animated: true)
                if success == false{
                    //print("//OPEN AS MENU")
                    documentInteraction.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
                }
            }
        } else {
            /*if arrDownloadURLs.contains(url) == false{
             arrDownloadURLs.append(url)
             }
             
             performDownload()*/
            
            if ChatAttachmentDownloader.sharedInstance.isDownloading(remoteURL: url){
                ChatAttachmentDownloader.sharedInstance.removeURLFromDownloading(remoteURL: url)
            }else {
                //ChatAttachmentDownloader.sharedInstance.startDownloading(remoteURL: url, saveToURL: self.URL_dirCurrentChat!)
                //payal changed
                let destination = DownloadRequest.suggestedDownloadDestination()
                Alamofire.download(url, to: destination).downloadProgress(queue: DispatchQueue.global(qos: .utility))
                { (progress) in
                    //print("Progress  download -----> : \(progress.fractionCompleted)")
                    DispatchQueue.main.async {
                        if userid != UserDefaultManager.getStringFromUserDefaults(key: kAppUserId) {
                            if let trackCell = self.tblchat.cellForRow(at: IndexPath(row: rows,
                                                                                     section: 0)) as? ChatSenderAttachCell {
                                //String(format: "%.1f%% of %@", progress * 100, totalSize)
                                trackCell.updateDisplay(progress: Float(progress.fractionCompleted), totalSize: "0 KB")
                            }
                        }
                        else {
                            if let trackCell = self.tblchat.cellForRow(at: IndexPath(row: rows,
                                                                                     section: 0)) as? ChatReceiverAttachCell {
                                //String(format: "%.1f%% of %@", progress * 100, totalSize)
                                trackCell.updateDisplay(progress: Float(progress.fractionCompleted), totalSize: "0 KB")
                            }
                        }
                    }
                    } .validate().responseData { ( response ) in
                        if let error = response.error{
                            //print("Error: \(error.localizedDescription)")
                        }
                        else {
                            //print("Saved path: \(response.destinationURL!)")
                            
                            let downloadContentLocalURL = save_Content(contentURL: response.destinationURL!, withName: response.destinationURL!.lastPathComponent, inDirectory: self.URL_dirCurrentChat!)
                            //print("downloadContentLocalURL: \(downloadContentLocalURL?.absoluteString ?? "---")")
 
                            /*//Change Name of document and save in local dir.
                            // NOTE :
                            // ERROR : If implement following code every time you download the attach content as mention in code.
                            let obj : StructChat = self.arrMsgs[rows]
                            let mediaURL = obj.kmediaurl
                            if (isPathForImage(path: mediaURL) == true) || (isPathForVideo(path: mediaURL) == true) || (isPathForContact(path: mediaURL) == true) || (isPathForAudio(path: mediaURL) == true) {
                                //---> Code
                                let downloadContentLocalURL = save_Content(contentURL: response.destinationURL!, withName: response.destinationURL!.lastPathComponent, inDirectory: self.URL_dirCurrentChat!)
                                //print("downloadContentLocalURL: \(downloadContentLocalURL?.absoluteString ?? "---")")
                            }
                            else {
                                let strFileName : String = obj.kchatmessage.base64Decoded ?? obj.kmediaurl.lastPathComponent
                                let downloadContentLocalURL = save_Content(contentURL: response.destinationURL!, withName: strFileName, inDirectory: self.URL_dirCurrentChat!)
                                //print("downloadContentLocalURL: \(downloadContentLocalURL?.absoluteString ?? "---")")
                            }*/
                            
                            if isPathForImage(path: (url.absoluteString)) {
                                do{
                                    let data = try Data.init(contentsOf: response.destinationURL!)
                                    let img = UIImage.init(data: data)
                                    SDWebImageManager.shared().saveImage(toCache: img, for: url)
                                }catch{
                                    print(error.localizedDescription)
                                }
                            }
                            removeFile_onURL(fileURL: response.destinationURL!)
                            UIView.performWithoutAnimation {
                                self.tblchat.reloadRows(at: [IndexPath.init(row: rows, section: 0)], with: .none)
                            }
                        }
                }
            }
        }
    }
    
    func performDownload(){
        guard isDownloading == false else { return }
        if arrDownloadURLs.count > 0 {
            isDownloading = true
            
            Downloader.download(url: arrDownloadURLs[0], completion: { (success, url) in
                if success {
                    //OTHERWISE THE DOCUMENT / VIDEO VIEWER WILL OPEN ANYTIME WHEN THE DOWNLOAD FINISHES
                    //WE SHOULD INDICAT IF THE FILE IS READY TO BE DISPLAYED OR NOT
                    //SO IF DOWNLOADED THEN WILL OPEN DIRECTLY
                    //OTHERWISE DOWNLOAD ONLY (OPEN NEXT TIME WHEN USER TAPS FILE)
                    //self.downloadAndOpenAttachment(url: url)
                    
                    self.arrDownloadURLs.remove(at: 0)
                    
                    //Download Content : Image, Video
                    //--------------------------->
                    //print("downloadContentURL: \(url)")
                    let downloadContentLocalURL : URL = save_Content(contentURL: url, withName: url.lastPathComponent, inDirectory: self.get_URL_inChatDir())!
                    //print("downloadContentLocalURL: \(downloadContentLocalURL)")
                    //--------------------------->
                    
                    //Remove Download file in Document Dir.
                    removeFile_onURL(fileURL: url)
                }else{
                    showStatusBarMessage("Download failed. Try again.")
                }
                self.isDownloading = false
                self.performDownload()
            })
        }
    }
    
    func downloadImage(url:String, reloadCellAt row:Int, and section:Int){
        if isConnectedToNetwork(){
            showHUD()
            
            SDWebImageDownloader.shared().downloadImage(with: url.toUrl, options: .highPriority, progress: nil, completed: { (image, data, error, finished) in
                
                hideHUD()
                
                if error == nil {
                    SDWebImageManager.shared().saveImage(toCache: image, for: url.toUrl)
                    /*self.reloadTable()
                     if scrollToBottom{
                     self.tableViewScrollToBottomAnimated(animated: false)
                     }*/
                    let indexpath = IndexPath.init(row: row, section: section)
                    //self.tblchat.reloadRows(at: [indexpath], with: .none)
                    UIView.performWithoutAnimation {
                        let loc = self.tblchat.contentOffset
                        self.tblchat.reloadRows(at: [indexpath], with: .none)
                        self.tblchat.contentOffset = loc
                    }
                    
                    //Save Download Image
                    //let imgURL = save_Content(image: image!, imageName: url.lastPathComponent, inDirectory: self.get_URL_inChatDir())
                    //print("imgURL: \(imgURL)")
                }
                
            })
        }
    }
    
    
}

extension ChatVC: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}

extension ChatVC {
    func clickOnReplyButtonInCell(frame: CGRect, view:UIView) {
        let button = UIButton(type: .system)
        button.frame = frame
        button.addTarget(self, action: #selector(btnReplyCell(_:)), for: .touchUpInside)
        //view.addSubview(button) //BECAUSE THIS PREVENTS CELL SELECTION & LINK PREVIEW CLICK
    }
    @objc func btnReplyCell(_ sender: UIButton) {
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.tblchat)
        let indexPath = self.tblchat.indexPathForRow(at: buttonPosition)
        let obj = arrMsgs[indexPath!.row]
        for i in 0..<arrMsgs.count {
            let objTmp = arrMsgs[i]
            if objTmp.kid == obj.parentid {
                let index = IndexPath(row: i, section: 0)
                self.tblchat.scrollToRow(at: index as IndexPath, at: .middle, animated: true)
                break
            }
        }
    }
}
