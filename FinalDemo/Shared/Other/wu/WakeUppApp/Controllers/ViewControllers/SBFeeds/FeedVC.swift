//
//  FeedVC.swift
//  WakeUppApp
//
//  Created by Admin on 01/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import SwiftyJSON

class FeedVC: UIViewController {
    
    //MARK:- Outlet
    @IBOutlet var btnAddPost: UIButton!
    @IBOutlet var tblFeed: UITableView!
    @IBOutlet var vwtabbar: UIView!
    @IBOutlet var vwnodata: UIView!
    @IBOutlet var vwnavbar: UIView!
    
    @IBOutlet weak var chatDot: UIImageView!
    @IBOutlet weak var storyDot: UIImageView!
    
    //MARK:- Variable
    var arrFeeds = [Feeds]()
    var arrFeeds_SeeMore : NSMutableArray = NSMutableArray.init() //Manage Feed Show More
    var offset = 0
    
    var selectedPost : IndexPath! // For user detect curret selected Post cell
    //Fo use manage Refresh Tableview
    lazy var refreshControl_tableview: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(FeedVC.AllPostListRefresh_Start(_:)), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.black
        
        return refreshControl
        //More Help : https://medium.com/anantha-krishnan-k-g/pull-to-refresh-how-to-implement-f915743703f8
    }()
    
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let isPreviouslyCached = UserDefaultManager.getBooleanFromUserDefaults(key: kPreviouslyCachedFeeds)
        if isPreviouslyCached == false{
            
        }
        else {
            let arr:NSArray = UserDefaultManager.getCustomObjFromUserDefaults(key: kCachedFeeds) as! NSArray
            for dic in arr{
                //print(dic)
                let feed = Feeds.init(json: JSON(dic))
                arrFeeds.append(feed)
            }
            
            let arrSeeMoreFlag : NSMutableArray = NSMutableArray.init()
            for _ in arrFeeds { arrSeeMoreFlag.add("0") }
            self.arrFeeds_SeeMore = arrSeeMoreFlag
        }
        
        layoutUI()
        self.add_NotificationObserver()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Custon Function
    func layoutUI() {
        self.tblFeed.delegate = self
        self.tblFeed.dataSource = self
        self.tblFeed.reloadData()
        
        //self.tblFeed.rowHeight = UITableViewAutomaticDimension
        //self.tblFeed.estimatedRowHeight = 375
        self.tblFeed.addSubview(self.refreshControl_tableview) // Added Refresh Loader in Tableview
        
        //Called API
        self.api_GetPost()
    }
    //MARK: Tableview Refresh Method
    @objc func AllPostListRefresh_Start(_ refreshControl: UIRefreshControl) {
        offset = 0
        self.api_GetPost()
    }
    @objc func AllPostListRefresh_Stop(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
    }
    
    //MARK:- Notifi. Obs. Manage
    func add_NotificationObserver() {
        //Noti. Obs. Manage
        NotificationCenter.default.addObserver(self, selector: #selector(reload_FeedPostList), name: NSNotification.Name(rawValue: NC_AddPostCommentRefresh), object: nil) // Manage re-call get all channel list, if user add new Comment
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload_FeedPostList), name: NSNotification.Name(rawValue: NC_RemovePostCommentRefresh), object: nil) // Manage re-call get all channel list, if user remove comment
        
        NotificationCenter.default.addObserver(self, selector: #selector(setChatDot), name: NSNotification.Name(NC_ChatDotChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setStoryDot), name: NSNotification.Name(NC_StoryDotChanged), object: nil)
        
        setChatDot()
        setStoryDot()
    }
    
    func remove_NotificationObserver() {
        let arrNotiObs : NSMutableArray = []
        arrNotiObs.add(NC_AddPostCommentRefresh)
        arrNotiObs.add(NC_RemovePostCommentRefresh)
        
        for strNotiObs in arrNotiObs {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: strNotiObs as! String), object: nil)
        }
    }
    
    @objc func setChatDot(){
        chatDot.isHidden = !APP_DELEGATE.chatDotVisible
    }
    
    @objc func setStoryDot(){
        storyDot.isHidden = !APP_DELEGATE.storyDotVisible
    }
    
    //MARK: Notifi. Obs. Method
    @objc func reload_FeedPostList() {
        self.arrFeeds.removeAll()
        offset = 0
        self.api_GetPost()
    }
    
    //MARK:- Button action method
    //MARK: Navitaton button action
    @IBAction func btnaddeditpostclicked(_ sender: Any) {
        self.remove_NotificationObserver()
        
        /*let storyvc = loadVC(strStoryboardId: SB_FEEDS, strVCId: idGalleryVC) as! GalleryVC
         APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: true)*/
        
        let assetPicker = loadVC(strStoryboardId: SB_ASSET_PICKER, strVCId: idAssetPickerVC) as! AssetPickerVC
        assetPicker.delegate = self
        assetPicker.shouldFilterAssets = true
        APP_DELEGATE.appNavigation?.pushViewController(assetPicker, animated: true)
    }
    
    @IBAction func btnchatclicked(_ sender: Any) {
        self.remove_NotificationObserver()
        
        let storyvc = loadVC(strStoryboardId: SB_CHAT, strVCId: "chatlistvc") as! ChatListVC
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
    }
    
    @IBAction func btnstoryclicked(_ sender: Any) {
        self.remove_NotificationObserver()
        
        /*let storyvc = loadVC(strStoryboardId: SB_STORIES, strVCId: "storylistvc") as! StoryListVC
         APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)*/
        
        let storyvc = loadVC(strStoryboardId: SB_STORIES, strVCId: idStoriesVC)
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
    }
    
    @IBAction func btnpostclicked(_ sender: Any) {
        self.remove_NotificationObserver()
        
        /*let storyvc = loadVC(strStoryboardId: SB_FEEDS, strVCId: "feedlistvc") as! FeedListVC
         APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)*/
        
        let feeds = loadVC(strStoryboardId: SB_FEEDS, strVCId: idFeedVC) as! FeedVC
        APP_DELEGATE.appNavigation?.pushViewController(feeds, animated: false)
    }
    
    @IBAction func btnchannelclicked(_ sender: Any) {
        self.remove_NotificationObserver()
        
        let storyvc = loadVC(strStoryboardId: SB_CHANNEL, strVCId: idChannelListVC) as! ChannelListVC
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
    }
    
    //MARK: Other button action method
    @IBAction func btnuserclicked(_ sender: Any) {
        let storyvc = loadVC(strStoryboardId: SB_MAIN, strVCId: idProfileVC) as! ProfileVC
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
    }
    
    @IBAction func btnNotificationClicked(_ sender: Any) {
        let notiVC : ChannelNotificationVC = loadVC(strStoryboardId: SB_CHANNEL, strVCId: idChannelNotificationVC) as! ChannelNotificationVC
        APP_DELEGATE.appNavigation?.pushViewController(notiVC, animated: true)
    }
    
    @IBAction func btnSearchAction() {
        let objVC : SearchContactVC = loadVC(strStoryboardId: SB_FEEDS, strVCId: idSearchContactVC) as! SearchContactVC
        APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
    }
}

