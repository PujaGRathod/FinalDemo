//
//  RegisterVC.swift
//  WakeUppApp
//
//  Created by Payal Umraliya on 21/03/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import IQDropDownTextField
import TransitionButton
import SwiftyJSON

//For Manage Crop Image
import IGRPhotoTweaks

class RegisterVC: UIViewController {
    
    /*@IBOutlet var imgpersonal: UIImageView!
     @IBOutlet var imgbusiness: UIImageView!
     @IBOutlet var btnbusiness: UIButton!
     @IBOutlet var btnpersonal: UIButton!*/
    @IBOutlet var imgprofile: UIImageView!
    @IBOutlet var btnprofile: UIButton!
    @IBOutlet var txtusername: UITextField!
    @IBOutlet var txtname: UITextField!
    @IBOutlet var txtbirth: IQDropDownTextField!
    @IBOutlet var vwtxtbio: UIView!
    @IBOutlet var txtbio: IQTextView!
    @IBOutlet var btnback: UIButton!
    
    var selectedImage : UIImage?{
        didSet{
            imgprofile.image = selectedImage
        }
    }
    var uploadedImageName = ""
    
    @IBOutlet var btnproceed: TransitionButton!
    var isbusiness = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        if UserDefaultManager.getBooleanFromUserDefaults(key: kAlreadyRegisterd) == true {
            self.setProfile()
        }
        
