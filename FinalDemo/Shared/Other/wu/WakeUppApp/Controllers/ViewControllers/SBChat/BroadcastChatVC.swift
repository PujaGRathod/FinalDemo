//
//  BroadcastChatVC.swift
//  WakeUppApp
//
//  Created by Admin on 29/05/18.
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
import SDWebImage

import IGRPhotoTweaks
import SwiftLinkPreview

import Zip
import CoreLocation

protocol BroadcastChatVC_Delegate : AnyObject {
    func manage_HiddentChat_onBroadcastChatVC(HideChatStatus: Bool?) -> Void
}

class BroadcastChatVC: UIViewController, AVAudioRecorderDelegate, ContactsSendVC_Delegate {
    
    weak var delegate: BroadcastChatVC_Delegate?
    
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
    
    @IBOutlet weak var imgLinkPreview: UIImageView!
    @IBOutlet weak var widthOfImgLinkPreview: NSLayoutConstraint!
    @IBOutlet weak var lblLinkTitle: UILabel!
    @IBOutlet weak var lblLinkDescription: UILabel!
    @IBOutlet weak var lblLinkURL: UILabel!
    @IBOutlet weak var heightOfLinkPreviewView: NSLayoutConstraint!
    
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

    var arrMsgs = [StructBroadcastMessage]()
    var arrAssortedMsgs = [AssortedMsgs]()
    
    var calledfrom = String()
    
    var broadcastListName = String()
    var imgTitleProfilePhoto : UIImage = #imageLiteral(resourceName: "boradcast_profile")
    
    var selectedBroadcastListID:String!
    
    var selectedBroadcastListDetails:StructBroadcastList!
    
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
    
    //Use for Add attach content in particuler user chat dir.
    var arrMember_IDs : [String] = []
    var arrMember_CountryCode : [String] = []
    var arrMember_PhoneNo : [String] = []
    
    var currentlySendingMessageID = ""

    let scrollbottombtn:UIButton = UIButton(frame: CGRect(x: -5,y: Int(SCREENHEIGHT()) - 150, width:  50, height:  45))
    
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setData()
        
        hideSoundRecordingBar()
        
        layoutUI()
        
        checkForMicrophonePermission()

