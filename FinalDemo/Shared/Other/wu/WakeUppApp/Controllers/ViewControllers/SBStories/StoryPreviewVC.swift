//
//  StoryPreviewVC.swift
//  WakeUppApp
//
//  Created by Payal Umraliya on 11/07/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import AVFoundation
import IQKeyboardManagerSwift
class StoryPreviewVC: UIViewController {
    
    //MARK : -
    @IBOutlet weak var imgpreview: UIImageView!
    var arrimages = [UIImage]()
    var vdourl:URL?
    var timechoosen :String?
    var isprivate :String?
    @IBOutlet weak var vwpreview: UIView!
    @IBOutlet weak var inuputValues: Inputbar!
    var player: AVPlayer?
    var playbackTimeCheckerTimer: Timer?
    var arrduration = [String]()
    var arrtypes = [String]()
    var arrdateupload = [String]()
    var arrcomments = [String]()
    var redirectfrom = ""
    var storyownerid = ""
    var storymsgformat = ""
    
    let maxNumberOfLines = 6
    
    var arrImagesProperty : NSMutableArray = [] //PV
    //MARK : -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.layoutUI()
    }
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        player?.seek(to: kCMTimeZero)
        player?.play()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnbackclicked(_ sender: Any) {
        if redirectfrom == "storyreply" {
            UIApplication.shared.statusBarView?.backgroundColor = themeWakeUppColor
            APP_DELEGATE.appNavigation?.backToViewController(viewController: StoriesVC.self)
        }
        else {
            APP_DELEGATE.appNavigation?.backToViewController(viewController: CreateStoryVC.self)
        }
    }
    
    func layoutUI() {
        UIApplication.shared.statusBarView?.backgroundColor = UIColor.clear
        IQKeyboardManager.shared.enable = false
        self.setInputbar()
    }
    
    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(animated)
        self.managekeyboard()
        if vdourl != nil {
            let playerItem = AVPlayerItem(asset: AVAsset.init(url: vdourl!))
            player = AVPlayer(playerItem: playerItem)
            
            NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(_:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            
            let layer: AVPlayerLayer = AVPlayerLayer(player: player)
            layer.backgroundColor = UIColor.white.cgColor
            layer.frame = CGRect(x: 0, y: 0, width: vwpreview.frame.width, height: vwpreview.frame.height)
            layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            player?.play()
            vwpreview.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
            vwpreview.layer.addSublayer(layer)
            self.imgpreview.isHidden = true
        }
        else {
            self.imgpreview.isHidden = false
            self.imgpreview.image = arrimages[0]
        }
    }
    
    override func viewDidDisappear(_ animated:Bool) {
        IQKeyboardManager.shared.enable = true
        super.viewDidDisappear(animated)
        
        player?.pause()
        player = nil
    }
    
    func setInputbar() {
        self.inuputValues.placeholder = "Write a caption..."
        self.inuputValues.rightButtonImage = #imageLiteral(resourceName: "send_btn")
        self.inuputValues.inputDelegate = self
        //self.inuputValues.textView.maxNumberOfLines
    }
    
    func managekeyboard() {
        self.view.keyboardTriggerOffset = self.inuputValues.frame.size.height
        self.view.addKeyboardNonpanning() {[unowned self](keyboardFrameInView:CGRect, opening:Bool, closing:Bool) in
            var toolBarFrame = self.inuputValues.frame
            if UIScreen.main.bounds.height >= 812 {
                if #available(iOS 11.0, *) {
                    if keyboardFrameInView.origin.y == SCREENHEIGHT() {
                        toolBarFrame.origin.y = keyboardFrameInView.origin.y  - toolBarFrame.size.height -  (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)! - 34
                    }
                    else {
                        toolBarFrame.origin.y = keyboardFrameInView.origin.y  - toolBarFrame.size.height - 34
                    }
                }
                else {
                    toolBarFrame.origin.y = keyboardFrameInView.origin.y  - toolBarFrame.size.height - 34
                }
            }
            else {
                toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height - 34
            }
            self.inuputValues.frame = toolBarFrame
        }
    }
}

