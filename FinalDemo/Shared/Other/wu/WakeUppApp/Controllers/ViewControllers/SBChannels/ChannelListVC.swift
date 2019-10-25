//
//  ChannelListVC.swift
//  WakeUppApp
//
//  Created by Payal Umraliya on 14/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import SwiftyJSON
//For Manage Play Video
import AVKit
import AVFoundation

class ChannelListVC: UIViewController, UITextFieldDelegate {
    
    //MARK:- Outlet
    @IBOutlet weak var storyDot: UIImageView!
    @IBOutlet weak var chatDot: UIImageView!
    
    @IBOutlet var imgshadow: UIImageView!
    @IBOutlet var tblchannel: UITableView!
    @IBOutlet var vwempty: UIView!
    @IBOutlet var btnmore: UIButton!
    @IBOutlet var vwchannel: UIView!
    @IBOutlet var collchannels: UICollectionView!
    
    //View Search
    @IBOutlet weak var btnSearch: UIButton!
    
    //MARK:- Variable
    var arrChannel = [MyChannel]() // For use store All Channel data, getting by WebService.
    var arrAllChannelVideo = [AllChannelVideo]() // For use store All channel Video data, getting by WebService.
    
    var selectedChannelVideo : IndexPath! // For user detect curret selected cell
    var selectedChannel : IndexPath! // For user detect curret selected channel cell
    
    var offset : Int = 0 // Manage LoadMore in AllChannelVideo List.
    
    //Fo use manage Refresh Tableview
    lazy var refreshControl_tableview: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(ChannelListVC.AllVideoListRefresh_Start(_:)), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.black
        
