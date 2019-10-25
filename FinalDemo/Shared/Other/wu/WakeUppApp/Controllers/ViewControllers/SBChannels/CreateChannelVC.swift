//
//  CreateChannelVC.swift
//  WakeUppApp
//
//  Created by Payal Umraliya on 16/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SwiftyJSON

enum enumChannel : Int {
    case enumChannel_AddNew = 0
    case enumChannel_Update
}

class CreateChannelVC: UIViewController, ImagePickerDelegate {
    
    @IBOutlet var btnback: UIButton!
    @IBOutlet var imgcover: UIImageView!
    @IBOutlet var imgprofile: UIImageView!
    @IBOutlet var txtchannelname: UITextField!
    @IBOutlet var txtchanneldesc: IQTextView!
    @IBOutlet var btnchange: UIButton!
    @IBOutlet var btncreate: UIButton!
    
    //MARK:- Variable
    let strChannelLogoChange : String = "Channel_Logo_Change" // Use detect who photo change
    let strChannelCoverChange : String = "Channel_Cover_Change" // Use detect who photo change
    
    var strChannelLogo_Name : String = "" // For use store channnel logo image name.
    var strChannelCover_Name : String = "" // For use store channnel cover image name.
    
    // For use manage channel add or Update Action manage.
    var objEnumChannel : enumChannel = enumChannel.enumChannel_AddNew //Set Default Add new
    var strChannelID : String = ""
    var strURL_BannerImg : String = ""
    var strURL_Logo : String = ""
    var strChannelName : String = ""
    var strChannelDescription : String = ""
    
    //For use validation manage
    var selectedImage_Cover : UIImage = #imageLiteral(resourceName: "imageplaceholder")
    var selectedImage_Logo : UIImage = #imageLiteral(resourceName: "channel_pro_pic")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set already set placeholder image set for manage check validation.
        selectedImage_Cover = imgcover.image!
        selectedImage_Logo = imgprofile.image!
        
        //Add Padding in TextFiled
        txtchannelname.addPaddingLeft(6)
        
        self.fillValues()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:-  Custon Function
    func fillValues() -> Void {
        var strTopTitle : String = "Create New Channel"
        var strButtonTitle : String = "Create Channel"
        
        switch objEnumChannel {
        case .enumChannel_AddNew:
            strURL_BannerImg = ""
            strURL_Logo = ""
            strChannelName = ""
            strChannelDescription = ""
            break
        case .enumChannel_Update:
            strTopTitle = "Update Channel"
            strButtonTitle = "Update Channel"
            break
        }
        
        //Title
        btnback.setTitle(strTopTitle, for: .normal)
        
        //Banner
        imgcover.sd_setImage(with: URL(string: strURL_BannerImg), placeholderImage: selectedImage_Cover)
        //Logo
        imgprofile.sd_setImage(with: URL(string: strURL_Logo), placeholderImage: selectedImage_Logo)
        
        txtchannelname.text = strChannelName
        txtchanneldesc.text = strChannelDescription
        
        //Button Title
        btncreate.setTitle(strButtonTitle, for: .normal)
    }
    
    //MARK: Button Action
    @IBAction func btnbackclicked(_ sender: Any) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnchangeclicked(_ sender: Any) {
        ImagePicker.sharedInstance.delegate = self
        ImagePicker.sharedInstance.selectImage(sender: strChannelCoverChange)
    }
    
    @IBAction func btnLogoChangeClicked(_ sender: Any) {
        ImagePicker.sharedInstance.delegate = self
        ImagePicker.sharedInstance.selectImage(sender: strChannelLogoChange)
    }
    
    @IBAction func btncreatechannelclicked(_ sender: Any) {
        //Check Validation
        //Channel Cover
        if (imgcover.image == selectedImage_Cover) {
            imgcover.shake()
            showMessage(SelectChannelCover);
            return
        }
        
        //Channel Photo
        if (imgprofile.image == selectedImage_Logo) {
            imgprofile.shake()
            showMessage(SelectChannelPhoto);
            return
        }
        
        //Channel Name
        if (validateTxtFieldLength(txtchannelname, withMessage: EnterChannelName) != true) {
            return
        }
        
        //Channel Desc
        let strChannelDesc = TRIM(string: txtchanneldesc.text)
        if (strChannelDesc.count == 0) {
            txtchanneldesc.shake()
            showMessage(EnterChannelDesc);
            return
        }
        
        //Manage Called Web Service - Upload Channel Image
        switch self.objEnumChannel {
        case .enumChannel_AddNew:
            self.api_UploadImage()
            break
        case .enumChannel_Update:
            //showMessage("Working process for Channel update.")
            self.api_UploadImage()
            break
        }
    }
    
    //MARK: ImagePickerDelegate method
    func pickImageComplete(_ imageData: UIImage, sender: String) {
        if (sender.uppercased() == strChannelCoverChange.uppercased()) {
            imgcover.image = imageData
        }
        else if (sender.uppercased() == strChannelLogoChange.uppercased()) {
            imgprofile.image = imageData
        }
    }
    