extension StoryPreviewVC:InputbarDelegate {
    func get_NoOfLine(text: String) -> Int {
        let label : UILabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: self.view.width - 30, height: 21))
        label.numberOfLines = 0
        label.text = text
        
        let textSize = CGSize(width: label.frame.size.width, height: CGFloat(Float.infinity))
        let rHeight = lroundf(Float(label.sizeThatFits(textSize).height))
        let charSize = lroundf(Float(label.font.lineHeight))
        let lineCount = rHeight/charSize
        return lineCount
    }
    
    func inputbarDidPressVoiceButton(inputbar: Inputbar) {
        if inputbar.textView.isFirstResponder() { self.view.endEditing(true) }
        
        let inputTextMess = TRIM(string: inputbar.text).nsString as String
        if get_NoOfLine(text: inputTextMess) > self.maxNumberOfLines {
            showMessage("Maximum \(self.maxNumberOfLines) lines message allow.")
            return
        }
        
        arrcomments.append(inputTextMess)
        
        self.inuputValues.resignFirstResponder()
        if redirectfrom == "storyreply" {
            self.uploadStoryMedia(arrimages,"","")
        }
        else {
            if vdourl != nil {
                do {
                    let asset = AVURLAsset(url: vdourl! , options: nil)
                    let imgGenerator = AVAssetImageGenerator(asset: asset)
                    imgGenerator.appliesPreferredTrackTransform = true
                    let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
                    let thumbnail = UIImage(cgImage: cgImage)
                    let img = thumbnail
                    img.accessibilityLabel = vdourl?.absoluteString
                    img.accessibilityValue = "\(asset.duration.seconds)"
                    let actionSheet = UIAlertController.init(title: nil, message: "Choose an option to upload this video story.", preferredStyle: .actionSheet)
                    let actionnow = UIAlertAction.init(title: "Publish now", style: .default) { (action) in
                        self.uploadStoryMedia([img], "","0")
                    }
                    let actionlater = UIAlertAction.init(title: "Schedule", style: .default) { (action) in
                        self.showdatepicker(uploadcontent: [img])
                    }
                    
                    let actioncancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
                        
                    }
                    actionSheet.addAction(actionnow)
                    actionSheet.addAction(actionlater)
                    actionSheet.addAction(actioncancel)
                    self.present(actionSheet, animated: true, completion: nil)
                }
                catch let error
                {
                    print(error)
                }
            }
            else
            {
                self.uploadStoryMedia(arrimages,timechoosen!,isprivate!)
            }
        }
    }
    func inputbarDidPressRightButton(inputbar:Inputbar)
    {
        
    }
    
    func inputbarDidPressLeft2Button(inputbar: Inputbar) {
        //emoji button
    }
    
    func inputbarDidPressLeftButton(inputbar:Inputbar) {
        //--->
    }
    
    func inputbarDidBecomeFirstResponder(inputbar:Inputbar) {
        //--->
    }
    
    func inputbarDidChangeHeight(newHeight:CGFloat) {
        self.view.keyboardTriggerOffset = newHeight
    }
}
extension StoryPreviewVC:UploadProgressDelegate
{
    func didReceivedProgress(progress: Float) {
        print(hudText);
        hudText = "Uploading \(Int(floor(progress*92)))% "
    }
}

