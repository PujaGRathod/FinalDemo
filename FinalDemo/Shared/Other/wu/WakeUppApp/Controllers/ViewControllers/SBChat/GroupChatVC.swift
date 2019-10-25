//
//  GroupChatVC.swift
//  WakeUppApp
//
//  Created by Admin on 07/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
//import SimpleImageViewer
import SwiftyJSON
import AVKit
import AVFoundation
import MobileCoreServices
import ContactsUI
import Contacts
import SDWebImage

import IGRPhotoTweaks
import SwiftLinkPreview

import Zip

import CoreLocation
import AudioToolbox //PV
import Alamofire

protocol GroupChatVC_Delegate : AnyObject {
    func manage_HiddentChat_onGroupChatVC(HideChatStatus: Bool?) -> Void
}

class GroupChatVC: UIViewController, AVAudioRecorderDelegate {
    
    weak var delegate: GroupChatVC_Delegate?
    
    @IBOutlet var btncontact: UILabel!
    @IBOutlet var btnlocation: UILabel!
    @IBOutlet var btndoc: UIButton!
    @IBOutlet var btncamera: UIButton!
    @IBOutlet var btngallery: UIButton!
    @IBOutlet var btnaudio: UIButton!
    @IBOutlet var vwnavbar: UIView!
    @IBOutlet var heightattach: NSLayoutConstraint!
    @IBOutlet var vwattach: UIView!
    @IBOutlet var btnvideo: UIButton!
    @IBOutlet var btncall: UIButton!
    @IBOutlet var lblusername: UILabel!
    @IBOutlet var imgTitlePhoto: UIImageView!
    @IBOutlet var btnnavigate: UIButton!
    @IBOutlet var lblisonline: UILabel!
    @IBOutlet weak var tblchat: UITableView!
    @IBOutlet weak var imgWallpaper: UIImageView!
    
    @IBOutlet var btnmenu: UIButton!
    
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
    
    @IBOutlet weak var heightOfLblCantSendMessage: NSLayoutConstraint!
    @IBOutlet weak var lblCantSendMessage: UILabel!
    
    @IBOutlet weak var imgLinkPreview: UIImageView!
    @IBOutlet weak var widthOfImgLinkPreview: NSLayoutConstraint!
    @IBOutlet weak var lblLinkTitle: UILabel!
    @IBOutlet weak var lblLinkDescription: UILabel!
    @IBOutlet weak var lblLinkURL: UILabel!
    @IBOutlet weak var heightOfLinkPreviewView: NSLayoutConstraint!
    var lastgroupmsgid = 0
    var recordingTimer : Timer?
    var recordingDurationInSeconds:Int = 0{
        didSet{
            lblRecordingTimer.text = timeFormatted(recordingDurationInSeconds)
        }
    }
    
    var audioRecorder: AVAudioRecorder!
    var isAudioRecordingGranted: Bool!
    
    var recordingFileName = "audioRecording.m4a"
    
    var audioPlayer: AVAudioPlayer?
    var audioPlayerProgressTimer : Timer?
    var currentPlayingAudioCellIndex : IndexPath?
    
    var documentInteraction = UIDocumentInteractionController()
    
    var imagePicker = UIImagePickerController() // FOR CAMERA CAPTURE
    
    var arrMsgs = [StructGroupChat]()
    //var arrAssortedMsgs = [AssortedMsgs]()
    
    var calledfrom = String()
    
    var groupName = String()
    var imgTitleProfilePhoto : UIImage = GroupPlaceholderImage
    
    var selectedGroupId:String!
    
    var selectedGroupDetails:StructGroupDetails!
    
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
    
    var arrDownloadURLs = Array<URL>()
    
    var arrSelectedIndexes = [Int]()
    
    var tapTable : UITapGestureRecognizer!
    
    var selectedMessageForReply : StructGroupChat?
    
    var photoBrowser:ChatAttachmentBrowser!
    
    let slp = SwiftLinkPreview(session: URLSession.shared,
                               workQueue: SwiftLinkPreview.defaultWorkQueue,
                               responseQueue: DispatchQueue.main,
                               cache: DisabledCache.instance)
    var linkPreview : Cancellable?
    
