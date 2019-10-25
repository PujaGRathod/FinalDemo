//
//  StoryCell.swift
//  WakeUppApp
//
//  Created by Admin on 06/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import AVFoundation

import Alamofire

protocol StoryCellDelegate:class {
    func btnMenuClicked(_ sender:UIButton)
    func btncameraclicked(_ sender: UIButton)
    func btngalleryclicked(_ sender: UIButton)
    func showImagePicker(_ sender: UIButton)
    func btnDeleteStoreClicked(_ sender:UIButton) //PV
}

class StoryCell: UICollectionViewCell {
    
    @IBOutlet var btnProfile: UIButton!
    @IBOutlet var btnMenu: UIButton!
    @IBOutlet var btnPrev: UIButton!
    @IBOutlet var btnNext: UIButton!
    @IBOutlet var btnSeen: UIButton!
    @IBOutlet var btnDelete: UIButton!
    
    @IBOutlet weak var vwstoymediachoose: UIView!
    @IBOutlet weak var vwprofilesection: UIView!
    @IBOutlet var activityiIndicator: UIActivityIndicatorView!
    @IBOutlet var vwLoader: RPCircularProgress!
    @IBOutlet var lblProgress: UILabel!
    
    @IBOutlet var imgShadow: UIImageView!
    @IBOutlet var imgBottomShadow: UIImageView!
    
    @IBOutlet var lblTime: UILabel!
    @IBOutlet var lblName: UILabel!
    
    @IBOutlet var vwMine: UIView!
    
    @IBOutlet var inputValues: Inputbar!
    
    @IBOutlet weak var progressBarContainer: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imgAndVideoContainer: UIView!
    @IBOutlet weak var videoContainer: UIView!
    @IBOutlet weak var imgvideothumb: UIImageView!
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var lblcaption: UILabel!
    var spb : SegmentedProgressBar!
    var avPlayer : AVPlayer!
    var clickedattach = false
    var currentStories : StoryListModel!{
        didSet{
            perform(#selector(setupSegmentedProgressBar), with: nil, afterDelay: 0.1)
        }
    }
    var isMine : Bool!
    var isViewTapped : Bool!
    let cardView = Bundle.main.loadNibNamed("StoryViewerView", owner: nil, options: nil)?.first as? StoryViewerView
    
    var currentStoryIndex = 0
    var selectedIndex = 0
    weak var storyCellDelegate: StoryCellDelegate?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        scrollView.bouncesZoom = false
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 6.0
        scrollView.delegate = self
        //self.txtreply.addPaddingLeft(10)
        imgBottomShadow.rotate(byAngle: 180, ofType: .degrees)
        cardView?.tag = 5000
        let aSelector : Selector = #selector(removeSubview)
        let tapGesture = UITapGestureRecognizer(target:self, action: aSelector)
        cardView?.addGestureRecognizer(tapGesture)
        self.setInputbar()
        self.vwstoymediachoose.isHidden = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(vwattachtapped(_:)))
        self.vwstoymediachoose.isUserInteractionEnabled = true
        self.vwstoymediachoose.addGestureRecognizer(tapGestureRecognizer)
        lblcaption.frame = CGRect.init(x: 10, y: self.vwMine.frame.origin.y - 30, width: SCREENWIDTH() - 10, height: 20)
        NotificationCenter.default.addObserver(self, selector: #selector(setViewerCountInButton), name: NSNotification.Name(rawValue: NC_ViewerRefresh), object: nil)
        
        //PU // Date : 01-08-2018 03:33pm
        avPlayer = nil
    }
    
    func removeSPBDelegate()
    {
        if spb != nil{
            spb.delegate = nil
        }
    }
    
    func stopVideo(){
        pausePlayer()
    }
    