        perform(#selector(checkNavigationStackForMemberSelectVC), with: nil, afterDelay: 1.0)
        perform(#selector(setChatWallpaperImage), with: nil, afterDelay: 0.0)

        NotificationCenter.default.addObserver(self, selector: #selector(sendPendingMessages), name: NSNotification.Name(NC_SocketConnected), object: nil)
        
        hideLinkPreviewView()
        
        //Set real Path of Dic.
        let URL_dirCurrentBroadcastChat : URL = get_URL_inBroadcastChatDir()
        //print("URL_dirCurrentBroadcastChat : \(URL_dirCurrentBroadcastChat)")
        
        self.set_UserID_and_PhoneNo()
        
        sendPendingMessages()
    }
    override func viewDidAppear(_ animated:Bool)
    {
        super.viewDidAppear(animated)
        setData()
        self.managekeyboard()
        
        self.setChatWallpaperImage()
    }
    override func viewDidDisappear(_ animated:Bool)
    {
        IQKeyboardManager.shared.enable = true
        super.viewDidDisappear(animated)
        self.view.removeKeyboardControl()
    }
    
    //MARK:- Manage Broadcast list included user info stoed in particuler array stoed info. 
    func set_UserID_and_PhoneNo() -> Void {
        let arrMember : [String] = selectedBroadcastListDetails.members.components(separatedBy: ",")
        for objUser : String in arrMember {
            let arrUserInfo = objUser.components(separatedBy: "_")
            
            //ID
            let strUserID : String = arrUserInfo.first ?? "0"
            arrMember_IDs.append(strUserID)
            
            //CountryCode
            let strUserCountryCode : String = arrUserInfo[1]
            arrMember_CountryCode.append(strUserCountryCode)
            
            //PhonrNo
            let strUserPhoneno : String = arrUserInfo.last ?? "0"
            arrMember_PhoneNo.append(strUserPhoneno)
        }
    }
    
    //MARK:- Manage BroadcastDir dataContent 
    func get_URL_inBroadcastChatDir() -> URL {
        let URL_dirCurrentBroadcastChat : URL = getURL_BroadcastChat_Directory(BroadcastID: self.selectedBroadcastListID)
        //print("URL_dirCurrentBroadcastChat : \(URL_dirCurrentBroadcastChat)")
        return URL_dirCurrentBroadcastChat
    }
    
    func downloadContent_audio(contentURL : URL) -> Void {
        Downloader.download(url: contentURL, completion: { (success, url) in
            if success {
                //print("downloadContentURL: \(url)")
                
                //Copy download file in ChatDir.
                let downloadContentLocalURL : URL = save_Content(contentURL: url, withName: url.lastPathComponent, inDirectory: self.get_URL_inBroadcastChatDir())!
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
    
    
    func saveContent_inParticuler_UserChat(contentURL : URL) -> Void {
        //print("send URL: \(contentURL)")
        
        let arrMemberIDs = selectedBroadcastListDetails.members.components(separatedBy: ",")
        for strUserID : String in arrMemberIDs {
            //print("strUserID: \(strUserID)")
            
            //Add contenrt in particuler chat dir.
            let indexOfUser = arrMemberIDs.index(of: strUserID)
            let strCountryCode = arrMember_CountryCode[indexOfUser!]
            let strPhoneNo = arrMember_PhoneNo[indexOfUser!]
            let dicSaveContentURL = getURL_ChatWithUser_Directory(countryCode: strCountryCode, PhoneNo: strPhoneNo)
            
            let savedURL = save_Content(contentURL: contentURL, withName: contentURL.lastPathComponent, inDirectory: dicSaveContentURL)
            //print("savedURL: \(savedURL)")
        }
    }
    
    //MARK: manage Export Chat
    @IBAction func perform_ExportChatAction() -> Void {
        
        let confirmAlert = UIAlertController.init(title: "Export Chat" , message: "Attaching media will generate a larger chat archive.", preferredStyle: .actionSheet)
        let attWithMedia = UIAlertAction.init(title: "Attach Media", style: .default) { (action) in
            //self.manage_ExportChat(withMedia: true)
            
            let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ImportExportProcessVC" ) as! ImportExportProcessVC
            let objBroadcastInfo = BroadcastChatInfo.init(BroadcastID: self.selectedBroadcastListID,
                                                          BroadcastImageURL: "",
                                                          DisplayNameOfTitle: self.selectedBroadcastListDetails.name,
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
            let objBroadcastInfo = BroadcastChatInfo.init(BroadcastID: self.selectedBroadcastListID,
                                                          BroadcastImageURL: "",
                                                          DisplayNameOfTitle: self.selectedBroadcastListDetails.name,
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
        
        present(confirmAlert, animated: true, completion: nil)
        //---------------------------------->
    }
    
    /*func manage_ExportChat(withMedia : Bool) {
        //Get ChatData
        var arrMessage = [StructBroadcastMessage]()
        //arrMessage = selectedBroadcastListDetails = CoreDBManager.sharedDatabase.getBroadcastListById(Id: selectedBroadcastListID)
        arrMessage = CoreDBManager.sharedDatabase.getMessagesForBroadcastListID(broadcastListID: selectedBroadcastListID)
        
        let arrGroupChatInfo : NSMutableArray = NSMutableArray.init()
        for obj : StructBroadcastMessage in arrMessage {
            //DateTime
            var strDateTime : String = obj.createddate
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            formatter.timeZone = TimeZone.current
            let date = formatter.date(from: strDateTime)            
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            strDateTime = formatter.string(from: date!)
            //Sender Name
            var strMessSender : String = obj.senderid
            if (strMessSender == UserDefaultManager.getStringFromUserDefaults(key:kAppUserId)) {
                strMessSender = UserDefaultManager.getStringFromUserDefaults(key:kAppUserFullName)
            }
            else { strMessSender = obj.sendername }
            
            let strMessType : String = obj.messagetype
            var strMessConent : String = "<Media omitted>"
            if (strMessType == "0") { strMessConent = obj.textmessage.base64Decoded! }
            
            var strFinalMess : String = ""
            strFinalMess += "\(strDateTime) - "
            strFinalMess += "\(strMessSender) - "
            strFinalMess += "\(strMessConent)"
            arrGroupChatInfo.add(strFinalMess)
        }
        //print("arrChatInfo total : \(arrGroupChatInfo.count)")
        
        if (arrGroupChatInfo.count == 0) {
            showMessage("No chat available for broadcast \(broadcastListName)")
        }
        else {
            //Save in File
            let chatBackupFolderURL : URL = self.get_URL_inBroadcastChatDir()
            //Check folder creded or not
            if (chatBackupFolderURL.lastPathComponent.count == 0) {
                showMessage("Error:\nSomething was wrong. Couldn't complete backup. Please try after some time")
                return
            }
            
            //Set Backup fileName and fileType
            var strFileName = "\(APPNAME)_\(Folder_Broadcast)_Backup.txt" //.TXT File
            strFileName = strFileName.replacingOccurrences(of: " ", with: "")
            
            //Set filePath for store location in device.
            let fileUrl = chatBackupFolderURL.appendingPathComponent(strFileName)
            
            showHUD() //Show loader
            //Save CHat data in File.
            do {
                //Export .txt File
                let txtExtFilePath = chatBackupFolderURL.appendingPathComponent(strFileName)
                let strExportData : String = arrGroupChatInfo.componentsJoined(by: "\n")
                try strExportData.write(to: txtExtFilePath, atomically: false, encoding: String.Encoding.utf8)
                //print("Success: \(txtExtFilePath)")
                
                hideHUD() // Hide Loader
                
                //Share the file.
                if (withMedia == true) {
                    //share(shareContent: [chatBackupFolderURL])
                    
                    showHUD() //Show loader
                    do {
                        strFileName = strFileName.replacingOccurrences(of: ".txt", with: "")
                        let zipFilePath = try Zip.quickZipFiles([chatBackupFolderURL], fileName: strFileName) // Zip
                        //print("zipFilePath: \(zipFilePath)")
                        
                        hideHUD() // Hide Loader
                        
                        //share(shareContent: [zipFilePath])
                        self.share_ExportChat(chatContent: [zipFilePath])
                        
                        //Remove file in Dir.
                        removeFile_onURL(fileURL: txtExtFilePath.absoluteURL)
                    }
                    catch {
                        hideHUD() // Hide Loader
                        
                        //print("Something went wrong")
                        showMessage("Error:\nSomething was wrong. Couldn't complete backup. Please try after some time")
                    }
                }
                else {
                    //share(shareContent: [fileUrl])
                    self.share_ExportChat(chatContent: [fileUrl])
                }
            } catch {
                hideHUD() // Hide Loader
                
                //print("Error: \(error)")
                //print("Error: \(error.localizedDescription)")
                showMessage("Error:\nSomething was wrong. Couldn't complete backup. Please try after some time")
            }
        }
    }
    
    //MARK: Share Export chat content
    func share_ExportChat(chatContent:[Any]) -> Void  {
        hideHUD() // Hide Loader
        
        // set up activity view controller
        let activityViewController = UIActivityViewController(activityItems: chatContent, applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            /*if completed == false { self.showAlertMessage("not-completed") }
             else { self.showAlertMessage("completed") }*/
            
            //Remove File
            removeFile_onURL(fileURL: chatContent.first as! URL)
        }
        activityViewController.excludedActivityTypes = [ .airDrop, .postToFacebook, .postToTwitter, .message, .mail, .postToFlickr, .copyToPasteboard]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }*/
    
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
        selectedBroadcastListDetails = CoreDBManager.sharedDatabase.getBroadcastListById(Id: selectedBroadcastListID)
        broadcastListName = selectedBroadcastListDetails.name
        
        self.lblusername.text = broadcastListName
        self.imgTitlePhoto.image = self.imgTitleProfilePhoto
        
        let memberIDs = selectedBroadcastListDetails.members.components(separatedBy: ",")
        self.lblisonline.text = "\(memberIDs.count) members in broadcast list."
    }
    
    @IBAction func btnBroadcastListInfoClicked(_ sender:UIButton){
        let broadcastListInfo = loadVC(strStoryboardId: SB_CHAT, strVCId: idBroadcastListInfoVC) as! BroadcastListInfoVC
        broadcastListInfo.selectedBroadcastListDetails = self.selectedBroadcastListDetails
        APP_DELEGATE.appNavigation?.pushViewController(broadcastListInfo, animated: true)
    }
    
    func checkForMicrophonePermission() {
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
    
    //MARK:- Other Function
    func layoutUI() {
        self.vwattach.accessibilityValue = "\(self.inputvalues.frame.origin.y)"
        self.vwattach.isHidden = true
        
        IQKeyboardManager.shared.enable = false
        
        //tblchat.register(UINib(nibName: "GroupChatInitialCell", bundle: nil), forCellReuseIdentifier: "GroupChatInitialCell")
        
        tblchat.register(UINib(nibName: "ChatReceiverAttachCell", bundle: nil), forCellReuseIdentifier: "ChatReceiverAttachCell")
        //tblchat.register(UINib(nibName: "GroupChatSenderAttachCell", bundle: nil), forCellReuseIdentifier: "GroupChatSenderAttachCell")
        
        tblchat.register(UINib(nibName: "ChatReceiverCell", bundle: nil), forCellReuseIdentifier: "ChatReceiverCell")
        //tblchat.register(UINib(nibName: "GroupChatSenderCell", bundle: nil), forCellReuseIdentifier: "GroupChatSenderCell")
        
        tblchat.register(UINib(nibName: "ChatContactReceiverCell", bundle: nil), forCellReuseIdentifier: "ChatContactReceiverCell")
        //tblchat.register(UINib(nibName: "GroupChatContactSenderCell", bundle: nil), forCellReuseIdentifier: "GroupChatContactSenderCell")
        
        tblchat.register(UINib(nibName: "ChatReceiverDocumentCell", bundle: nil), forCellReuseIdentifier: "ChatReceiverDocumentCell")
        //tblchat.register(UINib(nibName: "GroupChatSenderDocumentCell", bundle: nil), forCellReuseIdentifier: "GroupChatSenderDocumentCell")
        
        tblchat.register(UINib(nibName: "ChatReceiverAudioCell", bundle: nil), forCellReuseIdentifier: "ChatReceiverAudioCell")
        //tblchat.register(UINib(nibName: "GroupChatSenderAudioCell", bundle: nil), forCellReuseIdentifier: "GroupChatSenderAudioCell")
        
         tblchat.register(UINib(nibName: "ChatLinkPreviewReceiverCell", bundle: nil), forCellReuseIdentifier: "ChatLinkPreviewReceiverCell")
        
        let footervw = UIView.init(frame: .zero)
        self.tblchat.tableFooterView = footervw
        
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
        //fire_event_getmessaged()
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
            
            self.tblchat.frame = tableViewFrame
            if keyboardFrameInView.origin.y != SCREENHEIGHT() {
                self.tableViewScrollToBottomAnimated(animated: false)
            }
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
        self.tblchat.addGestureRecognizer(tap)
    }
    
    func setInputbar() {
        self.inputvalues.placeholder = "Type a message..."
        self.inputvalues.rightButtonImage =  #imageLiteral(resourceName: "voice_msg")
        self.inputvalues.inputDelegate = self
        self.inputvalues.leftButtonImage = UIImage(named:"add_media")
        //self.inputvalues.leftButtonImage1 = UIImage(named:"emoji_textbox")
    }
    
    @objc func tableTapped(tap:UITapGestureRecognizer) {
        self.inputvalues.inputResignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func reloadTable() {
        arrMsgs = CoreDBManager.sharedDatabase.getMessagesForBroadcastListID(broadcastListID: selectedBroadcastListID).sorted(by: { Float($0.id)! < Float($1.id)! })
        
        let sentMsgs = arrMsgs.filter({ $0.id.contains(".") == false })
        let pendingMsgs = arrMsgs.filter({$0.id.contains(".")})
        
        arrMsgs = sentMsgs + pendingMsgs
        
        if arrMsgs.count > 0{
            tblchat.reloadData()
            //setAllMessagesToRead()
        }
        
        //tableViewScrollToBottomAnimated(animated: false)
        /*var arrDates = [String]()
         for msg in arrMsgs{
         let date = msg.createddate.components(separatedBy: "T").first!
         if arrDates.contains(date) == false{
         arrDates.append(date)
         }
         }
         
         var arrAssorted = [AssortedMsgs]()
         for strDate in arrDates{
         var arrMsgsForThisDate = [StructGroupChat]()
         for msg in arrMsgs{
         if msg.createddate.contains(strDate){
         arrMsgsForThisDate.append(msg)
         }
         }
         let assortedMsg = AssortedMsgs.init(date: strDate, msgs: arrMsgsForThisDate)
         arrAssorted.append(assortedMsg)
         }
         
         arrAssortedMsgs = arrAssorted
         
         if arrAssortedMsgs.count > 0{
         tblchat.reloadData()
         setAllMessagesToRead()
         }*/
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
                let audioFilename = save_Content(withContentName: recordingFileName, inDirectory: self.get_URL_inBroadcastChatDir())
                
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
        removeFile(fileName: recordingFileName, inDirectory: self.get_URL_inBroadcastChatDir())
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
            
            let localURL = save_Content(contentURL: self.get_URL_inBroadcastChatDir().appendingPathComponent(recordingFileName), withName: "\(getNewPendingMessageID()).m4a", inDirectory: self.get_URL_inBroadcastChatDir())
            removeFile_onURL(fileURL: self.get_URL_inBroadcastChatDir().appendingPathComponent(recordingFileName))
            sendMediaMessage(forLocalURL: localURL!)
            //uploadChatAttachment(attachment: self.get_URL_inBroadcastChatDir().appendingPathComponent(recordingFileName))
            
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
    @IBAction func btnbackclicked(_ sender: Any)
    {
        if APP_DELEGATE.isHiddenChatUnlocked != false
        {
            self.delegate?.manage_HiddentChat_onBroadcastChatVC(HideChatStatus: true)
        }
        else
        {
            self.delegate?.manage_HiddentChat_onBroadcastChatVC(HideChatStatus: false)
        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NC_NewGroupMessage), object: nil)
        
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @objc func scrollbottombtnClicked() {
        self.tableViewScrollToBottomAnimated(animated: true)
    }
    
    //MARK: Titlebar button click
    @IBAction func btnMenuClicked(_ sender: Any) {
        
        let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
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
        
        let actionExportChat = UIAlertAction.init(title: "Export Chat", style: .default) { (action) in
            self.perform_ExportChatAction()
        }
        
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(actionWallpaper)
        actionSheet.addAction(actionExportChat)
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
            
            let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
            
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
            
            self.present(alert, animated: true, completion: nil)
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
            "senderid" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            //"broadcast_members" : self.selectedBroadcastListDetails.members,
            "broadcast_members" : self.arrMember_IDs.joined(separator: ","),
            "textmessage" : "\(location.coordinate.latitude),\(location.coordinate.longitude)".base64Encoded!,
            "messagetype" : "2",
            "mediaurl" : "",
            "platform" : PlatformName,
            "username" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
            "countrycode" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode).replacingOccurrences(of: "+", with: ""),
            "phonenumber" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)
        ]
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
}

extension BroadcastChatVC : UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate, CNContactPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
        let localURL = save_Content(contentURL: newUrls.first!, withName: fileName, inDirectory: self.get_URL_inBroadcastChatDir())
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
                let localURL = save_Content(contentURL: fileURL, withName: fileName, inDirectory: self.get_URL_inBroadcastChatDir())
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
        
        var dic = [
            "senderid" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            //"broadcast_members" : self.selectedBroadcastListDetails.members,
            "broadcast_members" : self.arrMember_IDs.joined(separator: ","),
            "textmessage" : strJSONString,
            "messagetype" : "5",
            "mediaurl" : "",
            "platform" : PlatformName,
            "username" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
            "countrycode" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode).replacingOccurrences(of: "+", with: ""),
            "phonenumber" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)
        ]
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
            let localURL = save_Content(image: imgView.image!, imageName: "\(self.getNewPendingMessageID()).png", inDirectory: self.get_URL_inBroadcastChatDir())
            self.sendMediaMessage(forLocalURL: localURL!)
            //self.uploadChatAttachment(attachment: tempImage)
        }
    }
}

extension BroadcastChatVC : AssetPickerDelegate{

    func assetPickerDidFinishSelectingAssets(withFilterAssetModels filterAssetModels: [FilterAssetModel]) {
        
        DispatchQueue.main.async {
            let viewControllers: [UIViewController] = APP_DELEGATE.appNavigation!.viewControllers as [UIViewController]
            APP_DELEGATE.appNavigation!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for filterModel in filterAssetModels{
                //let filterModel = filterAssetModels.first!
                if filterModel.originalPHAsset.mediaType == .image{
                    
                    let localURL = save_Content(image: filterModel.originalPHAsset.getOriginalImage(), imageName: "\(self.getNewPendingMessageID()).png", inDirectory: self.get_URL_inBroadcastChatDir())
                    self.sendMediaMessage(forLocalURL: localURL!)
                    
                    //self.uploadChatAttachment(attachment: filterModel.originalPHAsset.getOriginalImage())
                }else{
                    
                    let fileName = "\(self.getNewPendingMessageID())" + "." + filterModel.exportedFileURL!.pathExtension
                    let localURL = save_Content(contentURL: filterModel.exportedFileURL!, withName: fileName, inDirectory: self.get_URL_inBroadcastChatDir())
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
            "iospkid" : "\(getNewPendingMessageID())",
            "senderid" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            //"broadcast_members" : self.selectedBroadcastListDetails.members,
            "broadcast_members" : self.arrMember_IDs.joined(separator: ","),
            "textmessage" : self.vcfPersonName,
            "messagetype" : "1",
            "mediaurl" : localURL.path,
            "platform" : PlatformName,
            "username" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
            "countrycode" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode).replacingOccurrences(of: "+", with: ""),
            "phonenumber" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile),
            "mediasize":sizeoffile
        ]
        self.newSendMessageWithDic(dic: dic)
    }
    
    func uploadChatAttachment(attachment:Any){
        showLoaderHUD(strMessage: "Uploading Attachment")
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
                            let imgURL : URL = save_Content(image: img, imageName: imgName, inDirectory: self.get_URL_inBroadcastChatDir())!
                            //print("imgURL: \(imgURL)")
                            
                            
                            //Save in particuler user's chat folder
                            self.saveContent_inParticuler_UserChat(contentURL: imgURL)
                        }
                            //Video
                        else if isPathForVideo(path: strMediaURL) {
                            var videoName : String = "\(get_fileName_asCurretDateTime())\(get_RandomNo(noOfDigit: 2)).mp4"
                            videoName = strMediaURL.url?.lastPathComponent ?? videoName
                            //let videoURL : URL = self.save_MediaContent_inChatDir(contentURL: attachment as! URL, withName: videoName)!
                            let videoURL : URL = save_Content(contentURL: attachment as! URL, withName: videoName, inDirectory: self.get_URL_inBroadcastChatDir())!
                            //print("videoURL: \(videoURL)")
                            
                            
                            //Save in particuler user's chat folder
                            self.saveContent_inParticuler_UserChat(contentURL: videoURL)
                        }
                            //Audio
                        else if isPathForAudio(path: strMediaURL) {
                            var audioFileName : String = "\(get_fileName_asCurretDateTime())\(get_RandomNo(noOfDigit: 2)).m4a"
                            audioFileName = strMediaURL.url?.lastPathComponent ?? audioFileName
                            let audioFileURL : URL = save_Content(contentURL: attachment as! URL, withName: audioFileName, inDirectory: self.get_URL_inBroadcastChatDir())!
                            //print("audioFileURL: \(audioFileURL)")
                            
                            
                            //Save in particuler user's chat folder
                            self.saveContent_inParticuler_UserChat(contentURL: audioFileURL)
                            
                            //Remove temp. taken file
                            removeFile_onURL(fileURL: attachment as! URL)
                        }
                            //Contact
                        else if isPathForContact(path: strMediaURL) {
                            var contactFileName : String = "\(get_fileName_asCurretDateTime())\(get_RandomNo(noOfDigit: 2)).vcf"
                            contactFileName = strMediaURL.url?.lastPathComponent ?? contactFileName
                            let contactFileURL : URL = save_Content(contentURL: attachment as! URL, withName: contactFileName, inDirectory: self.get_URL_inBroadcastChatDir())!
                            //print("contactFileURL: \(contactFileURL)")
                            
                            
                            //Save in particuler user's chat folder
                            self.saveContent_inParticuler_UserChat(contentURL: contactFileURL)
                            
                            //Remove temp. taken file
                            removeFile_onURL(fileURL: attachment as! URL)
                        }
                            //OtherFile/Document
                        else {
                            let documentFileName : String = (strMediaURL.url?.lastPathComponent)!
                            let documentFileURL : URL = save_Content(contentURL: attachment as! URL, withName: documentFileName, inDirectory: self.get_URL_inBroadcastChatDir())!
                            //print("documentFileURL: \(documentFileURL)")
                            
                            
                            //Save in particuler user's chat folder
                            self.saveContent_inParticuler_UserChat(contentURL: documentFileURL)
                            
                            //Remove temp. taken file
                            removeFile_onURL(fileURL: attachment as! URL)
                        }
                        //--------------------------------------------->
                        
                        let dic = [
                            "senderid" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
                            //"broadcast_members" : self.selectedBroadcastListDetails.members,
                            "broadcast_members" : self.arrMember_IDs.joined(separator: ","),
                            "textmessage" : self.vcfPersonName,
                            "messagetype" : "1",
                            "mediaurl" : Get_Chat_Attachment_URL + (thedata!["data"] as! String),
                            "platform" : PlatformName,
                            "username" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
                            "countrycode" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode).replacingOccurrences(of: "+", with: ""),
                            "phonenumber" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)
                        ]
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

extension BroadcastChatVC:UITableViewDelegate,UITableViewDataSource
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
        
