//
//  ChannelProfileVC.swift
//  WakeUppApp
//
//  Created by Payal Umraliya on 16/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

//import  SimpleImageViewer //Show image in full screen.

//For Manage Play Video
import AVKit
import AVFoundation

class ChannelProfileVC: UIViewController {
    
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet var tblprofile: UITableView!
    @IBOutlet weak var heightHeaderView: NSLayoutConstraint!
    @IBOutlet weak var rightPadding: NSLayoutConstraint!
    @IBOutlet weak var leftPadding: NSLayoutConstraint!
    
    @IBOutlet weak var viewChannelInfo: UIView!
    @IBOutlet weak var imgBanner: UIImageView!
    
    @IBOutlet weak var viewSubscribers: UIView!
    @IBOutlet weak var lblSubscribers: UILabel!
    
    @IBOutlet weak var viewVideos: UIView!
    @IBOutlet weak var lblVideos: UILabel!
    
    @IBOutlet weak var btnSubscribe: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var lblChannelName: UILabel!
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    //MARK:- Variable
    var strChannelID : String = "" //For use getting curret channel ID in Privious VC screen.
    var objChannelDetails : GetSingleChannelDetails!  // For use stored channel detailss getting by API response.
    
    var arrSingalChannelVideoData = [GetSingleChannelVideo]() // For use store All Channel data, getting by WebService.
    var selectedChannelVideo : IndexPath! // For user detect curret selected cell
    var offset : Int = 0 // Manage LoadMore in ChannelVideo List.
    
    var flag_ChannelSubscribeStatus : Bool = false //For help getting curret channel subscribe Status
    var strChannelCreate_ByUserID : String = "" //For help manage channel Subscribe and Edit action using ChennelCreateUserID
    
    var imgEditChannel : UIImage = #imageLiteral(resourceName: "edit_profile_btn")
    var imgSubscribeChannel_Yes : UIImage = #imageLiteral(resourceName: "subscribed_check")
    var imgSubscribeChannel_No : UIImage = #imageLiteral(resourceName: "subscribe_add")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.layoutUI() //Manage UI Design
        self.fillValues() //Fill Default Values
        self.api_GetSingleChannelDetails(strChannelID: strChannelID) //Getting Channel Details
        
        //Notification Obs.
        NotificationCenter.default.addObserver(self, selector: #selector(reload_MySingalChannellVideoList), name: NSNotification.Name(NC_MySingalChannelVideoList), object: nil) // Manage User Add-OR-remove comment in particuler video , so manage total count comment and get all comment data.
        NotificationCenter.default.addObserver(self, selector: #selector(replace_MyChannelUpdate(notification:)), name: NSNotification.Name(NC_ChannelUpdateRefresh_ChannelProfileVC), object: nil) // Manage updated channel data object replace.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Custon Function
    func layoutUI() -> Void {
        //TableEmptyMessage(modulename: "Video", tbl: tblprofile)
        self.tblprofile.delegate = self
        self.tblprofile.dataSource = self
        self.tblprofile.bounces = true
        self.tblprofile.alwaysBounceVertical = false
        
        viewSubscribers.roundCorners([.topRight,.bottomRight], radius: 20.0)
        viewVideos.roundCorners([.topLeft,.bottomLeft], radius: 20.0)
    }
    
    func remove_NotificationObserver() {
        let arrNotiObs : NSMutableArray = []
        arrNotiObs.add(NC_MySingalChannelVideoList)
        arrNotiObs.add(NC_ChannelUpdateRefresh_ChannelProfileVC)
        
        for strNotiObs in arrNotiObs {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: strNotiObs as! String), object: nil)
        }
    }
    