    @objc func setupSegmentedProgressBar()
    {
        _ = progressBarContainer.subviews.map { $0.removeFromSuperview() }
        
        let white = UIColor.white
        let transWhite = white.withAlphaComponent(0.5)
        let frame = CGRect(origin: CGPoint(x: 0, y: 0), size: progressBarContainer.bounds.size)
        
        spb = SegmentedProgressBar.init(numberOfSegments: (currentStories.arrStories.count), durations: currentStories.arrStories.map{$0.duration.double()!})
        spb.frame = frame
        spb.topColor = white
        spb.bottomColor = transWhite
        spb.padding = 2
        spb.delegate = self
        progressBarContainer.addSubview(spb)
        spb.autoresizingMask = [.flexibleWidth];
        progressBarContainer.autoresizesSubviews = true
        spb.startSetupAnimation()
        
        setStoryForCurrentIndex()
        
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressedView))
        longPress.minimumPressDuration = 0.2
        addGestureRecognizer(longPress)
        if isViewTapped == true
        {
            self.btnSeenClicked(self.btnSeen)
        }
        if isMine == true
        {
            for (index, _) in currentStories.arrStories.enumerated()
            {
                if index < selectedIndex {
                    self.inputValues.inputResignFirstResponder()
                    vwLoader.isHidden = true
                    pausePlayer()
                    spb.skip()
                }
                else
                {
                    break
                }
            }
        }
    }
    
    func setStoryForCurrentIndex()
    {
        if avPlayer != nil {
            avPlayer.seek(to: CMTime.init(value: 0, timescale: 1))
            avPlayer.pause()
        }
        
        inputValues.textView.text = ""
        inputValues.inputResignFirstResponder()
        
        if currentStoryIndex < currentStories.arrStories.count
        {
            if isFileLocallySaved(fileUrl: currentStories.arrStories[currentStoryIndex].mediaURL.toUrl!) == false{
                spb.isPaused = true
            }
            else{
                spb.isPaused = false
            }
            /*var strDate = currentStories.arrStories[currentStoryIndex].createdDate
            print(strDate)
            strDate = strDate.replacingOccurrences(of: "T", with: " ").components(separatedBy: ".").first!
            let thenDate = DateFormater.getDateFromString(givenDate:strDate ) as Date
            let hr = thenDate.hours(from: Date())
            if (hr > 0)
            {
                let dt = DateFormater.generateDateWithFormat2FromGivenDatestring(strDate: strDate)
                lblTime.text = "\(dt)"
            }
            else
            {
                lblTime.text = timeAgoSinceStrDate(strDate: currentStories.arrStories[currentStoryIndex].createdDate, numericDates: true).capitalized
            }*/
            var strDate = currentStories.arrStories[currentStoryIndex].createdDate
            let storyDate:NSDate = DateFormater.convertDateToLocalTimeZoneForDateFromString(givenDate: strDate)
            let currentDate:NSDate =  NSDate()
            if storyDate as Date == currentDate as Date
            {
                lblTime.text = "Just Now"
            }
            else if storyDate as Date > currentDate as Date
            {
                lblTime.text = timeAgoSinceStrDate1(strDate: DateFormater.convertDateToLocalTimeZone(givenDate: DateFormater.getStringFromDate(givenDate: storyDate, toFormate: GLOBAL_APP_DATE_FORMAT), fromFormat: GLOBAL_APP_DATE_FORMAT, toFormat: GLOBAL_DATE_FORMAT), numericDates: true, isFutur: true)
            }
            else
            {
                lblTime.text = timeAgoSinceStrDate1(strDate: DateFormater.convertDateToLocalTimeZone(givenDate: DateFormater.getStringFromDate(givenDate: storyDate, toFormate: GLOBAL_APP_DATE_FORMAT), fromFormat: GLOBAL_APP_DATE_FORMAT, toFormat: GLOBAL_DATE_FORMAT), numericDates: true, isFutur: false)
            }
        }
        
       
        
//        lblName.text = currentStories.userName
        
        if isMine == true
        {
            lblName.text = "You"
//            btnProfile.sd_setImage(with: currentStories.arrStories[currentStoryIndex].profileURL.toUrl!, for: .normal, completed: nil)
        }
        else
        {
            let objContactInfo : StructDeviceContactInfo = ContactSync.shared.isUserInContacts(countryCode: currentStories.arrStories[currentStoryIndex].countrycode, phoneNo: currentStories.arrStories[currentStoryIndex].phoneno)
            if objContactInfo.Name?.count == 0
            {
                let st1 = "+" + (currentStories.arrStories[currentStoryIndex].countrycode + " " + currentStories.arrStories[currentStoryIndex].phoneno)
                lblName.text = st1.replacingOccurrences(of: "++", with: "+")
            }
            else
            {
                
                lblName.text = objContactInfo.Name!
            }
             btnProfile.sd_setImage(with: currentStories.profileURL.toUrl, for: .normal, completed: nil)
        }
        lblcaption.text = currentStories.arrStories[currentStoryIndex].caption.base64Decoded
        if lblcaption.text == nil
        {
            lblcaption.text  = ""
        }
        if lblcaption.text!.count > 0
        {
            lblcaption.isHidden = false
            lblcaption.numberOfLines = 30
            lblcaption.sizeToFit()
            lblcaption.textAlignment = .center
            lblcaption.frame = CGRect.init(x: 10, y: (self.vwMine.frame.origin.y - lblcaption.frame.size.height - 10), width: SCREENWIDTH() - 20, height: lblcaption.frame.size.height + 10)
        }
        else
        {
            lblcaption.isHidden = true
        }
        imgView.sd_setShowActivityIndicatorView(true)
        
        if isMine == true
        {
            setViewerCountInButton()
            vwMine.isHidden = false
            inputValues.isHidden = true
            btnMenu.isHidden = false
            
            
        }
        else {
            vwMine.isHidden = true
            inputValues.isHidden = false
            let str = CoreDBManager.sharedDatabase.checkCopyStatus(currentStories.arrStories[currentStoryIndex].storyID)
            if str == "1"
            {
                btnMenu.isHidden = true
            }
            else
            {
                btnMenu.isHidden = false
            }
        }
        
        
        
        if(currentStories.arrStories[currentStoryIndex].storyType == "1")
        {
            vwLoader.isHidden = true
            videoContainer.isHidden = true
            imgView.isHidden = false
            self.spb.isPaused = true
            
            self.imgView.sd_setShowActivityIndicatorView(true)
            self.imgView.sd_setIndicatorStyle(.gray)
            
            //addBlurAboveImage(self.imgView, 0.0)
            removeBlurAboveImage(self.imgView)
            
            if isFileLocallySaved(fileUrl: currentStories.arrStories[currentStoryIndex].mediaURL.toUrl!)
            {
                let image = UIImage.init(contentsOfFile: (getLocallySavedFileURL(with: URL.init(string: self.currentStories.arrStories[currentStoryIndex].mediaURL)!)?.path)!)
                self.imgView.image = image
                self.imgView.sd_setShowActivityIndicatorView(false)
                self.spb.animateSegment(animationIndex: currentStoryIndex)
            }
            else
            {
                //addBlurAboveImage(self.imgView, 0.9)
                self.imgView.sd_setImage(with: self.currentStories.arrStories[currentStoryIndex].mediaURL.toUrl, placeholderImage: #imageLiteral(resourceName: "story_phh"), options: .continueInBackground, completed: { (img, error, cachType, url) in
                    //DispatchQueue.main.async
                    //{
                    //addBlurAboveImage(self.imgView, 0.0)
                    //}
                    self.imgView.image = img
                    self.imgView.sd_setShowActivityIndicatorView(false)
                    self.spb.animateSegment(animationIndex: self.currentStoryIndex)
                })
            }
        }
        else
        {
            imgView.isHidden = true
            videoContainer.isHidden = false
            videoContainer.layer.sublayers?.removeAll()
            videoContainer.backgroundColor = UIColor.clear
            imgView.image = UIImage()
            vwLoader.isHidden = true
            addBlurAboveImage(self.imgvideothumb, 0.9)
            if isFileLocallySaved(fileUrl: currentStories.arrStories[currentStoryIndex].mediaURL.toUrl!)
            {
                addBlurAboveImage(self.imgvideothumb, 0.0)
                videoContainer.backgroundColor = UIColor.black
                self.imgvideothumb.isHidden = true
                self.playvideo(currentStoryIndex)
            }
            else
            {
                self.spb.isPaused = true
                vwLoader.isHidden = false
                
                self.imgvideothumb.isHidden = false
                let nm = currentStories.arrStories[currentStoryIndex].mediaURL.toUrl?.lastPathComponent
                let strnm = nm?.components(separatedBy: ".")
                let imgnmurl = "\(Get_Status_URL + "/" + strnm![0])_thumb.jpg"
                self.imgvideothumb.image = UIImage()
                self.imgvideothumb.sd_setShowActivityIndicatorView(true)
                self.imgvideothumb.sd_setImage(with: imgnmurl.toUrl, placeholderImage: SquarePlaceHolderImage, options: .continueInBackground, completed: { (img, error, cachType, url) in
                    self.imgvideothumb.image = img
                    self.imgvideothumb.sd_setShowActivityIndicatorView(false)
                })
                // self.imgvideothumb.contentMode = .scaleAspectFit //PV
                
                self.downloadStory(story: currentStories.arrStories[currentStoryIndex], loaddone: { (isdone,storyID) in
                    
                    if isdone{
                        addBlurAboveImage(self.imgvideothumb, 0.0)
                        if self.currentStories.arrStories[self.currentStoryIndex].storyID == storyID {
                            self.playvideo(self.currentStoryIndex)
                            self.videoContainer.backgroundColor = UIColor.black
                        }
                    }else{
                        showStatusBarMessage("Could not load stroy.")
                        self.spb.skip()
                    }
                })
            }
        }
        if self.currentStories.userID != UserDefaultManager.getStringFromUserDefaults(key: kAppUserId) {
            setViewedStory(ForStoryID: currentStories.arrStories[self.currentStoryIndex].storyID, ofUserID: currentStories.arrStories[self.currentStoryIndex].userID)
        }
    }
    
    @objc func setViewerCountInButton(){
        if isMine == true {
            let viewerCount = CoreDBManager.sharedDatabase.getViewers(ForMyStoryID: currentStories.arrStories[currentStoryIndex].storyID).count
            self.btnSeen.setTitle("\(viewerCount)", for: .normal)
        }
    }
    
    func playvideo(_ index:Int) {
        //self.spb.isPaused = true
        vwLoader.isHidden = true
        var avPlayerItem:AVPlayerItem! = nil
        var avPlayerLayer:AVPlayerLayer!
        let videoURL = getLocallySavedFileURL(with: currentStories.arrStories[currentStoryIndex].mediaURL.toUrl!)!
        let avAsset = AVAsset.init(url: videoURL)
        avPlayerItem = AVPlayerItem.init(asset: avAsset)
        avPlayer = AVPlayer.init(playerItem: avPlayerItem)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        videoContainer.layer.addSublayer(avPlayerLayer)
        avPlayerLayer.frame = self.videoContainer.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        self.resumePlayer()
        self.spb.animateSegment(animationIndex: index)
        self.imgView.isHidden = true
    }
    
    //MARK:- BUTTON CLICKS
    @IBAction func btnMenuClicked(_ sender:UIButton)
    {
        sender.accessibilityLabel =  self.currentStories.arrStories[currentStoryIndex].storyID
        storyCellDelegate?.btnMenuClicked(sender)
    }
    
    @IBAction func btnProfileClicked(_ sender:UIButton){
        
    }
    
    @IBAction func btnPreviousClicked(_ sender:UIButton){
        self.inputValues.inputResignFirstResponder()
        vwLoader.isHidden = true
        pausePlayer()
        spb.rewind()
    }
    
    @IBAction func btnNextClicked(_ sender:UIButton){
        self.inputValues.inputResignFirstResponder()
        vwLoader.isHidden = true
        pausePlayer()
        spb.skip()
    }
    
    @IBAction func btncameraclicked(_ sender: UIButton)
    {
        sender.tag = currentStoryIndex
        let model = currentStories.arrStories[currentStoryIndex]
        sender.accessibilityValue = "\(model.storyID)\(kStoryMessageSeparator)\(model.mediaURL)\(kStoryMessageSeparator)\(model.createdDate)\(kStoryMessageSeparator)\(model.duration)\(kStoryMessageSeparator)"
        sender.accessibilityLabel =  self.currentStories.arrStories[currentStoryIndex].userID
        storyCellDelegate?.btncameraclicked(sender)
    }
    @IBAction func btngalleryclicked(_ sender: UIButton)
    {
        sender.tag = currentStoryIndex
        let model = currentStories.arrStories[currentStoryIndex]
        sender.accessibilityValue = "\(model.storyID)\(kStoryMessageSeparator)\(model.mediaURL)\(kStoryMessageSeparator)\(model.createdDate)\(kStoryMessageSeparator)\(model.duration)\(kStoryMessageSeparator)"
        sender.accessibilityLabel =  self.currentStories.arrStories[currentStoryIndex].userID
        storyCellDelegate?.btngalleryclicked(sender)
    }
    @objc private func longPressedView(_ sender: UILongPressGestureRecognizer){
        if sender.state == .began{
            spb.isPaused = true
            pausePlayer()
            setVisibilityOnLongPress(0)
        }
        else if( sender.state == .ended){
            spb.isPaused = false
            resumePlayer()
            setVisibilityOnLongPress(1)
        }
    }
    
    func setVisibilityOnLongPress(_ boolval:Int)
    {
        if boolval == 1
        {
            self.vwprofilesection.isHidden = false
            if isMine == true
            {
                vwMine.isHidden = false
                inputValues.isHidden = true
                btnMenu.isHidden = false
            }
            else {
                vwMine.isHidden = true
                inputValues.isHidden = false
                let str = CoreDBManager.sharedDatabase.checkCopyStatus(currentStories.arrStories[currentStoryIndex].storyID)
                if str == "1"
                {
                    btnMenu.isHidden = true
                }
                else
                {
                    btnMenu.isHidden = false
                }
            }
        }
        else
        {
            self.vwMine.isHidden = true
            self.inputValues.isHidden = true
            self.vwprofilesection.isHidden = true
            btnMenu.isHidden = true
        }
        
    }
    @IBAction func btnSeenClicked(_ sender:UIButton)
    {
        spb.isPaused = true
        pausePlayer()
        cardView?.accessibilityLabel = self.currentStories.arrStories[currentStoryIndex].storyID
        cardView?.storyID = self.currentStories.arrStories[currentStoryIndex].storyID
        //cardView?.dicviewer = dicviewer
        cardView?.frame = self.frame
        self.contentView.addSubview(cardView!)
        cardView?.reloadTable()
    }
    
    @IBAction func btnDeleteClicked(_ sender: UIButton) {
        if (isMine == true) {
            sender.accessibilityLabel =  self.currentStories.arrStories[currentStoryIndex].storyID
            //storyCellDelegate?.btnMenuClicked(sender)            
            storyCellDelegate?.btnDeleteStoreClicked(sender)
        }
    }
    
    @objc func removeSubview() {
        //print("Start remove sibview")
        if let viewWithTag = self.viewWithTag(5000)
        {
            spb.isPaused = false
            resumePlayer()
            viewWithTag.removeFromSuperview()
        }
        else{
            //print("No!")
        }
    }
    func downloadStory(story:StructStatusStory,loaddone:@escaping (Bool,String)->())
    {
        vwLoader.updateProgress(0.0, initialDelay: 0.6, duration: 4)
        lblProgress.text = ""
        
        let storyURL = story.mediaURL
        if isFileLocallySaved(fileUrl: storyURL.toUrl!) == false
        {
            if isConnectedToNetwork()
            {
                APP_DELEGATE.cancelAllDownloadRequest()
                let req = HttpRequestManager.sharedInstance.alamoFireManager.download(storyURL, to: DownloadRequest.suggestedDownloadDestination())
                APP_DELEGATE.arrRequests.add(req)
                req.downloadProgress { progress in
                    if story.storyID == self.currentStories.arrStories[self.currentStoryIndex].storyID {
                        //print("Progress if - \(CGFloat(progress.fractionCompleted))")
                        self.lblProgress.text = "\(Int(floor(progress.fractionCompleted * 100)))%"
                        self.vwLoader.updateProgress(CGFloat(progress.fractionCompleted))
                    }
                    else {
                        //print("Progress else - \(CGFloat(progress.fractionCompleted))")
                    }
                }
                req.responseData { (response) in
                    if let error = response.error{
                        //print("Error: \(error.localizedDescription)")
                        loaddone(false,story.storyID)
                    }else{
                        loaddone(true,story.storyID)
                    }
                    APP_DELEGATE.arrRequests.remove(req)
                }
            }else{
                loaddone(false,story.storyID)
            }
        }
        else
        {
            loaddone(true,story.storyID)
        }
    }
    
}