        //PV
        UserDefaultManager.setBooleanToUserDefaults(value: false, key: kChatBackupRestore)
        //Check if user already upload backup on iCloud to show alert to restore chat.
        let objVC = loadVC(strStoryboardId: SB_CHAT, strVCId:"ImportExportProcessVC" ) as! ImportExportProcessVC
        objVC.strImgURL = ""
        objVC.strTitle = "Import chat"
        objVC.objEnumImpExpoAction = .Import_AppChat
        objVC.Popup_Show(onViewController: self)
    }
    
    func setupUI()
    {
        self.btnback.isHidden = true
        self.txtusername.addPaddingLeftIcon(UIImage.init(named: "name_textbox")!, padding: 15)
        self.txtname.addPaddingLeftIcon(UIImage.init(named: "name_textbox")!, padding: 15)
        self.txtbirth.addPaddingLeftIcon(UIImage.init(named: "dob_textbox")!, padding: 15)
        
        self.txtbirth.dropDownMode = IQDropDownMode.datePicker
        
        //self.imgprofile.layer.cornerRadius = self.imgprofile.frame.size.height/2
        //self.imgprofile.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        //self.imgprofile.layer.borderWidth = 2
    }
    func setProfile()
    {
        let jsonData = JSON(UserDefaultManager.getCustomObjFromUserDefaults(key: kAppUser))
        let userdata:User = User.init(json: jsonData)
        if userdata.userType == "personal"
        {
            /*btnbusiness.accessibilityLabel = "0"
             btnpersonal.accessibilityLabel = "1"
             self.imgbusiness.image = UIImage.init(named: "business_account")
             self.imgpersonal.image = UIImage.init(named: "pers_checked")*/
            isbusiness = false
        }
        else
        {
            /*btnbusiness.accessibilityLabel = "1"
             btnpersonal.accessibilityLabel = "0"
             self.imgbusiness.image = UIImage.init(named: "busi_checked")
             self.imgpersonal.image = UIImage.init(named: "personal_account")*/
            isbusiness = true
        }
        if userdata.birthDate != nil{
            txtbirth.setDate(DateFormater.getBirthDateFromString(givenDate: userdata.birthDate!) as Date, animated: false)
        }
        txtusername.text = userdata.username
        txtname.text = userdata.fullName
        txtbio.text = userdata.bio
        
        imgprofile.sd_setShowActivityIndicatorView(true)
        imgprofile.sd_setImage(with: userdata.imagePath?.toUrl, placeholderImage: #imageLiteral(resourceName: "channel_placeholder"), options: .delayPlaceholder) { (img, err, cahce, url) in
        }
    }
    
    @IBAction func btnsubmitclicked(_ sender: Any)
    {
        if /*validateTxtFieldLength(txtusername, withMessage: EnterUserName) &&*/ validateTxtFieldLength(txtname, withMessage: EnterName) &&
            validateTxtFieldLength(txtbirth, withMessage: SelectBirthDate)
        {
            let selectedBirthDate = txtbirth.date
            //var currentDate = Date()
            
            let age = DateFormater.calculateAge(birthdate: selectedBirthDate!)
            if age < Limit_Age {
                showMessage("You must be \(Limit_Age) years old to continue using \(APPNAME)!")
            }
            else {
                if selectedImage == nil{
                    if uploadedImageName.count == 0{
                        if UserDefaultManager.getBooleanFromUserDefaults(key: kAlreadyRegisterd) == true
                        {
                            let jsonData = JSON(UserDefaultManager.getCustomObjFromUserDefaults(key: kAppUser))
                            let userdata:User = User.init(json: jsonData)
                            let profilePath = userdata.imagePath
                            if profilePath!.count > 0{
                                let imageName = profilePath!.components(separatedBy: "/").last
                                if let imgName = imageName{
                                    uploadedImageName = imgName
                                }
                            }
                        }
                    }
                    self.api_SignUp()
                }else{
                    self.api_UploadImage()
                }
            }
        }
    }
    @IBAction func btnbackclicked(_ sender: Any) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func btnprofileclicked(_ sender: Any)
    {
        ImagePicker.sharedInstance.delegate = self
        ImagePicker.sharedInstance.selectImage(sender: "Profile Photo")
    }
    @IBAction func btnbusinessclicked(_ sender: UIButton)
    {
        if sender.accessibilityLabel == "1"
        {
            sender.accessibilityLabel = "0"
            /*self.imgbusiness.image = UIImage.init(named: "business_account")
             self.imgpersonal.image = UIImage.init(named: "pers_checked")*/
            isbusiness = false
        }
        else
        {
            sender.accessibilityLabel = "1"
            /*self.imgbusiness.image = UIImage.init(named: "busi_checked")
             self.imgpersonal.image = UIImage.init(named: "personal_account")*/
            isbusiness = true
        }
        
    }
    @IBAction func btnpersonalclicked(_ sender: UIButton)
    {
        if sender.accessibilityLabel == "1"
        {
            sender.accessibilityLabel = "0"
            /*self.imgpersonal.image = UIImage.init(named: "personal_account")
             self.imgbusiness.image = UIImage.init(named: "busi_checked")*/
            isbusiness = true
        }
        else
        {
            sender.accessibilityLabel = "1"
            /*self.imgpersonal.image = UIImage.init(named: "pers_checked")
             self.imgbusiness.image = UIImage.init(named: "business_account")*/
            isbusiness = false
        }
    }
    
    //MARK:- API
    func api_SignUp()
    {
        self.view.endEditing(true)
        let parameter:NSDictionary = ["service":APIUpdateUser,
                                      "request":
                                        ["data":[
                                            "full_name":txtname.text!,
                                            "username":txtusername.text!,
                                            "phoneno": UserDefaultManager.getStringFromUserDefaults(key: kAppUserMobile),
                                            "birth_date":DateFormater.generateBirthDateForGivenDate(strDate: txtbirth.date! as NSDate),
                                            "bio": txtbio.text!,
                                            "user_type": isbusiness ? "business" : "personal",
                                            "platform":PlatformName,
                                            "device_id":GetDeviceToken,
                                            "image" : uploadedImageName
                                            ]
            ],
                                      "auth" : getAuthForService()
        ]
        
        self.view.isUserInteractionEnabled = false
        self.btnproceed.startAnimation()
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIUpdateUser, parameters: parameter, keyname: ResponseKey as NSString, message: APISignUpMessage, showLoader: false,
                                                                   responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
                                                                    
                                                                    self.btnproceed.stopAnimation()
                                                                    self.view.isUserInteractionEnabled = true
                                                                    
                                                                    if error != nil
                                                                    {
                                                                        showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                                                                            self.api_SignUp()
                                                                        })
                                                                        return
                                                                    }
                                                                    else
                                                                    {
                                                                        if Int(apistatus) == 0
                                                                        {
                                                                            showMessage(statusmessage)
                                                                        }
                                                                        else
                                                                        {
                                                                            if responseArray!.count > 0
                                                                            {
                                                                               let homevc = loadVC(strStoryboardId: SB_CHAT, strVCId: idChatListVC) as! ChatListVC
                                                                               
                                                                                APP_DELEGATE.appNavigation?.pushViewController(homevc, animated: false)
                                                                                APP_DELEGATE.socketIOHandler = SocketIOHandler()
                                                                                APP_DELEGATE.setVoIPRegistry()
                                                                            }
                                                                            else
                                                                            {
                                                                                showMessage(statusmessage)
                                                                            }
                                                                        }
                                                                    }
        })
    }
    
    func api_UploadImage(){
        showLoaderHUD(strMessage: "Uploading Profile Picture")
        let parameter :NSMutableDictionary = ["token_id":UserDefaultManager.getStringFromUserDefaults(key: kToken)]
        let imageData:Data = UIImageJPEGRepresentation(selectedImage!, uploadImageCompression)!
        parameter.setObject(imageData, forKey: ("image" as NSString))
        
        HttpRequestManager.sharedInstance.requestWithPostMultipartParam(endpointurl: Upload_Profile_Pic_URL, isImage: true, parameters: parameter) {(data, error, message, responseDict) -> Void in
            if error != nil
            {
                hideLoaderHUD()
                showMessageWithRetry(RetryMessage, 3, buttonTapHandler: { _ in
                    hideBanner()
                    self.api_UploadImage()
                })
                return
            }
            else if let data = data
            {
                let thedata = data as? NSDictionary
                if(thedata != nil)
                {
                    //print("api_UploadImage : \(thedata!)")
                    if (thedata?.count)! > 0
                    {
                        self.uploadedImageName = thedata!.object(forKey: kData) as! String
                        self.api_SignUp()
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

extension RegisterVC:ImagePickerDelegate, IGRPhotoTweakViewControllerDelegate {
    //MARK - Get Selcted Image
    func pickImageComplete(_ imageData: UIImage, sender: String) {
        //selectedImage = imageData
        
        //Manage Image Crop
        let imageCropper = loadVC(strStoryboardId: SB_ASSET_PICKER, strVCId: idImageCropperVC) as! ImageCropperVC
        imageCropper.image = imageData
        imageCropper.delegate = self
        APP_DELEGATE.appNavigation?.pushViewController(imageCropper, animated: false)
    }
    
    //MARK - Crop Selcted Image manage
    func photoTweaksController(_ controller: IGRPhotoTweakViewController, didFinishWithCroppedImage croppedImage: UIImage) {
        selectedImage = croppedImage
        
        //Dismiss VC
        self.photoTweaksControllerDidCancel(controller)
    }
    
    func photoTweaksControllerDidCancel(_ controller: IGRPhotoTweakViewController) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
}