extension FeedVC:UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("TABLE ROWS COUNT   : \(self.arrFeeds.count)")
        //return arrFeeds.count
        
        let noOfPost : Int = arrFeeds.count
        tblFeed.isHidden = true
        vwnodata.isHidden = true
        
        if (noOfPost == 0) { vwnodata.isHidden = false }
        else { tblFeed.isHidden = false }
        
        return noOfPost
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedListCell") as! FeedListCell
        
        cell.feed = self.arrFeeds[indexPath.row]
        
        cell.viewMain.backgroundColor = UIColor.white
        cell.viewMain.cornerRadius = 10
        
        //Manage SeeMore
        let seeMore_Status : String = self.arrFeeds_SeeMore[indexPath.row] as! String
        cell.btnSeeMore.isHidden = true
        cell.lc_btnSeeMore_Height.constant = 0
        if (seeMore_Status == "0") {
            //cell.lblCaption.numberOfLines = 0
            if self.noOfLines(label: cell.lblCaption) > 2 {
                cell.lblCaption.numberOfLines = 2
                
                cell.btnSeeMore.setTitle("See More", for: .normal)
                cell.btnSeeMore.isHidden = false
                cell.lc_btnSeeMore_Height.constant = 25
            }
        }
        else {
            cell.lblCaption.numberOfLines = 0
            cell.btnSeeMore.setTitle("See Less", for: .normal)
        }
        //cell.lblCaption.sizeToFit()
        //self.tblFeed.layoutIfNeeded()
        
        //Manage Button action
        cell.btnSeeMore.tag = indexPath.row
        cell.btnSeeMore.addTarget(self, action: #selector(self.manage_Post_SeeMore(_:)), for: .touchUpInside)
        
        cell.btnProfile.tag = indexPath.row
        cell.btnProfile.addTarget(self, action: #selector(self.manage_Post_Profile(_:)), for: .touchUpInside)
        
        cell.btnMore.tag = indexPath.row
        cell.btnMore.addTarget(self, action: #selector(self.manage_Post_MoreOption(_:)), for: .touchUpInside)
        
        cell.btnLike.tag = indexPath.row
        cell.btnLike.addTarget(self, action: #selector(self.manage_Post_Like(_:)), for: .touchUpInside)
        
        cell.btnNoOfLike.tag = indexPath.row
        cell.btnNoOfLike.addTarget(self, action: #selector(self.manage_Post_NoOfLike(_:)), for: .touchUpInside)
        
        cell.btnComment.tag = indexPath.row
        cell.btnComment.addTarget(self, action: #selector(self.manage_Post_Comment(_:)), for: .touchUpInside)
        
        cell.btnShare.tag = indexPath.row
        cell.btnShare.addTarget(self, action: #selector(self.manage_Post_Share(_:)), for: .touchUpInside)
        
        cell.btnlocation.tag = indexPath.row
        cell.btnlocation.addTarget(self, action: #selector(self.manage_Location_Click(_:)), for: .touchUpInside)
        
        /*if (indexPath.row == (arrFeeds.count - 1)) == true {
         //print("Now Load More")
         api_GetPost()
         }*/
        return cell;
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       
        //if indexPath.row == (arrFeeds.count - 1) {
        if (indexPath.row == (arrFeeds.count - 1)) == true {
            //print("Now Load More")
            api_GetPost()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let seeMore_Status : String = self.arrFeeds_SeeMore[indexPath.row] as! String
        if (seeMore_Status == "0") {
            //return UITableViewAutomaticDimension
            //return 500
            return 495
        }
        else { return UITableViewAutomaticDimension }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func noOfLines(label: UILabel) -> Int {
        label.numberOfLines = 0
        let textSize = CGSize(width: label.frame.size.width, height: CGFloat(Float.infinity))
        let rHeight = lroundf(Float(label.sizeThatFits(textSize).height))
        let charSize = lroundf(Float(label.font.lineHeight))
        let lineCount = rHeight/charSize
        
        //print("Text: \(label.text!))")
        //print("lines: \(lineCount))")
        
        return lineCount
    }
    
    //MARK: Tableview button action method
    @objc func manage_Post_SeeMore(_ sender:UIButton) {
        self.view.endEditing(true) // Hide Keyboard
        
        self.selectedPost = IndexPath.init(item: sender.tag, section: 0)
        var seeMore_Status : String = self.arrFeeds_SeeMore[self.selectedPost.row] as! String
        seeMore_Status = seeMore_Status == "0" ? "1" : "0"
        
        //Replace Object in array list
        self.arrFeeds_SeeMore.replaceObject(at: self.selectedPost.row, with: seeMore_Status)
        
        //Manage Update and Reload Cell
        self.tblFeed.reloadRows(at: [self.selectedPost], with: .none) //Reload Cell
        self.tblFeed.scrollToRow(at: self.selectedPost, at: .none, animated: false) //Reload Cell Visible at Top Position.
    }
    
    @objc func manage_Post_Profile(_ sender:UIButton) {
        self.view.endEditing(true) // Hide Keyboard
        
        selectedPost = IndexPath.init(item: sender.tag, section: 0)
        let objData = arrFeeds[selectedPost.row]
        
        let objVC : OtherProfileVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idOtherProfileVC) as! OtherProfileVC
        objVC.strViewProfile_UserID = objData.userId!
        objVC.strUser_ProfilePhoto = objData.image!
        objVC.strUser_FullName = objData.fullName!
        //objVC.flag_UserFollow = objData. //------------------->
        APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
    }
    
    @objc func manage_Post_MoreOption(_ sender:UIButton) {
        self.view.endEditing(true) // Hide Keyboard
        
        selectedPost = IndexPath.init(item: sender.tag, section: 0)
        let objData = arrFeeds[selectedPost.row]
        
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let strChannelVideoByUserID : String = objData.userId!
        if (strChannelVideoByUserID.uppercased() == UserDefaultManager.getStringFromUserDefaults(key:kAppUserId).uppercased()) {
            //Delete Post
            let actionReport = UIAlertAction.init(title: "Delete post", style: .destructive) { (action) in
                self.Confirmation_DeletePost()
            }
            alert.addAction(actionReport)
        }
        else {
            //Report the Post
            let actionReport = UIAlertAction.init(title: kReport_Spam_Post, style: .default) { (action) in
                
                let parameter:NSDictionary = ["service":APIReportSpam,
                                              "request":["spam_id":objData.postId,
                                                         "action":"post"],
                                              "auth" : getAuthForService()]
                APP_DELEGATE.api_SpamReport(parameter: parameter, successMess: "Reported successfully.")

            }
            alert.addAction(actionReport)
        }
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func manage_Location_Click(_ sender: UIButton)
    {
        let feds = arrFeeds[sender.tag]
        let latitude = feds.latitude
        let longitude = feds.longitude
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
    
    func Confirmation_DeletePost() -> Void {
        self.view.endEditing(true) // Hide Keyboard
        
        let alert = UIAlertController(title: APPNAME, message: "Are you sure you want to delete this post?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes, Delete Now", style: .destructive, handler: { (action: UIAlertAction!) in
            //showMessage("Work in Progress...")
            
            //Called Web API in BG
            let objSelectedPost = self.arrFeeds[self.selectedPost.row]
            let parameter:NSDictionary = ["service":APIDeletePost,
                                          "request":["post_id": objSelectedPost.postId],
                                          "auth" : getAuthForService()]
            self.api_DeletePost(parameter: parameter)
            
            //Remove obj in Listing
            self.arrFeeds.remove(at: self.selectedPost.row) //Remove Object in array list
            self.tblFeed.deleteRows(at: [self.selectedPost], with: .left) //Remove Cell
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            //print("Dismiss Confirmation Alert")
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func manage_Post_Like(_ sender:UIButton) {
        self.view.endEditing(true) // Hide Keyboard
        
        selectedPost = IndexPath.init(item: sender.tag, section: 0)
        let objData = arrFeeds[selectedPost.row]
        
        let status : Bool = objData.isLike!
        var statusValue : String = ""
        if (status == true) {
            statusValue = "dislike"
        }
        else {
            statusValue = "like"
        }
        
        //Set parameter for Called WebService
        let parameter:NSDictionary = ["service":APIAddPostLike,
                                      "request":["post_id": objData.postId,
                                                 "action": statusValue],
                                      "auth" : getAuthForService()]
        self.api_AddLikeDislikePost(parameter: parameter)
        
        //Selected Object value Change ---->
        if (status == true) {
            objData.isLike = false
            objData.likeCount = objData.likeCount! - 1
        }
        else {
            objData.isLike = true
            objData.likeCount = objData.likeCount! + 1
        }
        //Replace Object in array list | 1st Remove obj after add object of it's index
        self.arrFeeds.remove(at: self.selectedPost.row)
        self.arrFeeds.insert(objData, at: self.selectedPost.row)
        
        //Reload Cell
        self.tblFeed.reloadRows(at: [self.selectedPost], with: .fade)
    }
    
    @objc func manage_Post_NoOfLike(_ sender:UIButton) {
        self.view.endEditing(true) // Hide Keyboard
        
        selectedPost = IndexPath.init(item: sender.tag, section: 0)
        let objSelectedPost = arrFeeds[selectedPost.row]
        let NoOfView : Int = objSelectedPost.likeCount!
        if (NoOfView == 0) { return }
        
        let objPopupVC : PopupVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idPopupVC) as! PopupVC
        objPopupVC.objEnumPopup = enumPopup.enumPopup_Post_NoOfLike
        objPopupVC.strPostID = objSelectedPost.postId!
        
        objPopupVC.modalPresentationStyle = .overCurrentContext
        self.present(objPopupVC, animated: true, completion: nil)
    }
    
    @objc func manage_Post_Comment(_ sender:UIButton) {
        self.view.endEditing(true) // Hide Keyboard
        
        selectedPost = IndexPath.init(item: sender.tag, section: 0)
        let objData = arrFeeds[selectedPost.row]
        
        let vc = loadVC(strStoryboardId: SB_FEEDS, strVCId: idCommentsVC) as! CommentsVC
        vc.strPostID = objData.postId!
        APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
    }
    
    @objc func manage_Post_Share(_ sender:UIButton) {
        self.view.endEditing(true) // Hide Keyboard
        
        selectedPost = IndexPath.init(item: sender.tag, section: 0)
        let objData = arrFeeds[selectedPost.row]
        
        //Share Message
        var mess = ""
        mess += objData.image! + "\n"
        mess += "Check Post by " + objData.fullName!
        mess += "(@" + objData.username! + ")"
        
        share(shareContent: [mess])
    }
}

extension FeedVC : AssetPickerDelegate {
    
    func assetPickerDidFinishSelectingAssets(withFilterAssetModels filterAssetModels: [FilterAssetModel]) {
        print(filterAssetModels.count)
        
        DispatchQueue.main.async {
            let viewControllers: [UIViewController] = APP_DELEGATE.appNavigation!.viewControllers as [UIViewController]
            APP_DELEGATE.appNavigation!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            //NOW GOTO POST VC
            let vc = loadVC(strStoryboardId: SB_FEEDS, strVCId: idPostVC) as! PostVC
            vc.arrAssets = filterAssetModels
            APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
        }
    }
    
    func assetPickerDidCancelSelectingAssets() {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
}

// MARK:- API
extension FeedVC {
    func api_GetPost() {
        self.view.endEditing(true)
        let parameter:NSDictionary = ["service":APIGetAllPost,
                                      "request":["offset":offset],
                                      "auth" : getAuthForService()]
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIGetAllPost, parameters: parameter, keyname: ResponseKey as NSString, message: APIFeedsMessage, showLoader: false, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            //Hide Loader
            hideMessage()
            hideLoaderHUD()
            
            //Hide Refresh Indicator
            self.AllPostListRefresh_Stop(self.refreshControl_tableview)
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_GetPost()
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    if responseArray!.count > 0 {
                        if self.offset == 0 {
                            self.arrFeeds = [Feeds]() //BECAUSE ARRAY MAY HAVE ELEMENTS FROM PREVIOUSLY CACHED RECORDS
                            self.arrFeeds_SeeMore = NSMutableArray.init()
                            
                            let cachedData = (responseDict?.object(forKey: "data") as! NSDictionary).object(forKey: "post") as! NSArray
                            UserDefaultManager.setCustomObjToUserDefaults(CustomeObj: cachedData, key: kCachedFeeds)
                            
                            UserDefaultManager.setBooleanToUserDefaults(value: true, key: kPreviouslyCachedFeeds)
                        }
                        self.arrFeeds += responseArray as! [Feeds]
                        //self.arrFeeds.sort(by: { Int($0.postId!)! > Int($1.postId!)!})
                        
                        var arrSeeMoreFlag : NSMutableArray = NSMutableArray.init()
                        arrSeeMoreFlag = self.arrFeeds_SeeMore.mutableCopy() as! NSMutableArray
                        
                        for _ in responseArray! { arrSeeMoreFlag.add("0") }
                        //self.arrFeeds_SeeMore.removeAllObjects()
                        self.arrFeeds_SeeMore = arrSeeMoreFlag
                        
                        //print("PARSING TOTAL DATA : \(self.arrFeeds.count)")
                        
                        /*let cachedArray:[Feeds] = Array(self.arrFeeds.prefix(10))
                         UserDefaultManager.setCustomObjToUserDefaultsInBackgroundThread(CustomeObj:cachedArray as AnyObject, key: kCachedFeeds)*/
                        
                        self.offset += 1
                        self.tblFeed.reloadData()
                    }
                    else {
                        showMessage(statusmessage)
                    }
                }
            }
        })
    }
    
    func api_AddLikeDislikePost(parameter : NSDictionary) {
        self.view.endEditing(true)
        //self.view.isUserInteractionEnabled = false
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIAddPostLike, parameters: parameter, keyname: "", message: "", showLoader: false, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            //self.view.isUserInteractionEnabled = true
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_AddLikeDislikePost(parameter: parameter)
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
    
    func api_DeletePost(parameter : NSDictionary) {
        self.view.endEditing(true)
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIDeletePost, parameters: parameter, keyname: "", message: "", showLoader: false, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_DeletePost(parameter: parameter)
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