extension StoryCell
{
    @objc func pausePlayer(){
        if avPlayer != nil {
            avPlayer.pause()
        }
    }
    @objc func resumePlayer(){
        if avPlayer != nil {
            avPlayer.play()
        }
    }
}

extension StoryCell : SegmentedProgressBarDelegate
{
    func segmentedProgressBarChangedIndex(index: Int){
        //print("segmentedProgressBarChangedIndex:\(index)")
        if currentStoryIndex == index{
            //print("Now Go Back To Previous")
            postNotification(with: NC_GoBackStory)
        }
        currentStoryIndex = index
        setStoryForCurrentIndex()
    }
    
    func segmentedProgressBarFinished(){
        //POST NOTIFICATION THAT CURRENT USER'S STORIES HAVE BEEN FINISHED
        currentStoryIndex = 0
        //print("segmentedProgressBarFinished")
        postNotification(with: NC_UnableScroll)
        postNotification(with: NC_UserStoryFinished)
    }
}

extension StoryCell : UIScrollViewDelegate
{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if(currentStories.arrStories[currentStoryIndex].storyType == "1"){
            return imgView
        }else{
            return videoContainer
        }
    }
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        //PAUSE SEGMENTED PROGRESS BECAUSE USER ZOOMED ON AN IMAGE
        if(currentStories.arrStories[currentStoryIndex].storyType == "1") {spb.isPaused = true}
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if(scale == 1){
            //RESUME SEGMENTED ANIMATION BECAUSE USER ZOOMED OUT COMPLETELY
            if(currentStories.arrStories[currentStoryIndex].storyType == "1") {spb.isPaused = false}
        }
    }
}

