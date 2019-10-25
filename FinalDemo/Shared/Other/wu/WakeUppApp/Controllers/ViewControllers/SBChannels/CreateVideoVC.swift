//
//  CreateVideoVC.swift
//  WakeUppApp
//
//  Created by Payal Umraliya on 16/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import MobileCoreServices
import AssetsLibrary

//For Manage Play Video
import AVKit
import AVFoundation

class CreateVideoVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate ,ImagePickerDelegate
{
    
    //MARK: Outlet
    @IBOutlet var tblcreate: UITableView!
    @IBOutlet var vwchannel: UIView!
    @IBOutlet var collchannel: UICollectionView!
    @IBOutlet var viewChannelPlaceholder: UIView!
    
    @IBOutlet var vwvideo: UIView!
    @IBOutlet var imgvideo: UIImageView!
    @IBOutlet var btnselectvideo: UIButton!
    
    @IBOutlet weak var imgThumb: UIImageView!
    @IBOutlet var btnthumb: UIButton!
    
    @IBOutlet var txttitle: UITextField!
    @IBOutlet var txtdesc: IQTextView!
    @IBOutlet var btnuplaod: UIButton!
    
    var selectedChannel = IndexPath.init(item: -1, section: 0)
    var prevChannel =  IndexPath.init(item: -1, section: 0)
    
    //MARK: Variable
    var arrChannel = [MyChannel]() // For use getting channel data in privious VC
    
    let select_ChannelVideo : String = "select_ChannelVideo" // Use detect Video upload select
    let select_ChanneleThumb : String = "select_ChanneleThumb" // Use detect Video Thumb photo select
    
    var strVideo_Name : String = "" // For use store channnel video name.
    var strVideoThumb_Name : String = "" // For use store channnel video thumb image name.
    
    //For use validation manage
    var selectedVideo : UIImage =  #imageLiteral(resourceName: "clappboard_ic")
    var selectedVideoThumb : UIImage = #imageLiteral(resourceName: "thumbnail_upload")
    
    // For use Upload Video and Photo
    let videoImgPickerController = UIImagePickerController()
    //For use store recorded OR selected video URL stored.
    var videoURL_selectedVideo : URL!
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collchannel.delegate = self
        self.collchannel.dataSource = self
        
        //Set already set placeholder image set for manage check validation.
        selectedVideo = imgvideo.image!
        selectedVideoThumb = imgThumb.image!
        
        if (arrChannel.count != 0) {
            selectedChannel = IndexPath.init(item: 0, section: 0)
            prevChannel =  IndexPath.init(item: 0, section: 0)
        }
        
        //Add Padding in TextFiled
        txttitle.addPaddingLeft(6)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Function
    // Manaasge Upload only Video in Camera nad Gallery.
    func upload_Video() -> Void {
        let alert = UIAlertController(title: "Select option", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera".uppercased(), style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery".uppercased(), style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel".uppercased(), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() -> Void {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            videoImgPickerController.delegate = self
            
            videoImgPickerController.sourceType = .camera
            videoImgPickerController.mediaTypes = [kUTTypeMovie as String]
            videoImgPickerController.showsCameraControls = true
            //videoImgPickerController.videoMaximumDuration = 10.0 // Set Duration of Record Video.
            
            present(videoImgPickerController, animated: true, completion: nil)
        }
        else {
            //print("Camera not available!")
            showMessage("Camera not available!")
        }
    }
    
    func openGallary() -> Void {
        videoImgPickerController.delegate = self
        videoImgPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        videoImgPickerController.mediaTypes = [kUTTypeMovie as String]
        
        present(videoImgPickerController, animated: true, completion: nil)
    }
    
    //MARK: Button Action
    @IBAction func btnbackclicked(_ sender: Any) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnselectvideoclicked(_ sender: Any) {
        //ImagePicker.sharedInstance.delegate = self
        //ImagePicker.sharedInstance.selectImage(sender: select_ChannelVideo)
        
        self.upload_Video()
    }
    