        let dtvalr = obj.createddate == "" ? "" : timeAgoSinceStrDate(strDate: obj.createddate, numericDates: true)
        
        if obj.messagetype == "-1"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatInitialCell") as! GroupChatInitialCell
            
            cell.lblInitialMessage.text = obj.textmessage.base64Decoded
            if obj.senderid == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId){
                //cell.lblInitialMessage.text = "You created group \(groupName)"
            }
            
            return cell
        }
        
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
                    /*cell.addGestureRecognizer(longPress)
                    
                    if parentMessage != nil {
                        cell.heightReplyView.constant = 48
                        cell.lblMessageReply.text = messageReply
                        cell.lblNameReply.text = nameReply
                    }else{
                        cell.lblMessageReply.text = ""
                        cell.lblNameReply.text = ""
                        cell.heightReplyView.constant = 0
                    }*/
                    
                    return cell
                }
                else if obj.messagetype == "5" {
                    let cell = self.manage_ContactCell_Receiver(tableView: tableView, indexPath: indexPath)
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
                    
                    if isPathForVideo(path: obj.mediaurl){
                        
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
                        cell.heightOfvwDownload.constant = 0
                        if obj.isread == "-1"{
                            cell.heightOfvwDownload.constant = 35
                            if obj.id == currentlySendingMessageID{
                                cell.downloadIndicator.startAnimating()
                                cell.lblDownload.text = "UPLOADING.."
                            }else{
                                cell.lblDownload.text = "QUEUED"
                            }
                        }else{
                            cell.downloadIndicator.stopAnimating()
                            cell.lblDownload.text = ""
                            cell.heightOfvwDownload.constant = 0
                        }
                        
                    }else if isPathForImage(path: obj.mediaurl){
                        //HIDE PLAY ICON
                        cell.imgPlayVideo.isHidden = true
                        cell.heightOfvwDownload.constant = 0
                        
                        //Set Blur Image
                        cell.imgBlurImage_Send.sd_setImage(with: URL.init(string: obj.mediaurl), placeholderImage: SquarePlaceHolderImage_Chat)
                        addBlurAboveImage(cell.imgBlurImage_Send, 0.9)
                        
                        cell.imgsent.image = nil
                        cell.imgsent.image = SquarePlaceHolderImage_Chat
                        
                        if obj.isread == "-1"{
                            cell.heightOfvwDownload.constant = 35
                            if obj.id == currentlySendingMessageID{
                                cell.downloadIndicator.startAnimating()
                                cell.lblDownload.text = "UPLOADING.."
                                cell.imgBlurImage_Send.isHidden = false
                            }else{
                                cell.lblDownload.text = "QUEUED"
                            }
                            
                            cell.imgBlurImage_Send.isHidden = false
                        }else{
                            cell.downloadIndicator.stopAnimating()
                            cell.lblDownload.text = ""
                            cell.heightOfvwDownload.constant = 0
                        }
                        
                        //cell.imgsent.sd_setImage(with: URL.init(string: obj.mediaurl), placeholderImage: PlaceholderImage)
                        /*SDWebImageManager.shared().cachedImageExists(for: obj.mediaurl.toUrl, completion: { (doesExist) in
                            if doesExist{
                                cell.imgsent.sd_setImage(with: obj.mediaurl.toUrl, placeholderImage: PlaceholderImage)
                                cell.heightOfvwDownload.constant = 0
                            }else{
                                cell.heightOfvwDownload.constant = 35
                            }
                        })*/
                        
                        if isFileLocallyExist(fileName: obj.mediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inBroadcastChatDir()){
                            //cell.lblDownload.text = ""
                            //cell.heightOfvwDownload.constant = 0
                            //cell.downloadIndicator.stopAnimating()
                             cell.imgBlurImage_Send.isHidden = false
                            
                            let url = getURL_LocallyFileExist(fileName: obj.mediaurl.toUrl!.lastPathComponent, inDirectory: self.get_URL_inBroadcastChatDir())
                            do{
                                let data = try Data.init(contentsOf: url)
                                let img = UIImage.init(data: data)
                                cell.imgsent.image = img
                                 cell.imgBlurImage_Send.isHidden = true
                            }catch{
                                print(error.localizedDescription)
                            }
                            
                        }
                        else {
                            cell.imgBlurImage_Send.isHidden = false
                        }
                        
                        cell.imgsent.backgroundColor = .clear
                        cell.imgsent.backgroundColor = SquarePlaceHolderImage_ChatBG
                        
                    }else if obj.messagetype == "2"{
                        cell.imgPlayVideo.isHidden = true
                        cell.imgsent.image = #imageLiteral(resourceName: "img_map")
                        cell.imgBlurImage_Send.isHidden = true
                        cell.heightOfvwDownload.constant = 0
                        
                        if obj.isread == "-1"{
                            cell.heightOfvwDownload.constant = 35
                            if obj.id == currentlySendingMessageID{
                                cell.downloadIndicator.startAnimating()
                                cell.lblDownload.text = "UPLOADING.."
                            }else{
                                cell.lblDownload.text = "QUEUED"
                            }
                        }else{
                            cell.downloadIndicator.stopAnimating()
                            cell.lblDownload.text = ""
                            cell.heightOfvwDownload.constant = 0
                        }
                    }
                    
                    cell.imgreceipt.image = imgReadReceipt
                    
                    cell.heightReplyView.constant = 0
                    cell.lblNameReply.text = ""
                    cell.lblMessageReply.text = ""
                    
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
                    
                    cell.heightReplyView.constant = 0
                    cell.lblNameReply.text = ""
                    cell.lblMessageReply.text = ""
                    
                    if obj.isread == "-1"{
                        if obj.id == currentlySendingMessageID{
                            cell.downloadIndicator.startAnimating()
                        }
                    }else{
                        cell.downloadIndicator.stopAnimating()
                    }
                    
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
                    
                    cell.heightReplyView.constant = 0
                    cell.lblNameReply.text = ""
                    cell.lblMessageReply.text = ""
                    
                    if obj.isread == "-1"{
                        if obj.id == currentlySendingMessageID{
                            cell.downloadIndicator.startAnimating()
                        }
                    }else{
                        cell.downloadIndicator.stopAnimating()
                    }
                    
                    return cell
                }
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatReceiverCell") as! ChatReceiverCell
                
                cell.lblmsg.text = obj.textmessage.base64Decoded
                cell.lbltime.text = dtvalr //obj.kcreateddate
                cell.lblmsg.numberOfLines = 0
                //cell.lblmsg.sizeToFit()
                cell.lblmsg.layoutIfNeeded()
                cell.imgreceipt.image = imgReadReceipt
                cell.imgbubble.image = bubbleImg
                
                cell.heightReplyView.constant = 0
                cell.lblNameReply.text = ""
                cell.lblMessageReply.text = ""
                
                return cell;
            }
        }
        return UITableViewCell()
        /*else{
            
            bubble = "left\(bubble)"
            bubbleImg = UIImage(named:bubble)
            
            let senderName = obj.sendername
            
            if Int(obj.messagetype)! > 0
            {
                
                if isPathForImage(path: obj.mediaurl) ||  isPathForVideo(path: obj.mediaurl) || obj.messagetype == "2"{
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatSenderAttachCell") as! GroupChatSenderAttachCell
                    cell.lbltime.text = dtvalr// obj.kcreateddate
                    cell.groupChatSenderAttachCellDelegate = self
                    cell.btnAttach.tag = indexPath.row
                    cell.btnAttach.accessibilityLabel = "\(indexPath.section)"
                    cell.imgreceived.image = nil
                    if isPathForVideo(path: obj.mediaurl){
                        //SHOW PLAY ICON ON CELL
                        cell.imgPlayVideo.isHidden = false
                        cell.imgreceived.backgroundColor = .black
                    }else if isPathForImage(path: obj.mediaurl){
                        //HIDE PLAY ICON
                        cell.imgPlayVideo.isHidden = true
                        cell.imgreceived.sd_setImage(with: URL.init(string: obj.mediaurl), placeholderImage: PlaceholderImage)
                        cell.imgreceived.backgroundColor = .clear
                    }else if obj.messagetype == "2"{
                        cell.imgPlayVideo.isHidden = true
                        cell.imgreceived.image = #imageLiteral(resourceName: "img_map")
                    }
                    cell.lblSender.text = senderName
                    return cell;
                    
                }
                else if isPathForContact(path: obj.mediaurl){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatContactSenderCell") as!
                    GroupChatContactSenderCell
                    cell.lblContact.text = obj.textmessage.base64Decoded
                    cell.imgContact.image = #imageLiteral(resourceName: "profile_pic_register")
                    cell.groupChatSenderContactCellDelegate = self
                    cell.btnContact.tag = indexPath.row
                    cell.btnContact.accessibilityLabel = "\(indexPath.section)"
                    cell.Lbltime.text = dtvalr
                    cell.imgbubble.image = bubbleImg
                    cell.lblSender.text = senderName
                    return cell
                }
                else if isPathForAudio(path: obj.mediaurl){
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
                }
                else {
                    //DOCUMENT
                    let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatSenderDocumentCell") as! GroupChatSenderDocumentCell
                    
                    cell.lbltime.text = dtvalr
                    
                    cell.groupChatSenderDocumentCellDelegate = self
                    cell.btnSenderDocument.tag = indexPath.row
                    cell.btnSenderDocument.accessibilityLabel = "\(indexPath.section)"
                    
                    cell.lblFileType.text = getFileType(for: obj.mediaurl)
                    cell.imgsent.image = getFileIcon(for: obj.mediaurl)
                    
                    cell.imgbubble.image = bubbleImg
                    cell.lblSender.text = senderName
                    return cell
                }
                
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChatSenderCell") as! GroupChatSenderCell
                cell.lblmsg.text = obj.textmessage.base64Decoded
                cell.lbltime.text = dtvalr //obj.kcreateddate
                cell.lblmsg.numberOfLines = 0
                cell.lblmsg.sizeToFit()
                /*if(obj.kbubbletype == "1")
                 {
                 cell.imgbubble.image = ChatLeftTopImage
                 }
                 else if(obj.kbubbletype == "2")
                 {
                 cell.imgbubble.image = ChatLeftCenterImage
                 }*/
                //else
                //{
                cell.imgbubble.image = ChatLeftBottomImage
                //}
                cell.imgbubble.image = bubbleImg
                cell.lblSender.text = senderName
                return cell;
            }
        }*/
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let intTotalrow = tableView.numberOfRows(inSection:indexPath.section)//first get total rows in that section by current indexPath.
        if indexPath.row == intTotalrow - 1 { scrollbottombtn.alpha = 0 }
        else { scrollbottombtn.alpha = 1 }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let obj = arrMsgs[indexPath.row]
        /*let assortedMsgs = arrAssortedMsgs[indexPath.section]
         let obj = assortedMsgs.Msgs[indexPath.row] as! StructGroupChat*/
        
        if Int(obj.messagetype)! > 0 {
            if obj.messagetype == "4"{ return UITableViewAutomaticDimension }
            if obj.senderid == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId) {
                if isPathForImage(path: obj.mediaurl) ||  isPathForVideo(path: obj.mediaurl) || obj.messagetype == "2"{
                    return 167//175
                }
                else if obj.messagetype == "5" { return 124 }
                else if isPathForContact(path: obj.mediaurl){
                    return 124//68//51
                }/*else if isPathForAudio(path: obj.mediaurl){
                    return 68
                }*/
                else{
                    return 80//68 //DOCUMENT
                }
            }else{
                if isPathForImage(path: obj.mediaurl) ||  isPathForVideo(path: obj.mediaurl) || obj.messagetype == "2"{
                    return 175 + 19
                }
                else if obj.messagetype == "5" { return 124 }
                else if isPathForContact(path: obj.mediaurl) { return 51 + 19 }
                /*else if isPathForAudio(path: obj.mediaurl){
                    return 68 + 19
                }*/
                else{
                    return 68 + 19 //DOCUMENT
                }
            }
        }
        else
        {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0//23
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    /*func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
     {
     let frame = CGRect(x:0,y: 3,width: tableView.frame.size.width,height: 20)
     let view = UIView(frame:frame)
     view.backgroundColor = UIColor.clear
     view.autoresizingMask = .flexibleWidth
     let label = UILabel()
     
     let assortedMsgs = arrAssortedMsgs[section]
     
     var strDate = assortedMsgs.Date
     strDate = DateFormater.convertDateForChatMessage(givenDate: strDate)
     
     label.text = strDate
     label.textAlignment = .center
     label.sizeToFit()
     label.center = view.center
     label.backgroundColor = Color_RGBA(238, 233, 230, 1)
     label.textColor = UIColor.darkGray
     label.font = UIFont.systemFont(ofSize: 11)
     label.layer.cornerRadius = 3
     label.layer.masksToBounds = true
     label.autoresizingMask = []
     view.addSubview(label)
     return view
     }*/
    
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
                self.tblchat.scrollToRow(at: pathToLastRow, at: .bottom, animated: animated)
                self.scrollbottombtn.alpha = 0
            }
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
    @objc func manage_ContactCell_Receiver(tableView: UITableView,  indexPath : IndexPath) -> ChatContactReceiverCell {
        let obj = arrMsgs[indexPath.row]
        let dateValue = obj.createddate == "" ? "" : timeAgoSinceStrDate(strDate: obj.createddate, numericDates: false)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatContactReceiverCell") as! ChatContactReceiverCell
        cell.chatReceiverContactCellDelegate = self
        
        cell.heightReplyView.constant = 0
        cell.lblNameReply.text = ""
        cell.lblMessageReply.text = ""
        
        cell.lblContact.text = get_ContactName(strMess: obj.textmessage)
        
        cell.btnContact.tag = indexPath.row
        cell.btnContact.accessibilityLabel = "\(indexPath.section)"
        cell.btnContact.setTitle("View", for: .normal)
        var strButtonTitle : String = get_ContactButtonTitle(strMess: obj.textmessage)
        if strButtonTitle.uppercased() == "Message".uppercased() { strButtonTitle = "View Contact" }
        
        cell.Lbltime.text = dateValue
        
        if obj.isread == "-1" {
            if obj.id == currentlySendingMessageID { cell.downloadIndicator.startAnimating() }
            else {  cell.downloadIndicator.stopAnimating() }
        }
        
        return cell
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
         //let objContactData : StructChat = CoreDBManager.sharedDatabase.getFriendById(userID: )
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
}