    var linkPreviewDetails : SwiftLinkPreview.Response?{
        didSet{
            if let result = linkPreviewDetails {
                let url = result[.url] as! URL
                let finalUrl = result[.finalUrl] as! URL
                let canonicalUrl = result[.canonicalUrl] as! String
                let title = result[.title] as? String
                let description = result[.description] as? String
                let images = result[.images] as? [String]
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
    let scrollbottombtn:UIButton = UIButton(frame: CGRect(x: -5,y: Int(SCREENHEIGHT()) - 150, width:  50, height:  45))
    
    var fileURLs = [NSURL]()
    
    //MARK:-
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setData()
        
        hideSoundRecordingBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(newMessageReceived), name: NSNotification.Name(rawValue: NC_NewGroupMessage), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(fire_event_getmessaged), name: NSNotification.Name(NC_LoadMessageFromServer), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: NSNotification.Name(NC_ChatAttachmentDownloaded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: NSNotification.Name(NC_ChatAttachmentDownloadFailed), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sendPendingMessages), name: NSNotification.Name(NC_SocketConnected), object: nil)
        
        layoutUI()
        
        checkForMicrophonePermission()
        
        perform(#selector(checkNavigationStackForMemberSelectVC), with: nil, afterDelay: 1.0)
        perform(#selector(setChatWallpaperImage), with: nil, afterDelay: 0.0)
        
        APP_DELEGATE.socketIOHandler?.socket?.on("TypingReceived") {data, ack in
            if data.count > 0{
                if let dicData = data.first as? [String:String]{
                    
                    //let senderId = dicData["senderid"]!
                    let recieverId = dicData["receiverid"]!
                    let isTyping = dicData["istyping"]!
                    let isGroup = dicData["isgroup"]!
                    let countrycode = dicData["countrycode"]!
                    let phoneno = dicData["phoneno"]!
                    
                    if recieverId == self.selectedGroupId && isGroup == "1"{
                        if isTyping == "1"{
                            let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: countrycode, phoneNo: phoneno)
                            if objContactInfo.Name?.count == 0 {
                                //print("NOT IN CONTACTS")
                                self.lblisonline.text = "+" + countrycode + " " + phoneno + " is typing.."
                            }
                            else {
                                self.lblisonline.text = objContactInfo.Name! + " is typing.."
                            }
                            
                            UIView.animate(withDuration: 0.3, animations: {
                                self.view.layoutIfNeeded()
                            })
                        }else{
                            let groupMemberIDs = self.selectedGroupDetails.members.components(separatedBy: ",")
                            self.lblisonline.text = "\(groupMemberIDs.count) group members."
                        }
                    }
                    
                }
            }
        }
        
        
        //Set real Path of Dic.
        let URL_dirCurrentGroupChat : URL = get_URL_inGroupChatDir()
        //print("URL_dirCurrentGroupChat : \(URL_dirCurrentGroupChat)")
        
        hideLinkPreviewView()
        
        sendPendingMessages()
    }
    
    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(animated)
        setData()
        //api_groupInfo()
        
        fire_event_getmessaged()
        reloadTable()
        arrSelectedIndexes.removeAll()
        hideEditingNavBar()
        self.managekeyboard()
        
        self.setChatWallpaperImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Hide Navigationbar | Save contact adter move on this screen for hide the navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidDisappear(_ animated:Bool)
    {
        IQKeyboardManager.shared.enable = true
        super.viewDidDisappear(animated)
        self.view.removeKeyboardControl()
        
        setAllMessagesToRead() //BECAUSE THE NEW MESSAGES THAT ARRIVE WHILE ON THE CHATVC WILL BE CONSIDERED AS UNREAD
    }
    
    //MARK:- Other function
    func layoutUI() {
        tblchat.contentInset = UIEdgeInsets.init(top: -32, left: 0, bottom: -20, right: 0)
        
        self.vwattach.accessibilityValue = "\(self.inputvalues.frame.origin.y)"
        self.vwattach.isHidden = true
        
        IQKeyboardManager.shared.enable = false
        
        tblchat.register(UINib(nibName: "GroupChatInitialCell", bundle: nil), forCellReuseIdentifier: "GroupChatInitialCell")
        
        tblchat.register(UINib(nibName: "ChatReceiverAttachCell", bundle: nil), forCellReuseIdentifier: "ChatReceiverAttachCell")
        tblchat.register(UINib(nibName: "GroupChatSenderAttachCell", bundle: nil), forCellReuseIdentifier: "GroupChatSenderAttachCell")
        
        tblchat.register(UINib(nibName: "ChatReceiverCell", bundle: nil), forCellReuseIdentifier: "ChatReceiverCell")
        tblchat.register(UINib(nibName: "GroupChatSenderCell", bundle: nil), forCellReuseIdentifier: "GroupChatSenderCell")
        
        tblchat.register(UINib(nibName: "ChatContactReceiverCell", bundle: nil), forCellReuseIdentifier: "ChatContactReceiverCell")
        tblchat.register(UINib(nibName: "GroupChatContactSenderCell", bundle: nil), forCellReuseIdentifier: "GroupChatContactSenderCell")
        
        tblchat.register(UINib(nibName: "ChatReceiverDocumentCell", bundle: nil), forCellReuseIdentifier: "ChatReceiverDocumentCell")
        tblchat.register(UINib(nibName: "GroupChatSenderDocumentCell", bundle: nil), forCellReuseIdentifier: "GroupChatSenderDocumentCell")
        
        tblchat.register(UINib(nibName: "ChatReceiverAudioCell", bundle: nil), forCellReuseIdentifier: "ChatReceiverAudioCell")
        tblchat.register(UINib(nibName: "GroupChatSenderAudioCell", bundle: nil), forCellReuseIdentifier: "GroupChatSenderAudioCell")
        
        tblchat.register(UINib(nibName: "ChatLinkPreviewReceiverCell", bundle: nil), forCellReuseIdentifier: "ChatLinkPreviewReceiverCell")
        tblchat.register(UINib(nibName: "GroupChatLinkPreviewSenderCell", bundle: nil), forCellReuseIdentifier: "GroupChatLinkPreviewSenderCell")
        
        
        let footervw = UIView.init(frame: .zero)
        self.tblchat.tableFooterView = footervw
        
        tapTable = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
        self.tblchat.addGestureRecognizer(tapTable)
        
        //vwattach.addShadow(ofColor:.black, radius: 8, offset: .zero, opacity:0.8)
        
        /*var dic = ["userid":"1","message":"Hiii","datetime":"09:20 PM","senderimage":"","mediatype":"0","media":"","mediaImage":UIImage(),"bubbletype":"1"] as [String : Any]
         arrMsgs.append(StructChat.init(dictionary: dic))
         dic = ["userid":"2","message":"Hello How are you!!","datetime":"09:20 PM","senderimage":"","mediatype":"0","media":"","mediaImage":UIImage(),"bubbletype":"1"] as [String : Any]
         arrMsgs.append(StructChat.init(dictionary: dic))
         dic = ["userid":"2","message":"This does display the view on screen. But the problem is, it doesn't accept any user interaction.","datetime":"09:20 PM","senderimage":"","mediatype":"1","media":"http://picanimal.com/wp-content/uploads/2018/01/butterflies-blue-xerces-butterfly-hd-desktop.jpg","mediaImage":UIImage()] as [String : Any]
         arrMsgs.append(StructChat.init(dictionary: dic))
         dic = ["userid":"1","message":"You cannot enter foreground from background just like that. When you send the VoIP-push the app will go into background.","datetime":"09:20 PM","senderimage":"","mediatype":"1","media":"https://itechway.net/wp-content/uploads/2017/08/cute-baby-1.jpg","mediaImage":UIImage()] as [String : Any]
         arrMsgs.append(StructChat.init(dictionary: dic))*/
        
        tblchat.delegate = self
        tblchat.dataSource = self
        tblchat.bounces = false
        self.set_ScrollToBottomButton()
        
        //print("layoutUI -> reloadTable")
        reloadTable()
        //self.tableViewScrollToBottomAnimated(animated: false)
        fire_event_getmessaged()
        self.setInputbar()
    }
    
    
    func set_ScrollToBottomButton() -> Void {
        scrollbottombtn.backgroundColor = UIColor.white
        scrollbottombtn.setTitle("^", for: .normal)
        scrollbottombtn.addTarget(self, action:#selector(self.scrollbottombtnClicked), for: .touchUpInside)
        scrollbottombtn.layer.cornerRadius = 5
        //        scrollbottombtn.layer.borderColor = themeGreenColor.cgColor
        //        scrollbottombtn.layer.borderWidth = 1
        scrollbottombtn.clipsToBounds = true
        scrollbottombtn .setImage(#imageLiteral(resourceName: "scrolldownarrow"), for: .normal)
        self.view.addSubview(scrollbottombtn)
        scrollbottombtn.alpha = 0
    }
    
    //MARK: Manage GroupChatDir dataContent
    
    func get_URL_inGroupChatDir() -> URL {
        let URL_dirCurrentGroupChat : URL = getURL_GroupChat_Directory(groupID: self.selectedGroupId)
        //print("URL_dirCurrentGroupChat : \(URL_dirCurrentGroupChat)")
        
        return URL_dirCurrentGroupChat
    }
    
    
    func downloadContent_audio(contentURL : URL) -> Void {
        Downloader.download(url: contentURL, completion: { (success, url) in
            if success {
                //print("downloadContentURL: \(url)")
                
                //Copy download file in ChatDir.
                let downloadContentLocalURL : URL = save_Content(contentURL: url, withName: url.lastPathComponent, inDirectory: self.get_URL_inGroupChatDir())!
                //print("downloadContentLocalURL: \(downloadContentLocalURL)")
            }
            else {
                showStatusBarMessage("Download failed. Try again.")
                //NOTE : Some case already downloadeded file exist or samew name file in document directory time show this alert.
            }
            
            //Remove Old File
            removeFile_onURL(fileURL: url)
        })
    }
    
    //MARK: manage Export Chat
    @IBAction func perform_ExportChatAction() -> Void {
        
        let confirmAlert = UIAlertController.init(title: "Export Chat" , message: "Attaching media will generate a larger chat archive.", preferredStyle: .actionSheet)
        let attWithMedia = UIAlertAction.init(title: "Attach Media", style: .default) { (action) in
            //self.manage_ExportChat(withMedia: true)
            
            let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ImportExportProcessVC" ) as! ImportExportProcessVC
            let objGroupInfo = GroupChatInfo.init(GroupID: self.selectedGroupId,
                                                  GroupImageURL: self.selectedGroupDetails.icon,
                                                  DisplayNameOfTitle: self.selectedGroupDetails.name,
                                                  userID: UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
                                                  CountryCode: UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode),
                                                  PhoneNo: UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile))
            objVC.objGroupChatInfo = objGroupInfo
            objVC.objEnumImpExpoAction = .Export_GroupChat_withContent
            objVC.Popup_Show(onViewController: self)
        }
        confirmAlert.addAction(attWithMedia)
        
        let attWithoutMedia = UIAlertAction.init(title: "Without Media", style: .default) { (action) in
            //self.manage_ExportChat(withMedia: false)
            
            let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ImportExportProcessVC" ) as! ImportExportProcessVC
            let objGroupInfo = GroupChatInfo.init(GroupID: self.selectedGroupId,
                                                  GroupImageURL: self.selectedGroupDetails.icon,
                                                  DisplayNameOfTitle: self.selectedGroupDetails.name,
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
        
        present(confirmAlert, animated: true, completion: nil)
        //---------------------------------->
    }
    
    //MARK:-
    @objc func checkNavigationStackForMemberSelectVC(){
        var VCs = APP_DELEGATE.appNavigation?.viewControllers
        let index = VCs?.index(where: {$0 is SelectMembersVC})
        if let foundIndex = index {
            VCs?.remove(at: foundIndex)
            APP_DELEGATE.appNavigation?.viewControllers = VCs!
        }
    }
    
    func setData(){
        //let groupList = CoreDBManager.sharedDatabase.getGroupsList() as! [StructGroupDetails]
        selectedGroupDetails = CoreDBManager.sharedDatabase.getGroupById(groupId: selectedGroupId)! // groupList.first(where: {$0.group_id == selectedGroupId})!
        groupName = selectedGroupDetails.name
        
        self.lblusername.text = groupName
        self.imgTitlePhoto.image = self.imgTitleProfilePhoto
        
        let groupMemberIDs = selectedGroupDetails.members.components(separatedBy: ",")
        self.lblisonline.text = "\(groupMemberIDs.count) group members."
        
        let userID = UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)
        
        let members = selectedGroupDetails.members.components(separatedBy: ",")
        if members.contains(userID){
            heightOfLblCantSendMessage.constant = 0
        }else{
            heightOfLblCantSendMessage.constant = 49
        }
        
        if heightOfLblCantSendMessage.constant != 49{
            if selectedGroupDetails.msg_permission == "1"{
                let admins = selectedGroupDetails.admins.components(separatedBy: ",")
                if admins.contains(userID) == false{
                    heightOfLblCantSendMessage.constant = 49
                    lblCantSendMessage.text = "Only admins can send message"
                }
            }
        }
    }
    
    @IBAction func btnGroupInfoClicked(_ sender:UIButton){
        let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: idGroupInfoVC) as! GroupInfoVC
        vc.selectedGroupDetails = selectedGroupDetails
        APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
    }
    
    func checkForMicrophonePermission(){
        switch AVAudioSession.sharedInstance().recordPermission() {
        case .granted:
            isAudioRecordingGranted = true
        case .denied:
            isAudioRecordingGranted = false
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
        let obj = StructGroupChat.init(dictionary: notification.userInfo as! [String : Any])
        _ = CoreDBManager.sharedDatabase.saveGroupMessageInLocalDB(objmessgae: obj)
        
        if obj.groupid != selectedGroupId{
            return
        }
        
        self.arrMsgs.append(obj)
        self.tblchat.beginUpdates()
        self.tblchat.insertRows(at: [IndexPath(row: (self.arrMsgs.count)-1, section: 0)], with: .none)
        self.tblchat.endUpdates()
        self.tblchat.scrollToRow(at: (IndexPath(row:(self.arrMsgs.count)-1, section:0)) as IndexPath, at:.bottom, animated:true)
        
        self.tableViewScrollToBottomAnimated(animated: false)
        
        doUpdateReadStatus()
        
        if obj.messagetype == "-1"{
            api_groupInfo()
        }
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
        self.view.keyboardTriggerOffset = self.inputvalues.frame.size.height
        self.view.addKeyboardNonpanning() {[unowned self](keyboardFrameInView:CGRect, opening:Bool, closing:Bool) in
            var toolBarFrame = self.inputvalues.frame
            var tableViewFrame = self.tblchat.frame
            if UIScreen.main.bounds.height >= 812 {
                tableViewFrame.size.height = toolBarFrame.origin.y - 95
                if #available(iOS 11.0, *) {
                    if keyboardFrameInView.origin.y == SCREENHEIGHT() {
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func reloadTable(){
        
        //tblchat.delegate = nil
        //tblchat.dataSource = nil
        
        arrMsgs = CoreDBManager.sharedDatabase.getMessagesForGroupID(groupId: selectedGroupId, includeDeleted: false).sorted(by: { Float($0.id)! < Float($1.id)! })
        
        let sentMsgs = arrMsgs.filter({ $0.id.contains(".") == false })
        let pendingMsgs = arrMsgs.filter({$0.id.contains(".")})
        
        arrMsgs = sentMsgs + pendingMsgs
        
        if arrMsgs.count > 0{
            setAllMessagesToRead()
        }
        
        //tblchat.delegate = self
        //tblchat.dataSource = self
        
        //tblchat.reloadData()
        refreshTable()
        
        //tableViewScrollToBottomAnimated(animated: false)
    }
    
    @objc func refreshTable(){
        tblchat.reloadData()
    }
    
    func setAllMessagesToRead(){
        if arrMsgs.count > 0{
            CoreDBManager.sharedDatabase.setUnreadCountToZeroGroup(for: selectedGroupDetails)
        }
    }
    
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
    
    func getFilteredMembersForSendMessage() -> String {
        
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
    
    func start_PersonalChat(user : User) -> Void {
        
        //let user = responseArray?.firstObject! as! User
        
        let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: idChatVC) as! ChatVC
        vc.selecteduserid = user.userId
        vc.calledfrom = "messages"
        vc.username = user.fullName!
        
        var dictionary = [String:String]()
        dictionary["id"] = user.userId
        dictionary["createddate"] = user.creationDatetime
        dictionary["platform"] = user.platform
        dictionary["textmessage"] = ""
        dictionary["receiverid"] = ""
        dictionary["senderid"] = user.userId
        dictionary["sendername"] = user.fullName
        dictionary["isdeleted"] = "0"
        dictionary["isread"] = "0"
        dictionary["mediaurl"] = ""
        dictionary["messagetype"] = "0"
        dictionary["chatid"] = "0"
        dictionary["image"] = user.imagePath
        dictionary["is_online"] = user.isOnline
        dictionary["last_login"] = user.lastLogin
        dictionary["username"] = user.fullName
        dictionary["user_id"] = ""
        dictionary["muted_by_me"] = user.mutedByMe
        dictionary["country_code"] = user.countryCode
        dictionary["phoneno"] = user.phoneno
        dictionary["blocked_contacts"] = user.blockedContacts
        dictionary["parent_id"] = ""
        dictionary["ishidden"] = "0"
        vc.selectedUser = StructChat.init(dictionary: dictionary)
        
        APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
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
                let audioFilename = save_Content(withContentName: recordingFileName, inDirectory: self.get_URL_inGroupChatDir())
                
                
                //Create the audio recording, and assign ourselves as the delegate
                
                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.record()
                
                soundRecordBar.isHidden = false
                soundRecordBar.isUserInteractionEnabled = true
                recordingTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateRecordingLabel), userInfo: nil, repeats: true)
                
            }
            catch let error {
                //print("Error for start audio recording: \(error.localizedDescription)")
            }
        }else{
            checkForMicrophonePermission()
        }
    }
    
    @IBAction func btnCancelRecordingClicked(_ sender: Any) {
        hideSoundRecordingBar()
        
        //Delete Record Autod File
        removeFile(fileName: recordingFileName, inDirectory: self.get_URL_inGroupChatDir())
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
            
            let localURL = save_Content(contentURL: self.get_URL_inGroupChatDir().appendingPathComponent(recordingFileName), withName: "\(getNewPendingMessageID()).m4a", inDirectory: self.get_URL_inGroupChatDir())
            removeFile_onURL(fileURL: self.get_URL_inGroupChatDir().appendingPathComponent(recordingFileName))
            sendMediaMessage(forLocalURL: localURL!)
            
            //uploadChatAttachment(attachment: getDocumentsDirectoryURL()!.appendingPathComponent(recordingFileName))
            //uploadChatAttachment(attachment: self.get_URL_inGroupChatDir().appendingPathComponent(recordingFileName))
            
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
    
    //MARK:- LinkPreviewView
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
    
    //MARK:- Button action Method
    @IBAction func btnbackclicked(_ sender: Any) {
       
        if APP_DELEGATE.isHiddenChatUnlocked != false
        {
             self.delegate?.manage_HiddentChat_onGroupChatVC(HideChatStatus: true)
        }
        else
        {
            self.delegate?.manage_HiddentChat_onGroupChatVC(HideChatStatus: false)
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NC_NewGroupMessage), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NC_LoadMessageFromServer), object: nil)
        
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @objc func scrollbottombtnClicked() {
        self.tableViewScrollToBottomAnimated(animated: true)
    }
    
    //MARK: Titlebar button click
    @IBAction func btnMenuClicked(_ sender: Any) {
        let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //let muteOrUnmute = isMutedChat(userId: selectedGroupId) ? "Unmute" : "Mute"
        let muteOrUnmute = isMutedGroupChat(groupId: selectedGroupId) ? "Unmute" : "Mute"
        let actionMuteUnMute = UIAlertAction.init(title: muteOrUnmute, style: .default) { (action) in
            let currentlyMutedUsers = UserDefaultManager.getStringFromUserDefaults(key: kMutedByMe)
            var arrMutedUserIds = currentlyMutedUsers.components(separatedBy: ",") as? NSMutableArray
            if arrMutedUserIds == nil{
                arrMutedUserIds = NSMutableArray()
            }
            if (arrMutedUserIds?.contains(""))!{ arrMutedUserIds?.remove("") }
            
            if isMutedGroupChat(groupId: self.selectedGroupId){ //isMutedGroup
                arrMutedUserIds?.remove(self.selectedGroupId)
            }else{
                arrMutedUserIds?.add(self.selectedGroupId)
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
            CoreDBManager.sharedDatabase.updateMuteIDsForGroup(muteIDs: mutedIds, groupID: self.selectedGroupId)
            //UserDefaultManager.setStringToUserDefaults(value: mutedIds, key: kMutedByMe)
        }
        actionSheet.addAction(actionMuteUnMute)
        
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
        actionSheet.addAction(actionWallpaper)
        
        let actionExportChat = UIAlertAction.init(title: "Export Chat", style: .default) { (action) in
            self.perform_ExportChatAction()
        }
        actionSheet.addAction(actionExportChat)
        
        //PV
        if APP_DELEGATE.Group_Exists_inHiddenGroupChat_List(strGroupID: selectedGroupDetails.group_id) == true {
            let restoHiddChat = UIAlertAction.init(title: "Restore Chat", style: .default, handler: { (action) in
                let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ImportExportProcessVC" ) as! ImportExportProcessVC
                objVC.strImgURL = self.selectedGroupDetails.icon
                objVC.strTitle = self.selectedGroupDetails.name
                objVC.objEnumImpExpoAction = .Import_HiddenChat
                objVC.Popup_Show(onViewController: self)
            })
            actionSheet.addAction(restoHiddChat)
        }
        
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(actionCancel)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func btnReplyClicked(_ sender: Any) {
        if arrSelectedIndexes.count == 1{
            
            //hideReplyView(sender)
            
            let model = arrMsgs[arrSelectedIndexes.first!]
            
            selectedMessageForReply = model
            inputvalues.textView.becomeFirstResponder()
            
            imgReply.image = nil
            
            if model.senderid == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId){
                lblReplySender.text = "You"
            }else{
                lblReplySender.text = model.sendername
            }
            
            let msgType = Int(model.messagetype)!
            if msgType == 0 || msgType == 4{
                lblReplyMessage.text = model.textmessage.base64Decoded
            }else if msgType == 1{
                if isPathForContact(path: model.mediaurl){
                    lblReplyMessage.text = model.textmessage.base64Decoded
                    imgReply.image = #imageLiteral(resourceName: "profile_pic_register")
                    //imgReplyWidth.constant = 48
                }else{
                    
                    if isPathForImage(path: model.mediaurl){
                        lblReplyMessage.text = "Image"
                        imgReply.sd_setImage(with: model.mediaurl.toUrl!, completed: { (image, error, cacheType, url) in
                            //self.imgReplyWidth.constant = 48
                        })
                    }
                    else{
                        lblReplyMessage.text = getFileType(for: model.mediaurl)
                        imgReply.image = getFileIcon(for: model.mediaurl)
                        //imgReplyWidth.constant = 48
                    }
                    
                }
            }else if msgType == 2{
                lblReplyMessage.text = "Location"
                imgReply.image = #imageLiteral(resourceName: "img_map")
                //imgReplyWidth.constant = 48
            }/*else if msgType == 3{ //BCZ STORY REPLY MESSAGE WON'T BE IN A GROUP CHAT
                 let arrDetails = model.textmessage.base64Decoded!.components(separatedBy: kStoryMessageSeparator)
                 lblReplyMessage.text = arrDetails[4]
                 }*/
            else if msgType == 5 {
                lblReplyMessage.text = get_ContactName(strMess: model.textmessage)
            }
            
            //vwReplyHeight.constant = 48
            /*UIView.animate(withDuration: 0.3) {
             self.view.layoutIfNeeded()
             }*/
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
                arrIDs.append(model.id)
                if isAllSentByMe{
                    if model.senderid != UserDefaultManager.getStringFromUserDefaults(key: kAppUserId){
                        isAllSentByMe = false
                    }
                }
                if isAllNonDeleted{
                    if model.isdeleted == "1"{
                        isAllNonDeleted = false
                    }
                }
                
            }
            
            let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let actionDeleteForMe = UIAlertAction.init(title: "Delete For Me", style: .destructive, handler: { (action) in
                CoreDBManager.sharedDatabase.deleteForMeGroupChatMessage(groupChatIDs: arrIDs)
                self.hideEditingNavBar()
                self.reloadTable()
                
                if self.arrMsgs.count > 0{
                    //TO UPDATE LAST MESSAGE IN CHATLISTVC
                    let lastMessage = self.arrMsgs.last!
                    CoreDBManager.sharedDatabase.updateGroupFor(groupMessage: lastMessage)
                }
                
            })
            alert.addAction(actionDeleteForMe)
            
            if isAllSentByMe && isAllNonDeleted{
                let actionDeleteForEveryone = UIAlertAction.init(title: "Delete For Everyone", style: .destructive, handler: { (action) in
                    
                    let dict = [
                        "chatids" : arrIDs.joined(separator: ","),
                        "groupid" : self.selectedGroupId
                        ] as [String : Any]
                    if let isConnected = APP_DELEGATE.socketIOHandler?.isSocektConnected(){
                        if isConnected{
                            APP_DELEGATE.socketIOHandler?.socket?.emit("DeleteGroupMessageForEveryone",dict)
                            CoreDBManager.sharedDatabase.deleteForEveryoneGroupChatMessage(groupChatIDs: arrIDs)
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
                var strMsg = model.textmessage.base64Decoded!
                var name = ""
                if model.sendername == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId){
                    name = "\(UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName))"
                }else{
                    name = "\(model.sendername)"
                }
                strMsg = "[\(model.createddate.components(separatedBy: "T").first!) \(name)] \(strMsg)"
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
            arrIDs.append(model.id)
            if isAllStarred == true{
                if model.isstarred == "0"{
                    isAllStarred = false
                }
            }
        }
        
        CoreDBManager.sharedDatabase.starUnstarGroupMessage(groupChatIDs: arrIDs, shouldStar: !isAllStarred)
        hideEditingNavBar()
        reloadTable()
    }
    
    @IBAction func btnForwardClicked(_ sender: Any) {
        //PASS SELECTED MESSAGES' ARRAY TO SELECT MEMBER VC
        if arrSelectedIndexes.count > 0{
            
            var selectedMsgs = [StructGroupChat]()
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
    
    //MARK: Attachment Button Clicks
    @IBAction func btnCameraClicked(_ sender: Any) {
        closeAttachmentView(completion: {})
        
        /*let assetVC = loadVC(strStoryboardId: SB_ASSET_PICKER, strVCId: idAssetPickerVC) as! AssetPickerVC
         assetVC.delegate = self
         assetVC.initallyCameraSelected = true
         APP_DELEGATE.appNavigation?.pushViewController(assetVC, animated: true)*/
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
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
            "groupid" : self.selectedGroupId,
            "senderid":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            "group_members":self.selectedGroupDetails.members,
            "textmessage": "\(location.coordinate.latitude),\(location.coordinate.longitude)".base64Encoded!,
            "messagetype": "2",
            "mediaurl": "",
            "platform":PlatformName,
            "createddate": "",
            "isdeleted":"0",
            "isread":"0",
            "username" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
            "filtered_members" : self.getFilteredMembersForSendMessage(),
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
    
    func openDocumentsPickerForAudio(forAudio:Bool) {
        var arrDocTypes = [String]()
        if forAudio {
            arrDocTypes = [kUTTypeMP3 as String, kUTTypeMPEG4Audio as String, kUTTypeWaveformAudio as String]
        } else {
            arrDocTypes = [kUTTypePDF as String, "com.microsoft.word.doc", "org.openxmlformats.wordprocessingml.document", "com.microsoft.excel.xls", kUTTypeSpreadsheet as String, kUTTypeText as String, kUTTypeRTF as String]
        }
        let documentPicker = UIDocumentPickerViewController.init(documentTypes: arrDocTypes, in: .import)
        documentPicker.delegate = self
        mostTopViewController?.present(documentPicker, animated: true, completion: nil)
    }
}

//MARK:-
extension GroupChatVC {
    //MARK: Web Service API
    func apiCheckUser_andStartChat(strContactNo:String, strPhoneNo:String) {
        self.view.endEditing(true)
        let parameter:NSDictionary = ["service":APICheckUserExistsWithPhone,
                                      "request":[ "countrycode" : strContactNo,
                                                  "phoneno": strPhoneNo ],
                                      "auth" : getAuthForService()
        ]
        showHUD()
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APICheckUserExistsWithPhone, parameters: parameter, keyname: ResponseKey as NSString, message: APICheckUserWithPhoneMessage, showLoader: false){ (error,apistatus,statusmessage,responseArray,responseDict) in
            
            hideHUD()
            //print("APICheckUserExistsWithPhone : \(responseDict!)")
            
            if error != nil{
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.apiCheckUser_andStartChat(strContactNo: strContactNo, strPhoneNo: strPhoneNo)
                })
                return
            }
            else {
                if apistatus == "0"{
                    showMessage("\(SomethingWrongMessage)\n Unable to get +\(strContactNo) \(strPhoneNo) info")
                }else{
                    let user = responseArray?.firstObject! as! User
                    self.start_PersonalChat(user: user)
                }
            }
        }
    }
    //MARK: Socket API
    @objc func fire_event_getmessaged()
    {
        var maxChatId:Float = 0
        let arr = CoreDBManager.sharedDatabase.getMessagesForGroupID(groupId: selectedGroupId, includeDeleted: true)
        if arr.count > 0{
            let chatIds = arr.map({Float($0.id)!})
            maxChatId = chatIds.max()!.rounded(.down)
        }
        if maxChatId == 0
        {
            maxChatId = Float(lastgroupmsgid - 1)
        }
        let msgDictionary = [
            "groupid" : selectedGroupId,
            "chatid" : String(maxChatId)
            ] as [String:Any]
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck(keyGetGroupChatMessagesByLastId,msgDictionary).timingOut(after: 1000)
        {data in
            //print("GetGroupChatMessagesByLastId : \(data)")
            
            let data = data as Array
            if(data.count > 0)
            {
                if data[0] is String { return }
                let dic = data[0] as! NSArray
                let obj = dic// dic["userResult"] as! NSArray
                for dicData in obj
                {
                    let objData:StructGroupChat = StructGroupChat.init(dictionary: dicData as! [String : Any])
                    _ = CoreDBManager.sharedDatabase.saveGroupMessageInLocalDB(objmessgae: objData)
                }
                
                self.reloadTable()
                self.tableViewScrollToBottomAnimated(animated: false)
                
                self.doUpdateReadStatus()
            }
            
        }
        
        doUpdateReadStatus()
    }
    
    func doUpdateReadStatus(){
        
        let userId = UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)
        
        let dtDate = DateFormater.getDateFromStringInLocalTimeZone(givenDate: DateFormater.getStringFromDate(givenDate: NSDate()))
        let strDate = DateFormater.getStringFromDate(givenDate: dtDate)
        
        let msgs = arrMsgs.filter({$0.senderid != userId}).map({$0.id})
        
        //for msgId in msgs{
        let dict = ["readtime" : strDate,
                    "groupchatid" : msgs.joined(separator: ","),
                    "userid" : userId ]
        APP_DELEGATE.socketIOHandler?.socket?.emit("Update_GroupMsgSeenStatus", dict)
        //}
    }
}

extension GroupChatVC : UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate, CNContactPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ContactsSendVC_Delegate {
    
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
                    
                    self.vcfPersonName = lastPathComponent.base64Encoded!
                    try FileManager.default.removeItem(atPath: tempURL.path)
                }
                // Move file from app_id-Inbox to tmp/filename
                try FileManager.default.moveItem(atPath: url.path, toPath: tempURL.path)
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
        let localURL = save_Content(contentURL: newUrls.first!, withName: fileName, inDirectory: self.get_URL_inGroupChatDir())
        sendMediaMessage(forLocalURL: localURL!)
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
        print(contact.givenName)
        print(contact.familyName)
        
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
                let localURL = save_Content(contentURL: fileURL, withName: fileName, inDirectory: self.get_URL_inGroupChatDir())
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
            "groupid":selectedGroupId,
            "senderid":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            "group_members": selectedGroupDetails.members,
            "textmessage": strJSONString,
            "messagetype": "5",
            "mediaurl": "",
            "platform":PlatformName,
            "createddate": "",
            "isdeleted":"0",
            "isread":"0",
            "username" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
            "filtered_members" : getFilteredMembersForSendMessage(),
            "countrycode" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode).replacingOccurrences(of: "+", with: ""),
            "phonenumber" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)]  as [String : Any]
        
        /*let dic = [
         //"uniqueid" : "\(getNewPendingMessageID())", //PV | Id not set app will be crash, if not found : "uniqueid"
         "senderid":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
         "receiverid":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
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
         "phonenumber" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)]  as [String : Any]*/
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
            let localURL = save_Content(image: imgView.image!, imageName: "\(self.getNewPendingMessageID()).png", inDirectory: self.get_URL_inGroupChatDir())
            self.sendMediaMessage(forLocalURL: localURL!)
            //self.uploadChatAttachment(attachment: tempImage)
        }
    }
}

