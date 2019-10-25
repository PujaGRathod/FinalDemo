//
//  EditProfileVC.swift
//  WakeUppApp
//
//  Created by C025 on 26/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

//For Manage Crop Image
import IGRPhotoTweaks

enum enumProfile : Int {
    case Profile_View = 0
    case Profile_Edit
}

class EditProfileVC: UIViewController, ImagePickerDelegate, IGRPhotoTweakViewControllerDelegate {
    //MARK: Outlet
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var imgBanner: UIImageView! 
    @IBOutlet weak var imgPhoto: UIImageView!
    
    @IBOutlet weak var btnChangeCover: UIButton!
    @IBOutlet weak var btnChangePhoto: UIButton!
    
    //@IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPhoneNo: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtDOB: UITextField!
    @IBOutlet weak var txtBiodata: IQTextView!
   
    @IBOutlet weak var btnChangeDOB: UIButton!
    
     @IBOutlet weak var btnUpdateProfile: UIButton!
    
    //MARK: Variable
    var objUserProfile:GetUserProfile! // For use store User Profiledata, getting by Privious VC
    var strUploadProfilePhotoName : String = ""
    
    var update_ProfilePhoto : Bool = false
    var update_ProfileBanner : Bool = false
    var objEnumProfile : enumProfile = .Profile_View
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.fillData()
        