extension StoryPreviewVC
{
    func showdatepicker(uploadcontent:NSMutableArray)
    {
        let objDatePicker: UIDatePicker = UIDatePicker()
        let lblTitle:UILabel = UILabel(frame: CGRect(x: 0, y: 15.0, width: SCREENWIDTH() - 20, height: 25))
        lblTitle.font = FontWithSize(FT_Regular, 18)
        lblTitle.textAlignment = .center
        lblTitle.text = title
        objDatePicker.datePickerMode = .dateAndTime
        objDatePicker.minimumDate = Date()
        objDatePicker.timeZone = TimeZone.current
        objDatePicker.frame = CGRect(x: 0, y: 40, width: SCREENWIDTH() - 20, height: 220)
        let alertController = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        alertController.view.addSubview(lblTitle)
        alertController.view.addSubview(objDatePicker)
        let btnOk = UIAlertAction(title: "Schedule this time", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
            showStatusBarMessage("Processing")
            self.uploadStoryMedia(uploadcontent as! [UIImage], "\(objDatePicker.date)","0")
        })
        let btnCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(alert: UIAlertAction!) in
            
        })
        
        alertController.addAction(btnOk)
        alertController.addAction(btnCancel)
        let alertControllerHeight:NSLayoutConstraint = NSLayoutConstraint(item: alertController.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 380)
        alertController.view.addConstraint(alertControllerHeight);
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.present(alertController, animated: true)
        }
    }
    func uploadStoryMedia(_ mediaForUpload:[UIImage], _ datechoose:String,_ privateornot:String)
    {
        HttpRequestManager.sharedInstance.delegate = self
        let parameter :NSMutableDictionary = ["token_id":UserDefaultManager.getStringFromUserDefaults(key: kToken)]
        let arrimgs = NSMutableArray()
        var arrcopies = [String]()
        for img in mediaForUpload {
            let imgv = img
            if imgv.accessibilityLabel == "IMAGE" {
                let imageData:Data = UIImageJPEGRepresentation(imgv, 0.6)!
                arrtypes.append("0")
                arrduration.append("5")
                arrimgs.add(imageData)
                arrdateupload.append(datechoose)
                arrcopies.append(privateornot)
            }
            else {
                arrtypes.append("1")
                arrduration.append(imgv.accessibilityValue!)
                arrimgs.add(imgv.accessibilityLabel!.toUrl!)
                arrdateupload.append(datechoose)
                arrcopies.append(privateornot)
            }
        }
        
        parameter.setObject(arrimgs, forKey: ("image[]" as NSString))
        showHUD()
        var path = ""
        if self.redirectfrom != "storyreply" {
            path = Upload_Story_URL
        }
        else {
            path = Upload_Chat_Attachment
        }
        HttpRequestManager.sharedInstance.requestWithPostMultipartParam(endpointurl: path, isImage: true, parameters: parameter) {(data, error, message, responseDict) -> Void in
            if error != nil
            {
                hideHUD()
                showMessageWithRetry(RetryMessage, 3, buttonTapHandler: { _ in
                    hideBanner()
                    self.uploadStoryMedia(mediaForUpload,datechoose,privateornot)
                })
                return
            }
            else if let data = data
            {
                hideHUD()
                HttpRequestManager.sharedInstance.delegate = nil
                let thedata = data as? NSDictionary
                if(thedata != nil)
                {
                    print(thedata!)
                    if (thedata?.count)! > 0
                    {
                        let images  = thedata!.object(forKey: kData) as! String
                        if self.redirectfrom != "storyreply"
                        {
                            if datechoose != ""
                            {
                                self.call_ScheduleCreateStory(images, self.arrduration.joined(separator: ","), self.arrtypes.joined(separator: ","),self.arrdateupload.joined(separator: ","),arrcopies.joined(separator: ","))
                            }
                            else
                            {
                                self.call_keyCreateStory(images, self.arrduration.joined(separator: ","), self.arrtypes.joined(separator: ","),arrcopies.joined(separator: ","))
                            }
                        }
                        else
                        {
                            self.replyToStory(images)
                        }
                        for nm in mediaForUpload
                        {
                            let imgv = nm
                            print(imgv.accessibilityLabel!.toUrl!)
                            try? FileManager.default.removeItem(at: imgv.accessibilityLabel!.toUrl!)
                        }
                    }
                }
                else
                {
                    
                }
            }
            else
            {
                hideHUD()
            }
        }
    }
    func replyToStory(_ imgs:String)
    {
        //        let model = currentStories.arrStories[currentStoryIndex]
        let textMessage = inuputValues.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let strMessage = "\(storymsgformat)\(textMessage)"
        
        
        let dic = [
            "senderid":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            "receiverid":storyownerid,
            "textmessage": strMessage.base64Encoded ?? "",
            "messagetype": "3",
            "mediaurl": Get_Chat_Attachment_URL + imgs,
            "platform":PlatformName,
            "createddate": "",
            "isdeleted":"0",
            "isread":"0",
            "username" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
            "mutestatus" : CoreDBManager.sharedDatabase.amIMutedByUser(receiverId: storyownerid) ? "1" : "0",
            "countrycode" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserCountryCode).replacingOccurrences(of: "+", with: ""),
            "phonenumber" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile)
            ]  as [String : Any]
        
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck(keySendMessage,dic).timingOut(after: 1000)
        {data in
            let data = data as Array
            if(data.count > 0)
            {
                if data[0] is String{
                    return
                }
                print(data)
                //CODE TO SAVE IN COREDB
                let msg = StructChat.init(dictionary: data[0] as! [String:Any])
                _ = CoreDBManager.sharedDatabase.saveMessageInLocalDB(objmessgae: msg)
                
                //print("fire_eventSend_Messgae -> reloadTable")
                
                APP_DELEGATE.socketIOHandler?.reloadFriendAndGroupList()
                self.inuputValues.resignFirstResponder()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    hideHUD()
                    UIApplication.shared.statusBarView?.backgroundColor = themeWakeUppColor
                    APP_DELEGATE.appNavigation?.backToViewController(viewController: StoriesVC.self)
                })
            }
        }
    }
    
    func call_keyCreateStory(_ imgs:String, _ durations:String , _ types : String, _ allowcopies:String)
    {
        hideHUD()
        showHUD()
        hudText = "Processing 95%"
        var strlist = ""
        if UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_Status) == "3"
        {
            strlist = UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_Status_Useridlist)
        }
        else if UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_Status) == "4"
        {
            strlist = UserDefaultManager.getStringFromUserDefaults(key: kOnlySharewith_Useridlist)
        }
        else
        {
            strlist = ""
        }
        let dic = [
            "images":imgs,
            "durations":durations,
            "types":types,
            "user_id": UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            "allowcopy":allowcopies,
            "storycaption":arrcomments.joined(separator: ","),
            "statusviewprivacy": UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_Status),
            "markedidlist":strlist
            ] as [String : Any]
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck(keyCreateStory,dic).timingOut(after: 30) {data in
            let data = data as Array
            if(data.count > 0)
            {
                if data[0] is String{
                    return
                }
                let dic = data[0] as! NSDictionary
                if dic.value(forKey: "success") as! String == "1"
                {
                    hudText = "Processing 100%"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        hideHUD()
                        postNotification(with: NC_MyStoryRefresh, andUserInfo:nil)
                        UIApplication.shared.statusBarView?.backgroundColor = themeWakeUppColor
                        APP_DELEGATE.appNavigation?.backToViewController(viewController: StoriesVC.self)
                    })
                }
                else
                {
                    hideHUD()
                    showMessage("Problem while creating story")
                }
            }
            else
            {
                hideHUD()
                hudText =  ""
            }
        }
    }
    func call_ScheduleCreateStory(_ imgs:String, _ durations:String , _ types : String, _ datechoose : String,_ allowcopies:String)
    {
        hideHUD()
        showHUD()
        hudText = "Processing 95%"
        var strlist = ""
        if UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_Status) == "3"
        {
            strlist = UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_Status_Useridlist)
        }
        else if UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_Status) == "4"
        {
            strlist = UserDefaultManager.getStringFromUserDefaults(key: kOnlySharewith_Useridlist)
        }
        else
        {
            strlist = ""
        }
        let dic = [
            "images":imgs,
            "durations":durations,
            "types":types,
            "datetime":datechoose,
            "user_id": UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            "allowcopy":allowcopies,
            "storycaption":arrcomments.joined(separator: ","),
            "statusviewprivacy": UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_Status),
            "markedidlist":strlist
            ] as [String : Any]
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck(keyScheduleCreateStory,dic).timingOut(after: 30) {data in
            let data = data as Array
            if(data.count > 0) {
                if data[0] is String{ return }
                
                let dic = data[0] as! NSDictionary
                if dic.value(forKey: "success") as! String == "1" {
                    hudText = "Processing 100%"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        hideHUD()
                        postNotification(with: NC_MyStoryRefresh, andUserInfo:nil)
                        UIApplication.shared.statusBarView?.backgroundColor = themeWakeUppColor
                        APP_DELEGATE.appNavigation?.backToViewController(viewController: StoriesVC.self)
                    })
                }
                else {
                    hideHUD()
                    showMessage("Problem while creating story")
                }
            }
            else {
                hideHUD()
                hudText =  ""
            }
        }
    }
}