extension GroupChatVC : AssetPickerDelegate{
    
    func assetPickerDidFinishSelectingAssets(withFilterAssetModels filterAssetModels: [FilterAssetModel]) {
        
        DispatchQueue.main.async {
            let viewControllers: [UIViewController] = APP_DELEGATE.appNavigation!.viewControllers as [UIViewController]
            APP_DELEGATE.appNavigation!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for filterModel in filterAssetModels{
                //let filterModel = filterAssetModels.first!
                if filterModel.originalPHAsset.mediaType == .image{
                    let localURL = save_Content(image: filterModel.originalPHAsset.getOriginalImage(), imageName: "\(self.getNewPendingMessageID()).png", inDirectory: self.get_URL_inGroupChatDir())
                    self.sendMediaMessage(forLocalURL: localURL!)
                    //self.uploadChatAttachment(attachment: filterModel.originalPHAsset.getOriginalImage())
                }else{
                    let fileName = "\(self.getNewPendingMessageID())" + "." + filterModel.exportedFileURL!.pathExtension
                    let localURL = save_Content(contentURL: filterModel.exportedFileURL!, withName: fileName, inDirectory: self.get_URL_inGroupChatDir())
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
        let sizeoffile = fileSize(url: localURL)
        let dic = [
            "groupid":selectedGroupId,
            "senderid":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            "group_members": selectedGroupDetails.members,
            "textmessage": self.vcfPersonName,
            "messagetype": "1",
            "mediaurl": localURL.path,
            "platform":PlatformName,
            "createddate": "",
            "isdeleted":"0",
            "isread":"0",
            "username" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
            "filtered_members" : getFilteredMembersForSendMessage(),
            "countrycode" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode).replacingOccurrences(of: "+", with: ""),
            "phonenumber" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile),
            "mediasize":sizeoffile
            ]  as [String : Any]
        
        newSendMessageWithDic(dic: dic)
    }
    
    func uploadChatAttachment(attachment:Any){
        //showLoaderHUD(strMessage: "Uploading Attachment")
        let parameter :NSMutableDictionary = ["token_id":UserDefaultManager.getStringFromUserDefaults(key: kToken)]
        
        if attachment is UIImage{
            let imageData:Data = UIImageJPEGRepresentation(attachment as! UIImage, uploadImageCompression)!
            parameter.setObject([imageData], forKey: ("image[]" as NSString))
        }
        else if attachment is URL{
            parameter.setObject([attachment], forKey: ("image[]" as NSString))
        }
        
        HttpRequestManager.sharedInstance.requestWithPostMultipartParam(endpointurl: Upload_Chat_Attachment, isImage: true, parameters: parameter) {(data, error, message, responseDict) -> Void in
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
                        }
                        
                        //--------------------------------------------->
                        if isPathForImage(path: strMediaURL) {
                            let img : UIImage = (attachment as? UIImage)!
                            var imgName : String = "\(get_fileName_asCurretDateTime())\(get_RandomNo(noOfDigit: 2)).jpg"
                            imgName = strMediaURL.url?.lastPathComponent ?? imgName
                            //let imgURL : URL = self.save_MediaContent_inChatDir(image: img, imageName: imgName)!
                            let imgURL : URL = save_Content(image: img, imageName: imgName, inDirectory: self.get_URL_inGroupChatDir())!
                            //print("imgURL: \(imgURL)")
                        }
                            //Video
                        else if isPathForVideo(path: strMediaURL) {
                            var videoName : String = "\(get_fileName_asCurretDateTime())\(get_RandomNo(noOfDigit: 2)).mp4"
                            videoName = strMediaURL.url?.lastPathComponent ?? videoName
                            //let videoURL : URL = self.save_MediaContent_inChatDir(contentURL: attachment as! URL, withName: videoName)!
                            let videoURL : URL = save_Content(contentURL: attachment as! URL, withName: videoName, inDirectory: self.get_URL_inGroupChatDir())!
                            //print("videoURL: \(videoURL)")
                        }
                            //Audio
                        else if isPathForAudio(path: strMediaURL) {
                            var audioFileName : String = "\(get_fileName_asCurretDateTime())\(get_RandomNo(noOfDigit: 2)).m4a"
                            audioFileName = strMediaURL.url?.lastPathComponent ?? audioFileName
                            let audioFileURL : URL = save_Content(contentURL: attachment as! URL, withName: audioFileName, inDirectory: self.get_URL_inGroupChatDir())!
                            //print("audioFileURL: \(audioFileURL)")
                            
                            //Remove temp. taken file
                            removeFile_onURL(fileURL: attachment as! URL)
                        }
                            //Contact
                        else if isPathForContact(path: strMediaURL) {
                            var contactFileName : String = "\(get_fileName_asCurretDateTime())\(get_RandomNo(noOfDigit: 2)).vcf"
                            contactFileName = strMediaURL.url?.lastPathComponent ?? contactFileName
                            let contactFileURL : URL = save_Content(contentURL: attachment as! URL, withName: contactFileName, inDirectory: self.get_URL_inGroupChatDir())!
                            //print("contactFileURL: \(contactFileURL)")
                            
                            //Remove temp. taken file
                            removeFile_onURL(fileURL: attachment as! URL)
                        }
                            //OtherFile/Document
                        else {
                            let documentFileName : String = (strMediaURL.url?.lastPathComponent)!
                            let contactFileURL : URL = save_Content(contentURL: attachment as! URL, withName: documentFileName, inDirectory: self.get_URL_inGroupChatDir())!
                            //print("documentFileURL: \(contactFileURL)")
                            
                            //Remove temp. taken file
                            removeFile_onURL(fileURL: attachment as! URL)
                        }
                        //--------------------------------------------->
                        
                        let dic = [
                            "groupid":self.selectedGroupId,
                            "senderid":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
                            "group_members":self.selectedGroupDetails.members,
                            "textmessage": self.vcfPersonName,
                            "messagetype": "1",
                            "mediaurl": strMediaURL,
                            "platform":PlatformName,
                            "createddate": "",
                            "isdeleted":"0",
                            "isread":"0",
                            "username" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
                            "filtered_members" : self.getFilteredMembersForSendMessage(),
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
        }
    }
    
}

extension GroupChatVC:UITableViewDelegate,UITableViewDataSource
{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1//arrAssortedMsgs.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMsgs.count
        /*let assortedMsgs = arrAssortedMsgs[section]
         return assortedMsgs.Msgs.count*/
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let obj = arrMsgs[indexPath.row]
        /*let assortedMsgs = arrAssortedMsgs[indexPath.section]
         let obj = assortedMsgs.Msgs[indexPath.row] as! StructGroupChat*/
        