    func fillValues() -> Void {
        var strlTitle : String = "---"
        var strBanner : String = ""
        var strSubscribers : String = "0"
        var strVideos : String = "0"
        var strLogo : String = ""
        var strUserName : String = "---"
        var strDescription : String = "---"
        
        if (objChannelDetails != nil) {
            strlTitle = self.objChannelDetails.title!
            strBanner = self.objChannelDetails.coverImg!
            strSubscribers = self.objChannelDetails.subscribeCount!
            strVideos = self.objChannelDetails.videoCount!
            strLogo = self.objChannelDetails.logo!
            strUserName = self.objChannelDetails.username!
            strDescription = self.objChannelDetails.descriptionValue!
            
            strChannelCreate_ByUserID = self.objChannelDetails.userId!
            flag_ChannelSubscribeStatus = self.objChannelDetails.isSubscribe! //-----> Set the Subscribe status value
        }
        
        //Title
        btnBack.setTitle(strlTitle, for: .normal)
        
        //Banner
        imgBanner.sd_setImage(with: URL(string: strBanner), placeholderImage: #imageLiteral(resourceName: "wall"))
        
        lblSubscribers.text = strSubscribers
        lblVideos.text = strVideos
        
        //Logo
        imgLogo.sd_setImage(with: URL(string: strLogo), placeholderImage: #imageLiteral(resourceName: "channel_placeholder"))
        
        lblChannelName.text = strlTitle
        lblUserName.text = strUserName //(strUserName).isEmpty ? "---" : strUserName
        lblDescription.text = strDescription
        lblDescription.numberOfLines = 0
        
        //Set Edit-OR-Subscribe button
        if (strChannelCreate_ByUserID.uppercased() == UserDefaultManager.getStringFromUserDefaults(key:kAppUserId).uppercased()) {
            btnSubscribe.setImage(imgEditChannel, for: .normal)
        }
        else {
            self.setChannel_SubscribButton_on(SubscribeStatus: flag_ChannelSubscribeStatus)
        }
        
        //Called API in Get particuler Channel Video's.
        self.api_GetChannelVideo(strChannelID: strChannelID)
    }
    
    func setChannel_SubscribButton_on(SubscribeStatus : Bool) -> Void {
        if (SubscribeStatus == true) {
            btnSubscribe.setImage(imgSubscribeChannel_Yes, for: .normal)
        }
        else {
            btnSubscribe.setImage(imgSubscribeChannel_No, for: .normal)
        }
    }
    
    func manange_and_Move_EditChannel() -> Void {
        //Move on CreateChannelVC Screen
        let objVC : CreateChannelVC = loadVC(strStoryboardId: SB_CHANNEL, strVCId: idCreateChannelVC) as! CreateChannelVC
        
        objVC.objEnumChannel = enumChannel.enumChannel_Update
        objVC.strChannelID = strChannelID
        objVC.strURL_BannerImg = self.objChannelDetails.coverImg!
        objVC.strURL_Logo = self.objChannelDetails.logo!
        objVC.strChannelName = self.objChannelDetails.title!
        objVC.strChannelDescription = self.objChannelDetails.descriptionValue!
        
        APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
    }
    
    //MARK:-  Notifi. Obs. Method
    @objc func reload_MySingalChannellVideoList() {
        offset = 0
        self.api_GetChannelVideo(strChannelID: strChannelID)
    }
    
    @objc func replace_MyChannelUpdate(notification: NSNotification) {
        //print("notification: %@",notification)
        
        //Fill Updated Chanel Details
        let objUpdateChannelData : GetSingleChannelDetails = notification.object as! GetSingleChannelDetails
        self.objChannelDetails = objUpdateChannelData
        self.fillValues()
        
        //Re-Called Channel App Video
        offset = 0
        self.api_GetChannelVideo(strChannelID: strChannelID)
    }
    
    //MARK:- Button Action
    @IBAction func btnBackAction() {
        self.remove_NotificationObserver()
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnSubscribeAction() {
        //Check ChannelID nil or not
        if (strChannelID.count == 0) {
            showMessage(SomethingWrongMessage)
            return
        }
        
        //Manage Channel Edit activity action.
        if (strChannelCreate_ByUserID.uppercased() == UserDefaultManager.getStringFromUserDefaults(key:kAppUserId).uppercased()) {
            
            self.manange_and_Move_EditChannel()
            return
        }
        
        //Manage Channel Subscribe activity action perform.
        // NOTE :
        // set action - subscribe/unsubscribe | base on API no.-42
        var strChannelSubscribeFlag : NSString = "unsubscribe"
        if (flag_ChannelSubscribeStatus == true) {
            strChannelSubscribeFlag = "subscribe"
        }
        
        //Set parameter for Called WebService
        let parameter:NSDictionary = ["service":APIAddChannelSubscribe,
                                      "request":["channel_id": strChannelID,
                                        "action": strChannelSubscribeFlag],
                                      "auth" : getAuthForService()]
        self.api_ChannelSubscribe(parameter: parameter)
    }
    
    @IBAction func btnShareAction() {
        if (strChannelID.count == 0) {
            showMessage(SomethingWrongMessage)
            return
        }
        
        var strlTitle : String = "---"
        var strLogo : String = ""
        var strUserName : String = "---"
        var strDescription : String = "---"
        if (objChannelDetails != nil) {
            strlTitle = self.objChannelDetails.title!
            strLogo = self.objChannelDetails.logo!
            strUserName = self.objChannelDetails.username!
            strDescription = self.objChannelDetails.descriptionValue!
        }
        
        //Share message
        var mess = ""
        mess += strLogo + "\n"
        mess += "View Channel '" + strlTitle + "'"
        mess += " by: (@" + strUserName + ")\n"
        mess += "About Channel: " + strDescription
        
        share(shareContent: [mess])
    }
    
    @IBAction func btnSubscribersListAction() {
        if (objChannelDetails == nil) { return }
        
        let NoOfSubscribe : Int = Int(objChannelDetails.subscribeCount!)!
        if (NoOfSubscribe == 0) { return }
        
        //let objPopupVC : ChannelPopupVC = loadVC(strStoryboardId: SB_CHANNEL, strVCId: idChannelPopupVC) as! ChannelPopupVC
        //objPopupVC.strChannelID = objChannelDetails.id!
        //objPopupVC.objEnumShowChannel = enumShowChannel.enumShowChannel_Subscribe
        
        if objChannelDetails.userId! == UserDefaultManager.getStringFromUserDefaults(key: kAppUserId){
            
            let objPopupVC : PopupVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idPopupVC) as! PopupVC
            objPopupVC.objEnumPopup = .enumPopup_Subscribe
            objPopupVC.strChannelID = objChannelDetails.id!
            
            objPopupVC.modalPresentationStyle = .overCurrentContext
            self.present(objPopupVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnShowPhoto_ChannelBannerAction() {
        let configuration = ImageViewerConfiguration { config in
            config.imageView = imgBanner //as? UIImageView
        }
        let imageViewerController = ImageViewerController(configuration: configuration)
        APP_DELEGATE.appNavigation?.present(imageViewerController, animated: false, completion: nil)
    }
    
    @IBAction func btnShowChannelPhotoAction() {
        let configuration = ImageViewerConfiguration { config in
            config.imageView = imgLogo //as? UIImageView
        }
        let imageViewerController = ImageViewerController(configuration: configuration)
        APP_DELEGATE.appNavigation?.present(imageViewerController, animated: false, completion: nil)
    }
    
    //MARK:- API
    func api_GetSingleChannelDetails(strChannelID : String) {
        self.view.endEditing(true)
        let parameter:NSDictionary = ["service":APIGetSingalChannelDetails,
                                      "request":["channel_id":strChannelID],
                                      "auth" : getAuthForService()]
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIGetSingalChannelDetails, parameters: parameter, keyname: "", message: "", showLoader: false, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_GetSingleChannelDetails(strChannelID: strChannelID)
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    let strMessage: String = responseDict!.object(forKey: kMessage) as! String
                    if let dicChannelData : NSDictionary = responseDict?.value(forKey: kData) as? NSDictionary
                    {
                        if (dicChannelData.allKeys.count == 0) {
                            showMessage(strMessage)
                        }
                        else {
                            self.objChannelDetails = GetSingleChannelDetails.init(object: dicChannelData)
                            self.fillValues()
                        }
                    }
                    else {
                        showMessage(strMessage)
                    }
                }
            }
        })
    }
    
    func api_GetChannelVideo(strChannelID : String) {
        self.view.endEditing(true)
        let parameter:NSDictionary = ["service":APIGetSingalChannelVideo,
                                      "request":["channel_id":strChannelID,
                                                 "offset":offset],
                                      "auth" : getAuthForService()]
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIGetSingalChannelVideo, parameters: parameter, keyname: kData as NSString, message: APIGetSingalChannelVideoMessage, showLoader: false, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_GetChannelVideo(strChannelID: strChannelID)
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    if (self.offset == 0) {
                        showMessage(statusmessage)
                    }
                }
                else {
                    if responseArray!.count > 0 {
                        if (self.offset == 0) {
                            self.arrSingalChannelVideoData = responseArray as! [GetSingleChannelVideo]
                        }
                        else {
                            for obj in responseArray! {
                                self.arrSingalChannelVideoData.append(obj as! GetSingleChannelVideo)
                            }
                        }
                        self.tblprofile.reloadData()
                    }
                }
            }
        })
    }
    
    func api_ChannelSubscribe(parameter : NSDictionary) {
        self.view.endEditing(true)
        self.view.isUserInteractionEnabled = false
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIAddChannelSubscribe, parameters: parameter, keyname: "", message: "", showLoader: true, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            self.view.isUserInteractionEnabled = true
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_ChannelSubscribe(parameter: parameter)
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    var noOfSubScrive : Int = 0 //Manage NoOfSubscribe count
                    noOfSubScrive = Int(self.lblSubscribers.text!)! //Get Curret Channel SubScribe Count
                    
                    //Change Image
                    if (self.flag_ChannelSubscribeStatus == true) {
                        self.setChannel_SubscribButton_on(SubscribeStatus: false)
                        self.flag_ChannelSubscribeStatus = false
                        
                        noOfSubScrive = noOfSubScrive - 1
                    }
                    else {
                        self.setChannel_SubscribButton_on(SubscribeStatus: true)
                        self.flag_ChannelSubscribeStatus = true
                        
                        noOfSubScrive = noOfSubScrive + 1
                    }
                    
                    self.lblSubscribers.text = "\(noOfSubScrive)" //Change Values in NoOfSubScrive Count Show Label.
                    
                    //Change Value in Object
                    self.objChannelDetails.subscribeCount = "\(noOfSubScrive)"
                    
                    //Called Notif.Obs. for show Channel Subscrive Count in Privious VC
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NC_MyChannelSubscribeCountActon), object: self.objChannelDetails, userInfo: nil)
                    
                    //Show Success message
                    let strMessage: String = responseDict!.object(forKey: kMessage) as! String
                    showMessage(strMessage)
                }
            }
        })
    }
    
    func api_ViewChannelVideo(parameter : NSDictionary) {
        self.view.endEditing(true)
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIViewChannelVideo, parameters: parameter, keyname: "", message: "", showLoader: false, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_ViewChannelVideo(parameter: parameter)
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
                    
                    //Selected Object value Change [Incrise View Counter] ---->
                    let objAllChannelVideo = self.arrSingalChannelVideoData[self.selectedChannelVideo.row]
                    objAllChannelVideo.viewCount = objAllChannelVideo.viewCount! + 1
                    
                    //Replace Object in array list | 1st Remove obj after add object of it's index
                    self.arrSingalChannelVideoData.remove(at: self.selectedChannelVideo.row)
                    self.arrSingalChannelVideoData.insert(objAllChannelVideo, at: self.selectedChannelVideo.row)
                    
                    //Reload Cell
                    self.tblprofile.reloadRows(at: [self.selectedChannelVideo], with: .fade)
                    
                    //Called Notif.Obs. for show ChannelVideo ViewCounter in Privious VC
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NC_MySingalChannelVideoListActivityEffect), object: nil, userInfo: nil) // ChannelListVC
                }
            }
        })
    }
    
    func api_AddLikeDislikeChannelVideo(parameter : NSDictionary) {
        self.view.endEditing(true)
        self.view.isUserInteractionEnabled = false
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIAddChannelLike, parameters: parameter, keyname: "", message: "", showLoader: false, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            self.view.isUserInteractionEnabled = true
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_AddLikeDislikeChannelVideo(parameter: parameter)
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
                }
            }
        })
    }
    
    func api_DeleteChannelVideo(parameter : NSDictionary) {
        self.view.endEditing(true)
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIDeleteChannelVideo, parameters: parameter, keyname: "", message: "", showLoader: false, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_DeleteChannelVideo(parameter: parameter)
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    let strMessage: String = responseDict!.object(forKey: kMessage) as! String
                    showMessage(strMessage)
                    
                    //Called Notif.Obs. for delete Channel Video after re-called API of get all channel list in Privious VC
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NC_DeleteChannelVideoRefresh), object: nil, userInfo: nil)
                }
            }
        })
    }
}

