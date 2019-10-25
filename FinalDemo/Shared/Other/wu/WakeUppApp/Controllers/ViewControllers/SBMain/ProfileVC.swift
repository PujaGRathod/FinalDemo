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

//For Manage Crop Image
import IGRPhotoTweaks

enum enumPhotoChange : String {
    case PhotoChange_None = "none"
    case PhotoChange_Profile = "Changes_Profile"
    case PhotoChange_Banner = "Changes_Banner"
}

class ProfileVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, ImagePickerDelegate, IGRPhotoTweakViewControllerDelegate 
{
    @IBOutlet weak var viewProfile: UIView!
    
    @IBOutlet weak var storyDot: UIImageView!
    @IBOutlet weak var chatDot: UIImageView!
    
    @IBOutlet weak var viewFollowers: UIView!
    @IBOutlet weak var lblFollowers: UILabel!
    
    @IBOutlet weak var viewFollowing: UIView!
    @IBOutlet weak var lblFollowing: UILabel!
    
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var imgProfilePhoto: UIImageView!
    
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnSetting: UIButton!
    
    @IBOutlet weak var lblUserFullName: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    
    @IBOutlet weak var collectionPhoto: UICollectionView!
    @IBOutlet weak var heightHeaderView: NSLayoutConstraint!
    @IBOutlet weak var rightPadding: NSLayoutConstraint!
    @IBOutlet weak var leftPadding: NSLayoutConstraint!
    
    @IBOutlet weak var viewCountTopSpacing: NSLayoutConstraint!
    
    //MARK: Variable
    var objUserProfile:GetUserProfile! // For use store User Profiledata, getting by WebService.
    var objArrUserPost = [PostData]() // For use store User PostData, getting by WebService.
    var strAPILoadMess : String = ""    
    var objEnumPhotoChange : enumPhotoChange = .PhotoChange_None
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.fillData() // Fill Data in view Profile
        self.add_NotificationObserver()
        