        var dtvalr = obj.createddate == "" ? "" : timeAgoSinceStrDate(strDate: obj.createddate, numericDates: true)
        if obj.isstarred == "1" { dtvalr = "★ \(dtvalr)" }
        
        if obj.messagetype == "-1" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatInitialCell") as! GroupChatInitialCell
            
            let message = obj.textmessage.base64Decoded!
            
            var phoneNo1 = ""
            var arrPhoneNos = [""]
            var msg = ""
            if message.contains("created"){
                var components = message.components(separatedBy: " ")
                phoneNo1 = components.first!
                components.remove(at: 0)
                msg = " " + components.joined(separator: " ")
            }else{
                var components = message.components(separatedBy: "|")
                phoneNo1 = components.first!
                components.removeFirst()
                arrPhoneNos = components.last!.components(separatedBy: ",")
                components.removeLast()
                msg = components.joined(separator: " ")
                //if components.contains("removed") || components.contains("added"){
                msg = " " + msg + " "
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
                
                /*let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: obj.countrycode , phoneNo: obj.phonenumber )
                 if objContactInfo.Name?.count == 0 {
                 //print("NOT IN CONTACTS")
                 //self.lblisonline.text = "+" + countrycode + " " + phoneno + " is typing.."
                 phoneNo1 = "+\(obj.countrycode)\(obj.phonenumber)"
                 }
                 else {
                 phoneNo1 = objContactInfo.Name!
                 }*/
            }
            
            //msg = phoneNo1 + " " + msg
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
            msg = msg.replacingOccurrences(of: "You is", with: "You are") //PU
            
            cell.lblInitialMessage.text = msg
            
            cell.selectionStyle = .none
            cell.isUserInteractionEnabled = false
            
            return cell
        }
        