    //MARK: API
    func api_UploadImage() {
        switch objEnumChannel {
        case .enumChannel_AddNew:
            showLoaderHUD(strMessage: APIAddChannelMessage)
            break
        case .enumChannel_Update:
            showLoaderHUD(strMessage: "Update Channel")
            break
        }
        
        let parameter :NSMutableDictionary = ["token_id":UserDefaultManager.getStringFromUserDefaults(key: kToken)]
        
        //let imageData_Cover:Data = UIImageJPEGRepresentation(selectedImage_Cover, uploadImageCompression)!
        //let imageData_Logo:Data = UIImageJPEGRepresentation(selectedImage_Logo, uploadImageCompression)!
        let imageData_Cover:Data = UIImageJPEGRepresentation(imgcover.image!, uploadImageCompression)!
        let imageData_Logo:Data = UIImageJPEGRepresentation(imgprofile.image!, uploadImageCompression)!
        
        let arrChannelImg : NSMutableArray = NSMutableArray.init()
        arrChannelImg.add(imageData_Cover)
        arrChannelImg.add(imageData_Logo)
        parameter.setObject(arrChannelImg, forKey: ("image[]" as NSString))
        //parameter.setValue("FMLCRIBlxQN-1fCgHba4fb7LRy0Dkc5SE", forKey: "token_id") // Set Static
        
        HttpRequestManager.sharedInstance.requestWithPostMultipartParam(endpointurl: Upload_Channel_ImageVideo, isImage: true, parameters: parameter) {(data, error, message, responseDict) -> Void in
            
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
                    print(thedata!)
                    if (thedata?.count)! > 0
                    {
                        let strUplodedPhotoName: String = thedata!.object(forKey: kData) as! String
                        
                        let arrUplodedPhotoName :NSArray = strUplodedPhotoName.components(separatedBy: ",") as NSArray
                        self.strChannelCover_Name = arrUplodedPhotoName.firstObject as! String
                        self.strChannelLogo_Name = arrUplodedPhotoName.lastObject as! String
                        
                        //Manage Called Web Service
                        switch self.objEnumChannel {
                        case .enumChannel_AddNew:
                            self.api_AddChannel()
                            break
                        case .enumChannel_Update:
                            self.api_UpdateChannel()
                            break
                        }
                    }
                }
                else {
                    showMessage(message!)
                }
                hideLoaderHUD()
            }
            else
            {
                showMessage(message!)
                hideLoaderHUD()
            }
        }
    }
    
    func api_AddChannel() {
        self.view.endEditing(true)
        
        let strLoaderMess : String = APIAddChannelMessage
        let parameter:NSDictionary = ["service":APIAddChannel,
                                      "request":["data":[
                                        "cover_img": strChannelCover_Name,
                                        "logo": strChannelLogo_Name,
                                        "title":txtchannelname.text!,
                                        "description":txtchanneldesc.text!,
                                        "username":UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName)]],
                                      "auth" : getAuthForService()]
        //print("parameter: \(parameter)")
        
        self.view.isUserInteractionEnabled = false
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIAddChannel, parameters: parameter, keyname: "", message: strLoaderMess, showLoader: true, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            self.view.isUserInteractionEnabled = true
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_AddChannel()
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    //Called Notif.Obs. for show added Channel in Privious VC
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NC_AddChannelRefresh), object: nil, userInfo: nil)
                    
                    let strMessage: String = responseDict!.object(forKey: kMessage) as! String
                    showMessage(strMessage)
                    
                    self.btnbackclicked(self) //Move to back.
                }
            }
        })
    }
    
    func api_UpdateChannel() {
        self.view.endEditing(true)
        
        let strLoaderMess : String = "Update Channel"
        let parameter:NSDictionary = ["service":APIUpdateChannel,
                                      "request":["data":[
                                        "channel_id":strChannelID,
                                        "cover_img": strChannelCover_Name,
                                        "logo": strChannelLogo_Name,
                                        "title": TRIM(string: txtchannelname.text!),
                                        "description":TRIM(string: txtchanneldesc.text!),
                                        "username":UserDefaultManager.getStringFromUserDefaults(key: kAppUserFName)]],
                                      "auth" : getAuthForService()]
        //print("parameter: \(parameter)")
        
        self.view.isUserInteractionEnabled = false
        
        //kData as NSString
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIUpdateChannel, parameters: parameter, keyname: "", message: strLoaderMess, showLoader: true, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            self.view.isUserInteractionEnabled = true
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_UpdateChannel()
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    let objUpdateChannelData : GetSingleChannelDetails = GetSingleChannelDetails.init(object: responseDict!.object(forKey: kData) as Any)
                    
                    //Called Noti.Obs.
                    //Update obj. in AllChannelListVC
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NC_ChannelUpdateRefresh_AllChannelListVC), object: objUpdateChannelData, userInfo: nil)
                    //Update obj. in ChannelProfileVC
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NC_ChannelUpdateRefresh_ChannelProfileVC), object: objUpdateChannelData, userInfo: nil)
                    
                    //Show Success Mess.
                    let strMessage: String = responseDict!.object(forKey: kMessage) as! String
                    showMessage(strMessage)
                    
                    self.btnbackclicked(self) //Move to back.
                }
            }
        })
    }
}