extension BroadcastChatVC:InputbarDelegate {
    
    func getBubbleImage(objChat:StructBroadcastMessage) -> String{
        
        var thisMessageIndex = 0
        if let foo = arrMsgs.enumerated().first(where: {$0.element.id == objChat.id}){
            thisMessageIndex = foo.offset
        }
        
        
        if thisMessageIndex == 0{
            return "1"
        }
        
        if thisMessageIndex == (arrMsgs.count - 1){
            return "3"
        }
        
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
            return "1" //BECAUSE RECEIVER IS COMMA SEPARATED STRING
            /*if previousReceiver != meAsReceiver{
             return "1"
             }
             if nextReceiver != meAsReceiver{
             return "3"
             }
             if previousReceiver == meAsReceiver && nextReceiver == meAsReceiver{
             return "2"
             }*/
        }
        
        return "2" //SHOULD NEVER FALLBACK HERE
        
    }
    
    func inputbarDidPressRightButton(inputbar:Inputbar)
    {
        
        /*let dic = [
            "groupid":selectedGroupId,
            "senderid":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            "group_members":selectedGroupDetails.members,
            "textmessage": inputbar.text.base64Encoded ?? "",
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
            ]  as [String : Any]*/
        
        let textMessage = inputbar.text.trimmingCharacters(in: .whitespacesAndNewlines)

        var dic = [
            "senderid" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            //"broadcast_members" : self.selectedBroadcastListDetails.members,
            "broadcast_members" : self.arrMember_IDs.joined(separator: ","),
            "textmessage" : textMessage.base64Encoded ?? "",
            "messagetype" : "0",
            "mediaurl" : "",
            "platform" : PlatformName,
            "username" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
            "countrycode" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode).replacingOccurrences(of: "+", with: ""),
            "phonenumber" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)
        ]
        
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
        
        if inputbar.text.count > 0{
            if linkPreview != nil{
                linkPreview?.cancel()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
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
    
    func openAttachmentView(){
        if isDNDActive == true{
            return
        }
        self.clickedattach = true
        self.vwattach.accessibilityValue = "\(self.inputvalues.frame.origin.y - self.vwattach.frame.size.height)"
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
    }
    
    func newSendMessageWithDic(dic:[String:Any]){
        var dic = dic
        dic["parent_id"] = "0"
        fire_eventSend_Messgae(objmsg: dic as NSDictionary)
        tableViewScrollToBottomAnimated(animated: true)
        /*if isConnectedToNetwork() && APP_DELEGATE.socketIOHandler?.isSocektConnected() == true{
            
            let structobj = StructBroadcastMessage.init(dictionary: dic)
            arrMsgs.append(structobj)
            
            
            self.tblchat.beginUpdates()
            self.tblchat.insertRows(at: [IndexPath(row: (self.arrMsgs.count)-1, section: 0)], with: .none)
            self.tblchat.endUpdates()
            self.tblchat.scrollToRow(at: (IndexPath(row:(self.arrMsgs.count)-1, section:0)) as IndexPath, at:.bottom, animated:true)
            
            self.tableViewScrollToBottomAnimated(animated: false)
        }
        runInBackground {
            //TEMPORARILY DISABLED
            self.socketCall_SendMessage(objmessage: dic as NSDictionary)
        }*/
    }
    
    /*func socketCall_SendMessage(objmessage:NSDictionary)
    {
        if(isConnectedToNetwork())
        {
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
    }*/
 
    func fire_eventSend_Messgae(objmsg:NSDictionary)
    {
       
        if linkPreviewDetails != nil {
            linkPreviewDetails = nil
        }

        let offlineMessageId = getNewPendingMessageID()

        var dictionary = [String:Any]()
        dictionary["id"] = String(offlineMessageId)
        dictionary["broadcastListID"] = selectedBroadcastListID
        dictionary["senderid"] = objmsg["senderid"]
        dictionary["sendername"] = UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName)
        dictionary["receiverid"] = objmsg["broadcast_members"]
        dictionary["textmessage"] = objmsg["textmessage"]
        dictionary["isread"] = "-1"
        dictionary["platform"] = PlatformName
        dictionary["isdeleted"] = "0"
        dictionary["createddate"] = DateFormater.getStringFromDate(givenDate: NSDate())
        dictionary["messagetype"] = objmsg["messagetype"]
        dictionary["mediaurl"] = objmsg["mediaurl"]
        
        let broadcastMessage = StructBroadcastMessage.init(dictionary: dictionary)
        
        CoreDBManager.sharedDatabase.saveBroadcastMessageInLocalDB(objmessgae: broadcastMessage)
        reloadTable()
        
        sendPendingMessages()
    }
    
    @objc func sendPendingMessages() {
        
        if isConnectedToNetwork() && APP_DELEGATE.socketIOHandler!.isSocektConnected(){
            
            let pendingMessages = self.arrMsgs.filter({$0.isread == "-1"})
            
            if pendingMessages.count == 0 || currentlySendingMessageID.count > 0 { return }
            
            let message = pendingMessages.first!
            
            let objmsg = [
                "iospkid" : message.id,
                "senderid" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
                //"broadcast_members" : self.selectedBroadcastListDetails.members,
                "broadcast_members" : self.arrMember_IDs.joined(separator: ","),
                "textmessage" : message.textmessage,
                "messagetype" : message.messagetype,
                "mediaurl" : message.mediaurl,
                "platform" : PlatformName,
                "username" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
                "countrycode" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode).replacingOccurrences(of: "+", with: ""),
                "phonenumber" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile),
                "mediasize":fileSize(url: message.mediaurl.toUrl)
            ]
            currentlySendingMessageID = objmsg["iospkid"]!
            
            if objmsg["messagetype"] == "1"{
                uploadAttachmentAndSendMessageThroughSocket(objmsg:objmsg)
            }else{
                sendMessageThroughSocket(objmsg:objmsg)
            }
            
        }
    }
    
    func sendMessageThroughSocket(objmsg:[String:Any]){
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck(keySendBroadcastMessage,objmsg).timingOut(after: 1000)
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
                var msg = StructBroadcastMessage.init(dictionary:dicMsg)
                msg.broadcastListID = self.selectedBroadcastListID
                CoreDBManager.sharedDatabase.replaceBroadcastMessageInLocalDB(objmessgae: msg, with: dicMsg["iospkid"] as! String)
                
                self.reloadTable()
                self.tableViewScrollToBottomAnimated(animated: true)
                
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

extension BroadcastChatVC : ImagePickerDelegate
{
    func pickImageComplete(_ imageData: UIImage, sender: String)
    {
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

extension BroadcastChatVC : IGRPhotoTweakViewControllerDelegate{
    //MARK:- CropImg Delegate Method
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

extension BroadcastChatVC : ChatReceiverAttachCellDelegate, ChatReceiverDocumentCellDelegate, ChatReceiverContactCellDelegate, ChatReceiverAudioCellDelegate, ChatLinkPreviewReceiverCellDelegate, AVAudioPlayerDelegate
{
    /*func btnZoomClicked(_ sender: UIButton) {
        let section = Int(sender.accessibilityLabel!)!
        openAttachment(atRow: sender.tag, inSection: section)
    }*/
    
    func btnZoomMineClicked(_ sender: UIButton){
        let section = Int(sender.accessibilityLabel!)!
        openAttachment(atRow: sender.tag, inSection: section)
    }
    
    /*func btnDocZoomClicked(_ sender: UIButton) {
        let section = Int(sender.accessibilityLabel!)!
        openAttachment(atRow: sender.tag, inSection: section)
    }*/
    
    func btnDocZoomMineClicked(_ sender: UIButton) {
        let section = Int(sender.accessibilityLabel!)!
        openAttachment(atRow: sender.tag, inSection: section)
    }
    
    /*func btnSenderContactClicked(_ sender: UIButton) {
        let section = Int(sender.accessibilityLabel!)!
        openAttachment(atRow: sender.tag, inSection: section)
    }*/
    
    /*func btnReceiverContactClicked(_ sender: UIButton) {
        let section = Int(sender.accessibilityLabel!)!
        openAttachment(atRow: sender.tag, inSection: section)
    }*/
    
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
    
    /*func btnPlayAudioClicked(_ sender: UIButton) {
        
        if audioPlayer != nil{
            audioPlayerDidFinishPlaying(audioPlayer!, successfully: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            
            let section = Int(sender.accessibilityLabel!)!
            self.currentPlayingAudioCellIndex = IndexPath.init(row: sender.tag, section: section)
            self.openAttachment(atRow: sender.tag, inSection: section)
            
        })
    }*/
    
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

extension BroadcastChatVC{
    
    func openAttachment(atRow row:Int, inSection section:Int){
        
        let obj = arrMsgs[row]
        /*let assortedMsgs = arrAssortedMsgs[section]
         let obj = assortedMsgs.Msgs[row] as! StructGroupChat*/
        
        if Int(obj.messagetype)! > 0
        {
            let cell = tblchat.cellForRow(at: IndexPath.init(row: row, section: section))!
            
            if isPathForImage(path: obj.mediaurl){
                
                SDWebImageManager.shared().cachedImageExists(for: obj.mediaurl.toUrl, completion: { (doesExist) in
                    if doesExist{
                        /*let configuration = ImageViewerConfiguration { config in
                            config.imageView = cell.viewWithTag(15) as? UIImageView
                        }
                        let imageViewerController = ImageViewerController(configuration: configuration)
                        self.present(imageViewerController, animated: true)*/
                        
                        self.photoBrowser = ChatAttachmentBrowser.init(broadcastListID: self.selectedBroadcastListID, startingFromMediaURL:obj.mediaurl, currentLocalDir: self.get_URL_inBroadcastChatDir())
                        self.photoBrowser.startFromGrid = false
                        self.photoBrowser.openBrowser()
                    }else{
                        self.downloadImage(url: obj.mediaurl, reloadCellAt: row, and: section)
                    }
                })
                
            }else if Int(obj.messagetype)! == 2{
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
                    
                    if isFileLocallyExist(fileName: obj.mediaurl.lastPathComponent, inDirectory: self.get_URL_inBroadcastChatDir()) == false {
                        //print("Audio download now.")
                        self.downloadContent_audio(contentURL: obj.mediaurl.url!)
                        //return
                    }
                    
                    let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: "ChatAudioPlayerVC") as! ChatAudioPlayerVC
                    vc.modalPresentationStyle = .overCurrentContext
                    vc.audioURL = obj.mediaurl
                    vc.URL_CurrentDir = self.get_URL_inBroadcastChatDir() 
                    present(vc, animated: true, completion: nil)
                }
                else{
                    //DOCUMENT
                    //downloadAndOpenAttachment(url: URL.init(string: obj.mediaurl)!)
                    downloadAndOpenAttachment(url: obj.mediaurl.url!, atRow: row, inSection: section)
                }
            }
        }
    }
    
    //func downloadAndOpenAttachment(url:URL)
    func downloadAndOpenAttachment(url:URL, atRow row:Int, inSection section:Int) {
        //if isFileLocallySaved(fileUrl: url) {
        if isFileLocallyExist(fileName: url.lastPathComponent, inDirectory: self.get_URL_inBroadcastChatDir()) == true {
            
            
            //let localURL = getLocallySavedFileURL(with: url)!
            let localURL = getURL_LocallyFileExist(fileName: url.lastPathComponent, inDirectory: get_URL_inBroadcastChatDir())
            
            if isPathForVideo(path: localURL.path) {
                /*let player = AVPlayer(url: localURL)
                 let playerViewController = AVPlayerViewController()
                 playerViewController.player = player
                 self.present(playerViewController, animated: true) {
                 playerViewController.player!.play()
                 }*/
                
                self.photoBrowser = ChatAttachmentBrowser.init(broadcastListID: self.selectedBroadcastListID, startingFromMediaURL:url.absoluteString, currentLocalDir: self.get_URL_inBroadcastChatDir())
                self.photoBrowser.startFromGrid = false
                self.photoBrowser.currentLocalDirectory = self.get_URL_inBroadcastChatDir() 
                self.photoBrowser.openBrowser()
            }
            else if isPathForAudio(path: localURL.path){
                /*do{
                 audioPlayer = try AVAudioPlayer.init(contentsOf: localURL)
                 audioPlayer?.delegate = self
                 audioPlayer?.prepareToPlay()
                 audioPlayer?.play()
                 
                 if currentPlayingAudioCellIndex != nil{
                 tblchat.reloadRows(at: [currentPlayingAudioCellIndex!], with: .none)
                 let cell = tblchat.cellForRow(at: currentPlayingAudioCellIndex!)
                 audioPlayerProgressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateAudioCellProgressView), userInfo: ["cell":cell], repeats: true)
                 }
                 
                 }catch{
                 print(error.localizedDescription)
                 }*/
                let vc = loadVC(strStoryboardId: SB_CHAT, strVCId: "AudioPlayerVC") as! AudioPlayerVC
                vc.modalPresentationStyle = .overCurrentContext
                vc.audioURL = url.path
                present(vc, animated: true, completion: nil)
            }else{
                let objData : StructBroadcastMessage = self.arrMsgs[row]
                
                documentInteraction = UIDocumentInteractionController.init(url: localURL)
                documentInteraction.delegate = self
                documentInteraction.name = objData.textmessage.base64Encoded?.count != 0 ? objData.textmessage.base64Decoded : objData.mediaurl.lastPathComponent
                
                let success = documentInteraction.presentPreview(animated: true)
                if success == false{
                    //print("//OPEN AS MENU")
                    documentInteraction.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
                }
            }
            
        }else{
            
            if arrDownloadURLs.contains(url) == false{
                arrDownloadURLs.append(url)
            }
            
            performDownload()
            
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
                    
                    //--------------------------->
                    //print("downloadContentURL: \(url)")
                    let downloadContentLocalURL : URL = save_Content(contentURL: url, withName: url.lastPathComponent, inDirectory: self.get_URL_inBroadcastChatDir())!
                    //print("downloadContentLocalURL: \(downloadContentLocalURL)")
                    
                    //Save in Particuler user's folder dir.
                    self.saveContent_inParticuler_UserChat(contentURL: downloadContentLocalURL)
                    
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
                let imgURL : URL = save_Content(image: image!, imageName: "\(url.lastPathComponent)", inDirectory: self.get_URL_inBroadcastChatDir())!
                //print("imgURL: \(imgURL)")
            })
        }
    }
    
}
