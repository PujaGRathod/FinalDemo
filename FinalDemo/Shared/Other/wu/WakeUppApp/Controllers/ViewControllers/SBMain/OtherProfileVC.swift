//
//  ProfileVC.swift
//  WakeUppApp
//
//  Created by Admin on 22/03/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
//import SimpleImageViewer 
//For Manage Play Video
import AVKit
import AVFoundation
import MapKit

class OtherProfileVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    //MARK:- Outlet
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var viewFollowers: UIView!
    @IBOutlet weak var lblFollowers: UILabel!
    
    @IBOutlet weak var viewFollowing: UIView!
    @IBOutlet weak var lblFollowing: UILabel!
    
    @IBOutlet weak var viewCountTopSpacing: NSLayoutConstraint!
    
    @IBOutlet weak var btnFollowStatus: UIButton!
    
    @IBOutlet weak var imgProfilePhoto: UIImageView!
    @IBOutlet weak var imgProfileBanner: UIImageView!
    @IBOutlet weak var lblUserFullName: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    
    @IBOutlet weak var collectionPhoto: UICollectionView!
    @IBOutlet weak var heightHeaderView: NSLayoutConstraint!
    @IBOutlet weak var rightPadding: NSLayoutConstraint!
    @IBOutlet weak var leftPadding: NSLayoutConstraint!
    
    //MARK:- Variable
    var strViewProfile_UserID : String = "" //Getting by Privious VC
    var strUser_FullName : String = "" //Getting by Privious VC
    var strUser_ProfilePhoto : String = "" //Getting by Privious VC
    
    var objUserProfile:GetUserProfile! // For use store User Profiledata, getting by WebService.
    var objArrUserPost = [PostData]() // For use store User PostData, getting by WebService.
    var flag_UserFollow : Bool = false //For help getting user follow Status
    
    //For help set user follow Status base set image
    var imgFollow_Yes : UIImage = #imageLiteral(resourceName: "following_btn")
    var imgFollow_No : UIImage = #imageLiteral(resourceName: "follow_btn")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isStatusBarHidden = false
        collectionPhoto.delegate = self
        collectionPhoto.dataSource = self
        
        runAfterTime(time: 0.1) {
            self.viewFollowers.roundCorners([.topRight,.bottomRight], radius: 20.0)
            self.viewFollowing.roundCorners([.topLeft,.bottomLeft], radius: 20.0)
        }
        
        self.fillValues() //Fill Default Values
        
        // Get Profile Data
        self.api_GetOtherUserProfile(userId: strViewProfile_UserID)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Custon Function
    func fillValues() -> Void {
        var strCover : String = "---" 
        var strPhoto : String = "---"
        var strNoOfFollowers : String = "0"
        var strNoOfFollowings : String = "0"
        var strFullName : String = "---"
        var strUsername : String = "---"
        var strBio : String = "---"
        
        if (objUserProfile != nil) {
            strCover = "\(Get_Profile_Pic_URL + "/" + self.objUserProfile.coverimage!)" 
            strPhoto = objUserProfile.imagePath!
            strNoOfFollowers = "\(objUserProfile.followers!)"
            strNoOfFollowings = "\(objUserProfile.following!)"
            
            strFullName = objUserProfile.fullName!
            strUsername = objUserProfile.username!
            strBio = objUserProfile.bio!
        }
        else {
            strCover = UserDefaultManager.getStringFromUserDefaults(key:kAppUserProfile_Banner) 
            strPhoto = strUser_ProfilePhoto
            strFullName = strUser_FullName
        }
        
        //View Title
        lblTitle.text = strFullName
        
        //Banner
        imgProfileBanner.sd_setImage(with: URL(string: strCover), placeholderImage: #imageLiteral(resourceName: "wall")) 
        
        //Photo
        imgProfilePhoto.sd_setImage(with: URL(string: strPhoto), placeholderImage: ProfilePlaceholderImage)
        
        lblFollowers.text = strNoOfFollowers + "\nfollowers".uppercased()
        lblFollowers.font = FontWithSize(lblFollowers.font.familyName, 10)
        
        lblFollowing.text = strNoOfFollowings + "\nfollowings".uppercased()
        lblFollowing.font = FontWithSize(lblFollowing.font.familyName, 10)
        
        lblUserFullName.text = strFullName
        lblUserName.text = strUsername
        lblAddress.text = strBio // Show Bio Data
        lblAddress.numberOfLines = 2
        
        //Follow Button Img Set
        self.set_FollowButton_base_on_UserFollow_Status()
    }
    
    func set_FollowButton_base_on_UserFollow_Status() -> Void {
        if (flag_UserFollow == true) {
            btnFollowStatus.setImage(imgFollow_Yes, for: .normal)
        }
        else {
            btnFollowStatus.setImage(imgFollow_No, for: .normal)
        }
    }
    
    //MARK:- Button Action Method
    @IBAction func btnClick(_ sender: Any) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnChatAction() {
        //--> Move to Chat Screen.
    }
    
    @IBAction func btnMoreOptionAction() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //let strBlockUser : String = UserDefaultManager.getStringFromUserDefaults(key: kBlockContact)
        //let arrBlockUser : NSArray = strBlockUser.components(separatedBy: ",") as NSArray
        
        var strBlockStatus_Title : String = "Add to Block List"
        //strBlockStatus_Title = arrBlockUser.contains(self.objUserProfile.userId!) ? "Remove to Block List" : strBlockStatus_Title
        strBlockStatus_Title = APP_DELEGATE.User_Exists_inBlockContactList(strUserID: self.objUserProfile.userId!) ? "Remove to Block List" : strBlockStatus_Title
        
        
        alert.addAction(UIAlertAction(title: strBlockStatus_Title.localizedCapitalized, style: .default, handler: { _ in
            //Manage User block/Unblock manage
            // NOTE : Set action - block / unblock | base on API no.-67
            var strUserBlockStatus : NSString = "block"
            if (APP_DELEGATE.User_Exists_inBlockContactList(strUserID: self.objUserProfile.userId!) == true) {
                strUserBlockStatus = "unblock"
                APP_DELEGATE.RemoveUser_BlockContactList(strUserID: self.objUserProfile.userId!)
            }
            else {
                APP_DELEGATE.AddUser_BlockContactList(strUserID: self.objUserProfile.userId!)
            }
            
            //Set parameter for Called WebService
            let parameter:NSDictionary = ["service":APIBlockUser,
                                          "request":["block_user_id":self.objUserProfile.userId!,
                                                     "action":strUserBlockStatus],
                                          "auth" : getAuthForService()]
            self.api_BlockUser(parameter: parameter)
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel".localizedCapitalized, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnFollow() {
        self.view.endEditing(true)
        
        //Manage Channel Subscribe activity action perform.
        // NOTE :
        // set action - follow/unfollow | base on API no.-21
        var strUserFollowStatus : NSString = "follow"
        if (flag_UserFollow == true) {
            strUserFollowStatus = "unfollow"
        }
        
        //Set parameter for Called WebService
        let parameter:NSDictionary = ["service":APIUserFollow,
                                      "request":["follow_to":strViewProfile_UserID,
                                                 "action":strUserFollowStatus],
                                      "auth" : getAuthForService()]
        self.api_userFollow(parameter: parameter)
    }
    
    @IBAction func btnFollowersAction() {
        /*if (self.objUserProfile.followers == 0) { return }
         
         let objPopupVC : PopupVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idPopupVC) as! PopupVC
         objPopupVC.objEnumPopup = .enumPopup_Followers
         objPopupVC.strTitle = "Followers".uppercased()
         objPopupVC.strUserID = strViewProfile_UserID
         
         objPopupVC.modalPresentationStyle = .overCurrentContext
         self.present(objPopupVC, animated: true, completion: nil)*/
    }
    
    @IBAction func btnFollowingsAction() {
        /*if (self.objUserProfile.following == 0) { return }
         
         let objPopupVC : PopupVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idPopupVC) as! PopupVC
         objPopupVC.objEnumPopup = .enumPopup_Following
         objPopupVC.strTitle = "Followings".uppercased()
         objPopupVC.strUserID = strViewProfile_UserID
         
         objPopupVC.modalPresentationStyle = .overCurrentContext
         self.present(objPopupVC, animated: true, completion: nil)*/
    }
    
    
    @IBAction func btnShowPhoto_UserBannerAction() {
        let configuration = ImageViewerConfiguration { config in
            config.imageView = self.imgProfileBanner //as? UIImageView
        }
        let imageViewerController = ImageViewerController(configuration: configuration)
        APP_DELEGATE.appNavigation?.present(imageViewerController, animated: false, completion: nil)
    }
    
    
    @IBAction func btnShow_UserProfileAction() {
        let configuration = ImageViewerConfiguration { config in
            config.imageView = self.imgProfilePhoto //as? UIImageView
        }
        let imageViewerController = ImageViewerController(configuration: configuration)
        APP_DELEGATE.appNavigation?.present(imageViewerController, animated: false, completion: nil)
    }
    
    //MARK:- Collection View
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objArrUserPost.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(indexPath.row == 0) {
            let cell:PhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCountCell", for: indexPath as IndexPath) as! PhotoCell
            
            let image = UIImage(named: "ic_gradient")!
            cell.lblPhotoCount.textColor = UIColor.init(patternImage: image)
            cell.lblPhotoCount.text = "\(objArrUserPost.count) POSTS".uppercased()
            return cell
        }
        else {
            let cell:PhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath as IndexPath) as! PhotoCell
            
            let objUserPostData : PostData = self.objArrUserPost[indexPath.row - 1]
            var strURL : String = ""
            strURL = objUserPostData.mapImage!
            
            var arrUserPost_PostImage = [PostImages]()
            arrUserPost_PostImage = objUserPostData.postImages!
            
            cell.btnPlay.isHidden = true //Default hide video Play button
            if (arrUserPost_PostImage.count != 0) {
                let objUserPost_PostImage : PostImages = arrUserPost_PostImage[0]
                
                //Detect Post is Video and manage Play Video--->
                strURL = objUserPost_PostImage.postImage!
                let arrDetectPostType : NSArray = strURL.components(separatedBy: ".") as NSArray
                let strPostExtension : String = arrDetectPostType.lastObject as! String
                
                if (strPostExtension.uppercased() != "jpg".uppercased()) {
                    cell.btnPlay.isHidden = false
                    cell.btnPlay.tag = indexPath.row
                    cell.btnPlay.addTarget(self, action: #selector(Manage_PostVideo_Play(sender:)), for: .touchUpInside)
                    
                    //Set Default Image
                    cell.imgPic.image = SquarePlaceHolderImage
                    
                    
                    /*DispatchQueue.main.async {
                     strURL = objUserPost_PostImage.imagePath!
                     cell.imgPic.image = getVideoThumbnail(videoURL: URL.init(string: strURL)!)
                     }*/
                    //New Suggested by Payal U.
                    strURL = arrDetectPostType.firstObject as! String
                    strURL += "_thumb.jpg"
                    strURL = "\(PostImage_URL + "/" + strURL)"
                    cell.imgPic.sd_setImage(with: URL.init(string: strURL), placeholderImage: SquarePlaceHolderImage)
                }
                else {
                    strURL = objUserPost_PostImage.imagePath!
                    cell.imgPic.sd_setImage(with: URL.init(string: strURL), placeholderImage: SquarePlaceHolderImage)
                }
            }
            if arrUserPost_PostImage.count > 1 {
                cell.btnCount.isHidden = false
            }
            else {
                cell.btnCount.isHidden = true
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if(indexPath.row == 0) { return }
        else {
            let objVC : PostDetailVC = loadVC(strStoryboardId: SB_FEEDS, strVCId: "PostDetailVC") as! PostDetailVC
            let objUserPostData : PostData = self.objArrUserPost[indexPath.row - 1]
            objVC.selectedpost = objUserPostData
            APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(indexPath.row == 0) {
            return CGSize.init(width: SCREENWIDTH() , height: 40 )
        }
        else {
            return CGSize.init(width: (SCREENWIDTH()/3)-0.10 ,height: (SCREENWIDTH()/3)-0.10)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 250, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //MARK: Collection button action method
    @objc func Manage_PostVideo_Play(sender:UIButton!) {
        let objUserPostData : PostData = self.objArrUserPost[sender.tag - 1]
        var strURL : String = ""
        
        var arrUserPost_PostImage = [PostImages]()
        arrUserPost_PostImage = objUserPostData.postImages!
        
        if (arrUserPost_PostImage.count != 0) {
            let objUserPost_PostImage : PostImages = arrUserPost_PostImage[0]
            
            //Detect Post is Video and manage Play Video--->
            strURL = objUserPost_PostImage.postImage!
            let arrDetectPostType : NSArray = strURL.components(separatedBy: ".") as NSArray
            let strPostExtension : String = arrDetectPostType.lastObject as! String
            
            if (strPostExtension.uppercased() != "jpg".uppercased()) {
                strURL = objUserPost_PostImage.imagePath!
            }
        }
        else {
            showAlertMessage(SomethingWrongMessage)
            return
        }
        
        // Play Video in Full Screen
        let videoURL : URL = URL.init(string: strURL)!
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView.contentOffset.y < 0) {
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
    
    //MARK:- API
    func api_GetOtherUserProfile(userId : String) {
        self.view.endEditing(true)
        let parameter:NSDictionary = ["service":APIGetUserProfile,
                                      "request":["user_id":userId],
                                      "auth" : getAuthForService()]
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIGetUserProfile, parameters: parameter, keyname: "", message: APIGetUserProfileMessage, showLoader: true, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            hideLoaderHUD() // Hide Loader
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_GetOtherUserProfile(userId: userId)
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    //showMessage(statusmessage)
                    
                    let dicRespo : NSDictionary = responseDict?.value(forKey: kData) as! NSDictionary
                    if dicRespo.allKeys.count > 0 {
                        self.objUserProfile = GetUserProfile.init(object: dicRespo)
                    }
                    self.fillValues() // Fill Data in view Profile
                    
                    self.objArrUserPost = self.objUserProfile.postData!
                    self.collectionPhoto.reloadData()
                }
            }
        })
    }
    
    func api_userFollow(parameter : NSDictionary) {
        self.view.endEditing(true)
        self.view.isUserInteractionEnabled = false
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIUserFollow, parameters: parameter, keyname: "", message: "", showLoader: true, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
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
                    let strMessage: String = responseDict!.object(forKey: kMessage) as! String
                    showMessage(strMessage)
                    
                    //Manage Changes Follow Image --->
                    if (self.flag_UserFollow == true) { self.flag_UserFollow = false }
                    else { self.flag_UserFollow = true }
                    self.set_FollowButton_base_on_UserFollow_Status()
                    
                }
            }
        })
    }
    
    func api_BlockUser(parameter : NSDictionary) {
        self.view.endEditing(true)
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIBlockUser, parameters: parameter, keyname: "", message: "", showLoader: true, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
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
                    if (self.objUserProfile.blockedContacts?.uppercased() == "1".uppercased()) {
                        self.objUserProfile.blockedContacts = "0"
                    }
                    else {
                        self.objUserProfile.blockedContacts = "1"
                    }
                    
                    //Show Success message
                    let strMessage: String = responseDict!.object(forKey: kMessage) as! String
                    showMessage(strMessage)
                }
            }
        })
    }
}