        switch objEnumProfile {
        case .Profile_View:
            self.manage_ViewProfile()
            break
            
        case .Profile_Edit:
            self.manage_EditProfile()
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Custom Function
    func setupUI()  {
        
        /*//Not Working
         //self.imgBanner.roundCorners([.topRight,.bottomRight], radius: 20.0)
         //self.viewTop.roundCorners([.topRight,.bottomRight], radius: 20.0)*/
        
        self.imgBanner.cornerRadius = 25
        
        imgPhoto.cornerRadius = imgPhoto.frame.height/2
        imgPhoto.layer.masksToBounds = true
        
        //Add Padding in TextFiled
        txtName.addPaddingLeftIcon(#imageLiteral(resourceName: "name_textbox_g"), padding: 20)
        txtPhoneNo.addPaddingLeftIcon(#imageLiteral(resourceName: "mobile_textbox_g"), padding: 20)
        txtDOB.addPaddingLeftIcon(#imageLiteral(resourceName: "dob_textbox_g"), padding: 20)
    }
    
    func fillData() {
        if (objUserProfile == nil) {
            var strBanner = UserDefaultManager.getStringFromUserDefaults(key:kAppUserProfile_Banner)
            strBanner = "\(Get_Profile_Pic_URL + "/" + strBanner)"
            imgBanner.sd_setImage(with: URL(string: strBanner), placeholderImage: #imageLiteral(resourceName: "wall"))
            
            let strPhoto = UserDefaultManager.getStringFromUserDefaults(key:kAppUserProfile)
            imgPhoto.sd_setImage(with: URL(string: strPhoto), placeholderImage: ProfilePlaceholderImage)
            
            txtName.text = UserDefaultManager.getStringFromUserDefaults(key:kAppUserFullName)
            var strFullPhoneNo = "+"
            strFullPhoneNo += UserDefaultManager.getStringFromUserDefaults(key:kAppUserCountryCode)
            strFullPhoneNo += " "
            strFullPhoneNo += UserDefaultManager.getStringFromUserDefaults(key:kAppUserMobile)
            txtPhoneNo.text = strFullPhoneNo
            txtDOB.text = UserDefaultManager.getStringFromUserDefaults(key:kDateOfBrith)
            txtBiodata.text = UserDefaultManager.getStringFromUserDefaults(key:kBio)
            return
        }
        
        //Cover
        //Profile Photo
        let strBanner : String = "\(Get_Profile_Pic_URL + "/" + self.objUserProfile.coverimage!)"
        imgBanner.sd_setImage(with: URL(string: strBanner), placeholderImage: #imageLiteral(resourceName: "wall"))
        
        //Logo
        imgPhoto.sd_setImage(with: URL(string: objUserProfile.imagePath!), placeholderImage: ProfilePlaceholderImage)
        
        //Fill Values
        txtName.text = objUserProfile.fullName!
        //txtUsername.text = objUserProfile.username!
        
        var strFullPhoneNo = "+"
        strFullPhoneNo += objUserProfile.countryCode!
        strFullPhoneNo += " "
        strFullPhoneNo += objUserProfile.phoneno!
        txtPhoneNo.text = strFullPhoneNo
        txtDOB.text = objUserProfile.birthDate!
        txtBiodata.text = objUserProfile.bio!
    }
    
    func manage_ViewProfile() -> Void {
        
        self.btnBack.setTitle("Profile", for: .normal)
        self.btnEdit.isHidden = false
        self.btnEdit.setTitle("Edit", for: .normal)
        
        self.btnChangeCover.isHidden = true
        self.btnChangePhoto.isHidden = true
        
        self.txtName.isUserInteractionEnabled = false
        self.btnChangeDOB.isUserInteractionEnabled = false
        self.txtBiodata.isUserInteractionEnabled = false
        
        self.btnUpdateProfile.isHidden = true
        
        self.view.endEditing(true)
    }
    
    func manage_EditProfile() -> Void {
        self.btnBack.setTitle("Edit Profile", for: .normal)
        //self.btnEdit.isHidden = true
        self.btnEdit.setTitle("Cancel", for: .normal)
        
        self.btnChangeCover.isHidden = false
        self.btnChangePhoto.isHidden = false
        
        self.txtName.isUserInteractionEnabled = true
        self.btnChangeDOB.isUserInteractionEnabled = true
        self.txtBiodata.isUserInteractionEnabled = true
        
        self.btnUpdateProfile.isHidden = false
        
        runAfterTime(time: 0.30) {
            self.txtName.becomeFirstResponder()
        }
    }
    
    //MARK: - Button action method
    @IBAction func btnBackAction() {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnEditAction(_ sender: Any) {
        
        if (btnEdit.titleLabel?.text?.uppercased() == "Cancel".uppercased()) {
            self.objEnumProfile = .Profile_View
            self.manage_ViewProfile()
        }
        else {
            self.objEnumProfile = .Profile_Edit
            self.manage_EditProfile()
        }
    }
    
    @IBAction func btnChangeCoverAction() {
        ImagePicker.sharedInstance.delegate = self
        ImagePicker.sharedInstance.selectImage(sender: "ProfileCover")
    }
    
    @IBAction func btnChangePhotoAction() {
        ImagePicker.sharedInstance.delegate = self
        ImagePicker.sharedInstance.selectImage(sender: "ProfilePhoto")
    }
    
    @IBAction func btnChangeDOBAction() {
        DatePicker.sharedInstance.showDateTimePicker(title: "Select your brithdate", pickerMode: UIDatePickerMode.date, style: UIAlertControllerStyle.actionSheet) { (selectedDate) in
            
            let age = DateFormater.calculateAge(birthdate: selectedDate)
            if age < Limit_Age {
                showMessage("You must be \(Limit_Age) years old to using \(APPNAME)!")
            }
            else {
                self.txtDOB.text = DateFormater.generateBirthDateForGivenDate(strDate: selectedDate as NSDate)
            }
        }
    }
    
    @IBAction func btnUpdateProfileAction() {
        //if (objUserProfile == nil) {return}
        
        //Validation
        //Name
        if (TRIM(string: txtName.text as Any).count == 0) {
            txtName.shake()
            showMessage(EnterName);
            return
        }
        /*
         //Username
         if (TRIM(string: txtUsername.text as Any).count == 0) {
         txtUsername.shake()
         showMessage(EnterUserName);
         return
         }
         //MobileNo
         if (TRIM(string: txtPhoneNo.text as Any).count == 0) {
         txtPhoneNo.shake()
         showMessage(EnterMobileNumber);
         return
         }*/
        //DOB
        if (TRIM(string: txtDOB.text as Any).count == 0) {
            txtDOB.shake()
            showMessage(SelectBirthDate);
            return
        }
        /*
         //Biodata
         if (TRIM(string: txtBiodata.text as Any).count == 0) {
         txtBiodata.shake()
         showMessage(EnterBio);
         return
         }*/
        
        //self.api_UploadProfileImage()
        
        
        //Manage called API
        //Upload Photo
        if (self.update_ProfileBanner == true) && (self.update_ProfilePhoto == true) {
            self.api_UploadProfileBanner()
            self.api_UploadProfilePhoto()
        }
        else if (self.update_ProfileBanner == true) { self.api_UploadProfileBanner() }
        else {
            if (self.update_ProfilePhoto == true) { self.api_UploadProfilePhoto() }
            else {
                var strUserPhotoName = UserDefaultManager.getStringFromUserDefaults(key:kAppUserProfile)
                strUserPhotoName = strUserPhotoName.components(separatedBy: "/").last!
                self.strUploadProfilePhotoName = strUserPhotoName
                
                self.api_UpdateUser()
            }
        }
    }
    
    //MARK:- ImagePickerDelegate method
    
    func pickImageComplete(_ imageData: UIImage, sender: String) {
        if (sender.uppercased() == "ProfilePhoto".uppercased()) {
            //imgPhoto.image = imageData
            
            //Manage Image Crop
            let imageCropper = loadVC(strStoryboardId: SB_ASSET_PICKER, strVCId: idImageCropperVC) as! ImageCropperVC
            imageCropper.image = imageData
            imageCropper.delegate = self
            APP_DELEGATE.appNavigation?.pushViewController(imageCropper, animated: false)
        }
        else if (sender.uppercased() == "ProfileCover".uppercased()) {
            self.imgBanner.image = imageData
            update_ProfileBanner = true
        }
    }
    
    
    //MARK:- CropImg Delegate Method
    func photoTweaksController(_ controller: IGRPhotoTweakViewController, didFinishWithCroppedImage croppedImage: UIImage) {
        imgPhoto.image = croppedImage
        
        update_ProfilePhoto = true
        
        //Dismiss VC
        self.photoTweaksControllerDidCancel(controller)
    }
    
    func photoTweaksControllerDidCancel(_ controller: IGRPhotoTweakViewController) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    //MARK:- API
    //MARK: Manage Profile Photo and OtheInfo Update
    func api_UploadProfilePhoto() {
        showLoaderHUD(strMessage: APIUpdateUserMessage)
        showHUD()
        
        let parameter :NSMutableDictionary = ["token_id":UserDefaultManager.getStringFromUserDefaults(key: kToken)]
        
        let imgProfilePhoto_Data:Data = UIImageJPEGRepresentation(imgPhoto.image!, 0.4)!
        let arrProfileImg : NSMutableArray = NSMutableArray.init()
        arrProfileImg.add(imgProfilePhoto_Data)
        parameter.setObject(arrProfileImg, forKey: ("image" as NSString))
        
        HttpRequestManager.sharedInstance.requestWithPostMultipartParam(endpointurl: Upload_Profile_Pic_URL, isImage: true, parameters: parameter) {(data, error, message, responseDict) -> Void in
            
            hideHUD()
            
            if error != nil {
                hideLoaderHUD()
                showMessageWithRetry(RetryMessage, 3, buttonTapHandler: { _ in
                    hideBanner()
                    self.api_UploadProfilePhoto()
                })
                return
            }
            else if let data = data {
                let thedata = data as? NSDictionary
                if(thedata != nil) {
                    print(thedata!)
                    if (thedata?.count)! > 0 {
                        let strUplodedPhotoName: String = thedata!.object(forKey: kData) as! String
                        
                        self.strUploadProfilePhotoName = strUplodedPhotoName
                        self.api_UpdateUser()
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
    func api_UpdateUser() {
        self.view.endEditing(true)
        
        var strUserName : String = TRIM(string: txtName.text as Any)
        strUserName = strUserName.replacingOccurrences(of: " ", with: "_")
        strUserName = strUserName.lowercased()
        let strPhoneNo : String = UserDefaultManager.getStringFromUserDefaults(key:kAppUserMobile) //objUserProfile.phoneno!
        
        let parameter:NSDictionary = ["service":APIUpdateUser,
                                      "request":["data":[
                                        "full_name": TRIM(string: txtName.text as Any),
                                        //"username": TRIM(string: txtUsername.text as Any),
                                        "username": strUserName,
                                        //"phoneno":TRIM(string: txtPhoneNo.text as Any),
                                        "phoneno":strPhoneNo,
                                        "birth_date":TRIM(string: txtDOB.text as Any),
                                        "bio":TRIM(string: txtBiodata.text as Any),
                                        "image":strUploadProfilePhotoName,
                                        "user_type":"personal",
                                        "platform":PlatformName,
                                        "device_id":UserDefaultManager.getStringFromUserDefaults(key: kAppDeviceToken)]],
                                      "auth" : getAuthForService()]
        //print("parameter: \(parameter)")
        
        self.view.isUserInteractionEnabled = false
        
        showHUD()
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIUpdateUser, parameters: parameter, keyname: "", message: APIUpdateUserMessage, showLoader: false, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            hideHUD()
            
            self.view.isUserInteractionEnabled = true
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_UpdateUser()
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    
                    let objUser : User = User.init(object: responseDict?.object(forKey: kData)! as Any)
                    //Updated Info Update in UserDefault
                    UserDefaultManager.setStringToUserDefaults(value: objUser.imagePath ?? "", key: kAppUserProfile) //ProfilePhoto URL
                    UserDefaultManager.setStringToUserDefaults(value: objUser.fullName ?? "", key: kAppUserFullName) //Fullname
                    UserDefaultManager.setStringToUserDefaults(value: objUser.username ?? "", key: kUsername) //Username
                    UserDefaultManager.setStringToUserDefaults(value: objUser.birthDate ?? "", key: kDateOfBrith) //DOB
                    UserDefaultManager.setStringToUserDefaults(value: objUser.bio ?? "", key: kBio) //Bio
                    
                    //Called Notif.Obs. for show updated profile data
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NC_UpdateProfile), object: objUser, userInfo: nil)
                    
                    let strMessage: String = responseDict!.object(forKey: kMessage) as! String
                    showMessage(strMessage)
                    
                    self.btnBackAction() //Move to back.
                    
                    //Called Socket for inform all user
                    let dicData = ["user_id":objUser.userId,
                               "imagename":objUser.imagePath,
                               "bio":objUser.bio,
                               "fullname":objUser.fullName,
                               "birthdate":objUser.birthDate]
                    APP_DELEGATE.socketIOHandler?.socket?.emit(keyNotify_Update_UserBioProfile, with: [dicData])
                }
            }
        })
    }
    
    //MARK: Manage Banner Update
    func api_UploadProfileBanner() {
        
        if (self.update_ProfilePhoto == false) {
            showLoaderHUD(strMessage: APIUpdateUserMessage)
            showHUD()
        }
        let parameter :NSMutableDictionary = ["token_id":UserDefaultManager.getStringFromUserDefaults(key: kToken)]
        
        let imgProfileBanner_Data:Data = UIImageJPEGRepresentation(imgBanner.image!, 0.4)!
        let arrProfileImg : NSMutableArray = NSMutableArray.init()
        arrProfileImg.add(imgProfileBanner_Data)
        
        parameter.setObject(arrProfileImg, forKey: ("image" as NSString))
        
        HttpRequestManager.sharedInstance.requestWithPostMultipartParam(endpointurl: Upload_Profile_Pic_URL, isImage: true, parameters: parameter) {(data, error, message, responseDict) -> Void in
            
            hideHUD()
            
            if error != nil {
                hideLoaderHUD()
                showMessageWithRetry(RetryMessage, 3, buttonTapHandler: { _ in
                    hideBanner()
                    self.api_UploadProfileBanner()
                })
                return
            }
            else if let data = data {
                let thedata = data as? NSDictionary
                if(thedata != nil) {
                    print(thedata!)
                    if (thedata?.count)! > 0 {
                        let strUplodedPhotoName: String = thedata!.object(forKey: kData) as! String
                        
                        // Called API Update Banner Photo
                        let parameter:NSDictionary = ["service":APIEditCoverPic,
                                                      "request":["data":["image":strUplodedPhotoName]],
                                                      "auth" : getAuthForService()]
                        //print("parameter: \(parameter)")
                        self.api_UpdateUserProfile_Banner(parameter: parameter)
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
                    
                    
                    if (self.update_ProfilePhoto == false) {
                        let strMessage: String = responseDict!.object(forKey: kMessage) as! String
                        showMessage(strMessage)
                        
                        self.btnBackAction() //Move to back.
                    }
                }
            }
        })
    }
}