        //Called API
        strAPILoadMess = APIGetUserProfileMessage
        self.api_GetUserProfile()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setChatDot), name: NSNotification.Name(NC_ChatDotChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setStoryDot), name: NSNotification.Name(NC_StoryDotChanged), object: nil)
        
        setChatDot()
        setStoryDot()
        
    }
    
    @objc func setChatDot() {
        chatDot.isHidden = !APP_DELEGATE.chatDotVisible
    }
    
    @objc func setStoryDot(){
        storyDot.isHidden = !APP_DELEGATE.storyDotVisible
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Custom Function
    func setupUI()  {
        isStatusBarHidden = false
        collectionPhoto.delegate = self
        collectionPhoto.dataSource = self
        //collectionPhoto.backgroundColor = UIColor.white
        
        runAfterTime(time: 0.1) {
            self.viewFollowers.roundCorners([.topRight,.bottomRight], radius: 20.0)
            self.viewFollowing.roundCorners([.topLeft,.bottomLeft], radius: 20.0)
        }
        self.view.layoutIfNeeded() // viewFollowing View rounde corner not proper set
    }
    
    func fillData()  {
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
            strCover = "\(Get_Profile_Pic_URL + "/" + strCover)"
            strPhoto = UserDefaultManager.getStringFromUserDefaults(key:kAppUserProfile)
            strNoOfFollowers = "0"
            strNoOfFollowings = "0"
            
            strFullName = UserDefaultManager.getStringFromUserDefaults(key:kAppUserFullName)
            strUsername = UserDefaultManager.getStringFromUserDefaults(key:kUsername)
            strBio = UserDefaultManager.getStringFromUserDefaults(key:kBio)
        }
        
        
        //Banner
        imgCover.sd_setImage(with: URL(string: strCover), placeholderImage: imgCover.image)
        
        //Logo
        imgProfilePhoto.sd_setImage(with: URL(string: strPhoto), placeholderImage: ProfilePlaceholderImage)
        
        
        lblFollowers.text = strNoOfFollowers + "\nfollowers".uppercased()
        lblFollowers.font = FontWithSize(lblFollowers.font.familyName, 10)
        
        lblFollowing.text = strNoOfFollowings + "\nfollowings".uppercased()
        lblFollowing.font = FontWithSize(lblFollowing.font.familyName, 10)
        
        lblUserFullName.text = strFullName
        lblUserName.text = strUsername
        lblAddress.text = strBio // Show Bio Data
        lblAddress.numberOfLines = 2
    }
    
    //MARK:-  Notifi. Obs. Method
    func add_NotificationObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(update_ProfileData(notification:)), name: NSNotification.Name(rawValue: NC_UpdateProfile), object: nil) // Manage re-call get profile API, if update profile.
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload_ProfileData), name: NSNotification.Name(rawValue: NC_UpdateProfile_Followings), object: nil) // Manage re-call get profile API, if  profile change followings.
    }
    
    
    @objc func update_ProfileData(notification: NSNotification) {
        //Get received obj.
        let objUser : User = notification.object as! User
        
        let strPhoto = objUser.imagePath ?? "---"
        let strFullName = objUser.fullName ?? "---"
        let strUsername = objUser.username ?? "---"
        let strBio = objUser.bio ?? "---"
        
        imgProfilePhoto.sd_setImage(with: URL(string: strPhoto), placeholderImage: ProfilePlaceholderImage) //Logo
        
        lblUserFullName.text = strFullName //Fullname
        lblUserName.text = strUsername //Username
        lblAddress.text = strBio // Show Bio Data
    }
    
    @objc func reload_ProfileData() {
        strAPILoadMess = ""
        self.api_GetUserProfile()
    }
    
    //MARK:- Top bar Button Action
    @IBAction func btnchatclicked(_ sender: Any) {
        let storyvc = loadVC(strStoryboardId: SB_CHAT, strVCId: "chatlistvc") as! ChatListVC
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
    }
    
    @IBAction func btnstoryclicked(_ sender: Any) {
        let storyvc = loadVC(strStoryboardId: SB_STORIES, strVCId: idStoriesVC) as! StoriesVC
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
    }
    
    @IBAction func btnpostclicked(_ sender: Any) {
        let storyvc = loadVC(strStoryboardId: SB_FEEDS, strVCId: idFeedVC) as! FeedVC
        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
    }
    
    @IBAction func btchannelclicked(_ sender: Any) {
        //        let storyvc = loadVC(strStoryboardId: SB_FEEDS, strVCId: "NotificationVC") as! NotificationVC
        //        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
        
        let objVC = loadVC(strStoryboardId: SB_CHANNEL, strVCId: idChannelListVC)
        APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: false)
    }
    
    @IBAction func btnuserclicked(_ sender: Any) {
        //        let storyvc = loadVC(strStoryboardId: SB_MAIN, strVCId: "ProfileVC") as! ProfileVC
        //        APP_DELEGATE.appNavigation?.pushViewController(storyvc, animated: false)
    }
    
    //MARK: Button Action Method
    @IBAction func btnSearchAction() {
        
        let objVC : SearchVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idSearchVC) as! SearchVC
        APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
    }
    
    @IBAction func btnOptionClickAction() {
        //--- --- --->
    }
    
    @IBAction func btnProfileAction() {
        /*let configuration = ImageViewerConfiguration { config in
         config.imageView = imgProfilePhoto
         }
         let imageViewerController = ImageViewerController(configuration: configuration)
         APP_DELEGATE.appNavigation?.present(imageViewerController, animated: false, completion: nil)*/
        
        self.objEnumPhotoChange = .PhotoChange_Profile
        
        //Manage Edit Profile
        ImagePicker.sharedInstance.delegate = self
        ImagePicker.sharedInstance.selectImage(sender: self.objEnumPhotoChange.rawValue)
    }
    
    @IBAction func btnProfile_BannerEditAction() {
        
        self.objEnumPhotoChange = .PhotoChange_Banner
        
        //Manage Edit Profile Banner
        ImagePicker.sharedInstance.delegate = self
        ImagePicker.sharedInstance.selectImage(sender: self.objEnumPhotoChange.rawValue)
    }
    
    @IBAction func btnProfile_BannerAction() {
        let configuration = ImageViewerConfiguration { config in
            config.imageView = self.imgCover
        }
        let imageViewerController = ImageViewerController(configuration: configuration)
        APP_DELEGATE.appNavigation?.present(imageViewerController, animated: false, completion: nil)
    }
    
    @IBAction func btnEditAction() {
        //if (objUserProfile == nil) { return }
        
        let objEditProVC : EditProfileVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idEditProfileVC) as! EditProfileVC
        //objEditProVC.objUserProfile = objUserProfile
        APP_DELEGATE.appNavigation?.pushViewController(objEditProVC, animated: true)
    }
    
    @IBAction func btnSettingAction() {
        //if (objUserProfile == nil) { return }
        
        let objVC : ProfileSettingVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idProfileSettingVC) as! ProfileSettingVC
        APP_DELEGATE.appNavigation?.pushViewController(objVC, animated: true)
    }
    
    @IBAction func btnFollowersAction() {
        if (self.objUserProfile == nil) { return }
        if (self.objUserProfile.followers == 0) { return }
        
        let objPopupVC : PopupVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idPopupVC) as! PopupVC
        objPopupVC.modalPresentationStyle = .overCurrentContext
        objPopupVC.objEnumPopup = .enumPopup_Followers
        objPopupVC.strTitle = "Followers".uppercased()
        objPopupVC.strUserID = UserDefaultManager.getStringFromUserDefaults(key:kAppUserId)
        self.present(objPopupVC, animated: true, completion: nil)
    }
    
    @IBAction func btnFollowingsAction() {
        if (self.objUserProfile == nil) { return }
        if (self.objUserProfile.following == 0) { return }
        
        let objPopupVC : PopupVC = loadVC(strStoryboardId: SB_MAIN, strVCId: idPopupVC) as! PopupVC
        objPopupVC.modalPresentationStyle = .overCurrentContext
        objPopupVC.objEnumPopup = .enumPopup_Following
        objPopupVC.strTitle = "Followings".uppercased()
        objPopupVC.strUserID = UserDefaultManager.getStringFromUserDefaults(key:kAppUserId)
        self.present(objPopupVC, animated: true, completion: nil)
    }
    
    //MARK:- ImagePickerDelegate method
    func pickImageComplete(_ imageData: UIImage, sender: String) {
        
        switch self.objEnumPhotoChange.rawValue {
        case enumPhotoChange.PhotoChange_None.rawValue: break
        case enumPhotoChange.PhotoChange_Profile.rawValue:
            
            //imgProfilePhoto.image = imageData
            //self.api_UploadProfileImage()
            
            //Manage Image Crop
            let imageCropper = loadVC(strStoryboardId: SB_ASSET_PICKER, strVCId: idImageCropperVC) as! ImageCropperVC
            imageCropper.image = imageData
            imageCropper.delegate = self
            APP_DELEGATE.appNavigation?.pushViewController(imageCropper, animated: false)
            
            break
        case enumPhotoChange.PhotoChange_Banner.rawValue:
            self.imgCover.image = imageData
            self.api_UploadProfileImage()
            break
        default:
            break
        }
    }
    
    //MARK: - Crop Selcted Image manage
    func photoTweaksController(_ controller: IGRPhotoTweakViewController, didFinishWithCroppedImage croppedImage: UIImage) {
        imgProfilePhoto.image = croppedImage
        self.api_UploadProfileImage()
        
        //Dismiss VC
        self.photoTweaksControllerDidCancel(controller)
    }
    
    func photoTweaksControllerDidCancel(_ controller: IGRPhotoTweakViewController) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    //MARK:- API
    func api_GetUserProfile() {
        self.view.endEditing(true)
        let parameter:NSDictionary = ["service":APIGetUserProfile,
                                      "request":[:],
                                      "auth" : getAuthForService()]
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIGetUserProfile, parameters: parameter, keyname: "", message: strAPILoadMess, showLoader: true, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_GetUserProfile()
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
                    self.fillData() // Fill Data in view Profile
                    
                    self.objArrUserPost = self.objUserProfile.postData!
                    self.collectionPhoto.reloadData()
                }
            }
        })
    }
    
    func api_UploadProfileImage() {
        
        var strMess : String = ""
        var imgProfileData : Data = Data.init()
        switch self.objEnumPhotoChange {
        case .PhotoChange_None: break
        case.PhotoChange_Profile:
            strMess = APIUpdateUserPhotoMessage
            imgProfileData = UIImageJPEGRepresentation(imgProfilePhoto.image!, 0.4)!
            break
        case .PhotoChange_Banner:
            strMess = APIUpdateUserBannerMessage
            imgProfileData = UIImageJPEGRepresentation(imgCover.image!, 0.4)!
            break
        }
        showLoaderHUD(strMessage: strMess)
        
        let parameter :NSMutableDictionary = ["token_id":UserDefaultManager.getStringFromUserDefaults(key: kToken)]
        let arrChannelImg : NSMutableArray = NSMutableArray.init()
        arrChannelImg.add(imgProfileData)
        parameter.setObject(arrChannelImg, forKey: ("image" as NSString))
        
        HttpRequestManager.sharedInstance.requestWithPostMultipartParam(endpointurl: Upload_Profile_Pic_URL, isImage: true, parameters: parameter) {(data, error, message, responseDict) -> Void in
            
            if error != nil {
                hideLoaderHUD()
                showMessageWithRetry(RetryMessage, 3, buttonTapHandler: { _ in
                    hideBanner()
                    self.api_UploadProfileImage()
                })
                return
            }
            else if let data = data {
                let thedata = data as? NSDictionary
                if(thedata != nil) {
                    print(thedata!)
                    if (thedata?.count)! > 0 {
                        let strUplodedPhotoName: String = thedata!.object(forKey: kData) as! String
                        //print("strUplodedPhotoName: \(strUplodedPhotoName)")
                        
                        
                        switch self.objEnumPhotoChange.rawValue {
                        case enumPhotoChange.PhotoChange_None.rawValue: break
                        case enumPhotoChange.PhotoChange_Profile.rawValue:
                            let parameter:NSDictionary = ["service":APIEditProfilePic,
                                                          "request":["data":["image":strUplodedPhotoName]],
                                                          "auth" : getAuthForService()]
                            self.api_UpdateUserProfilePhoto(parameter: parameter)
                            break
                        case enumPhotoChange.PhotoChange_Banner.rawValue:
                            let parameter:NSDictionary = ["service":APIEditCoverPic,
                                                          "request":["data":["image":strUplodedPhotoName]],
                                                          "auth" : getAuthForService()]
                            self.api_UpdateUserProfile_Banner(parameter: parameter)
                            break
                        default:
                            break
                        }
                    }
                }
                else {
                    showMessage(message!)
                }
                hideLoaderHUD()
            }
            else {
                showMessage(message!)
                hideLoaderHUD()
            }
        }
    }
    
    func api_UpdateUserProfilePhoto(parameter : NSDictionary) {
        self.view.endEditing(true)
        //print("parameter: \(parameter)")
        self.view.isUserInteractionEnabled = false
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIEditProfilePic, parameters: parameter, keyname: "", message: APIUpdateUserPhotoMessage, showLoader: true, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            self.view.isUserInteractionEnabled = true
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_UpdateUserProfilePhoto(parameter: parameter)
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    //Success Mess.
                    //let strMessage: String = responseDict!.object(forKey: kMessage) as! String
                    //showMessage(strMessage)
                    
                    let dicRespo : NSDictionary = responseDict?.value(forKey: kData) as! NSDictionary
                    if dicRespo.allKeys.count > 0 {
                        self.objUserProfile = GetUserProfile.init(object: dicRespo)
                    }
                    
                    //New Photo URL update in UserDefault
                    UserDefaultManager.setStringToUserDefaults(value: self.objUserProfile.imagePath!, key: kAppUserProfile)
                    
                    //Profile Photo
                    self.imgProfilePhoto.sd_setImage(with: URL(string: self.objUserProfile.imagePath!), placeholderImage: ProfilePlaceholderImage)
                }
            }
        })
    }
    
    
    func api_UpdateUserProfile_Banner(parameter : NSDictionary) {
        self.view.endEditing(true)
        self.view.isUserInteractionEnabled = false
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIEditCoverPic, parameters: parameter, keyname: "", message: APIUpdateUserBannerMessage, showLoader: true, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            self.view.isUserInteractionEnabled = true
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_UpdateUserProfile_Banner(parameter: parameter) 
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    //Success Mess.
                    //let strMessage: String = responseDict!.object(forKey: kMessage) as! String
                    //showMessage(strMessage)
                    
                    let dicRespo : NSDictionary = responseDict?.value(forKey: kData) as! NSDictionary
                    if dicRespo.allKeys.count > 0 {
                        self.objUserProfile = GetUserProfile.init(object: dicRespo)
                    }
                    
                    //New Photo URL update in UserDefault
                    UserDefaultManager.setStringToUserDefaults(value: self.objUserProfile.coverimage!, key: kAppUserProfile_Banner)
                    
                    //Profile Photo
                    let strURL : String = "\(Get_Profile_Pic_URL + "/" + self.objUserProfile.coverimage!)"
                    self.imgCover.sd_setImage(with: URL(string: strURL), placeholderImage: #imageLiteral(resourceName: "wall"))
                }
            }
        })
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
            //return cell //-------->
            
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
                    //New Sueested by Payal U.
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
            if arrUserPost_PostImage.count > 1
            {
                cell.btnCount.isHidden = false
            }
            else
            {
                cell.btnCount.isHidden = true
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.row == 0) {
            return
        }
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
            return CGSize.init(width: (SCREENWIDTH()/3)-0.10 ,height: (SCREENWIDTH()/3))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
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
}