    @IBAction func btnthumbclicked(_ sender: Any) {
        ImagePicker.sharedInstance.delegate = self
        ImagePicker.sharedInstance.selectImage(sender: select_ChanneleThumb)
    }
    
    @IBAction func btnuplaodclicked(_ sender: Any) {
        //Check Validation
        
        //Selecte Channel
        if (selectedChannel.row < 0) {
            vwchannel.shake()
            showMessage(SelectChannel);
            return
        }
        
        //Channel video
        if (imgvideo.image == selectedVideo) {
            vwchannel.shake()
            showMessage(SelectVideo);
            return
        }
        
        //Video Name
        if (validateTxtFieldLength(txttitle, withMessage: EnterVideoTitle) != true) {
            return
        }
        
        //Video Desc
        let strVideoDesc = TRIM(string: txtdesc.text)
        if (strVideoDesc.count == 0) {
            txtdesc.shake()
            showMessage(EnterVideoDesc);
            return
        }
        
        //Set Channel thumb image
        if (imgThumb.image == selectedVideoThumb) {
            imgThumb.image = getVideoThumbnail(videoURL: videoURL_selectedVideo)
            selectedVideoThumb = imgThumb.image!
        }
        
        //Upload Video and Image
        self.api_Upload_VideoImage()
    }
    
    //MARK: - Video Show & Play Methods
    func playVideo_on(view: UIView, videoURL : URL) -> Void {
        
        var avPlayer: AVPlayer!
        avPlayer = AVPlayer(url: videoURL)
        avPlayer.play()
        avPlayer.seek(to: kCMTimeZero)
        
        let avPlayerController = AVPlayerViewController()
        avPlayerController.player = avPlayer
        avPlayerController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        
        //  hide show control
        avPlayerController.showsPlaybackControls = true
        avPlayerController.updatesNowPlayingInfoCenter = true
        
        // play video
        avPlayerController.player?.play()
        view.addSubview(avPlayerController.view)
    }
    
    
    //MARK: - ImagePickerDelegate method
    func pickImageComplete(_ imageData: UIImage, sender: String) {
        if (sender.uppercased() == select_ChannelVideo.uppercased()) {
            imgvideo.image = imageData
        }
        else if (sender.uppercased() == select_ChanneleThumb.uppercased()) {
            imgThumb.image = imageData
        }
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        if picker.mediaTypes == [kUTTypeMovie as String] {
            //print("Select Video")
            
            let videoURL = info[UIImagePickerControllerMediaURL] as? URL
            videoURL_selectedVideo = videoURL
            //print("videoURL_selectedVideo:\(videoURL_selectedVideo))")
            
            //Play Selected Video
            self.playVideo_on(view: imgvideo, videoURL: videoURL_selectedVideo)
            
            //Set Image
            imgvideo.image = getVideoThumbnail(videoURL: videoURL_selectedVideo)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - API
    func api_AddChannelVideo() {
        self.view.endEditing(true)
        
        let objSelectedChannel = arrChannel[selectedChannel.row]
        let strSelectedChannelID : String = objSelectedChannel.id!
        
        let parameter:NSDictionary = ["service":APIAddChannelVideo,
                                      "request":["data":[
                                        "channel_id":strSelectedChannelID,
                                        "video": strVideo_Name,
                                        "thum_img": strVideoThumb_Name,
                                        "title":txttitle.text!,
                                        "description":txtdesc.text!]],
                                      "auth" : getAuthForService()
        ]
        //print("parameter: \(parameter)")
        
        self.view.isUserInteractionEnabled = false
        
        HttpRequestManager.sharedInstance.requestWithPostJsonParam(endpointurl: Server_URL, service: APIAddChannelVideo, parameters: parameter, keyname: "", message: APIAddChannelVideoMessage, showLoader: true, responseData: { (error,apistatus,statusmessage,responseArray,responseDict) in
            
            self.view.isUserInteractionEnabled = true
            
            if error != nil {
                showMessageWithRetry(RetryMessage,3, buttonTapHandler: { _ in
                    self.api_AddChannelVideo()
                })
                return
            }
            else {
                if Int(apistatus) == 0 {
                    showMessage(statusmessage)
                }
                else {
                    //Called Notif.Obs. for show added Channel Video in Privious VC
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NC_AddChannelVideoRefresh), object: nil, userInfo: nil)
                    
                    let strMessage: String = responseDict!.object(forKey: kMessage) as! String
                    showMessage(strMessage)
                    
                    self.btnbackclicked(self) //Move to back.
                }
            }
        })
    }
    