extension StoryCell
{
    func setInputbar()
    {
        self.inputValues.placeholder = "Write a reply..."
        self.inputValues.inputDelegate = self
        self.inputValues.rightButtonImage =  #imageLiteral(resourceName: "send_btn")
        self.inputValues.leftButtonImage = UIImage(named:"add_media")
        self.removeKeyboardControl()
        self.managekeyboard()
    }
}

extension StoryCell:InputbarDelegate
{
    func inputbarDidPressRightButton(inputbar:Inputbar)
    {
        
        let textMessage = inputbar.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let model = currentStories.arrStories[currentStoryIndex]
        let strMessage = "\(model.storyID)\(kStoryMessageSeparator)\(model.mediaURL)\(kStoryMessageSeparator)\(model.createdDate)\(kStoryMessageSeparator)\(model.duration)\(kStoryMessageSeparator)\(textMessage)"
        
        
        let dic = [
            "senderid":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            "receiverid":currentStories.userID,
            "textmessage": strMessage.base64Encoded ?? "",
            "messagetype": "3",
            "mediaurl": "",
            "platform":PlatformName,
            "createddate": "",
            "isdeleted":"0",
            "isread":"0",
            "username" : UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
            "mutestatus" : CoreDBManager.sharedDatabase.amIMutedByUser(receiverId: currentStories.userID) ? "1" : "0",
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
                
                self.inputResignFirstResponder()
            }
        }
        
    }
    func inputbarDidPressLeft2Button(inputbar: Inputbar) {
        //emoji button
    }
    func inputbarDidPressLeftButton(inputbar:Inputbar)
    {
        self.inputValues.inputResignFirstResponder()
        if self.clickedattach == false
        {
            self.vwstoymediachoose.isHidden = false
            self.clickedattach = true
        }
        else
        {
            self.vwstoymediachoose.isHidden = true
            self.clickedattach = false
        }
        spb.isPaused = true
        pausePlayer()
    }
    
    func inputbarDidBecomeFirstResponder(inputbar:Inputbar)
    {
        postNotification(with: NC_DisableScroll)
        spb.isPaused = true
        pausePlayer()
    }
    func inputbarDidChangeHeight(newHeight:CGFloat)
    {
        self.keyboardTriggerOffset = newHeight
    }
    
    func inputResignFirstResponder()
    {
        inputValues.endEditing(true)
        spb.isPaused = false
        resumePlayer()
        spb.skip()
    }
    
    func managekeyboard()
    {
        self.keyboardTriggerOffset = self.inputValues.frame.size.height
        self.addKeyboardNonpanning() {[unowned self](keyboardFrameInView:CGRect, opening:Bool, closing:Bool) in
            var toolBarFrame = self.inputValues.frame
            
            //var tableViewFrame = self.tblcomment.frame
            if UIScreen.main.bounds.height >= 812
            {
                //tableViewFrame.size.height = toolBarFrame.origin.y - 95
                if #available(iOS 11.0, *)
                {
                    if keyboardFrameInView.origin.y == SCREENHEIGHT()
                    {
                        toolBarFrame.origin.y = keyboardFrameInView.origin.y  - toolBarFrame.size.height -  (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)! - 30
                    }
                    else
                    {
                        toolBarFrame.origin.y = keyboardFrameInView.origin.y  - toolBarFrame.size.height - 30
                    }
                }
                else
                {
                    toolBarFrame.origin.y = keyboardFrameInView.origin.y  - toolBarFrame.size.height - 30
                }
                self.inputValues.frame = toolBarFrame
            }
            else
            {
                toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height - 30
                self.inputValues.frame = toolBarFrame
            }
            if keyboardFrameInView.origin.y == SCREENHEIGHT()
            {
                self.inputValues.inputResignFirstResponder()
            }
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
        self.addGestureRecognizer(tap)
        
    }
    @objc func tableTapped(tap:UITapGestureRecognizer)
    {
        self.inputValues.inputResignFirstResponder()
    }
    
    
    @objc func vwattachtapped(_ sender:UITapGestureRecognizer)
    {
        self.vwstoymediachoose.isHidden = true
        self.clickedattach = false
        spb.isPaused = false
        resumePlayer()
    }
    func setViewedStory(ForStoryID storyID:String, ofUserID userID:String)
    {
        //print("READ STORY ID :\(storyID)")
        let msgDictionary = [
            "user_id":userID,
            "statusids":storyID,
            "viewer_id":UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            "viewer_name":UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName),
            "view_date":DateFormater.getFullDateStringFromDate(givenDate: Date() as NSDate),
            "viewer_pic":UserDefaultManager.getStringFromUserDefaults(key: kAppUserProfile)
        ]
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck(keyUpdateReadStatusStory,msgDictionary).timingOut(after: 60)
        {data in
            print(data)
            //SET THIS STORIE'S IsViewedByMe = 1 IN COREDB
            CoreDBManager.sharedDatabase.setStoryIsViewedByMe(ForStoryID: storyID)
            //CoreDBManager.sharedDatabase.udpateViewerList(uid: uid1, sid: sid1, vid: UserDefaultManager.getStringFromUserDefaults(key: kAppUserId), prof: UserDefaultManager.getStringFromUserDefaults(key: kAppUserProfile), nm: UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName), tm: DateFormater.getStringFromDate(givenDate: Date() as NSDate))
        }
    }
}