extension ChannelProfileVC:UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSingalChannelVideoData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelListCell") as! ChannelListCell
        
        let objChannelVideo = arrSingalChannelVideoData[indexPath.row]
        
        cell.imgprofile.sd_setImage(with: URL.init(string: objChannelVideo.logo!), placeholderImage: ProfilePlaceholderImage)
        cell.lblchannelname.text = objChannelVideo.channelTitle
        //Set Date
        let date : Date =  DateFormater.convertDateToLocalTimeZoneForDateFromString(givenDate: objChannelVideo.creationDatetime!) as Date
        cell.lblpostedtime.text = timeAgoSinceDate(date: date, numericDates: false)
        
        //MoreOption--->
        cell.btndomore.tag = indexPath.row
        cell.btndomore.addTarget(self, action: #selector(Manage_ChannelVideo_MoreOption(sender:)), for: .touchUpInside)
        
        //Channel ImageLoad--->
        cell.imgpostimage.sd_setImage(with: URL.init(string: objChannelVideo.thumImg!), placeholderImage: PlaceholderImage)
        cell.lbldescription.text = objChannelVideo.title
        
        //NoOfView
        let noOfTotalView : Int = objChannelVideo.viewCount!
        cell.lblNoOfView.text = suffixNumber(number: NSNumber(value: noOfTotalView)) as String
        cell.btntotalviewed.setTitle("", for: .normal)
        cell.btntotalviewed.tag = indexPath.row
        cell.btntotalviewed.addTarget(self, action: #selector(Manage_ChannelVideo_TotalView(sender:)), for: .touchUpInside)
        
        //Play Video--->
        cell.btnplay.tag = indexPath.row
        cell.btnplay.addTarget(self, action: #selector(Manage_ChannelVideo_Play(sender:)), for: .touchUpInside)
        
        //NoOfLive--->
        let noOfLike : Int = objChannelVideo.likeCount!
        //cell.btnlikes.setTitle(suffixNumber(number: NSNumber(value: noOfLike)) as String, for: .normal);
        if (objChannelVideo.isLike == true) {
            cell.btnlikes.setImage(#imageLiteral(resourceName: "liked_icon.png"), for: .normal)
        }
        else {
            cell.btnlikes.setImage(#imageLiteral(resourceName: "like_icon.png"), for: .normal)
        }
        cell.btnlikes.tag = indexPath.row
        cell.btnlikes.addTarget(self, action: #selector(Manage_ChannelVideo_LikeUnlike(sender:)), for: .touchUpInside)
        
        cell.lblNoOfLike.text = suffixNumber(number: NSNumber(value: noOfLike)) as String
        cell.btnNoOfLikes.setTitle("", for: .normal);
        cell.btnNoOfLikes.tag = indexPath.row
        cell.btnNoOfLikes.addTarget(self, action: #selector(Manage_ChannelVideo_NoOfLikeUnlike(sender:)), for: .touchUpInside)
        
        
        //Comment--->
        let noOfComment : Int = objChannelVideo.commentCount!
        var strNoOfComment : String = ""
        if (noOfComment == 0) {
            strNoOfComment = "Add Comment"
        }
        else {
            strNoOfComment = "View all \(suffixNumber(number: NSNumber(value: noOfComment)) as String) comments"
        }
        cell.btncomments.setTitle(strNoOfComment, for: .normal);
        cell.btncomments.tag = indexPath.row
        cell.btncomments.addTarget(self, action: #selector(Manage_ChannelVideo_Comment(sender:)), for: .touchUpInside)
        
        //Share--->
        cell.btnshare.tag = indexPath.row
        cell.btnshare.addTarget(self, action: #selector(Manage_ChannelVideo_Share(sender:)), for: .touchUpInside)
        
        //Manage LoadMore
        if (indexPath.row == arrSingalChannelVideoData.count - 1) {
            //offset = offset + 1
            //self.api_GetChannelVideo(strChannelID: strChannelID)
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 315
    }
    
    //Manage LoadMore
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = arrSingalChannelVideoData.count - 1
        if indexPath.row == lastElement {
            
            if (self.objChannelDetails != nil) {
                let totalVideoOfChannel = Int(self.objChannelDetails.videoCount!)!
                if (arrSingalChannelVideoData.count != totalVideoOfChannel) {
                    offset = offset + 1
                    self.api_GetChannelVideo(strChannelID: strChannelID)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let vc = loadVC(strStoryboardId: SB_FEEDS, strVCId: idCommentsVC) as! CommentsVC
        //APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
    }
    
    //MARK: Tableview button action method
    @objc func Manage_ChannelVideo_MoreOption(sender:UIButton!) {
        selectedChannelVideo = IndexPath.init(item: sender.tag, section: 0)
        let objSelectedChannelVideo = arrSingalChannelVideoData[selectedChannelVideo.row]
        
        //Get CreatedVideoPostID------------>
        var strChannelVideo_ByUserID : String = "0"
        strChannelVideo_ByUserID = objSelectedChannelVideo.createdUserid!
        
        //Manage ActionSheet------------>
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        if (strChannelVideo_ByUserID.uppercased() == UserDefaultManager.getStringFromUserDefaults(key:kAppUserId).uppercased()) {
            //Delete Post
            let actionReport = UIAlertAction.init(title: "Delete post", style: .destructive) { (action) in
                self.Confirmation_DeletePostVideo()
            }
            alert.addAction(actionReport)
        }
        else {
            //Report the Post
            let actionReport = UIAlertAction.init(title: kReport_Spam_ChannelVideo, style: .destructive) { (action) in
                let parameter:NSDictionary = ["service":APIReportSpam,
                                              "request":["spam_id":objSelectedChannelVideo.channelVideoId,
                                                         "action":"channelVideo"],
                                              "auth" : getAuthForService()]
                  APP_DELEGATE.api_SpamReport(parameter: parameter, successMess: "Reported successfully")
            }
            alert.addAction(actionReport)
        }
        
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionCancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func Confirmation_DeletePostVideo() -> Void {
        let alert = UIAlertController(title: APPNAME, message: "Are you sure you want to delete this post?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes, Delete Now", style: .destructive, handler: { (action: UIAlertAction!) in
            //showMessage("Work in Progress...")
            
            //Called Web API in BG
            let objSelectedChannelVideo : GetSingleChannelVideo = self.arrSingalChannelVideoData[self.selectedChannelVideo.row]
            let parameter:NSDictionary = ["service":APIDeleteChannelVideo,
                                          "request":["channel_video_id": objSelectedChannelVideo.channelVideoId],
                                          "auth" : getAuthForService()]
            self.api_DeleteChannelVideo(parameter: parameter)
            
            //Remove obj in Listing
            self.arrSingalChannelVideoData.remove(at: self.selectedChannelVideo.row) //Remove Object in array list
            self.tblprofile.deleteRows(at: [self.selectedChannelVideo], with: .left) //Remove Cell
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            //print("Dismiss Confirmation Alert")
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func Manage_ChannelVideo_Play(sender:UIButton!) {
        selectedChannelVideo = IndexPath.init(item: sender.tag, section: 0)
        let objSelectedChannelVideo = arrSingalChannelVideoData[selectedChannelVideo.row]
        let videoURL : URL = URL.init(string: objSelectedChannelVideo.video!)!
        
        // Play Video in Full Screen
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        present(playerViewController, animated: true) {
            playerViewController.player!.play()
            
            //Set parameter for Called WebService
            let parameter:NSDictionary = ["service":APIViewChannelVideo,
                                          "request":["channel_video_id": objSelectedChannelVideo.channelVideoId],
                                          "auth" : getAuthForService()]
            self.api_ViewChannelVideo(parameter: parameter)
        }
    }
    
    @objc func Manage_ChannelVideo_TotalView(sender:UIButton!) {
        selectedChannelVideo = IndexPath.init(item: sender.tag, section: 0)
        let objSelectedChannelVideo = arrSingalChannelVideoData[selectedChannelVideo.row]
        let NoOfView : Int = objSelectedChannelVideo.viewCount!
        if (NoOfView == 0) {
            return
        }
        
        //let objPopupVC : ChannelPopupVC = loadVC(strStoryboardId: SB_CHANNEL, strVCId: idChannelPopupVC) as! ChannelPopupVC
        //objPopupVC.strSelectedChannelVideoID = objSelectedChannelVideo.channelVideoId!
        //objPopupVC.objEnumShowChannel = enumShowChannel.enumShowChannel_Views
        
        let objPopupVC : PopupVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idPopupVC) as! PopupVC
        objPopupVC.objEnumPopup = .enumPopup_Views
        objPopupVC.strSelectedChannelVideoID = objSelectedChannelVideo.channelVideoId!
        
        objPopupVC.modalPresentationStyle = .overCurrentContext
        self.present(objPopupVC, animated: true, completion: nil)
    }
    
    @objc func Manage_ChannelVideo_Comment(sender:UIButton!) {
        selectedChannelVideo = IndexPath.init(item: sender.tag, section: 0)
        let objSelectedChannelVideo = arrSingalChannelVideoData[selectedChannelVideo.row]
        
        let objVC : ChannelCommentVC = loadVC(strStoryboardId: SB_CHANNEL, strVCId: idChannelCommentVC) as! ChannelCommentVC
        objVC.strChannelVideoID = objSelectedChannelVideo.channelVideoId!
        objVC.arrComments_ChannelVideo = objSelectedChannelVideo.commentData!
        APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
    }
    
    @objc func Manage_ChannelVideo_LikeUnlike(sender:UIButton!) {
        selectedChannelVideo = IndexPath.init(item: sender.tag, section: 0)
        let objAllChannelVideo = arrSingalChannelVideoData[selectedChannelVideo.row]
        
        let status : Bool = objAllChannelVideo.isLike!
        var statusValue : String = ""
        if (status == true) {
            statusValue = "dislike"
        }
        else {
            statusValue = "like"
        }
        
        //Set parameter for Called WebService
        let parameter:NSDictionary = ["service":APIAddChannelLike,
                                      "request":["channel_video_id": objAllChannelVideo.channelVideoId,
                                                 "action": statusValue],
                                      "auth" : getAuthForService()]
        self.api_AddLikeDislikeChannelVideo(parameter: parameter)
        
        //Selected Object value Change ---->
        if (status == true) {
            objAllChannelVideo.isLike = false
            objAllChannelVideo.likeCount = objAllChannelVideo.likeCount! - 1
        }
        else {
            objAllChannelVideo.isLike = true
            objAllChannelVideo.likeCount = objAllChannelVideo.likeCount! + 1
        }
        //Replace Object in array list | 1st Remove obj after add object of it's index
        self.arrSingalChannelVideoData.remove(at: self.selectedChannelVideo.row)
        self.arrSingalChannelVideoData.insert(objAllChannelVideo, at: self.selectedChannelVideo.row)
        
        //Reload Cell
        self.tblprofile.reloadRows(at: [self.selectedChannelVideo], with: .fade)
        
        //Called Notif.Obs. for show ChannelVideo NoOfLike in Privious VC
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NC_MySingalChannelVideoListActivityEffect), object: nil, userInfo: nil) // ChannelListVC
    }
    
    @objc func Manage_ChannelVideo_NoOfLikeUnlike(sender:UIButton!) {
        selectedChannelVideo = IndexPath.init(item: sender.tag, section: 0)
        let objSelectedChannelVideo = arrSingalChannelVideoData[selectedChannelVideo.row]
        let NoOfLike : Int = objSelectedChannelVideo.likeCount!
        if (NoOfLike == 0) { return }
        
        //let objPopupVC : ChannelPopupVC = loadVC(strStoryboardId: SB_CHANNEL, strVCId: idChannelPopupVC) as! ChannelPopupVC
        //objPopupVC.strSelectedChannelVideoID = objSelectedChannelVideo.channelVideoId!
        //objPopupVC.objEnumShowChannel = enumShowChannel.enumShowChannel_Likes
        
        let objPopupVC : PopupVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idPopupVC) as! PopupVC
        objPopupVC.objEnumPopup = .enumPopup_Likes
        objPopupVC.strSelectedChannelVideoID = objSelectedChannelVideo.channelVideoId!
        
        objPopupVC.modalPresentationStyle = .overCurrentContext
        self.present(objPopupVC, animated: true, completion: nil)
    }
    
    @objc func Manage_ChannelVideo_Share(sender:UIButton!) {
        selectedChannelVideo = IndexPath.init(item: sender.tag, section: 0)
        let objSelectedChannelVideo = arrSingalChannelVideoData[selectedChannelVideo.row]
        
        //Share message
        var mess = ""
        mess += objSelectedChannelVideo.video! + "\n"
        mess += "'" + objSelectedChannelVideo.title! + "'"
        mess += " Video by Channel:"
        mess += objSelectedChannelVideo.channelTitle!
        mess += "(@" + objSelectedChannelVideo.username! + ")"
        
        share(shareContent: [mess])
    }
    
    //MARK: Scrollview Delegate method
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y < 0) {
            leftPadding.constant = scrollView.contentOffset.y
            rightPadding.constant = scrollView.contentOffset.y
            heightHeaderView.constant = 125 + abs(scrollView.contentOffset.y)
        }
        else {
            leftPadding.constant = 0
            rightPadding.constant = 0
            heightHeaderView.constant = 125
        }
        self.view.layoutIfNeeded()
    }
}