        return refreshControl
        //More Help : https://medium.com/anantha-krishnan-k-g/pull-to-refresh-how-to-implement-f915743703f8
    }()
    
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        self.layoutUI()
        
        
        
        self.get_APIAllChannelVideo_ResponseData_Stored_in_UserDefault()
        tblchannel.reloadData()
        
        self.api_MyAllChannelVideo()
        self.api_MyChannel()
        self.add_NotificationObserver()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setChatDot), name: NSNotification.Name(NC_ChatDotChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setStoryDot), name: NSNotification.Name(NC_StoryDotChanged), object: nil)
        
        setChatDot()
        setStoryDot()
    }
    
    @objc func setChatDot(){
        chatDot.isHidden = !APP_DELEGATE.chatDotVisible
    }
    
    @objc func setStoryDot(){
        storyDot.isHidden = !APP_DELEGATE.storyDotVisible
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    //MARK:- Custon Function
    func layoutUI() {
        self.tblchannel.delegate = self
        self.tblchannel.dataSource = self
        self.tblchannel.addSubview(self.refreshControl_tableview) // Added Refresh Loader in Tableview
        
        self.collchannels.dataSource = self
        self.collchannels.delegate = self
        
        //Default Hide ChannelView
        showHideChannel(ishide: true)
    }
    
    
    func add_NotificationObserver() {
        //Noti. Obs. Manage
        NotificationCenter.default.addObserver(self, selector: #selector(reload_MyChannelList), name: NSNotification.Name(rawValue: NC_AddChannelRefresh), object: nil) // Manage re-call get all channel list, if user add new channel
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload_MyChannelAllVideoList), name: NSNotification.Name(NC_AddChannelVideoRefresh), object: nil) // [1] Manage re-call get all channel video list, if user add new channel video | [2] Manage re-call get all channel video list, if user add new video comments.
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload_MyChannelAllVideoList), name: NSNotification.Name(NC_MySingalChannelVideoListActivityEffect), object: nil) // Manage ChannelProfile screen into List of channel video activity effect manage in this screen.
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload_ChannelSubscribrCount(notification:)), name: NSNotification.Name(NC_MyChannelSubscribeCountActon), object: nil) // Manage ChannelProfile screen into channel Subscrive-UnSubscribe activity effect manage in this screen.
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload_MyChannelAllVideoList), name: NSNotification.Name(NC_DeleteChannelVideoRefresh), object: nil) // Manage re-call get all channel video list, if user delete channel video.
        
        NotificationCenter.default.addObserver(self, selector: #selector(replace_MyChannelUpdate(notification:)), name: NSNotification.Name(NC_ChannelUpdateRefresh_AllChannelListVC), object: nil) // Manage updated channel data object replace.
    }
    
    func remove_NotificationObserver() {
        let arrNotiObs : NSMutableArray = []
        arrNotiObs.add(NC_AddChannelRefresh)
        arrNotiObs.add(NC_AddChannelVideoRefresh)
        arrNotiObs.add(NC_MySingalChannelVideoListActivityEffect)
        arrNotiObs.add(NC_MyChannelSubscribeCountActon)
        arrNotiObs.add(NC_DeleteChannelVideoRefresh)
        arrNotiObs.add(NC_ChannelUpdateRefresh_AllChannelListVC)
        
        for strNotiObs in arrNotiObs {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: strNotiObs as! String), object: nil)
        }
    }
    
    func showHideChannel(ishide:Bool) {
        self.vwchannel.isHidden = ishide
    }
    
    //MARK: Tableview Refresh Method
    @objc func AllVideoListRefresh_Start(_ refreshControl: UIRefreshControl) {
        offset = 0
        self.api_MyAllChannelVideo()
    }
    
    @objc func AllVideoListRefresh_Stop(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
    }
    
    //MARK:- Button Action Method
    //MARK: Tab Button
    @IBAction func btnchatclicked(_ sender: Any) {
        self.remove_NotificationObserver()
        
        let storyvc = loadVC(strStoryboardId: SB_CHAT, strVCId: "chatlistvc") as! ChatListVC
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
    }
    
    @IBAction func btnstoryclicked(_ sender: Any) {
        self.remove_NotificationObserver()
        
        let storyvc = loadVC(strStoryboardId: SB_STORIES, strVCId: idStoriesVC) as! StoriesVC
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
    }
    
    @IBAction func btnpostclicked(_ sender: Any) {
        self.remove_NotificationObserver()
        
        let storyvc = loadVC(strStoryboardId: SB_FEEDS, strVCId: idFeedVC) as! FeedVC
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
    }
    
    @IBAction func btnChannelClicked(_ sender: Any) {
        let storyvc = loadVC(strStoryboardId: SB_CHANNEL, strVCId: idChannelListVC) as! ChannelListVC
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
    }
    
    @IBAction func btnuserclicked(_ sender: Any) {
        self.remove_NotificationObserver()
        
        //        let storyvc = loadVC(strStoryboardId: SB_MAIN, strVCId: "ProfileVC") as! ProfileVC
        //        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
    }
    
    @IBAction func btnProfileAction() {
        self.remove_NotificationObserver()
        
        let storyvc = loadVC(strStoryboardId: SB_MAIN, strVCId: idProfileVC) as! ProfileVC
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
    }
    
    //MARK: Other Button
    @IBAction func btnNotificationAction() {
        self.view.endEditing(true) // Hide Keyboard
        
        let notiVC : ChannelNotificationVC = loadVC(strStoryboardId: SB_CHANNEL, strVCId: idChannelNotificationVC) as! ChannelNotificationVC
        APP_DELEGATE.appNavigation?.pushViewController(notiVC, animated: true)
    }
    
    @IBAction func btnSearchAction() {
        let objVC : ChannelSearchVC = loadVC(strStoryboardId: SB_CHANNEL, strVCId: idChannelSearchVC) as! ChannelSearchVC
        APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
    }
    
    @IBAction func btnmoreclicked(_ sender: Any) {
        showHideChannel(ishide: false)
    }
    
    @IBAction func btnDismiss_ChannelViewAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showHideChannel(ishide: true)
        }
    }
    
    //MARK: Notifi. Obs. Method
    @objc func reload_MyChannelList() {
        self.api_MyChannel()
    }
    
    @objc func reload_MyChannelAllVideoList() {
        offset = 0
        self.api_MyAllChannelVideo()
    }
    
    @objc func reload_ChannelSubscribrCount(notification: NSNotification) {
        //print("notification: %@",notification)
        //offset = 0
        //self.api_MyAllChannelVideo()
        
        
        //Get received obj.
        let objChannelDetails : GetSingleChannelDetails = notification.object as! GetSingleChannelDetails
        
        //Get Selected Obj. and Replace values of NoOfSubscriberCount
        //Replace Object in array list | 1st Remove obj after add object of it's index
        let SelectedObj : AllChannelVideo = self.arrAllChannelVideo[self.selectedChannelVideo.row]
        SelectedObj.subscribeCount = objChannelDetails.subscribeCount
        
        self.arrAllChannelVideo.remove(at: self.selectedChannelVideo.row)
        self.arrAllChannelVideo.insert(SelectedObj, at: self.selectedChannelVideo.row)
        
        //Reload Cell
        self.tblchannel.reloadRows(at: [self.selectedChannelVideo], with: .fade)
    }
    
    @objc func replace_MyChannelUpdate(notification: NSNotification) {
        // Comment this code B-Coz the problem of Updated obj replace in listing (All Channel Video listing AND User creaded channel Listing.)
        /*//print("notification: %@",notification)
         let objUpdateChannelData : MyChannel = notification.object as! MyChannel
         
         //Replace Object in MyChannel array list | 1st Remove obj after add object of it's index
         self.arrChannel.remove(at: self.selectedChannel.row)
         self.arrChannel.insert(objUpdateChannelData, at: self.selectedChannel.row)
         
         //Reload Cell
         self.collchannels.reloadItems(at: [self.selectedChannelVideo])
         //<----------------------------------------------------------------------
         */
        
        //Re-Called User created Channel List
        self.api_MyChannel()
        
        //Re-Called All Channel Video List
        offset = 0
        self.api_MyAllChannelVideo()
    }
    
    //MARK:- Scrollview Delegate method
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /*let yVelocity : CGFloat = scrollView.contentOffset.y
         if (yVelocity < 0) {
         //print("Up")
         } else if (yVelocity > 0) {
         //print("Down")
         } else {
         //print("Can't determine direction as velocity is 0")
         }*/
        
        if scrollView.contentOffset.y < 0 {
            //self.headerHeightConstraint.constant += abs(scrollView.contentOffset.y)
            
        }
    }
    
    //MARK:- API
    func api_MyChannel() {
        self.view.endEditing(true)
        let parameter:NSDictionary = ["service":APIMyChannel,
                                      "request":[:],
                                      "auth" : getAuthForService()]
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIMyChannel, parameters: parameter, keyname: kData as NSString, message: APIMyChannelMessage, showLoader: false, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_MyChannel()
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    if responseArray!.count > 0 {
                        self.arrChannel = responseArray as! [MyChannel]
                        self.collchannels.reloadData()
                    }
                    else {
                        //showMessage(statusmessage)
                    }
                }
            }
        })
    }
    
    func api_MyAllChannelVideo() {
        self.view.endEditing(true)
        
        let parameter:NSDictionary = ["service":APIAllChannelVideo,
                                      "request":["offset":offset],
                                      "auth" : getAuthForService()]
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIAllChannelVideo, parameters: parameter, keyname: kData as NSString, message: APIGetAllChannelVideoMessage, showLoader: false, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            //Hide Refresh Indicator
            self.AllVideoListRefresh_Stop(self.refreshControl_tableview)
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_MyChannel()
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
                            self.arrAllChannelVideo.removeAll()
                            self.arrAllChannelVideo = responseArray as! [AllChannelVideo]
                            
                            // Stored in User Default
                            self.set_APIAllChannelVideo_ResponseData_Stored_in_UserDefault(arrDate: responseArray!, dicData: responseDict!)
                            UserDefaultManager.setBooleanToUserDefaults(value: true, key: kIsPreviouslyCachedChannels)
                        }
                        else {
                            for obj in responseArray! {
                                self.arrAllChannelVideo.append(obj as! AllChannelVideo)
                            }
                        }
                        self.tblchannel.reloadData()
                        self.offset = self.offset + 1
                    }
                }
            }
        })
    }
    
    func get_APIAllChannelVideo_ResponseData_Stored_in_UserDefault() -> Void {
        
        let isPreviouslyCached = UserDefaultManager.getBooleanFromUserDefaults(key: kIsPreviouslyCachedChannels)
        if isPreviouslyCached == false {
            
        }
        else {
            let arr: NSArray = UserDefaultManager.getCustomObjFromUserDefaults(key: kAllChannelVideo) as! NSArray
            
            let arrData = NSMutableArray()
            for jsondata in arr {
                let j = JSON(jsondata)
                let objData:AllChannelVideo = AllChannelVideo.init(json: j)
                arrData.add(objData)
            }
            self.arrAllChannelVideo.removeAll()
            self.arrAllChannelVideo = arrData as! [AllChannelVideo]
        }
        
        //print("Total AllChannelVide : \(self.arrAllChannelVideo.count)")
        //print("AllChannelVide : \(self.arrAllChannelVideo)")
    }
    
    func set_APIAllChannelVideo_ResponseData_Stored_in_UserDefault(arrDate:NSArray, dicData:NSDictionary) -> Void {
        
        //Get Already Stored Data
        var storeData : NSArray = NSArray.init()
        if (UserDefaultManager.iskeyAlreadyExist(key: kAllChannelVideo) == true) {
            storeData = UserDefaultManager.getCustomObjFromUserDefaults(key: kAllChannelVideo) as! NSArray
        }
        
        if arrDate.count > 0 {
            if (storeData.count > 0) {
                UserDefaultManager.removeCustomObject(key: kAllChannelVideo)
            }
            let newKeyDic  = dicData[kData] as! NSDictionary
            let storeData = newKeyDic["video"] as! NSArray
            
            UserDefaultManager.setCustomObjToUserDefaults(CustomeObj: storeData, key: kAllChannelVideo)
            
            //print("Data Store in UserDefault Success")
        }
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
                    let objAllChannelVideo = self.arrAllChannelVideo[self.selectedChannelVideo.row]
                    objAllChannelVideo.viewCount = objAllChannelVideo.viewCount! + 1
                    
                    //Replace Object in array list | 1st Remove obj after add object of it's index
                    self.arrAllChannelVideo.remove(at: self.selectedChannelVideo.row)
                    self.arrAllChannelVideo.insert(objAllChannelVideo, at: self.selectedChannelVideo.row)
                    
                    //Reload Cell
                    self.tblchannel.reloadRows(at: [self.selectedChannelVideo], with: .fade)
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
                }
            }
        })
    }
}
extension ChannelListVC:UITableViewDelegate,UITableViewDataSource
{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let noOfRow: Int = arrAllChannelVideo.count
        tblchannel.isHidden = true
        if (noOfRow == 0) {
            //TableEmptyMessage(modulename: "Video", tbl: tblchannel)
        }
        else {
            //tableView.backgroundView = UIView.init()
            tblchannel.isHidden = false
        }
        return noOfRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelListCell") as! ChannelListCell
        