        let parentMessage = arrMsgs.first(where: {$0.id == obj.parent_id} )
        var nameReply:String? = "You"
        if parentMessage?.senderid != UserDefaultManager.getStringFromUserDefaults(key: kAppUserId){
            nameReply = parentMessage?.sendername
        }
        var messageReply:String? = ""
        if parentMessage != nil{
            messageReply = parentMessage?.textmessage.base64Decoded
            if messageReply!.count == 0 {
                if parentMessage!.mediaurl.count > 0{
                    messageReply = getFileType(for: parentMessage!.mediaurl)
                }
            }
            
            if parentMessage?.messagetype == "2" { messageReply = "Location" }
            else if parentMessage?.messagetype == "5" { messageReply = get_ContactName(strMess: (parentMessage?.textmessage)!) }
        }
        
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(cellLongPressed(sender:)))
        longPress.accessibilityLabel = "\(indexPath.row)"
        
        var bubble = getBubbleImage(objChat: obj)
        var bubbleImg:UIImage? = UIImage()
        
        if obj.senderid == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)
        {
            bubble = "right\(bubble)"
            bubbleImg = UIImage(named:bubble)
            
            var imgReadReceipt:UIImage? = #imageLiteral(resourceName: "pending_msg")
            switch obj.isread {
            case "-1":
                imgReadReceipt = #imageLiteral(resourceName: "pending_msg")
            case "0":
                imgReadReceipt = #imageLiteral(resourceName: "sent_msg")
            case "1":
                imgReadReceipt = #imageLiteral(resourceName: "delivered_msg")
            case "2":
                imgReadReceipt = #imageLiteral(resourceName: "read_msg")
            default:
                break;
            }
            
            if Int(obj.messagetype)! > 0 {
                if obj.messagetype == "4"{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatLinkPreviewReceiverCell") as! ChatLinkPreviewReceiverCell
                    
                    let arrMedia = obj.mediaurl.components(separatedBy: kLinkMessageSeparator)
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
                    
                    cell.lblmsg.text = obj.textmessage.base64Decoded
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
                else if obj.messagetype == "5" {
                    //let cell : ChatContactSenderCell = self.manage_ContactCell_Sender(tableView: tableView, indexPath: indexPath)
                    //return cell
                    
                    let cell  = self.manage_ContactCell_Receiver(tableView: tableView, indexPath: indexPath)
                    return cell
                }
                
                if isPathForImage(path: obj.mediaurl) ||  isPathForVideo(path: obj.mediaurl) || obj.messagetype == "2"{
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatReceiverAttachCell") as! ChatReceiverAttachCell
                    cell.lbltime.text = dtvalr //obj.kcreateddate
                    //cell.imgsent.image = obj.kmediaImage
                    cell.chatReceiverAttachCellDelegate = self
                    cell.btnAttach.tag = indexPath.row
                    cell.btnAttach.accessibilityLabel = "\(indexPath.section)"
                    
                    cell.imgsent.image = nil
                    cell.imgsent.image = SquarePlaceHolderImage_Chat
                    
                    if isPathForVideo(path: obj.mediaurl)
                    {
                        cell.imgsent.image = UIImage.init(color: .black)
                        
                        let fileName = obj.mediaurl.lastPathComponent
                        let replacedFileName = fileName.components(separatedBy: ".").first! + "_thumb.jpg"
                        var strThumbURL = obj.mediaurl.replacingOccurrences(of: fileName, with: replacedFileName)
                        
                        if strThumbURL.contains("http") == false{
                            strThumbURL = Get_Chat_Attachment_URL + replacedFileName
                        }
                        cell.imgsent.sd_setImage(with: strThumbURL.toUrl, placeholderImage: PlaceholderImage)
                        
                        //SHOW PLAY ICON ON CELL
                        cell.imgPlayVideo.isHidden = false
                        
                        
                        if obj.isread == "-1"{
                            cell.heightOfvwDownload.constant = 35
                            if obj.id == currentlySendingMessageID{
                                cell.downloadIndicator.startAnimating()
                                cell.lblDownload.text = "UPLOADING.."
                            }else{
                                cell.lblDownload.text = "QUEUED"
                            }
                        }else{
                            if ChatAttachmentDownloader.sharedInstance.isDownloading(remoteURL: obj.mediaurl.toUrl!){
                                cell.lblDownload.text = "Downloading.."
                                cell.heightOfvwDownload.constant = 35
                                cell.downloadIndicator.startAnimating()
                                addBlurAboveImage(cell.imgsent, 0.9)
                            }else{
                                if isFileLocallyExist(fileName: obj.mediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inGroupChatDir()){
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
                            }
                        }
                    }
                    else if isPathForImage(path: obj.mediaurl)
                    {
                        //HIDE PLAY ICON
                        cell.imgPlayVideo.isHidden = true
                        
                        //Set Blur Image
                        cell.imgBlurImage_Send.sd_setImage(with: URL.init(string: obj.mediaurl), placeholderImage: SquarePlaceHolderImage_Chat)
                        if isFileLocallyExist(fileName: obj.mediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inGroupChatDir())
                        {
                            let url = getURL_LocallyFileExist(fileName: obj.mediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inGroupChatDir())
                            do{
                                let data = try Data.init(contentsOf: url)
                                let img = UIImage.init(data: data)
                                cell.imgBlurImage_Send.image = img
                            }catch{
                                print(error.localizedDescription)
                            }
                        }
                        addBlurAboveImage(cell.imgBlurImage_Send, 0.9)
                        
                        //cell.imgsent.sd_setImage(with: URL.init(string: obj.kmediaurl), placeholderImage: PlaceholderImage)
                        /*SDWebImageManager.shared().cachedImageExists(for: obj.kmediaurl.toUrl, completion: { (doesExist) in
                         if doesExist{
                         cell.imgsent.sd_setImage(with: obj.kmediaurl.toUrl, placeholderImage: PlaceholderImage)
                         cell.heightOfvwDownload.constant = 0
                         }else{
                         cell.heightOfvwDownload.constant = 35
                         }
                         })*/
                        cell.imgsent.image = nil
                        cell.imgsent.image = SquarePlaceHolderImage_Chat
                        if isFileLocallyExist(fileName: obj.mediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inGroupChatDir())
                        {
                            cell.vwDownload.isHidden = true
                            let url = getURL_LocallyFileExist(fileName: obj.mediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inGroupChatDir())
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
                        if obj.isread == "-1"{
                            if obj.id == currentlySendingMessageID{
                                cell.downloadIndicator.startAnimating()
                                cell.lblDownload.text = "UPLOADING.."
                            }else{
                                cell.lblDownload.text = "QUEUED"
                            }
                        }else{
                            if ChatAttachmentDownloader.sharedInstance.isDownloading(remoteURL: obj.mediaurl.toUrl!){
                                cell.lblDownload.text = "Downloading.."
                                cell.heightOfvwDownload.constant = 35
                                cell.downloadIndicator.startAnimating()
                                cell.imgBlurImage_Send.isHidden = false
                            }else{
                                if isFileLocallyExist(fileName: obj.mediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inGroupChatDir()){
                                    cell.lblDownload.text = ""
                                    cell.heightOfvwDownload.constant = 0
                                    cell.downloadIndicator.stopAnimating()
                                    
                                    let url = getURL_LocallyFileExist(fileName: obj.mediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inGroupChatDir())
                                    do{
                                        let data = try Data.init(contentsOf: url)
                                        let img = UIImage.init(data: data)
                                        cell.imgsent.image = img
                                        cell.imgBlurImage_Send.isHidden = true
                                    }catch{
                                        print(error.localizedDescription)
                                    }
                                    
                                }else{
                                    cell.lblDownload.text = "Download"
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
                    }else if obj.messagetype == "2"{
                        cell.imgPlayVideo.isHidden = true
                        cell.imgsent.image = #imageLiteral(resourceName: "img_map")
                        cell.imgBlurImage_Send.isHidden = true
                        cell.heightOfvwDownload.constant = 0
                        
                        if obj.isread == "-1"{
                            if obj.id == currentlySendingMessageID{
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
                else if isPathForContact(path: obj.mediaurl){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatContactReceiverCell") as!
                    ChatContactReceiverCell
                    cell.lblContact.text = obj.textmessage.base64Decoded
                    //cell.imgContact.image = #imageLiteral(resourceName: "profile_pic_register")
                    cell.chatReceiverContactCellDelegate = self
                    cell.btnContact.tag = indexPath.row
                    cell.btnContact.accessibilityLabel = "\(indexPath.section)"
                    cell.Lbltime.text = dtvalr
                    
                    cell.imgreceipt.image = imgReadReceipt
                    cell.imgbubble.image = bubbleImg
                    
                    cell.selectionStyle = .blue
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
                    
                    if obj.isread == "-1"{
                        if obj.id == currentlySendingMessageID{
                            cell.downloadIndicator.startAnimating()
                        }
                    }else{
                        if ChatAttachmentDownloader.sharedInstance.isDownloading(remoteURL: obj.mediaurl.toUrl!){
                            cell.btnContact.setTitle("Downloading", for: .normal)
                            cell.downloadIndicator.startAnimating()
                        }else{
                            if isFileLocallyExist(fileName: obj.mediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inGroupChatDir()){
                                cell.btnContact.setTitle("Add to Contacts", for: .normal)
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
                    /*else if isPathForAudio(path: obj.mediaurl){
                     let cell = tableView.dequeueReusableCell(withIdentifier: "ChatReceiverAudioCell") as! ChatReceiverAudioCell
                     cell.lbltime.text = dtvalr
                     cell.imgUser.image = #imageLiteral(resourceName: "profile_pic_register")
                     cell.btnPlay.tag = indexPath.row
                     cell.btnPlay.accessibilityLabel = "\(indexPath.section)"
                     cell.chatReceiverAudioCellDelegate = self
                     cell.imgreadicon.image = imgReadReceipt
                     
                     cell.audioSlider.setValue(0, animated:false)
                     
                     if isFileLocallySaved(fileUrl: URL.init(string: obj.mediaurl)!){
                     let localURL = getLocallySavedFileURL(with: URL.init(string: obj.mediaurl)!)!
                     if audioPlayer?.url == localURL{
                     if (audioPlayer?.isPlaying)!{
                     cell.audioSlider.setValue(Float(audioPlayer!.currentTime/audioPlayer!.duration), animated: true)
                     currentPlayingAudioCellIndex = indexPath
                     }
                     }
                     }
                     cell.imgbubble.image = bubbleImg
                     
                     //cell.heightReplyView.constant = 0
                     
                     return cell
                     }*/
                else{
                    //DOCUMENT RECEIVER CELL
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatReceiverDocumentCell") as! ChatReceiverDocumentCell
                    
                    cell.lbltime.text = dtvalr
                    
                    cell.chatReceiverDocumentCellDelegate = self
                    cell.btnReceiverDocument.tag = indexPath.row
                    cell.btnReceiverDocument.accessibilityLabel = "\(indexPath.section)"
                    
                    cell.lblFileType.text = getFileType(for: obj.mediaurl)
                    cell.imgsent.image = getFileIcon(for: obj.mediaurl)
                    
                    //*************************
                    //cell.lblFileType.text = obj.textmessage.base64Decoded ?? obj.mediaurl.lastPathComponent
                    cell.lblFileType.text = obj.textmessage.base64Decoded?.count != 0 ? obj.textmessage.base64Decoded : obj.mediaurl.lastPathComponent
                    cell.lblFileType.numberOfLines = 2
                    
                    cell.imgreceipt.image = imgReadReceipt
                    cell.imgbubble.image = bubbleImg
                    
                    cell.selectionStyle = .blue
                    cell.addGestureRecognizer(longPress)
                    
                    if parentMessage != nil {
                        cell.heightReplyView.constant = 48
                        cell.lblMessageReply.text = messageReply
                        cell.lblNameReply.text = nameReply
                    } else {
                        cell.lblMessageReply.text = ""
                        cell.lblNameReply.text = ""
                        cell.heightReplyView.constant = 0
                    }
                    
                    if obj.isread == "-1" {
                        if obj.id == currentlySendingMessageID { cell.downloadIndicator.startAnimating() }
                    } else {
                        if ChatAttachmentDownloader.sharedInstance.isDownloading(remoteURL: obj.mediaurl.toUrl!){
                            cell.downloadIndicator.startAnimating()
                        } else {
                            if isFileLocallyExist(fileName: obj.mediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inGroupChatDir()){
                                cell.downloadIndicator.stopAnimating()
                            } else {
                                cell.downloadIndicator.stopAnimating()
                            }
                        }
                    }
                    
                    clickOnReplyButtonInCell(frame: cell.contentView.bounds, view: cell.contentView)
                    return cell
                }
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatReceiverCell") as! ChatReceiverCell
                
                cell.lblmsg.text = obj.textmessage.base64Decoded
                cell.lbltime.text = dtvalr //obj.kcreateddate
                cell.lblmsg.numberOfLines = 0
                //cell.lblmsg.sizeToFit()
                cell.lblmsg.layoutIfNeeded()
                cell.imgreceipt.image = imgReadReceipt
                cell.imgbubble.image = bubbleImg
                
                cell.selectionStyle = .blue
                cell.addGestureRecognizer(longPress)
                
                if parentMessage != nil {
                    cell.heightReplyView.constant = 48
                    cell.lblMessageReply.text = messageReply
                    cell.lblNameReply.text = nameReply
                } else{
                    cell.lblMessageReply.text = ""
                    cell.lblNameReply.text = ""
                    cell.heightReplyView.constant = 0
                }
                
                clickOnReplyButtonInCell(frame: cell.contentView.bounds, view: cell.contentView)
                
                return cell;
            }
        }
        else {
            bubble = "left\(bubble)"
            bubbleImg = UIImage(named:bubble)
            
            //PV
            //------>
            var senderName = ""
            senderName = obj.sendername
            //DispatchQueue.main.async(execute: {
            let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: obj.countrycode, phoneNo: obj.phonenumber)
            if objContactInfo.Name?.count == 0 {
                //print("NOT IN CONTACTS")
                senderName = "+\(obj.countrycode) \(obj.phonenumber)"
                if TRIM(string: senderName) == "+" { senderName = obj.sendername }
            }
            else { senderName = objContactInfo.Name ?? obj.sendername }
            //})
            //<------
            
            if Int(obj.messagetype)! > 0 {
                
                if obj.messagetype == "4"{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatLinkPreviewSenderCell") as! GroupChatLinkPreviewSenderCell
                    
                    let arrMedia = obj.mediaurl.components(separatedBy: kLinkMessageSeparator)
                    let linkURL = arrMedia[0]
                    let linkImage = arrMedia[1]
                    let linkTitle = arrMedia[2]
                    var linkDesc = "-"
                    if arrMedia.count > 3 { linkDesc = arrMedia[3] }
                    
                    cell.imgLinkPreview.contentMode = .scaleAspectFit
                    cell.imgLinkPreview.sd_setImage(with: linkImage.toUrl, completed: { (image, error, cacheType, url) in
                        if error == nil { cell.widthImgLinkPreview.constant = 40 }
                        else { cell.widthImgLinkPreview.constant = 0 }
                    })
                    
                    cell.lblSender.text = senderName
                    cell.btnSender_LinkMess.tag = indexPath.row
                    cell.btnSender_LinkMess.addTarget(self, action: #selector(btnSender_LinkMessAction(_:)), for: .touchUpInside)
                    
                    cell.btnLink.tag = indexPath.row
                    cell.btnLink.accessibilityLabel = "\(indexPath.section)"
                    cell.groupChatLinkPreviewSenderCellDelegate = self
                    
                    cell.lblLinkTitle.text = linkTitle
                    cell.lblLinkDescription.text = linkDesc
                    cell.lblLinkUrl.text = linkURL
                    
                    cell.lblmsg.text = obj.textmessage.base64Decoded
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
                else if obj.messagetype == "5" {
                    let cell = self.manage_ContactCell_Sender(tableView: tableView, indexPath: indexPath)
                    return cell
                }
                
                if isPathForImage(path: obj.mediaurl) ||  isPathForVideo(path: obj.mediaurl) || obj.messagetype == "2"{
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatSenderAttachCell") as! GroupChatSenderAttachCell
                    cell.lbltime.text = dtvalr// obj.kcreateddate
                    cell.groupChatSenderAttachCellDelegate = self
                    cell.btnAttach.tag = indexPath.row
                    cell.btnAttach.accessibilityLabel = "\(indexPath.section)"
                    
                    cell.imgreceived.image = nil
                    cell.imgreceived.image = SquarePlaceHolderImage_Chat //PV
                    
                    if isPathForVideo(path: obj.mediaurl){
                        
                        cell.imgreceived.image = UIImage.init(color: .black)
                        cell.imgBlurImage_Received.isHidden = true
                        
                        let fileName = obj.mediaurl.lastPathComponent
                        let replacedFileName = fileName.components(separatedBy: ".").first! + "_thumb.jpg"
                        var strThumbURL = obj.mediaurl.replacingOccurrences(of: fileName, with: replacedFileName)
                        
                        if strThumbURL.contains("http") == false{
                            strThumbURL = Get_Chat_Attachment_URL + replacedFileName
                        }
                        cell.imgreceived.sd_setImage(with: strThumbURL.toUrl, placeholderImage: PlaceholderImage)
                        
                        //SHOW PLAY ICON ON CELL
                        cell.imgPlayVideo.isHidden = false
                        
                        if ChatAttachmentDownloader.sharedInstance.isDownloading(remoteURL: obj.mediaurl.toUrl!){
                            cell.lblDownload.text = "Downloading.."
                            cell.heightOfvwDownload.constant = 35
                            cell.downloadIndicator.startAnimating()
                            addBlurAboveImage(cell.imgreceived, 0.9)
                            cell.imgBlurImage_Received.isHidden = false
                        }
                        else {
                            if isFileLocallyExist(fileName: obj.mediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inGroupChatDir()){
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
                        
                        if cell.heightOfvwDownload.constant == 0 {
                            cell.vwloader.isHidden = true
                            cell.imgloaderbg.isHidden = false
                        }
                        else {
                            if cell.lblDownload.text != "" {
                                cell.vwloader.isHidden = true
                                cell.imgloaderbg.isHidden = false
                            }
                            else {
                                cell.vwloader.isHidden = false
                                cell.imgloaderbg.isHidden = true
                            }
                        }
                    }else if isPathForImage(path: obj.mediaurl){
                        //HIDE PLAY ICON
                        cell.imgPlayVideo.isHidden = true
                        
                        //Set Blur Image
                        cell.imgBlurImage_Received.sd_setImage(with: URL.init(string: obj.mediaurl), placeholderImage: SquarePlaceHolderImage_Chat)
                        addBlurAboveImage(cell.imgBlurImage_Received, 0.9)
                        
                        //cell.imgreceived.sd_setImage(with: URL.init(string: obj.kmediaurl), placeholderImage: PlaceholderImage)
                        /*SDWebImageManager.shared().cachedImageExists(for: obj.kmediaurl.toUrl, completion: { (doesExist) in
                         if doesExist{
                         cell.imgreceived.sd_setImage(with: obj.kmediaurl.toUrl, placeholderImage: PlaceholderImage)
                         cell.heightOfvwDownload.constant = 0
                         }else{
                         cell.heightOfvwDownload.constant = 35
                         }
                         })*/
                        cell.imgreceived.image = nil
                        cell.imgreceived.image = SquarePlaceHolderImage_Chat //PV
                        
                        if ChatAttachmentDownloader.sharedInstance.isDownloading(remoteURL: obj.mediaurl.toUrl!){
                            cell.lblDownload.text = "Downloading.."
                            cell.heightOfvwDownload.constant = 35
                            cell.downloadIndicator.startAnimating()
                            cell.imgBlurImage_Received.isHidden = false
                        }
                        else {
                            if isFileLocallyExist(fileName: obj.mediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inGroupChatDir()){
                                cell.lblDownload.text = ""
                                cell.heightOfvwDownload.constant = 0
                                cell.downloadIndicator.stopAnimating()
                                
                                let url = getURL_LocallyFileExist(fileName: obj.mediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inGroupChatDir())
                                do{
                                    let data = try Data.init(contentsOf: url)
                                    let img = UIImage.init(data: data)
                                    cell.imgreceived.image = img
                                    cell.imgBlurImage_Received.isHidden = true
                                }catch{
                                    print(error.localizedDescription)
                                }
                                
                            }else{
                                cell.lblDownload.text = "Download"
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
                        cell.imgreceived.backgroundColor = SquarePlaceHolderImage_ChatBG //PV
                    }else if obj.messagetype == "2"{
                        cell.imgPlayVideo.isHidden = true
                        cell.imgreceived.image = #imageLiteral(resourceName: "img_map")
                        cell.imgBlurImage_Received.isHidden = true
                        cell.heightOfvwDownload.constant = 0
                    }
                    cell.lblSender.text = senderName
                    cell.btnSender_withAttach.tag = indexPath.row
                    cell.btnSender_withAttach.addTarget(self, action: #selector(btnSender_withAttachAction(_:)), for: .touchUpInside)
                    
                    cell.selectionStyle = .blue
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
                else if isPathForContact(path: obj.mediaurl){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatContactSenderCell") as!
                    GroupChatContactSenderCell
                    cell.lblContact.text = obj.textmessage.base64Decoded
                    //cell.imgContact.image = #imageLiteral(resourceName: "profile_pic_register")
                    cell.groupChatSenderContactCellDelegate = self
                    cell.btnContact.tag = indexPath.row
                    cell.btnContact.accessibilityLabel = "\(indexPath.section)"
                    cell.Lbltime.text = dtvalr
                    cell.imgbubble.image = bubbleImg
                    
                    cell.lblSender.text = senderName
                    cell.btnSender_ContactMess.tag = indexPath.row
                    cell.btnSender_ContactMess.addTarget(self, action: #selector(btnSender_ContactMessAction(_:)), for: .touchUpInside)
                    
                    cell.selectionStyle = .blue
                    cell.addGestureRecognizer(longPress)
                    
                    if parentMessage != nil {
                        cell.heightReplyView.constant = 48
                        cell.lblMessageReply.text = messageReply
                        cell.lblNameReply.text = nameReply
                    } else {
                        cell.lblMessageReply.text = ""
                        cell.lblNameReply.text = ""
                        cell.heightReplyView.constant = 0
                    }
                    
                    if ChatAttachmentDownloader.sharedInstance.isDownloading(remoteURL: obj.mediaurl.toUrl!){
                        cell.btnContact.setTitle("Downloading", for: .normal)
                        cell.downloadIndicator.startAnimating()
                    }else{
                        if isFileLocallyExist(fileName: obj.mediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inGroupChatDir()){
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
                    /*else if isPathForAudio(path: obj.mediaurl){
                     let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatSenderAudioCell") as! GroupChatSenderAudioCell
                     cell.lbltime.text = dtvalr
                     cell.imgUser.image = #imageLiteral(resourceName: "profile_pic_register")
                     cell.btnPlay.tag = indexPath.row
                     cell.btnPlay.accessibilityLabel = "\(indexPath.section)"
                     cell.groupChatSenderAudioCellDelegate = self
                     
                     cell.audioSlider.setValue(0, animated:false)
                     
                     if isFileLocallySaved(fileUrl: URL.init(string: obj.mediaurl)!){
                     let localURL = getLocallySavedFileURL(with: URL.init(string: obj.mediaurl)!)!
                     if audioPlayer?.url == localURL{
                     if (audioPlayer?.isPlaying)!{
                     cell.audioSlider.setValue(Float(audioPlayer!.currentTime/audioPlayer!.duration), animated: true)
                     currentPlayingAudioCellIndex = indexPath
                     }
                     }
                     }
                     cell.imgbubble.image = bubbleImg
                     cell.lblSender.text = senderName
                     return cell
                     }*/
                else {
                    //DOCUMENT
                    let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatSenderDocumentCell") as! GroupChatSenderDocumentCell
                    
                    cell.lbltime.text = dtvalr
                    
                    cell.groupChatSenderDocumentCellDelegate = self
                    cell.btnSenderDocument.tag = indexPath.row
                    cell.btnSenderDocument.accessibilityLabel = "\(indexPath.section)"
                    
                    cell.lblFileType.text = getFileType(for: obj.mediaurl)
                    cell.imgsent.image = getFileIcon(for: obj.mediaurl)
                    
                    //*************************
                    //cell.lblFileType.text = obj.textmessage.base64Decoded ?? obj.mediaurl.lastPathComponent
                    cell.lblFileType.text = obj.textmessage.base64Decoded?.count != 0 ? obj.textmessage.base64Decoded : obj.mediaurl.lastPathComponent
                    cell.lblFileType.numberOfLines = 2
                    
                    cell.imgbubble.image = bubbleImg
                    
                    cell.lblSender.text = senderName
                    cell.btnSender_DocumentMess.tag = indexPath.row
                    cell.btnSender_DocumentMess.addTarget(self, action: #selector(btnSender_DocumentMessAction(_:)), for: .touchUpInside)
                    
                    cell.selectionStyle = .blue
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
                    
                    let strURL : String = obj.mediaurl
                    if strURL.contains("http://") == true {
                        if ChatAttachmentDownloader.sharedInstance.isDownloading(remoteURL: obj.mediaurl.toUrl!){
                            cell.downloadIndicator.startAnimating()
                        }else{
                            if isFileLocallyExist(fileName: obj.mediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inGroupChatDir()) {
                                cell.downloadIndicator.stopAnimating()
                            }
                            else{ cell.downloadIndicator.stopAnimating() }
                        }
                    }
                    
                    clickOnReplyButtonInCell(frame: cell.contentView.bounds, view: cell.contentView)
                    
                    return cell
                }
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatSenderCell") as! GroupChatSenderCell
                cell.lblmsg.text = obj.textmessage.base64Decoded
                cell.lbltime.text = dtvalr //obj.kcreateddate
                cell.lblmsg.numberOfLines = 0
                //cell.lblmsg.sizeToFit()
                cell.lblmsg.layoutIfNeeded()
                cell.imgbubble.image = bubbleImg
                
                cell.lblSender.text = senderName
                cell.btnSender_TextMess.tag = indexPath.row
                cell.btnSender_TextMess.addTarget(self, action: #selector(btnSender_TextMessAction(_:)), for: .touchUpInside)
                
                cell.selectionStyle = .blue
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let obj = arrMsgs[indexPath.row]
        /*let assortedMsgs = arrAssortedMsgs[indexPath.section]
         let obj = assortedMsgs.Msgs[indexPath.row] as! StructGroupChat*/
        
        let parentMessage = arrMsgs.first(where: {$0.id == obj.parent_id} )
        
        if Int(obj.messagetype)! > 0 {
            if obj.senderid == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId) {
                //MIGHT NEED TO DEDUCT 19 (SENDER LABEL)
                if isPathForImage(path: obj.mediaurl) ||  isPathForVideo(path: obj.mediaurl) || obj.messagetype == "2"{
                    if parentMessage != nil { return 222 }
                    else{ return 167 }
                }
                else if isPathForContact(path: obj.mediaurl) {
                    if parentMessage != nil {
                        return 172//130
                    }
                    else{
                        return 124//68
                    }
                }
                else if obj.messagetype == "4" { return UITableViewAutomaticDimension }
                else if obj.messagetype == "5" {
                    if (obj.parent_id != "0") { return 172 }
                    else { return 124 }
                }
                else {
                    if parentMessage != nil { return 155 }
                    else { return 80 }
                }
                
            }
            else {
                if isPathForImage(path: obj.mediaurl) ||  isPathForVideo(path: obj.mediaurl) || obj.messagetype == "2"{
                    if parentMessage != nil { return 222 }
                    else { return 167 }
                    //return 167 + 19
                }
                else if isPathForContact(path: obj.mediaurl) {
                    if parentMessage != nil {
                        return 185//130
                    }
                    else {
                        return 137//68
                    }
                    //return 68 + 19
                }
                else if obj.messagetype == "4" { return UITableViewAutomaticDimension }
                else if obj.messagetype == "5" {
                    if (obj.parent_id != "0") { return 185 }
                    else { return 137 }
                }
                else {
                    if parentMessage != nil { return 155 }
                    else { return 80 + 19 }
                    //return 80 + 19 //DOCUMENT
                }
            }
        }
        else { return UITableViewAutomaticDimension }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    /*func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
     return ""
     }*/
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
        label.text = "🔒 Messages to this group are secured with end-to-end encryption."
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectOrDeselectCell(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectOrDeselectCell(at: indexPath)
    }
    
    func selectOrDeselectCell(at indexPath:IndexPath){
        if tblchat.isEditing{
            if arrSelectedIndexes.contains(indexPath.row) {
                arrSelectedIndexes.remove(at: arrSelectedIndexes.index(of: indexPath.row)!)
            }
            else {
                arrSelectedIndexes.append(indexPath.row)
                //PV
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
            vwEditingTitle.text = "\(arrSelectedIndexes.count)"
            
            if arrSelectedIndexes.count == 1 { btnReplyWidth.constant = 35 }
            else{ btnReplyWidth.constant = 0 }
            
            var isAnyMediaMessage = false
            for index in arrSelectedIndexes {
                let model = arrMsgs[index]
                if Int(model.messagetype)! > 0 {
                    isAnyMediaMessage = true
                    break
                }
            }
            
            if isAnyMediaMessage { btnCopyWidth.constant = 0 }
            else { btnCopyWidth.constant = 35 }
            
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
        if (editingStyle == .delete) {
            //--> Code
        }
    }
    
    @objc func cellLongPressed(sender:UILongPressGestureRecognizer) {
        let index = Int(sender.accessibilityLabel!)!
        let model = arrMsgs[index]
        
        print(model.textmessage.base64Decoded!)
        
        if model.senderid == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId) {
            let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let actionInfo = UIAlertAction.init(title: "Info", style: .default, handler: { (action) in
                let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: "ReadInfoVC") as! ReadInfoVC
                vc.selectedgid = model.id
                vc.objEnumReadInfo = .ReadInfo_GroupChat
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
    
    func tableViewScrollToBottomAnimated(animated:Bool) {
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
                self.tblchat.scrollToRow(at: pathToLastRow, at: .bottom, animated: animated)
                self.scrollbottombtn.alpha = 0
            }
        }
    }
    
    @objc func updateAudioCellProgressView(timer:Timer){
        if audioPlayer?.isPlaying != nil && (audioPlayer?.isPlaying)! {
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
    
    //MARK: Tableview Cell - Contact
    @objc func manage_ContactCell_Sender(tableView: UITableView,  indexPath : IndexPath) ->  GroupChatContactSenderCell {
        let obj = arrMsgs[indexPath.row]
        let dataValue = obj.createddate == "" ? "" : timeAgoSinceStrDate(strDate: obj.createddate, numericDates: false)
        
        var bubble = getBubbleImage(objChat: obj)
        var bubbleImg:UIImage? = UIImage()
        //bubble = "right\(bubble)"
        bubble = "left\(bubble)"
        bubbleImg = UIImage(named:bubble)
        
        var senderName = obj.sendername
        let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: obj.countrycode, phoneNo: obj.phonenumber)
        if objContactInfo.Name?.count == 0 {
            senderName = "+\(obj.countrycode) \(obj.phonenumber)"
            if TRIM(string: senderName) == "+" { senderName = obj.sendername }
        }
        else { senderName = objContactInfo.Name ?? obj.sendername }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatContactSenderCell") as! GroupChatContactSenderCell
        cell.groupChatSenderContactCellDelegate = self
        
        //cell.imgContact.image = #imageLiteral(resourceName: "profile_pic_register")
        cell.imgbubble.image = bubbleImg
        
        cell.lblSender.text = senderName
        cell.btnSender_ContactMess.tag = indexPath.row
        cell.btnSender_ContactMess.addTarget(self, action: #selector(btnSender_ContactMessAction(_:)), for: .touchUpInside)
        
        cell.lblContact.text = get_ContactName(strMess: obj.textmessage)
        
        cell.btnContact.tag = indexPath.row
        cell.btnContact.accessibilityLabel = "\(indexPath.section)"
        cell.btnContact.setTitle("View", for: .normal)
        var strButtonTitle : String = get_ContactButtonTitle(strMess: obj.textmessage)
        if strButtonTitle.uppercased() == "Message".uppercased() { strButtonTitle = "Save Contact" }
        cell.btnContact.setTitle(strButtonTitle, for: .normal)
        
        cell.Lbltime.text = dataValue
        
        //---------------------->
        if (obj.parent_id == "0") {
            cell.heightReplyView.constant = 0
            
            cell.lblMessageReply.text = ""
            cell.lblNameReply.text = ""
        } else {
            let parentMessage = arrMsgs.first(where: {$0.id == obj.parent_id} )
            var nameReply:String? = ""
            var messageReply:String? = ""
            
            if parentMessage != nil{
                //NameReply
                if parentMessage?.senderid != UserDefaultManager.getStringFromUserDefaults(key: kAppUserId) { nameReply = parentMessage?.sendername }
                else { nameReply = "You" }
                
                //Message Reply
                if parentMessage?.messagetype == "2" { messageReply = "Location" }
                else if parentMessage?.messagetype == "5" { messageReply = get_ContactName(strMess: (parentMessage?.textmessage)!) }
                else { messageReply = parentMessage!.textmessage.base64Decoded }
                
                if messageReply!.count == 0 {
                    if parentMessage!.mediaurl.count > 0 { messageReply = getFileType(for: parentMessage!.mediaurl) }
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
        let dateValue = obj.createddate == "" ? "" : timeAgoSinceStrDate(strDate: obj.createddate, numericDates: false)
        
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
        
        cell.lblContact.text = get_ContactName(strMess: obj.textmessage)
        
        cell.btnContact.tag = indexPath.row
        cell.btnContact.accessibilityLabel = "\(indexPath.section)"
        cell.btnContact.setTitle("View", for: .normal)
        var strButtonTitle : String = get_ContactButtonTitle(strMess: obj.textmessage)
        if strButtonTitle.uppercased() == "Message".uppercased() { strButtonTitle = "View Contact" }
        cell.btnContact.setTitle(strButtonTitle, for: .normal)
        
        cell.Lbltime.text = dateValue
        
        cell.imgreceipt.image = self.getReadStatus(strStatus: obj.isread)
        if obj.isread == "-1" {
            if obj.id == currentlySendingMessageID { cell.downloadIndicator.startAnimating() }
            else {  cell.downloadIndicator.stopAnimating() }
        }
        
        ///---------------------->
        if (obj.parent_id == "0") {
            cell.heightReplyView.constant = 0
            cell.lblMessageReply.text = ""
            cell.lblNameReply.text = ""
        }
        else {
            let parentMessage = arrMsgs.first(where: {$0.id == obj.parent_id} )
            var nameReply:String? = ""
            var messageReply:String? = ""
            
            if parentMessage != nil{
                //NameReply
                if parentMessage?.senderid != UserDefaultManager.getStringFromUserDefaults(key: kAppUserId) {
                    nameReply = parentMessage?.sendername
                }
                else { nameReply = "You" }
                
                //Message Reply
                if parentMessage?.messagetype == "2" { messageReply = "Location" }
                else if parentMessage?.messagetype == "5" { messageReply = get_ContactName(strMess: (parentMessage?.textmessage)!) }
                else { messageReply = parentMessage!.textmessage.base64Decoded }
                
                if messageReply!.count == 0 {
                    if parentMessage!.mediaurl.count > 0 { messageReply = getFileType(for: parentMessage!.mediaurl) }
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
        //You have received Contact
        let obj = arrMsgs[sender.tag]
        if isPathForContact(path: obj.mediaurl) {
            let section = Int(sender.accessibilityLabel!)!
            self.openAttachment(atRow: sender.tag, inSection: section)
            return
        }
        
        var strButtonTitle : String = get_ContactButtonTitle(strMess: obj.textmessage)
        if strButtonTitle.uppercased() == "Message".uppercased() { strButtonTitle = "Save Contact" }
        if strButtonTitle.uppercased() == "Message".uppercased() {
            /*let arrPhoneNo = get_Contact_PhoneNoList(strMess: obj.textmessage)
             if arrPhoneNo.count > 0 {
             var strPhoneNo : String = arrPhoneNo[0]
             //if strPhoneNo.contains("+") { strPhoneNo = strPhoneNo.replacingCharacters(in: "+", with: "") }
             //self.apiCheckUser_andStartChat(strContactNo: <#T##String#>, strPhoneNo: <#T##String#>)
             return
             }
             //show
             return*/
        }
        else if strButtonTitle.uppercased() == "Save Contact".uppercased() {
            let contact = get_ContactObj(strMess: obj.textmessage)
            let controller = CNContactViewController(forNewContact: contact[0])
            controller.delegate = self
            controller.allowsActions = false
            
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.navigationBar.backgroundColor = UIColor.white
            self.navigationController?.navigationBar.topItem?.title = "Back"
            APP_DELEGATE.appNavigation?.pushViewController(controller, animated: true)
            return
        }
        
        let contact = get_ContactObj(strMess: obj.textmessage)
        
        let objVC : ContactsSendVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ContactsSendVC" ) as! ContactsSendVC
        objVC.delegate = self
        objVC.arrContact = contact
        objVC.objEnumContact = .contact_View
        APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
    }
    
    func btnReceiverContactClicked(_ sender: UIButton) {
        //You send Contact
        let obj = arrMsgs[sender.tag]
        if isPathForContact(path: obj.mediaurl) {
            let section = Int(sender.accessibilityLabel!)!
            self.openAttachment(atRow: sender.tag, inSection: section)
            return
        }
        
        let contact = get_ContactObj(strMess: obj.textmessage)
        
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
        APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
    }
    
    @IBAction func btnSender_ContactMessAction(_ sender: UIButton) {
        let obj : StructGroupChat = arrMsgs[sender.tag]
        self.manage_AddContact_Message(obj: obj)
    }
    
    //MARK: Tableview button method
    @objc func tapChatHeader(){
        let alert = UIAlertController.init(title: nil, message: "Messages to this chat are now secured with end-to-end encryption.", preferredStyle: .alert)
        
        let actionLearnMore = UIAlertAction.init(title: "Learn More", style: .default) { (action) in
            
        }
        alert.addAction(actionLearnMore)
        
        let actionOk = UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(actionOk)
        
        present(alert, animated: true, completion: nil)
    }
    
    func manage_AddContact_Message(obj : StructGroupChat) -> Void {
        let strCountryCode : String =  TRIM(string: obj.countrycode)
        let strPhoneNo : String = TRIM(string: obj.phonenumber)
        if (strCountryCode.count == 0 && strPhoneNo.count == 0) {
            //print("NOT FOUNT CONTACTS - ContryCode & Phoneno")
            return
        }
        
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: strCountryCode, phoneNo: strPhoneNo)
        let senderName = "+\(strCountryCode) \(strPhoneNo)"
        if objContactInfo.Name?.count == 0 {
            //print("NOT IN CONTACTS")
            
            if TRIM(string: senderName) == "+" {
                //return
            }
            else {
                let actionMore = UIAlertAction.init(title: "Add to Contacts", style: .default){ (action) in
                    
                    self.addToContacts(strCountryCode: strCountryCode, strPhoneNo: strPhoneNo)
                }
                alert.addAction(actionMore)
            }
        }
        
        let actionSave = UIAlertAction.init(title: "Message \(senderName)", style: .default) { (action) in
            //---> Send Mess.
            let selectedUserInfo:StructChat = StructChat.init(dictionary: ["id":"1",
                                                                           "username":obj.sendername as Any,
                                                                           "user_id":obj.id as Any,
                                                                           "country_code":obj.countrycode as Any,
                                                                           "phoneno":obj.phonenumber as Any,
                                                                           "image":obj.mediaurl as Any])
            let convo = loadVC(strStoryboardId: SB_CHAT, strVCId:idChatVC ) as! ChatVC
            convo.calledfrom = "messages"
            convo.selecteduserid = obj.id
            convo.strTitle = self.lblusername.text ?? obj.sendername
            convo.username = obj.sendername
            convo.selectedUser = selectedUserInfo
            APP_DELEGATE.appNavigation?.pushViewController(convo, animated: true)
        }
        alert.addAction(actionSave)
        
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionCancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnSender_LinkMessAction(_ sender: UIButton) {
        let obj : StructGroupChat = arrMsgs[sender.tag]
        self.manage_AddContact_Message(obj: obj)
    }
    
    @IBAction func btnSender_withAttachAction(_ sender: UIButton) {
        let obj : StructGroupChat = arrMsgs[sender.tag]
        self.manage_AddContact_Message(obj: obj)
    }
    
    @IBAction func btnSender_DocumentMessAction(_ sender: UIButton) {
        let obj : StructGroupChat = arrMsgs[sender.tag]
        self.manage_AddContact_Message(obj: obj)
    }
    
    @IBAction func btnSender_TextMessAction(_ sender: UIButton) {
        let obj : StructGroupChat = arrMsgs[sender.tag]
        self.manage_AddContact_Message(obj: obj)
    }
    
}

//MARK: -
extension GroupChatVC : CNContactViewControllerDelegate
{
    //MARK: Add Contact Delegate Method
    func addToContacts(strCountryCode : String, strPhoneNo: String) -> Void {
        let contact = ContactSync.shared.get_ContactObject(strCountryCode: strCountryCode , strPhoneNo: strPhoneNo ?? "")
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
            self.tblchat.reloadData()
        }
        APP_DELEGATE.appNavigation?.popViewController(animated: false)
    }
    
    func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        return true
    }
}

extension GroupChatVC:InputbarDelegate {
    func getBubbleImage(objChat:StructGroupChat) -> String {
        var thisMessageIndex = 0
        if let foo = arrMsgs.enumerated().first(where: {$0.element.id == objChat.id}) {
            thisMessageIndex = foo.offset
        }
        
        if thisMessageIndex == 0 { return "1" }
        if thisMessageIndex == (arrMsgs.count - 1) { return "3" }
        
        let previousMessage = arrMsgs[thisMessageIndex-1]
        let nextMessage = arrMsgs[thisMessageIndex+1]
        
        let previousSender = previousMessage.senderid
        let nextSender = nextMessage.senderid
        let meAsSender = UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)
        
        let previousReceiver = previousMessage.receiverid
        let nextReceiver = nextMessage.receiverid
        let meAsReceiver = objChat.receiverid
        
        if objChat.senderid == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId){
            if previousSender != meAsSender{
                return "1"
            }
            if nextSender != meAsSender{
                return "3"
            }
            if previousSender == meAsSender && nextSender == meAsSender{
                return "2"
            }
        }else{
            return "1"
        }
        
        return "2" //SHOULD NEVER FALLBACK HERE
        
    }
    
    func inputbarDidPressRightButton(inputbar:Inputbar)
    {
        let textMessage = inputbar.text.trimmingCharacters(in: .whitespacesAndNewlines)
        var dic = [
            "groupid":selectedGroupId,
            "senderid":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            "group_members": selectedGroupDetails.members,
            "textmessage": textMessage.base64Encoded ?? "",
            "messagetype": "0",
            "mediaurl": "",
            "platform":PlatformName,
            "createddate": "",
            "isdeleted":"0",
            "isread":"0",
            "username" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
            "filtered_members" : getFilteredMembersForSendMessage(),
            "countrycode" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode).replacingOccurrences(of: "+", with: ""),
            "phonenumber" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)
            ]  as [String : Any]
        
        if let linkDetails = linkPreviewDetails{
            let mediaURL = "\(linkDetails[.canonicalUrl] ?? "-")\(kLinkMessageSeparator)\(linkDetails[.image] ?? "-")\(kLinkMessageSeparator)\(linkDetails[.title] ?? "-")\(kLinkMessageSeparator)\(linkDetails[.description] ?? "-")"
            dic["messagetype"] = "4"
            dic["mediaurl"] = mediaURL
            
            linkPreviewDetails = nil
            linkPreview?.cancel()
        }
        
        newSendMessageWithDic(dic: dic)
        
    }
    func inputbarDidPressLeft2Button(inputbar: Inputbar) {
        //emoji button
    }
    func inputbarDidPressLeftButton(inputbar:Inputbar)
    {
        self.inputvalues.inputResignFirstResponder()
        if self.clickedattach == false
        {
            openAttachmentView()
        }
        else
        {
            closeAttachmentView(completion: {})
        }
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
        let dic = [
            "senderid" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            "receiverid" : selectedGroupId,
            "istyping" : "1",
            "countrycode" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode),
            "phoneno" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile),
            "isgroup" : "1"
        ]
        
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck("TypingSent",dic).timingOut(after: 1000)
        {data in
            let data = data as Array
            if(data.count > 0)
            {
                if data[0] is String { return }
                
                NSObject.cancelPreviousPerformRequests(
                    withTarget: self,
                    selector: #selector(GroupChatVC.stopTyping),
                    object: nil)
                
                self.perform(
                    #selector(GroupChatVC.stopTyping),
                    with: nil,
                    afterDelay: 0.5)
            }
        }
        
        if inputbar.text.count > 0{
            if linkPreview != nil{
                linkPreview?.cancel()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.linkPreview = self.slp.preview(
                    inputbar.text,
                    onSuccess: { result in
                        //print("\(result)")
                        self.linkPreviewDetails = result
                },
                    onError: {error in
                        //print("\(error)")
                        self.hideLinkPreviewView()
                        self.linkPreviewDetails = nil
                }
                )
            })
            
        }
        
    }
    
    @objc func stopTyping(){
        let dic = [
            "senderid" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            "receiverid" : selectedGroupId,
            "istyping" : "0",
            "countrycode" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode),
            "phoneno" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile),
            "isgroup" : "1"
        ]
        
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck("TypingSent",dic).timingOut(after: 1000)
        { data in }
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
        self.vwattach.accessibilityValue = "\(self.inputvalues.frame.origin.y)"
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
    
    func newSendMessageWithDic(dic:[String:Any]){
        var dic = dic
        dic["parent_id"] = selectedMessageForReply?.id ?? "0"
        dic["groupname"] = selectedGroupDetails.name
        dic["groupicon"] = selectedGroupDetails.icon
        fire_eventSend_Messgae(objmsg: dic as NSDictionary)
        tableViewScrollToBottomAnimated(animated: true)
        
    }
    
    func fire_eventSend_Messgae(objmsg:NSDictionary)
    {
        if selectedMessageForReply != nil {
            hideReplyView(nil)
        }
        
        let offlineMessageId = getNewPendingMessageID()
        
        var dictionary = [String:Any]()
        dictionary["id"] = String(offlineMessageId)
        dictionary["groupid"] = objmsg["groupid"]
        dictionary["senderid"] = UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)
        dictionary["sendername"] = UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName)
        dictionary["receiverid"] = objmsg["group_members"]
        dictionary["textmessage"] = objmsg["textmessage"]
        dictionary["isread"] = "-1"
        dictionary["platform"] = PlatformName
        dictionary["isdeleted"] = "0"
        dictionary["createddate"] = DateFormater.getStringFromDate(givenDate: NSDate())
        dictionary["messagetype"] = objmsg["messagetype"]
        dictionary["mediaurl"] = objmsg["mediaurl"]
        dictionary["isstarred"] = "0"
        dictionary["parent_id"] = objmsg["parent_id"]
        dictionary["countrycode"] = UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode).replacingOccurrences(of: "+", with: "")
        dictionary["phonenumber"] = UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)
        
        
        let groupMessage = StructGroupChat.init(dictionary: dictionary)
        print(groupMessage)
        _ = CoreDBManager.sharedDatabase.saveGroupMessageInLocalDB(objmessgae: groupMessage)
        reloadTable()
        sendPendingMessages()
        
    }
    
    @objc func sendPendingMessages(){
        
        if isConnectedToNetwork() && APP_DELEGATE.socketIOHandler!.isSocektConnected(){
            
            let pendingMessages = self.arrMsgs.filter({$0.isread == "-1"})
            
            if pendingMessages.count == 0 || currentlySendingMessageID.count > 0{
                return
            }
            
            let message = pendingMessages.first!
            
            let objmsg = [
                "iospkid":message.id,
                "groupid":message.groupid,
                "senderid":message.senderid,
                "group_members": message.receiverid,
                "textmessage": message.textmessage,
                "messagetype": message.messagetype,
                "mediaurl": message.mediaurl,
                "platform":message.platform,
                "createddate": message.createddate,
                "isdeleted":"0",
                "isread":"0",
                "username" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
                "filtered_members" : getFilteredMembersForSendMessage(),
                "countrycode" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode).replacingOccurrences(of: "+", with: ""),
                "phonenumber" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile),
                "mediasize":fileSize(url: message.mediaurl.toUrl),
                "parent_id" : message.parent_id]
            
            currentlySendingMessageID = objmsg["iospkid"]!
            
            if objmsg["messagetype"] == "1"{
                uploadAttachmentAndSendMessageThroughSocket(objmsg:objmsg)
            }else{
                sendMessageThroughSocket(objmsg:objmsg)
            }
            
        }
    }
    
    func sendMessageThroughSocket(objmsg:[String:Any]){
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
                let dicMsg = data[0] as! [String:Any]
                let msg = StructGroupChat.init(dictionary: dicMsg)
                //_ = CoreDBManager.sharedDatabase.saveGroupMessageInLocalDB(objmessgae: msg)
                CoreDBManager.sharedDatabase.replaceGroupMessageInLocalDB(objmessgae: msg, with: dicMsg["iospkid"] as! String)
                
                self.reloadTable()
                self.tableViewScrollToBottomAnimated(animated: false)
                
                APP_DELEGATE.socketIOHandler?.reloadFriendAndGroupList()
                
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
        
        //HttpRequestManager.sharedInstance.delegate = self;
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
            offlineMessageId = Float(lastMessage.id)!
        }
        offlineMessageId = offlineMessageId + 0.1
        return offlineMessageId
    }
}

extension GroupChatVC : ImagePickerDelegate
{
    func pickImageComplete(_ imageData: UIImage, sender: String)
    {
        if sender == "Wallpaper"{
            let imageCropper = loadVC(strStoryboardId: SB_ASSET_PICKER, strVCId: idImageCropperVC) as! ImageCropperVC
            imageCropper.shouldSquare = false
            imageCropper.shouldBackgroundOfChat = true //PV
            imageCropper.image = imageData
            imageCropper.delegate = self
            
            //            imageCropper.setCropAspectRect(aspect: "2:3")
            //            imageCropper.lockAspectRatio(true)
            //            imageCropper.showDetailViewController(self, sender: nil)
            
            APP_DELEGATE.appNavigation?.pushViewController(imageCropper, animated: false)
        }
    }
    
}

//MARK:-
extension GroupChatVC : IGRPhotoTweakViewControllerDelegate{
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

extension GroupChatVC : GroupChatSenderAttachCellDelegate, ChatReceiverAttachCellDelegate, GroupChatSenderDocumentCellDelegate, ChatReceiverDocumentCellDelegate, GroupChatSenderContactCellDelegate, ChatReceiverContactCellDelegate, ChatSenderContactCellDelegate, GroupChatSenderAudioCellDelegate, ChatReceiverAudioCellDelegate, ChatLinkPreviewReceiverCellDelegate, GroupChatLinkPreviewSenderCellDelegate, AVAudioPlayerDelegate
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
        tblchat.reloadRows(at: [currentPlayingAudioCellIndex!], with: .none)
        currentPlayingAudioCellIndex = nil
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
        let arrMedia = obj.mediaurl.components(separatedBy: kLinkMessageSeparator)
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

//MARK:-
import QuickLook
extension GroupChatVC : QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    //MARK: Open Document
    func openDoc(strURL:String) -> Void {
        //return documentInteraction.accessibilityValue?.url as! QLPreviewItem
        
        let quickLookController = QLPreviewController()
        quickLookController.dataSource = self
        
        self.fileURLs.removeAll()
        self.fileURLs.append(strURL.url! as NSURL)
        
        if QLPreviewController.canPreview(fileURLs[0]) {
            quickLookController.currentPreviewItemIndex = 0
            
            //navigationController?.pushViewController(quickLookController, animated: true)
            self.present(quickLookController, animated: true, completion: nil)
        }
    }
    func previewController(controller: QLPreviewController, shouldOpenURL url: NSURL, forPreviewItem item: QLPreviewItem) -> Bool {
        if item as! NSURL == fileURLs[0] {
            return true
        }
        else {
            //print("Will not open URL \(url.absoluteString)")
        }
        
        return false
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return self.fileURLs.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        //return self.fileURLs[index]
        
        controller.title = "Hello 123"
        let item : QLPreviewItem = self.fileURLs[index]
        //item.previewItemTitle = "Hello 123"
        return item
    }
    
    func previewControllerWillDismiss(controller: QLPreviewController) {
        //print("The Preview Controller will be dismissed.")
    }
    
    func previewControllerDidDismiss(controller: QLPreviewController) {
        //print("The Preview Controller has been dismissed.")
    }
}

extension GroupChatVC  {
    
    func openAttachment(atRow row:Int, inSection section:Int){
        
        let obj = arrMsgs[row]
        /*let assortedMsgs = arrAssortedMsgs[section]
         let obj = assortedMsgs.Msgs[row] as! StructGroupChat*/
        
        if Int(obj.messagetype)! > 0
        {
            //let cell = tblchat.cellForRow(at: IndexPath.init(row: row, section: section))!
            
            if isPathForImage(path: obj.mediaurl){
                
                let doesExist = isFileLocallyExist(fileName: obj.mediaurl.lastPathComponent, inDirectory: self.get_URL_inGroupChatDir())
                if doesExist{
                    /*let configuration = ImageViewerConfiguration { config in
                     config.imageView = cell.viewWithTag(15) as? UIImageView
                     }
                     let imageViewerController = ImageViewerController(configuration: configuration)
                     self.present(imageViewerController, animated: true)*/
                    
                    self.photoBrowser = ChatAttachmentBrowser.init(userID: self.selectedGroupId, startingFromMediaURL:obj.mediaurl, currentLocalDir:self.get_URL_inGroupChatDir())
                    self.photoBrowser.startFromGrid = false
                    self.photoBrowser.currentLocalDirectory = self.get_URL_inGroupChatDir()
                    self.photoBrowser.openBrowser()
                }else{
                    //self.downloadImage(url: obj.kmediaurl, reloadCellAt: row, and: section)
                    //self.downloadAndOpenAttachment(url: obj.mediaurl.toUrl!)
                    self.downloadAndOpenAttachment(url: obj.mediaurl.toUrl!, row, section, obj.senderid)
                    
                    tblchat.reloadRows(at: [IndexPath.init(row: row, section: section)], with: .none)
                }
                /*SDWebImageManager.shared().cachedImageExists(for: obj.kmediaurl.toUrl, completion: { (doesExist) in
                 })*/
            }
            else if Int(obj.messagetype)! == 2 {
                //print("//OPEN LOCATION")
                
                let arrLocation = obj.textmessage.base64Decoded!.components(separatedBy: ",")
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
                                    //print("Open GMaps in Browser : \(success ? "SUCCESS" : "FAILURE")")
                                })
                            }
                        }
                    }
                }
                
            }
            else {
                if isPathForAudio(path: obj.mediaurl){
                    
                    if isFileLocallyExist(fileName: obj.mediaurl.lastPathComponent, inDirectory: self.get_URL_inGroupChatDir()) == false {
                        //print("Audio download now.")
                        self.downloadContent_audio(contentURL: obj.mediaurl.url!)
                        //return
                    }
                    
                    let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: "ChatAudioPlayerVC") as! ChatAudioPlayerVC
                    vc.modalPresentationStyle = .overCurrentContext
                    vc.audioURL = obj.mediaurl
                    vc.URL_CurrentDir = self.get_URL_inGroupChatDir()
                    present(vc, animated: true, completion: nil)
                }
                else{
                    //DOCUMENT
                    //downloadAndOpenAttachment(url: URL.init(string: obj.mediaurl)!)
                    
                    //downloadAndOpenAttachment(url: URL.init(string: obj.mediaurl)!,row,section,obj.senderid)
                    //tblchat.reloadRows(at: [IndexPath.init(row: row, section: section)], with: .none)
                    
                    if(obj.mediaurl.contains("http://")) {
                        downloadAndOpenAttachment(url: URL.init(string: obj.mediaurl)!,row,section,obj.senderid)
                        tblchat.reloadRows(at: [IndexPath.init(row: row, section: section)], with: .none)
                    }
                    else {
                        showMessage(SomethingWrongMessage)
                    }
                }
            }            
        }
    }
    
    //func downloadAndOpenAttachment(url:URL){
    //func downloadAndOpenAttachment(url:URL,_ rows:Int = -1,_ sections:Int = -1,_ userid:String = "0") {
    func downloadAndOpenAttachment(url:URL,_ rows:Int,_ sections:Int,_ userid:String) {
        if isFileLocallyExist(fileName: url.lastPathComponent, inDirectory: self.get_URL_inGroupChatDir()) == true {
            
            let localURL = getURL_LocallyFileExist(fileName: url.lastPathComponent, inDirectory: get_URL_inGroupChatDir())
            
            if isPathForVideo(path: localURL.path){
                
                /*let player = AVPlayer(url: localURL)
                 let playerViewController = AVPlayerViewController()
                 playerViewController.player = player
                 self.present(playerViewController, animated: true) {
                 playerViewController.player!.play()
                 }*/
                
                self.photoBrowser = ChatAttachmentBrowser.init(groupID: self.selectedGroupId, startingFromMediaURL:url.absoluteString, currentLocalDir: self.get_URL_inGroupChatDir())
                self.photoBrowser.startFromGrid = false
                self.photoBrowser.currentLocalDirectory = self.get_URL_inGroupChatDir() 
                self.photoBrowser.openBrowser()
                
            }else{
                let objData : StructGroupChat = self.arrMsgs[rows]
                
                documentInteraction = UIDocumentInteractionController.init(url: localURL)
                documentInteraction.delegate = self
                documentInteraction.name = objData.textmessage.base64Encoded?.count != 0 ? objData.textmessage.base64Decoded : objData.mediaurl.lastPathComponent
                
                let success = documentInteraction.presentPreview(animated: true)
                if success == false{
                    //print("//OPEN AS MENU")
                    documentInteraction.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
                }
                
                
                /*//------------------>
                 documentInteraction.accessibilityValue = localURL.absoluteString
                 self.openDoc(strURL: localURL.absoluteString)*/
            }
            
        }else{
            
            /*if arrDownloadURLs.contains(url) == false{
             arrDownloadURLs.append(url)
             }
             
             performDownload()*/
            if ChatAttachmentDownloader.sharedInstance.isDownloading(remoteURL: url){
                ChatAttachmentDownloader.sharedInstance.removeURLFromDownloading(remoteURL: url)
            }else{
                //ChatAttachmentDownloader.sharedInstance.startDownloading(remoteURL: url, saveToURL: self.get_URL_inGroupChatDir())
                
                //payal changed
                let destination = DownloadRequest.suggestedDownloadDestination()
                Alamofire.download(url, to: destination).downloadProgress(queue: DispatchQueue.global(qos: .utility))
                { (progress) in
                    //print("Progress  download -----> : \(progress.fractionCompleted)")
                    DispatchQueue.main.async {
                        if userid != UserDefaultManager.getStringFromUserDefaults(key: kAppUserId)
                        {
                            if let trackCell = self.tblchat.cellForRow(at: IndexPath(row: rows,
                                                                                     section: 0)) as? GroupChatSenderAttachCell {
                                //String(format: "%.1f%% of %@", progress * 100, totalSize)
                                trackCell.updateDisplay(progress: Float(progress.fractionCompleted), totalSize: "0 KB")
                            }
                        }
                        else
                        {
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
                        else
                        {
                            //print("Saved path: \(response.destinationURL!)")
                            let downloadContentLocalURL = save_Content(contentURL: response.destinationURL!, withName: response.destinationURL!.lastPathComponent, inDirectory: self.get_URL_inGroupChatDir())
                            //print("downloadContentLocalURL: \(downloadContentLocalURL?.absoluteString ?? "---")")
                            
                            if isPathForImage(path: (url.absoluteString))
                            {
                                do{
                                    let data = try Data.init(contentsOf: response.destinationURL!)
                                    let img = UIImage.init(data: data)
                                    SDWebImageManager.shared().saveImage(toCache: img, for: url)
                                }catch{
                                    print(error.localizedDescription)
                                }
                            }
                            removeFile_onURL(fileURL: response.destinationURL!)
                            self.tblchat.reloadRows(at: [IndexPath.init(row: rows, section: 0)], with: .none)
                        }
                }
            }
            
        }
    }
    
    func performDownload(){
        guard isDownloading == false else{
            return
        }
        if arrDownloadURLs.count > 0{
            isDownloading = true
            
            Downloader.download(url: arrDownloadURLs[0], completion: { (success, url) in
                if success{
                    
                    //OTHERWISE THE DOCUMENT / VIDEO VIEWER WILL OPEN ANYTIME WHEN THE DOWNLOAD FINISHES
                    //WE SHOULD INDICAT IF THE FILE IS READY TO BE DISPLAYED OR NOT
                    //SO IF DOWNLOADED THEN WILL OPEN DIRECTLY
                    //OTHERWISE DOWNLOAD ONLY (OPEN NEXT TIME WHEN USER TAPS FILE)
                    //self.downloadAndOpenAttachment(url: url)
                    
                    //Download Content : Image, Video, Contact, Document
                    //--------------------------->
                    //print("downloadContentURL: \(url)")
                    let downloadContentLocalURL : URL = save_Content(contentURL: url, withName: url.lastPathComponent, inDirectory: self.get_URL_inGroupChatDir())!
                    //print("downloadContentLocalURL: \(downloadContentLocalURL)")
                    
                    //Remove Download file in Document Dir.
                    removeFile_onURL(fileURL: url)
                    //--------------------------->
                }else{
                    showStatusBarMessage("Download failed. Try again.")
                }
                self.arrDownloadURLs.remove(at: 0)
                self.isDownloading = false
                self.performDownload()
            })
        }
    }
    
    func downloadImage(url:String, reloadCellAt row:Int, and section:Int){
        if isConnectedToNetwork(){
            showHUD()
            SDWebImageDownloader.shared().downloadImage(with: url.toUrl, options: .highPriority, progress: nil, completed: { (image, data, error, finished) in
                SDWebImageManager.shared().saveImage(toCache: image, for: url.toUrl)
                /*self.reloadTable()
                 if scrollToBottom{
                 self.tableViewScrollToBottomAnimated(animated: false)
                 }*/
                let indexpath = IndexPath.init(row: row, section: section)
                self.tblchat.reloadRows(at: [indexpath], with: .none)
                hideHUD()
                
                //Save Download Image
                let imgURL : URL = save_Content(image: image!, imageName: "\(url.lastPathComponent)", inDirectory: self.get_URL_inGroupChatDir())!
                //print("imgURL: \(imgURL)")
                
            })
        }
    }
    
}

extension GroupChatVC {
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
            if objTmp.id == obj.parent_id {
                let index = IndexPath(row: i, section: 0)
                self.tblchat.scrollToRow(at: index as IndexPath, at: .middle, animated: true)
                break
            }
        }
    }
}

extension GroupChatVC {
    @objc func api_groupInfo() {
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck("Get_GroupInfo",["groupid":selectedGroupId]).timingOut(after: 1000)
        {data in
            let data = data as Array
            if(data.count > 0) {
                if data[0] is String { return }
                let jsonData = JSON(data.first! as! NSDictionary)
                
                let selectedGroupInfo = GroupInfo.init(json: jsonData)
                CoreDBManager.sharedDatabase.updateGroupInfo(groupInfo: selectedGroupInfo)
                self.setData()
            }
        }
    }
    
}

