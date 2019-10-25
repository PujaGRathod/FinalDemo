//
//  PopupVC.swift
//  WakeUppApp
//
//  Created by C025 on 30/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import SwiftyJSON

enum enumPopup : Int {
    case enumPopup_None = 0
    case enumPopup_Following // Present on User Profile Screen
    case enumPopup_Followers // Present on User Profile Screen
    case enumPopup_BlockContact // Present on User Profile Setting Screen
    case enumPopup_Views // Present on ChannelListing & ChannelProfile Screen
    case enumPopup_Likes // Present on ChannelListing & ChannelProfile Screen
    case enumPopup_Subscribe // Present on ChannelProfile Screen
    case enumPopup_Post_NoOfLike // Present on FeedVC Screen | Show NoOfLike Post
}
//-------------------------->
//NOTE:
//NOTE:
//NOTE:
//NOTE:
//NOTE:
//NOTE:
//NOTE:
//-> Abow enum into Only BlockContact Class define in - "HttpRequestManager.swift" file, If use another plz. set class file after getted API response manasge in this popupVC.
//-------------------------->

let duration_bgColorChange = 0.40

protocol PopupVC_Delegate: class {
    func manage_BlockContactUpdate()
}

class PopupVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: PopupVC_Delegate?
    
    //MARK - Outlet
    @IBOutlet weak var viewMain: UIView!
    
    @IBOutlet weak var viewPopup: UIView!
    
    @IBOutlet weak var lc_viewPopup_Height: NSLayoutConstraint!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var lblPlaceholder: UILabel!
    
    //MARK - Variable
    var objEnumPopup : enumPopup = .enumPopup_None //For manage what web API Called, get value in Privious VC
    var selectedCell : IndexPath! //Manage curret Selected Cell detect
    var strPlaceholder : String = "Loading..."
    
    var strTitle : String = "" //Show title of popup
    var strUserID : String = "" //For user getting data by Web API, Getting by Privious VC
    var strSelectedChannelVideoID : String = "" //Store Particuler channel video ID getting by privious VC, and get video info pass this values in API.
    var strChannelID : String = "" //For user Store Particuler channel ID getting by privious VC, and get person list of who Channel Subscribe
    var strPostID : String = "" //For user Store Particuler Post ID getting by privious VC, and get person list of who Post Likes.
    
    var arrFollowers = [FollowList_Followers]() // For use store User Followers data, getting by WebService.
    var arrFollowing = [FollowList_Following]() // For use store User following data, getting by WebService.
    var objChannelVideoCommentLikesView : GetChannelVideoCommentsLikes! // For use get video's  Comment-Likes-View's | Get info in WebService respo.
    var arrDataList_View = [ViewData]() //Store Video View's person Info list | Get info in WebService respo.
    var arrDataList_Like = [LikeData]() //Store Video Like's person Info list | Get info in WebService respo.
    var arrDataList_Subscribe = [GetSubscribeList]() //Store Channel subscribe user list | Get in API response.
    
    var arrPost_NoOfLike = [LikeData]() //Store Post Like's person Info list | Get info in WebService respo.
    var arrBlockUserList = [GetUserBlocked]() //Store Block User Info list | Get info in WebService respo.
    
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = UIColor.clear
        viewMain.backgroundColor = UIColor.clear
        
        //Set BG Color
        let deadlineTime = DispatchTime.now() + duration_bgColorChange
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            UIView.animate(withDuration: duration_bgColorChange) {
                self.viewMain.backgroundColor = COLOR_PopupBG 
            }
        }
        
        //Set Text and title
        lblTitle.text = strTitle
        lblPlaceholder.text = strPlaceholder
        switch objEnumPopup {
        case .enumPopup_None:
            lblTitle.text = ""
            strPlaceholder = ""
            break
        case .enumPopup_Following:
            lblTitle.text = "Following"
            //strPlaceholder = "Getting Following data..."
            self.api_FollowList(userID: strUserID)
            break
        case .enumPopup_Followers:
            lblTitle.text = "Followes"
            //strPlaceholder = "Getting Followes data..."
            self.api_FollowList(userID: strUserID)
            break
        case .enumPopup_BlockContact:
            lblTitle.text = "Block Contact"
            //strPlaceholder = "Getting Block Contact data..."
            self.api_GetBlockUserList()
            break
        case .enumPopup_Views:
            lblTitle.text = "Views"
            self.api_GetChannel_VideoCommentsLikes(strVideoID: strSelectedChannelVideoID)
            break
        case .enumPopup_Likes:
            lblTitle.text = "Likes"
            self.api_GetChannel_VideoCommentsLikes(strVideoID: strSelectedChannelVideoID)
            break
        case .enumPopup_Subscribe:
            lblTitle.text = "Subscribe"
            self.api_GetSubscribeList(strChannelID: strChannelID)
            break
        case .enumPopup_Post_NoOfLike:
            lblTitle.text = "Likes"
            self.api_GetPostLikes(strPostID: strPostID)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ////MARK: - Custom Function
    
    //MARK: - Buttom action method
    @IBAction func btnCloseAction() {
        viewMain.backgroundColor = UIColor.clear
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Tableview Delegate Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var noOfRow = 0
        switch objEnumPopup {
        case .enumPopup_None:
            noOfRow = 0
            break
        case .enumPopup_Following:
            noOfRow = self.arrFollowing.count
            break
        case .enumPopup_Followers:
            noOfRow = self.arrFollowers.count
            break
        case .enumPopup_BlockContact:
            noOfRow = arrBlockUserList.count
            break
        case .enumPopup_Views:
            noOfRow = arrDataList_View.count
            break
        case .enumPopup_Likes:
            noOfRow = arrDataList_Like.count
            break
        case .enumPopup_Subscribe:
            noOfRow = arrDataList_Subscribe.count
            break
        case .enumPopup_Post_NoOfLike:
            noOfRow = arrPost_NoOfLike.count
            break
        }
        tblList.isHidden = true
        lblPlaceholder.isHidden = true
        
        if (noOfRow == 0) {
            lblPlaceholder.text = strPlaceholder
            lblPlaceholder.isHidden = false
        }
        else {
            tblList.isHidden = false
        }
        return noOfRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : PopupCell = tableView.dequeueReusableCell(withIdentifier: "PopupCell") as! PopupCell
        
        var strPhotoURL : String = ""
        var strName : String = ""
        var strUsername : String = ""
        var flag_UserFollow : Bool = false
        
        switch objEnumPopup {
        case .enumPopup_None:
            break
        case .enumPopup_Following:
            let objFollowing = arrFollowing[indexPath.row]
            strPhotoURL = objFollowing.profileImg!
            strName = objFollowing.fullName!
            strUsername = objFollowing.username!
            flag_UserFollow = objFollowing.isFollowing!
            break
        case .enumPopup_Followers:
            let objFollowing = arrFollowers[indexPath.row]
            strPhotoURL = objFollowing.profileImg!
            strName = objFollowing.fullName!
            strUsername = objFollowing.username!
            flag_UserFollow = objFollowing.isFollowing!
            break
        case .enumPopup_BlockContact:
            let objBlockUserInfo = arrBlockUserList[indexPath.row]
            //arrBlockUserList
            strPhotoURL = objBlockUserInfo.imagePath!
            strName = objBlockUserInfo.fullName!
            strUsername = objBlockUserInfo.username?.count == 0 ? "-" : objBlockUserInfo.username!
            break
        case .enumPopup_Views:
            let objViewData = arrDataList_View[indexPath.row]
            strPhotoURL = objViewData.imagePath!
            strName = (objViewData.fullName != nil) ? objViewData.fullName! : "---"
            strUsername = objViewData.creationDatetime!
            //Date---->
            let date : Date =  DateFormater.convertDateToLocalTimeZoneForDateFromString(givenDate: strUsername) as Date
            strUsername = timeAgoSinceDate(date: date, numericDates: false)
            
            flag_UserFollow = objViewData.isFollowing!
            break
            
        case .enumPopup_Likes:
            let objLikeData = arrDataList_Like[indexPath.row]
            strPhotoURL = objLikeData.imagePath!
            strName = (objLikeData.fullName != nil) ? objLikeData.fullName! : "---"
            strUsername = objLikeData.creationDatetime!
            //Date---->
            let date : Date =  DateFormater.convertDateToLocalTimeZoneForDateFromString(givenDate: strUsername) as Date
            strUsername = timeAgoSinceDate(date: date, numericDates: false)
            
            flag_UserFollow = objLikeData.isFollowing!
            break
        case .enumPopup_Subscribe:
            let objData = arrDataList_Subscribe[indexPath.row]
            strPhotoURL = objData.imagePath!
            strName = (objData.fullName != nil) ? objData.fullName! : "---"
            strUsername = (objData.username != nil) ? objData.username! : "---"
            
            flag_UserFollow = objData.isFollowing!
            break
        case .enumPopup_Post_NoOfLike:
            let objData = arrPost_NoOfLike[indexPath.row]
            strPhotoURL = objData.imagePath!
            strName = (objData.fullName != nil) ? objData.fullName! : "---"
            strUsername = (objData.username != nil) ? objData.username! : "---"
            
            flag_UserFollow = objData.isFollowing!
            break
        }
        
        cell.imgPhoro.cornerRadius = cell.imgPhoro.frame.height/2
        cell.imgPhoro.sd_setImage(with: URL.init(string: strPhotoURL), placeholderImage: ProfilePlaceholderImage)
        
        cell.lblName.text = strName
        cell.lblUsername.text = strUsername
        
        //Manage Show Button and it's action method
        cell.btnFollow.setTitle("", for: .normal)
        cell.btnFollow.cornerRadius = cell.btnFollow.height/2
        cell.btnFollow.borderWidth = 0.80
        cell.btnFollow.borderColor = UIColor.white
        cell.btnFollow.layer.masksToBounds = true
        cell.btnFollow.isHidden = true
        
        //Manage Follow button HideShow
        switch objEnumPopup {
        case .enumPopup_None:
            //cell.btnFollow.setTitle("", for: .normal)
            //cell.btnFollow.isHidden = true
            break
        case .enumPopup_Following, .enumPopup_Followers, .enumPopup_Views, .enumPopup_Likes, .enumPopup_Subscribe, .enumPopup_Post_NoOfLike:
            cell.btnFollow.isHidden = false
            if (flag_UserFollow == true) {
                cell.btnFollow.setTitle("Following", for: .normal)
                cell.btnFollow.setBackgroundImage(nil, for: .normal)
                cell.btnFollow.backgroundColor = UIColor.lightGray
            }
            else {
                cell.btnFollow.setTitle("Follow", for: .normal)
                cell.btnFollow.setBackgroundImage(#imageLiteral(resourceName: "ic_gradient"), for: .normal)
            }
            cell.btnFollow.tag = indexPath.row
            cell.btnFollow.addTarget(self, action: #selector(btnUnFollowAction_OnPopup(sender:)), for: .touchUpInside)
            break
        case .enumPopup_BlockContact:
            cell.btnFollow.isHidden = false
            cell.btnFollow.setTitle("Unblock", for: .normal)
            cell.btnFollow.setBackgroundImage(nil, for: .normal)
            cell.btnFollow.backgroundColor = UIColor.lightGray
            
            cell.btnFollow.tag = indexPath.row
            cell.btnFollow.addTarget(self, action: #selector(btnBlockAction_OnPopup(sender:)), for: .touchUpInside)
            break
        }
        
        
        //Set Dynemic PopupView Height
        lc_viewPopup_Height.constant = (tblList.contentSize.height) + 55
        if ((SCREENHEIGHT() - 40) < lc_viewPopup_Height.constant) {
            UIView.animate(withDuration: 0.30) {
                self.lc_viewPopup_Height.constant = (SCREENHEIGHT() * 0.805)
                //self.view.layoutIfNeeded()
                self.viewPopup.layoutIfNeeded()
            }
        }
        
        tableView.separatorColor = UIColor.clear
        tableView.allowsSelection = true
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tblList.deselectRow(at: indexPath, animated: true)
        
        var strUserID : String = ""
        var strPhotoURL : String = ""
        var strFullName : String = ""
        var userFollow : Bool = false
        
        switch objEnumPopup {
        case .enumPopup_None:
            break
        case .enumPopup_Following:
            let objFollowing : FollowList_Following = arrFollowing[indexPath.row]
            strUserID = objFollowing.userId!
            strPhotoURL = objFollowing.profileImg!
            strFullName = objFollowing.fullName!
            userFollow = objFollowing.isFollowing!
            break
        case .enumPopup_Followers:
            let objFollowers : FollowList_Followers = arrFollowers[indexPath.row]
            strUserID = objFollowers.userId!
            strPhotoURL = objFollowers.profileImg!
            strFullName = objFollowers.fullName!
            userFollow = objFollowers.isFollowing!
            break
        case .enumPopup_BlockContact:
            break
        case .enumPopup_Views:
            let objViewData = arrDataList_View[indexPath.row]
            strUserID = objViewData.userId!
            strPhotoURL = objViewData.imagePath!
            strFullName = objViewData.fullName!
            userFollow = objViewData.isFollowing!
        case .enumPopup_Likes:
            let objLikeData = arrDataList_Like[indexPath.row]
            strUserID = objLikeData.userId!
            strPhotoURL = objLikeData.imagePath!
            strFullName = objLikeData.fullName?.count == 0 ? objLikeData.fullName! : "---"
            userFollow = objLikeData.isFollowing!
        case .enumPopup_Subscribe:
            let objData = arrDataList_Subscribe[indexPath.row]
            strUserID = objData.userId!
            strPhotoURL = objData.imagePath!
            strFullName = (objData.fullName != nil) ? objData.fullName! : "---"
            userFollow = objData.isFollowing!
        case .enumPopup_Post_NoOfLike:
            let objLikeData = arrPost_NoOfLike[indexPath.row]
            strUserID = objLikeData.userId!
            strPhotoURL = objLikeData.imagePath!
            strFullName = objLikeData.fullName?.count == 0 ? objLikeData.fullName! : "---"
            userFollow = objLikeData.isFollowing!
        }
        
        if (strUserID.count == 0) { return }
        self.btnCloseAction()
        
        let objVC : OtherProfileVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idOtherProfileVC) as! OtherProfileVC
        objVC.strViewProfile_UserID = strUserID
        objVC.strUser_ProfilePhoto = strPhotoURL
        objVC.strUser_FullName = strFullName
        objVC.flag_UserFollow = userFollow
        APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
    }
    
    //MARK: Tableview button action method
    @objc func btnUnFollowAction_OnPopup(sender:UIButton!) {
        selectedCell = IndexPath.init(row: sender.tag, section: 0)
        
        var strUserID : String = ""
        var strName : String = ""
        var flag_UserFollow : Bool = false
        
        switch objEnumPopup {
        case .enumPopup_None:
            break
        case .enumPopup_Following:
            let objFollowing = arrFollowing[sender.tag]
            strUserID = objFollowing.userId!
            strName = objFollowing.fullName!
            flag_UserFollow = objFollowing.isFollowing!
            break
        case .enumPopup_Followers:
            let objFollowing = arrFollowers[sender.tag]
            strUserID = objFollowing.userId!
            strName = objFollowing.fullName!
            flag_UserFollow = objFollowing.isFollowing!
            break
        case .enumPopup_BlockContact:
            break
        case .enumPopup_Views:
            let objViewData = arrDataList_View[sender.tag]
            strUserID = objViewData.userId!
            strName = objViewData.fullName!
            flag_UserFollow = objViewData.isFollowing!
            break
        case .enumPopup_Likes:
            let objLikeData = arrDataList_Like[sender.tag]
            strUserID = objLikeData.userId!
            strName = objLikeData.fullName?.count == 0 ? objLikeData.fullName! : "---"
            flag_UserFollow = objLikeData.isFollowing!
            break
        case .enumPopup_Subscribe:
            let objData = arrDataList_Subscribe[sender.tag]
            strUserID = objData.userId!
            strName = (objData.fullName != nil) ? objData.fullName! : "---"
            flag_UserFollow = objData.isFollowing!
            break
        case .enumPopup_Post_NoOfLike:
            let objLikeData = arrPost_NoOfLike[sender.tag]
            strUserID = objLikeData.userId!
            strName = objLikeData.fullName?.count == 0 ? objLikeData.fullName! : "---"
            flag_UserFollow = objLikeData.isFollowing!
            break
        }
        
        if (flag_UserFollow == true) {
            let strTitle : String = "Are you sure you went to Unfollow \(strName)?"
            let alert = UIAlertController.init(title: "", message: strTitle, preferredStyle: .actionSheet)
            let actionReport = UIAlertAction.init(title: "Unfollow", style: .destructive) { (action) in
                
                //Reload Table/Cell
                runAfterTime(time: 0.20, block: {
                    //self.tblList.reloadData()
                    self.tblList.reloadRows(at: [IndexPath.init(row: sender.tag, section: 0)], with: .fade)
                })
                
                //Manage Channel Subscribe activity action perform.
                // NOTE :
                // set action - follow/unfollow | base on API no.-21
                var strUserFollowStatus : NSString = "follow"
                if (flag_UserFollow == true) {
                    strUserFollowStatus = "unfollow"
                }
                //Set parameter for Called WebService
                let parameter:NSDictionary = ["service":APIUserFollow,
                                              "request":["follow_to":strUserID,
                                                         "action":strUserFollowStatus],
                                              "auth" : getAuthForService()]
                self.api_userFollow(parameter: parameter)
            }
            alert.addAction(actionReport)
            let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(actionCancel)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            var strUserFollowStatus : NSString = "follow"
            if (flag_UserFollow == true) {
                strUserFollowStatus = "unfollow"
            }
            //Set parameter for Called WebService
            let parameter:NSDictionary = ["service":APIUserFollow,
                                          "request":["follow_to":strUserID,
                                                     "action":strUserFollowStatus],
                                          "auth" : getAuthForService()]
            self.api_userFollow(parameter: parameter)
        }
    }
    
    @objc func btnBlockAction_OnPopup(sender:UIButton!) {
        selectedCell = IndexPath.init(row: sender.tag, section: 0)
        
        let objBlockUserInfo : GetUserBlocked = arrBlockUserList[sender.tag]
        let strFullName : String =  objBlockUserInfo.fullName!
        //let flag_UserFollow : Bool = false //objUserFollowing.###!
        
        let strTitle : String = "Are you sure you went to Unblock \(strFullName)?"
        let alert = UIAlertController.init(title: "", message: strTitle, preferredStyle: .actionSheet)
        let actionReport = UIAlertAction.init(title: "Unblock", style: .destructive) { (action) in
            
            //Remove obj in Listing
            self.arrBlockUserList.remove(at: sender.tag) //Remove Object in list
            self.tblList.deleteRows(at: [IndexPath.init(row: sender.tag, section: 0)], with: .left) //Remove Cell
            //Reload Table/Cell
            runAfterTime(time: 0.20, block: {
                self.tblList.reloadData()
            })
            
            //Remove UserID in UserDefault BlockContact Listing
            APP_DELEGATE.RemoveUser_BlockContactList(strUserID: objBlockUserInfo.userId!)
            
            //Called Delegate Protocol Method for Show Latest Count of Unblock Contact
            self.delegate?.manage_BlockContactUpdate()
            
            //Manage User block/Unblock manage
            // NOTE : Set action - block / unblock | base on API no.-67
            let strUserBlockID : NSString = objBlockUserInfo.userId! as NSString
            let strUserBlockStatus : NSString = "unblock"
            
            //Set parameter for Called WebService
            let parameter:NSDictionary = ["service":APIBlockUser,
                                          "request":["block_user_id":strUserBlockID,
                                                     "action":strUserBlockStatus],
                                          "auth" : getAuthForService()]
            self.api_BlockUser(parameter: parameter)
        }
        alert.addAction(actionReport)
        
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionCancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func btnFollowAction_OnPopup(sender:UIButton!) {
        showMessage("Following")
    }
    
    //MARK:- API
    
    func api_FollowList(userID: String)
    {
        //showHUD()
        self.view.endEditing(true)
        let parameter:NSDictionary = ["service":APIFollowList,
                                      "request":["user_id":userID],
                                      "auth" : getAuthForService()]
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIFollowList, parameters: parameter, keyname: "", message: "", showLoader: false, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            hideLoaderHUD()
            hideHUD()
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_FollowList(userID: userID)
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    /*if responseArray!.count > 0 {
                     self.arrFollowing = responseArray as! [GetUserFollowing]
                     }*/
                    let dicRespo : NSDictionary = responseDict?.value(forKey: kData) as! NSDictionary
                    if dicRespo.allKeys.count > 0 {
                        switch self.objEnumPopup {
                        case .enumPopup_None:
                            break
                        case .enumPopup_Following:
                            let arrData = dicRespo.object(forKey: "following") as! NSArray
                            let arrObjData : NSMutableArray = NSMutableArray.init()
                            for objData in arrData {
                                let j = JSON(objData)
                                let objData:FollowList_Following = FollowList_Following.init(json: j)
                                arrObjData.add(objData)
                            }
                            self.arrFollowing = arrObjData as! [FollowList_Following]
                            break
                        case .enumPopup_Followers:
                            let arrData : NSArray = dicRespo.object(forKey: "followers") as! NSArray
                            let arrObjData : NSMutableArray = NSMutableArray.init()
                            for objData in arrData {
                                let j = JSON(objData)
                                let objData:FollowList_Followers = FollowList_Followers.init(json: j)
                                arrObjData.add(objData)
                            }
                            self.arrFollowers = arrObjData as! [FollowList_Followers]
                            break
                        case .enumPopup_BlockContact:
                            break
                        case .enumPopup_Views:
                            break
                        case .enumPopup_Likes:
                            break
                        case .enumPopup_Subscribe:
                            break
                        case .enumPopup_Post_NoOfLike:
                            break
                        }
                    }
                    self.strPlaceholder = "No available user following data"
                    self.tblList.reloadData()
                }
            }
        })
    }
    
    func api_userFollow(parameter : NSDictionary) {
        self.view.endEditing(true)
        //self.view.isUserInteractionEnabled = false
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIUserFollow, parameters: parameter, keyname: "", message: "", showLoader: false
            , responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            hideLoaderHUD() // Hide Loader
            self.view.isUserInteractionEnabled = true
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_userFollow(parameter: parameter)
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    //Show Success message
                    //let strMessage: String = responseDict!.object(forKey: kMessage) as! String
                    //showMessage(strMessage)
                    
                    
                    //Manage Changes/Update Follow Status & Image --->
                    switch self.objEnumPopup {
                    case .enumPopup_None:
                        break
                    case .enumPopup_Following:
                        let objFollowing = self.arrFollowing[self.selectedCell.row]
                        if (objFollowing.isFollowing == true) { objFollowing.isFollowing = false }
                        else { objFollowing.isFollowing = true }
                        
                        //Replace Obj.
                        self.arrFollowing.remove(at: self.selectedCell.row)
                        self.arrFollowing.insert(objFollowing, at: self.selectedCell.row)
                        self.tblList.reloadData()
                        break
                    case .enumPopup_Followers:
                        let objFollowing = self.arrFollowers[self.selectedCell.row]
                        if (objFollowing.isFollowing == true) { objFollowing.isFollowing = false }
                        else { objFollowing.isFollowing = true }
                        
                        //Replace Obj.
                        self.arrFollowers.remove(at: self.selectedCell.row)
                        self.arrFollowers.insert(objFollowing, at: self.selectedCell.row)
                        self.tblList.reloadData()
                        break
                    case .enumPopup_BlockContact:
                        break
                    case .enumPopup_Views:
                        let objData = self.arrDataList_View[self.selectedCell.row]
                        if (objData.isFollowing == true) { objData.isFollowing = false }
                        else { objData.isFollowing = true }
                        
                        //Replace Obj.
                        self.arrDataList_View.remove(at: self.selectedCell.row)
                        self.arrDataList_View.insert(objData, at: self.selectedCell.row)
                        self.tblList.reloadData()
                        break
                    case .enumPopup_Likes:
                        let objData = self.arrDataList_Like[self.selectedCell.row]
                        if (objData.isFollowing == true) { objData.isFollowing = false }
                        else { objData.isFollowing = true }
                        
                        //Replace Obj.
                        self.arrDataList_Like.remove(at: self.selectedCell.row)
                        self.arrDataList_Like.insert(objData, at: self.selectedCell.row)
                        self.tblList.reloadData()
                        break
                    case .enumPopup_Subscribe:
                        let objData = self.arrDataList_Subscribe[self.selectedCell.row]
                        if (objData.isFollowing == true) { objData.isFollowing = false }
                        else { objData.isFollowing = true }
                        
                        //Replace Obj.
                        self.arrDataList_Subscribe.remove(at: self.selectedCell.row)
                        self.arrDataList_Subscribe.insert(objData, at: self.selectedCell.row)
                        self.tblList.reloadData()
                        break
                    case .enumPopup_Post_NoOfLike:
                        let objData = self.arrPost_NoOfLike[self.selectedCell.row]
                        if (objData.isFollowing == true) { objData.isFollowing = false }
                        else { objData.isFollowing = true }
                        
                        //Replace Obj.
                        self.arrPost_NoOfLike.remove(at: self.selectedCell.row)
                        self.arrPost_NoOfLike.insert(objData, at: self.selectedCell.row)
                        self.tblList.reloadData()
                        break
                    }
                    
                    //Called Notif.Obs. for show updated user followings data
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NC_UpdateProfile_Followings), object: nil, userInfo: nil)
                }
            }
        })
    }
    
    func api_GetChannel_VideoCommentsLikes(strVideoID : String) {
        self.view.endEditing(true)
        let parameter:NSDictionary = ["service":APIGetChannel_VideoCommentsLikes,
                                      "request":["channel_video_id":strVideoID],
                                      "auth" : getAuthForService()]
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIGetChannel_VideoCommentsLikes, parameters: parameter, keyname: "", message: "", showLoader: false, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_GetChannel_VideoCommentsLikes(strVideoID: strVideoID)
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    /*if responseArray!.count > 0 {
                     self.arrChannelVideoCommentLikesView = responseArray as! [GetChannelVideoCommentsLikes]
                     self.tblList.reloadData()
                     }
                     else {
                     showMessage(statusmessage)
                     }*/
                    
                    let dicRespo : NSDictionary = responseDict?.value(forKey: kData) as! NSDictionary
                    if dicRespo.allKeys.count > 0 {
                        self.objChannelVideoCommentLikesView = GetChannelVideoCommentsLikes.init(object: dicRespo)
                        
                        switch self.objEnumPopup {
                        case .enumPopup_None:
                            break
                        case .enumPopup_Subscribe:
                            break
                        case .enumPopup_Following:
                            break
                        case .enumPopup_Followers:
                            break
                        case .enumPopup_BlockContact:
                            break
                        case .enumPopup_Views:
                            self.arrDataList_View = self.objChannelVideoCommentLikesView.viewData!
                            if (self.arrDataList_View.count == 0) {
                                self.lblPlaceholder.text = "No Data Available"
                            }
                            self.lblTitle.text = "\(self.objChannelVideoCommentLikesView.viewCount!)" + " Views"
                            break
                        case .enumPopup_Likes:
                            self.arrDataList_Like = self.objChannelVideoCommentLikesView.likeData!
                            if (self.arrDataList_Like.count == 0) {
                                self.lblPlaceholder.text = "No Data Available"
                            }
                            self.lblTitle.text = "\(self.objChannelVideoCommentLikesView.likeCount!)" + " Likes"
                            break
                        case .enumPopup_Post_NoOfLike:
                            break
                        }
                    }
                    else {
                        self.lblPlaceholder.text = "No Data Available"
                    }
                    self.tblList.reloadData()
                }
            }
        })
    }
    
    func api_GetSubscribeList(strChannelID : String) {
        self.view.endEditing(true)
        let parameter:NSDictionary = ["service":APIGetSubscribeList,
                                      "request":["channel_id":strChannelID],
                                      "auth" : getAuthForService()]
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIGetSubscribeList, parameters: parameter, keyname: kData as NSString, message: "", showLoader: false, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_GetSubscribeList(strChannelID: strChannelID)
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    if responseArray!.count > 0 {
                        self.arrDataList_Subscribe = responseArray as! [GetSubscribeList]
                        self.lblTitle.text = "\(self.arrDataList_Subscribe.count)" + " Subscribe"
                    }
                    else {
                        self.lblPlaceholder.text = "No Data Available"
                    }
                    self.tblList.reloadData()
                }
            }
        })
    }
    
    func api_GetPostLikes(strPostID : String) {
        self.view.endEditing(true)
        let parameter:NSDictionary = ["service":APIGetAllPostLikeComment,
                                      "request":["post_id":strPostID,
                                                 "action":"like"],
                                      "auth" : getAuthForService()]
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIGetAllPostLikeComment, parameters: parameter, keyname: kData as NSString, message: "", showLoader: false, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_GetPostLikes(strPostID: strPostID)
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    switch self.objEnumPopup {
                    case .enumPopup_None: break
                    case .enumPopup_Subscribe: break
                    case .enumPopup_Following: break
                    case .enumPopup_Followers: break
                    case .enumPopup_BlockContact: break
                    case .enumPopup_Views: break
                    case .enumPopup_Likes: break
                    case .enumPopup_Post_NoOfLike:
                        self.arrPost_NoOfLike = responseArray as! [LikeData]
                        if (self.arrPost_NoOfLike.count == 0) {
                            self.lblPlaceholder.text = "No Data Available"
                        }
                        self.lblTitle.text = "\(self.arrPost_NoOfLike.count)" + " Likes"
                    }
                    self.tblList.reloadData()
                }
            }
        })
    }
    
    func api_GetBlockUserList() {
        self.view.endEditing(true)
        
        let parameter:NSDictionary = ["service":APIGetUserBlocked,
                                      "request":"",
                                      "auth" : getAuthForService()]
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIGetUserBlocked, parameters: parameter, keyname: kData as NSString, message: "", showLoader: false, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            hideLoaderHUD() // Hide Loader
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_GetBlockUserList()
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    switch self.objEnumPopup {
                    case .enumPopup_None: break
                    case .enumPopup_Subscribe: break
                    case .enumPopup_Following: break
                    case .enumPopup_Followers: break
                    case .enumPopup_BlockContact:
                        self.arrBlockUserList.removeAll()
                        self.arrBlockUserList = responseArray as! [GetUserBlocked]
                        
                        self.strPlaceholder = "No data available"
                        //self.lblTitle.text = "\(self.arrBlockUserList.count)" + " Block User"
                        break
                    case .enumPopup_Views: break
                    case .enumPopup_Likes: break
                    case .enumPopup_Post_NoOfLike: break
                    }
                    self.tblList.reloadData()
                    
                    //Show Success message
                    //let strMessage: String = responseDict!.object(forKey: kMessage) as! String
                    //showMessage(strMessage)
                }
            }
        })
    }
    
    func api_BlockUser(parameter : NSDictionary) {
        self.view.endEditing(true)
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIUserFollow, parameters: parameter, keyname: "", message: "", showLoader: false, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            hideLoaderHUD() // Hide Loader
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_BlockUser(parameter: parameter)
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    //Manage Changes Block Status --->
                    switch self.objEnumPopup {
                    case .enumPopup_None: break
                    case .enumPopup_Subscribe: break
                    case .enumPopup_Following: break
                    case .enumPopup_Followers: break
                    case .enumPopup_BlockContact: break
                    case .enumPopup_Views: break
                    case .enumPopup_Likes: break
                    case .enumPopup_Post_NoOfLike: break
                    }
                    //self.tblList.reloadData()
                    
                    //Show Success message
                    //let strMessage: String = responseDict!.object(forKey: kMessage) as! String
                    //showMessage(strMessage)
                }
            }
        })
    }
}