        let objAllChannelVideo = arrAllChannelVideo[indexPath.row]
        
        //Header--->
        cell.imgprofile.sd_setImage(with: URL.init(string: objAllChannelVideo.logo!), placeholderImage: ProfilePlaceholderImage)
        cell.lblchannelname.text = objAllChannelVideo.channelTitle
        
        //SubScribe
        let noOfSubScribe : Int = Int(objAllChannelVideo.subscribeCount!)!
        cell.lblsubscribe.text = suffixNumber(number: NSNumber(value: noOfSubScribe)) as String + " Subscribers"
        
        // Channel Info--->
        cell.btnChannel.tag = indexPath.row
        cell.btnChannel.addTarget(self, action: #selector(Manage_ChannelVideo_ChannelOption(sender:)), for: .touchUpInside)
        
        //Set Date
        let date : Date =  DateFormater.convertDateToLocalTimeZoneForDateFromString(givenDate: objAllChannelVideo.creationDatetime!) as Date
        cell.lblpostedtime.text = timeAgoSinceDate(date: date, numericDates: false)
        //MoreOption--->
        cell.btndomore.tag = indexPath.row
        cell.btndomore.addTarget(self, action: #selector(Manage_ChannelVideo_MoreOption(sender:)), for: .touchUpInside)
        
        //Channel ImageLoad--->
        cell.imgpostimage.sd_setImage(with: URL.init(string: objAllChannelVideo.thumImg!), placeholderImage: PlaceholderImage)
        cell.lbldescription.text = objAllChannelVideo.title
        
        //NoOfView
        let noOfTotalView : Int = objAllChannelVideo.viewCount!
        cell.lblNoOfView.text = suffixNumber(number: NSNumber(value: noOfTotalView)) as String
        cell.btntotalviewed.setTitle("", for: .normal)
        cell.btntotalviewed.tag = indexPath.row
        cell.btntotalviewed.addTarget(self, action: #selector(Manage_ChannelVideo_TotalView(sender:)), for: .touchUpInside)
        
        //Play Video--->
        cell.btnplay.tag = indexPath.row
        cell.btnplay.addTarget(self, action: #selector(Manage_ChannelVideo_Play(sender:)), for: .touchUpInside)
        
        //NoOfLike--->
        if (objAllChannelVideo.isLike == true) {
            cell.btnlikes.setImage(#imageLiteral(resourceName: "liked_icon.png"), for: .normal)
        }
        else {
            cell.btnlikes.setImage(#imageLiteral(resourceName: "like_icon.png"), for: .normal)
        }
        cell.btnlikes.tag = indexPath.row
        cell.btnlikes.addTarget(self, action: #selector(Manage_ChannelVideo_LikeUnlike(sender:)), for: .touchUpInside)
        
        let noOfLike : Int = objAllChannelVideo.likeCount!
        cell.lblNoOfLike.text = suffixNumber(number: NSNumber(value: noOfLike)) as String
        cell.btnNoOfLikes.setTitle("", for: .normal);
        cell.btnNoOfLikes.tag = indexPath.row
        cell.btnNoOfLikes.addTarget(self, action: #selector(Manage_ChannelVideo_NoOfLikeUnlike(sender:)), for: .touchUpInside)
        
        //Comment--->
        let noOfComment : Int = objAllChannelVideo.commentCount!
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
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 315
    }
    
    //Manage LoadMore
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == arrAllChannelVideo.count - 1) == true { 
            //offset = offset + 1 
            self.api_MyAllChannelVideo()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let vc = loadVC(strStoryboardId: SB_FEEDS, strVCId: idCommentsVC) as! CommentsVC
        //APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
    }
    
    //MARK: Tableview button action method
    @objc func Manage_ChannelVideo_ChannelOption(sender:UIButton!) {
        self.view.endEditing(true) // Hide Keyboard
        showHideChannel(ishide: true) //Hide View
        
        selectedChannelVideo = IndexPath.init(item: sender.tag, section: 0)
        let objSelectedChannelVideo = arrAllChannelVideo[selectedChannelVideo.row]
        
        //Move on Channel Profile Screen.
        let objChannelProVC : ChannelProfileVC = loadVC(strStoryboardId: SB_CHANNEL, strVCId: idChannelProfileVC) as! ChannelProfileVC
        objChannelProVC.strChannelID = objSelectedChannelVideo.channelId!
        APP_DELEGATE.appNavigation?.pushViewController(objChannelProVC, animated: true)
    }
    @objc func Manage_ChannelVideo_MoreOption(sender:UIButton!) {
        self.view.endEditing(true) // Hide Keyboard
        showHideChannel(ishide: true) //Hide View
        
        selectedChannelVideo = IndexPath.init(item: sender.tag, section: 0)
        let objSelectedChannelVideo = arrAllChannelVideo[selectedChannelVideo.row]
        
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //---------------------> Change Following ID
        let strChannelVideoByUserID : String = objSelectedChannelVideo.createdUserid!
        if (strChannelVideoByUserID.uppercased() == UserDefaultManager.getStringFromUserDefaults(key:kAppUserId).uppercased()) {
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
                                              "request":["spam_id":objSelectedChannelVideo.channelVideoId ,
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
        self.view.endEditing(true) // Hide Keyboard
        
        let alert = UIAlertController(title: APPNAME, message: "Are you sure you want to delete this post?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes, Delete Now", style: .destructive, handler: { (action: UIAlertAction!) in
            //showMessage("Work in Progress...")
            
            //Called Web API in BG
            let objSelectedChannelVideo = self.arrAllChannelVideo[self.selectedChannelVideo.row]
            let parameter:NSDictionary = ["service":APIDeleteChannelVideo,
                                          "request":["channel_video_id": objSelectedChannelVideo.channelVideoId],
                                          "auth" : getAuthForService()]
            self.api_DeleteChannelVideo(parameter: parameter)
            
            //Remove obj in Listing
            self.arrAllChannelVideo.remove(at: self.selectedChannelVideo.row) //Remove Object in array list
            self.tblchannel.deleteRows(at: [self.selectedChannelVideo], with: .left) //Remove Cell
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            //print("Dismiss Confirmation Alert")
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func Manage_ChannelVideo_TotalView(sender:UIButton!) {
        self.view.endEditing(true) // Hide Keyboard
        showHideChannel(ishide: true) //Hide View
        
        selectedChannelVideo = IndexPath.init(item: sender.tag, section: 0)
        let objSelectedChannelVideo = arrAllChannelVideo[selectedChannelVideo.row]
        let NoOfView : Int = objSelectedChannelVideo.viewCount!
        if (NoOfView == 0) {
            return
        }
        
        //let objPopupVC : ChannelPopupVC = loadVC(strStoryboardId: SB_CHANNEL, strVCId: idChannelPopupVC) as! ChannelPopupVC
        //objPopupVC.strSelectedChannelVideoID = objSelectedChannelVideo.channelVideoId!
        //objPopupVC.objEnumShowChannel = enumShowChannel.enumShowChannel_Views
        
        let objPopupVC : PopupVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idPopupVC) as! PopupVC
        objPopupVC.objEnumPopup = enumPopup.enumPopup_Views
        objPopupVC.strSelectedChannelVideoID = objSelectedChannelVideo.channelVideoId!
        
        objPopupVC.modalPresentationStyle = .overCurrentContext
        self.present(objPopupVC, animated: true, completion: nil)
    }
    
    @objc func Manage_ChannelVideo_Play(sender:UIButton!) {
        self.view.endEditing(true) // Hide Keyboard
        showHideChannel(ishide: true) //Hide View
        
        selectedChannelVideo = IndexPath.init(item: sender.tag, section: 0)
        let objSelectedChannelVideo = arrAllChannelVideo[selectedChannelVideo.row]
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
    
    @objc func Manage_ChannelVideo_Comment(sender:UIButton!) {
        self.view.endEditing(true) // Hide Keyboard
        showHideChannel(ishide: true) //Hide View
        
        selectedChannelVideo = IndexPath.init(item: sender.tag, section: 0)
        let objSelectedChannelVideo = arrAllChannelVideo[selectedChannelVideo.row]
        
        let objVC : ChannelCommentVC = loadVC(strStoryboardId: SB_CHANNEL, strVCId: idChannelCommentVC) as! ChannelCommentVC
        objVC.strChannelVideoID = objSelectedChannelVideo.channelVideoId!
        objVC.arrComments_ChannelVideo = objSelectedChannelVideo.commentData!
        APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
    }
    
    @objc func Manage_ChannelVideo_LikeUnlike(sender:UIButton!) {
        self.view.endEditing(true) // Hide Keyboard
        showHideChannel(ishide: true) //Hide View
        
        selectedChannelVideo = IndexPath.init(item: sender.tag, section: 0)
        let objAllChannelVideo = arrAllChannelVideo[selectedChannelVideo.row]
        
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
        self.arrAllChannelVideo.remove(at: self.selectedChannelVideo.row)
        self.arrAllChannelVideo.insert(objAllChannelVideo, at: self.selectedChannelVideo.row)
        
        //Reload Cell
        self.tblchannel.reloadRows(at: [self.selectedChannelVideo], with: .fade)
    }
    
    @objc func Manage_ChannelVideo_NoOfLikeUnlike(sender:UIButton!) {
        self.view.endEditing(true) // Hide Keyboard
        showHideChannel(ishide: true) //Hide View
        
        selectedChannelVideo = IndexPath.init(item: sender.tag, section: 0)
        let objSelectedChannelVideo = arrAllChannelVideo[selectedChannelVideo.row]
        let NoOfLike : Int = objSelectedChannelVideo.likeCount!
        if (NoOfLike == 0) {
            return
        }
        
        //let objPopupVC : ChannelPopupVC = loadVC(strStoryboardId: SB_CHANNEL, strVCId: idChannelPopupVC) as! ChannelPopupVC
        //objPopupVC.strSelectedChannelVideoID = objSelectedChannelVideo.channelVideoId!
        //objPopupVC.objEnumShowChannel = enumShowChannel.enumShowChannel_Likes
        
        let objPopupVC : PopupVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idPopupVC) as! PopupVC
        objPopupVC.objEnumPopup = enumPopup.enumPopup_Likes
        objPopupVC.strSelectedChannelVideoID = objSelectedChannelVideo.channelVideoId!
        
        objPopupVC.modalPresentationStyle = .overCurrentContext
        self.present(objPopupVC, animated: true, completion: nil)
    }
    
    @objc func Manage_ChannelVideo_Share(sender:UIButton!) {
        self.view.endEditing(true) // Hide Keyboard
        showHideChannel(ishide: true) //Hide View
        
        selectedChannelVideo = IndexPath.init(item: sender.tag, section: 0)
        let objSelectedChannelVideo = arrAllChannelVideo[selectedChannelVideo.row]
        
        //Share Message
        var mess = ""
        mess += objSelectedChannelVideo.video! + "\n"
        mess += "'" + objSelectedChannelVideo.title! + "'"
        mess += " Video by Channel:"
        mess += objSelectedChannelVideo.channelTitle!
        mess += "(@" + objSelectedChannelVideo.username! + ")"
        
        share(shareContent: [mess])
    }
}

extension ChannelListVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        else {
            return arrChannel.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllChannelCell", for: indexPath as IndexPath)
        let imgView = cell.viewWithTag(88) as! UIImageView
        let lblnm = cell.viewWithTag(99) as! UILabel
        if indexPath.section == 0 {
            if indexPath.item == 0 {
                imgView.image = #imageLiteral(resourceName: "float_create_channel")
                lblnm.text = "Create New Channel"
            }
            else {
                imgView.image = #imageLiteral(resourceName: "float_addnewvideo")
                lblnm.text = "Add New Video"
            }
        }
        else {
            let objChannel = arrChannel[indexPath.row]
            
            lblnm.text = objChannel.title
            //lblnm.text = objChannel.id! + "\n" + objChannel.title!
            
            let imgURL:String = objChannel.logo!
            imgView.sd_setImage(with: URL(string: imgURL), placeholderImage: #imageLiteral(resourceName: "channel_placeholder"))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view.endEditing(true) // Hide Keyboard
        
        if indexPath.section == 0 {
            if indexPath.item == 0 {
                let createvc = loadVC(strStoryboardId: SB_CHANNEL, strVCId: idCreateChannelVC)
                APP_DELEGATE.appNavigation?.pushViewController(createvc, animated: true)
            }
            else {
                let createvc : CreateVideoVC = loadVC(strStoryboardId: SB_CHANNEL, strVCId: idCreateVideoVC) as! CreateVideoVC
                createvc.arrChannel = self.arrChannel
                APP_DELEGATE.appNavigation?.pushViewController(createvc, animated: true)
            }
        }
        else {
            self.selectedChannel = indexPath
            let objChannel = arrChannel[indexPath.row]
            
            let objChannelProVC : ChannelProfileVC = loadVC(strStoryboardId: SB_CHANNEL, strVCId: idChannelProfileVC) as! ChannelProfileVC
            objChannelProVC.strChannelID = objChannel.id!
            APP_DELEGATE.appNavigation?.pushViewController(objChannelProVC, animated: true)
        }
        //Hide View
        showHideChannel(ishide: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: SCREENWIDTH() / 3
            , height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