    func api_Upload_VideoImage() {
        showLoaderHUD(strMessage: "Uploading Video")
        let parameter :NSMutableDictionary = ["token_id":UserDefaultManager.getStringFromUserDefaults(key: kToken)]
        let arrChannelImg : NSMutableArray = NSMutableArray.init()
        
        //Add Video
        /*
         //let imageData_Video:Data = UIImageJPEGRepresentation(selectedVideo, uploadImageCompression)! //Image to Data
         var imageData_Video : Data! //Video to Data
         do {
         imageData_Video = try Data(contentsOf: videoURL_selectedVideo)
         } catch {
         //print("Unable to load data: \(error)")
         }
         //print(imageData_Video)
         print(imageData_Video.count)
         //arrChannelImg.add(imageData_Video) // No Send Image data, Bcoz, upload in DB only image
         */
        arrChannelImg.add(videoURL_selectedVideo) // Send Image URL, API Called Structure manage it.
        
        //Add Video Thumb
        let imageData_VideoThumb:Data = UIImageJPEGRepresentation(imgThumb.image!, uploadImageCompression)!
        arrChannelImg.add(imageData_VideoThumb)
        
        parameter.setObject(arrChannelImg, forKey: ("image[]" as NSString))
        //parameter.setValue("FMLCRIBlxQN-1fCgHba4fb7LRy0Dkc5SE", forKey: "token_id") // Set Static
        
        HttpRequestManager.sharedInstance.requestWithPostMultipartParam(endpointurl: Upload_Channel_ImageVideo, isImage: true, parameters: parameter) {(data, error, message, responseDict) -> Void in
            
            if error != nil {
                hideLoaderHUD()
                showMessageWithRetry(RetryMessage, 3, buttonTapHandler: { _ in
                    hideBanner()
                    self.api_Upload_VideoImage()
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
                        
                        //Set Image Name
                        self.strVideo_Name = arrUplodedPhotoName.firstObject as! String
                        self.strVideoThumb_Name = arrUplodedPhotoName.lastObject as! String
                        
                        // Called Add Channel API
                        self.api_AddChannelVideo()
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
    
}

extension CreateVideoVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let noOfCell : Int = arrChannel.count
        if (noOfCell == 0) {
            viewChannelPlaceholder.isHidden = false
        }
        else {
            viewChannelPlaceholder.isHidden = true
        }
        return noOfCell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "channelcell", for: indexPath as IndexPath)
        let imgslected = cell.viewWithTag(77) as! UIImageView
        let imgView = cell.viewWithTag(88) as! UIImageView
        let lblnm = cell.viewWithTag(99) as! UILabel
        
        let objChannel = arrChannel[indexPath.row]
        let imgURL:String = objChannel.logo!
        
        lblnm.text = objChannel.title
        imgView.sd_setImage(with: URL(string: imgURL), placeholderImage: #imageLiteral(resourceName: "channel_placeholder"))
        
        if selectedChannel == indexPath {
            imgslected.isHidden = false
        }
        else {
            imgslected.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        prevChannel = selectedChannel
        selectedChannel = indexPath
        self.collchannel.reloadItems(at: [prevChannel,selectedChannel])
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: SCREENWIDTH() / 4
            , height: 150)
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
