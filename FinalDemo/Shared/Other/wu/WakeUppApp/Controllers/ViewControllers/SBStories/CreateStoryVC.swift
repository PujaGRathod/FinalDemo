//
//  CreateStoryVC.swift
//  WakeUppApp
//
//  Created by Payal Umraliya on 23/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import CameraManager
import MobileCoreServices
import  AVKit
import AVFoundation
import Photos
import OpalImagePicker

//let key_Id : String = "key_Id"
let key_ContentType : String = "key_ContentType"
let key_VideoURL : String = "key_VideoURL"
let key_OriginalImage : String = "key_OriginalImage"
let key_EditedImage : String = "key_EditedImage"
let key_Timer : String = "key_Timer"
let key_IsPrivate : String = "key_IsPrivate"
let key_CaptionText : String = "key_CaptionText"
let key_Video_StartDuration : String = "key_Video_StartDuration"
let key_Video_StopDuration : String = "key_Video_StopDuration"

class CreateStoryVC: UIViewController {
    @IBOutlet var vwcamera: UIView!
    @IBOutlet var vwbottom: UIView!
    @IBOutlet var btnclose: UIButton!
    @IBOutlet var btncapture: UIButton!
    @IBOutlet var btngallery: UIButton!
    @IBOutlet var btnflipcamera: UIButton!
    @IBOutlet var btnflash: UIButton!
    var recordButton : RecordButton!
    var progressTimer : Timer!
    var progress : CGFloat! = 0
    var imgechoosen:UIImage!
    let cameraManager = CameraManager()
    //let imagePicker = UIImagePickerController()
    var arrduration = [String]()
    var arrdateupload = [String]()
    var arrtypes = [String]()
    var arrcomments = [String]()
    var arrcopies = [String]()
     let arrimgs = NSMutableArray()
    var arrSelectedImage : [UIImage] = []
    var arrSelectedVideo : [URL] = []
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarView?.backgroundColor = UIColor.clear
        //self.imagePicker.delegate = self
        cameraManager.cameraOutputQuality = .medium
        cameraManager.addPreviewLayerToView(self.vwcamera)
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
        btncapture.addGestureRecognizer(longGesture)
        cameraManager.cameraOutputMode = .stillImage
    }
    
    @objc func longTap(_ sender: UIGestureRecognizer)
    {
        if sender.state == .ended {
            self.progressTimer.invalidate()
            progress = 0
            recordButton.setProgress(0)
            recordButton.removeFromSuperview()
            
            performRedirection()
        }
        else if sender.state == .began {
            self.addRecordButton()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isStatusBarHidden = true
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isStatusBarHidden = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Button action
    @IBAction func btnflashclicked(_ sender: UIButton)
    {
        switch cameraManager.changeFlashMode() {
        case .off:
            cameraManager.flashMode = .off
            sender.setImage(UIImage.init(named: "cam_flashoff"), for: .normal)
        case .on:
            cameraManager.flashMode = .on
            sender.setImage(UIImage.init(named: "cam_flash"), for: .normal)
        case .auto:
            cameraManager.flashMode = .auto
            sender.setImage(UIImage.init(named: "cam_flash_auto"), for: .normal)
        }
    }
    
    @IBAction func btncloseclicked(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionFromBottom
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        APP_DELEGATE.appNavigation?.popViewController(animated: false)
    }
    
    @IBAction func btncaptureclicked(_ sender: Any) {
        cameraManager.capturePictureWithCompletion({ (image, error) -> Void in
            if let errorOccured = error {
                self.cameraManager.showErrorBlock("Error occurred", errorOccured.localizedDescription)
            }
            else {
                DispatchQueue.main.async(execute: {
                    //self.showeditor(arrImages: [image!])
                    
                    let arrSelectedContent : NSMutableArray = NSMutableArray.init()
                    arrSelectedContent.add(self.get_ImageObject(image: image!))
                    self.upload_Status_Photo(arrSelectedContent: arrSelectedContent, arrImages: [image!])
                })
            }
        })
    }
    
    func performRedirection() {
        switch (cameraManager.cameraOutputMode) {
        case .stillImage:
            cameraManager.capturePictureWithCompletion({ (image, error) -> Void in
                if let errorOccured = error {
                    self.cameraManager.showErrorBlock("Error occurred", errorOccured.localizedDescription)
                }
                else {
                    DispatchQueue.main.async(execute: {
                        //self.showeditor(image: image!)
                        
                        let arrSelectedContent : NSMutableArray = NSMutableArray.init()
                        arrSelectedContent.add(self.get_ImageObject(image: image!))
                        self.upload_Status_Photo(arrSelectedContent: arrSelectedContent, arrImages: [image!])
                    })
                }
            })
        case .videoWithMic, .videoOnly:
            cameraManager.stopVideoRecording({ (videoURL, error) -> Void in
                if let errorOccured = error {
                    self.cameraManager.showErrorBlock("Error occurred", errorOccured.localizedDescription)
                }
                else
                {
                    let arrSelectedContent : NSMutableArray = NSMutableArray.init()
                    arrSelectedContent.add(self.get_VideoObject(strURL: (videoURL?.absoluteString)!))
                    DispatchQueue.main.async(execute: {
                        self.upload_Status_Video(arrSelectedContent: arrSelectedContent)
                    })
                }
            })
        }
    }
    
    func selectExportedVideo(videoURL:URL) {
        runOnMainThreadWithoutDeadlock {
            let vcvw = loadVC(strStoryboardId: SB_STORIES, strVCId: "idVideoEditorVC") as! VideoEditorVC
            vcvw.videoselected = AVAsset.init(url: videoURL)
            vcvw.videourl = videoURL
            vcvw.videoEditorVCDelegate = self
            APP_DELEGATE.appNavigation?.pushViewController(vcvw, animated: false)
        }
    }
    
    @IBAction func btngalleryclicked(_ sender: Any) {
        let alert = UIAlertController.init(title: "Status", message: "Chosse an option for select media for create your status", preferredStyle: .actionSheet)
        let alert_image = UIAlertAction.init(title: "Photo", style: .default, handler: { (action) in
            let imagePicker = OpalImagePickerController()
            imagePicker.imagePickerDelegate = self
            imagePicker.statusBarPreference = UIStatusBarStyle.default
            imagePicker.allowedMediaTypes = [PHAssetMediaType.image] //Image Selection.
            imagePicker.maximumSelectionsAllowed = 5
            imagePicker.changePickerOpalTopBarColor(.white, themeWakeUppColor, .white)
            self.present(imagePicker, animated: true, completion: nil)
        })
        alert.addAction(alert_image)
        
        let alert_video = UIAlertAction.init(title: "Video", style: .default, handler: { (action) in
            let imagePicker = OpalImagePickerController()
            imagePicker.imagePickerDelegate = self
            imagePicker.statusBarPreference = UIStatusBarStyle.lightContent
            imagePicker.allowedMediaTypes = [PHAssetMediaType.video] //Video Selection.
            imagePicker.maximumSelectionsAllowed = 2
              imagePicker.changePickerOpalTopBarColor(.white, themeWakeUppColor, .white)
            self.present(imagePicker, animated: true, completion: nil)
        })
        alert.addAction(alert_video)
     
        let action_no = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(action_no)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnflipclicked(_ sender: Any) {
        cameraManager.cameraDevice = cameraManager.cameraDevice == CameraDevice.front ? CameraDevice.back : CameraDevice.front
    }
    
    //MARK:-
    /*func showeditor(arrImages:[UIImage]) {
        if (arrImages.count == 0) {
            showMessage("Something was wrong.\n Please select photo.")
            return
        }
        
        let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
        photoEditor.photoEditorDelegate = self
     
        var imagesValue: [(UIImage,[String: Any?]?)] = []
        for i in arrImages {
            imagesValue.append((i, nil))
        }
        //-------->
        
        photoEditor.stickers.removeAll()
        photoEditor.view.frame = self.view.bounds;
        photoEditor.view.backgroundColor = UIColor.black
        present(photoEditor, animated: true, completion: nil)
    }*/
    
    func get_ImageObject(image : UIImage) -> NSMutableDictionary {
        let dic = NSMutableDictionary.init()
        
        dic.setValue("0", forKey: key_ContentType)
        dic.setValue(image.sd_imageData(), forKey: key_OriginalImage)
        dic.setValue(image.sd_imageData(), forKey: key_EditedImage)
        dic.setValue("0", forKey: key_IsPrivate)
        dic.setValue("", forKey: key_Timer)
        dic.setValue("", forKey: key_CaptionText)
        
        return dic
    }
    
    func get_VideoObject(strURL : String) -> NSMutableDictionary {
        let dic = NSMutableDictionary.init()
        
        dic.setValue("1", forKey: key_ContentType)
        dic.setValue(strURL, forKey: key_VideoURL)
        dic.setValue("0", forKey: key_IsPrivate)
        dic.setValue("", forKey: key_Timer)
        dic.setValue("", forKey: key_CaptionText)
        
        //dic.setValue("0.0", forKey: key_Video_StartDuration)
        dic.setValue(0.01, forKey: key_Video_StartDuration)
        //dic.setValue("0.0", forKey: key_Video_StopDuration)
        
        let asset = AVAsset(url: strURL.url!)
        let duration = asset.duration
        let durationTime : Double = CMTimeGetSeconds(duration) as Double
        dic.setValue(durationTime, forKey: key_Video_StopDuration)
        
        let img : UIImage = getVideoThumbnail(videoURL: strURL.url!)!
        dic.setValue(img.sd_imageData(), forKey: key_OriginalImage)
        
        return dic
    }
    
    func showeditor(arrSelectedContent:NSMutableArray, arrImages:[UIImage]) {
        if (arrSelectedContent.count == 0) {
            showMessage("Something was wrong.\n Please select again.")
            return
        }
        
        let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
        photoEditor.photoEditorDelegate = self
        //photoEditor.arrVideoProperty = arrSelectedContent
        
        //Temp.--->
        /*//photoEditor.image = arrImages.first
        if arrImages.first != nil { photoEditor.image = arrImages.first }
        else { photoEditor.image = #imageLiteral(resourceName: "img_Placeholder") }*/
        
        var imagesValue: [(UIImage,[String: Any?]?)] = []
        for i in arrImages { imagesValue.append((i, nil)) }
        photoEditor.arrPhoto = imagesValue
        //<----
        
        photoEditor.stickers.removeAll()
        photoEditor.view.frame = self.view.bounds;
        photoEditor.view.backgroundColor = UIColor.black
        present(photoEditor, animated: true, completion: nil)
    }
    
    func upload_Status_Photo(arrSelectedContent:NSMutableArray, arrImages:[UIImage]) {
        if (arrSelectedContent.count == 0) {
            showMessage("Something was wrong.\n Please select photo again.")
            return
        }
        
        let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
        photoEditor.photoEditorDelegate = self
        photoEditor.objEnumEditor = .Editor_Photo
        
        var imagesValue: [(UIImage,[String: Any?]?)] = []
        for i in arrImages { imagesValue.append((i, nil)) }
        photoEditor.arrPhoto = imagesValue
        photoEditor.arrPhotoProperty = arrSelectedContent
        
        photoEditor.stickers.removeAll()
        photoEditor.view.frame = self.view.bounds;
        photoEditor.view.backgroundColor = UIColor.black
        present(photoEditor, animated: true, completion: nil)
    }
    
    func upload_Status_Video(arrSelectedContent:NSMutableArray)
    {
        if (arrSelectedContent.count == 0) {
            showMessage("Something was wrong.\n Please select video again.")
            return
        }
        
        let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
        photoEditor.photoEditorDelegate = self
        photoEditor.objEnumEditor = .Editor_Video
        photoEditor.arrVideoProperty = arrSelectedContent
        
        photoEditor.stickers.removeAll()
        photoEditor.view.frame = self.view.bounds;
        photoEditor.view.backgroundColor = UIColor.black
        present(photoEditor, animated: true, completion: nil)
    }
    
    //MARK:- API Called
    //MARK: Upload Status - Image
    func API_UploadStoryMedia(_ mediaForUpload:[UIImage], _ imagesProperty:NSArray,_ isimages:Bool,_ videoForUpload:[URL])
    {
        HttpRequestManager.sharedInstance.delegate = self
        let parameter :NSMutableDictionary = ["token_id":UserDefaultManager.getStringFromUserDefaults(key: kToken)]
        let arrImgData = NSMutableArray()
        if isimages == true
        {
            for (i, element) in mediaForUpload.enumerated()
            {
                let imgData:Data = UIImageJPEGRepresentation(element, 0.6)!
                arrImgData.add(imgData)
                let dicImgProperty : NSMutableDictionary = imagesProperty[i] as! NSMutableDictionary
                let strCaptionMess : String = dicImgProperty.value(forKey: key_CaptionText) as! String
                let strPrivate : String = dicImgProperty.value(forKey: key_IsPrivate) as! String
                let strTimer : String = dicImgProperty.value(forKey: key_Timer) as! String
                self.arrtypes.append("0")
                self.arrduration.append("5")
                if strTimer.count > 0
                {
                    self.arrdateupload.append(strTimer)
                }
                else
                {
                    self.arrdateupload.append("currentdate")
                }
                self.arrcopies.append(strPrivate)
                self.arrcomments.append(strCaptionMess)
            }
        }
        else
        {
            for (i, element) in videoForUpload.enumerated()
            {
                let dicImgProperty : NSMutableDictionary = imagesProperty[i] as! NSMutableDictionary
                let strCaptionMess : String = dicImgProperty.value(forKey: key_CaptionText) as! String
                let strPrivate : String = dicImgProperty.value(forKey: key_IsPrivate) as! String
                let strTimer : String = dicImgProperty.value(forKey: key_Timer) as! String
                let uploadVideoURL : URL = videoForUpload[i]
                let asset = AVAsset(url: uploadVideoURL)
                let durationTime = asset.duration.seconds
                arrImgData.add(element)
                self.arrtypes.append("1")
                self.arrduration.append("\(durationTime)")
                if strTimer.count > 0
                {
                    self.arrdateupload.append(strTimer)
                }
                else
                {
                    self.arrdateupload.append("currentdate")
                }
                self.arrcopies.append(strPrivate)
                self.arrcomments.append(strCaptionMess)
            }
        }
        parameter.setObject(arrImgData, forKey: ("image[]" as NSString))
        
        //showHUD()
        let path = Upload_Story_URL
        HttpRequestManager.sharedInstance.requestWithPostMultipartParam(endpointurl: path, isImage: true, parameters: parameter) {(data, error, message, responseDict) -> Void in
            hideHUD()
            
            if error != nil {
                showMessageWithRetry(RetryMessage, 3, buttonTapHandler: { _ in
                    hideBanner()
                    self.API_UploadStoryMedia(mediaForUpload, imagesProperty,isimages,videoForUpload)
                })
                return
            }
            else if let data = data
            {
                HttpRequestManager.sharedInstance.delegate = nil
                let thedata = data as? NSDictionary
                if(thedata != nil) {
                    //print("thedata: \(thedata!)")
                    if (thedata?.count)! > 0
                    {
                        let images  = thedata!.object(forKey: kData) as! String
                        //print("images: \(images)")
                        self.call_ScheduleCreateStory(images, self.arrduration.joined(separator: ","), self.arrtypes.joined(separator: ","),self.arrdateupload.joined(separator: ","),self.arrcopies.joined(separator: ","), self.arrcomments.joined(separator: ","))
                    }
                    else
                    {
                        showMessage("Problem while uplaoding image.")
                        return
                    }
                }
            }
        }
    }
    
    //Payal Added
    func call_ScheduleCreateStory(_ imgs:String, _ durations:String , _ types : String, _ datechoose : String,_ allowcopies:String,_ captions:String)
    {
        hideHUD()
        showHUD()
        hudText = "Processing 95%"
        var strlist = ""
        if UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_Status) == "3"
        {
            strlist = UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_Status_Useridlist)
        }
        else if UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_Status) == "4"
        {
            strlist = UserDefaultManager.getStringFromUserDefaults(key: kOnlySharewith_Useridlist)
        }
        else
        {
            strlist = ""
        }
        let dic = [
            "images":imgs,
            "durations":durations,
            "types":types,
            "datetime":datechoose,
            "user_id": UserDefaultManager.getStringFromUserDefaults(key: kAppUserId),
            "allowcopy":allowcopies,
            "storycaption":captions,
            "statusviewprivacy": UserDefaultManager.getStringFromUserDefaults(key: kPrivacy_Status),
            "markedidlist":strlist
            ] as [String : Any]
        APP_DELEGATE.socketIOHandler?.socket?.emitWithAck(keyScheduleCreateStory,dic).timingOut(after: 30) {data in
            let data = data as Array
            if(data.count > 0) {
                if data[0] is String{ return }
                
                let dic = data[0] as! NSDictionary
                if dic.value(forKey: "success") as! String == "1" {
                    hudText = "Processing 100%"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        hideHUD()
                        postNotification(with: NC_MyStoryRefresh, andUserInfo:nil)
                        UIApplication.shared.statusBarView?.backgroundColor = themeWakeUppColor
                        APP_DELEGATE.appNavigation?.backToViewController(viewController: StoriesVC.self)
                    })
                }
                else {
                    hideHUD()
                    showMessage("Problem while creating story")
                }
            }
            else {
                hideHUD()
                hudText =  ""
            }
        }
    }
}
//MARK:- Delegate Method
extension CreateStoryVC : UINavigationControllerDelegate, OpalImagePickerControllerDelegate, UploadProgressDelegate, PhotoEditorDelegate {
   
    //MARK: OpalImagePickerControllerDelegate Method
    /*func imagePicker(_ picker: OpalImagePickerController, didFinishPickingImages images: [UIImage]) {
     self.dismiss(animated: true) {
     self.showeditor(arrImages: images)
     }
     }*/
    
    func imagePicker(_ picker: OpalImagePickerController, didFinishPickingAssets assets: [PHAsset]) {
        self.dismiss(animated: true) {
            
            let arrSelectedContent : NSMutableArray = NSMutableArray.init()
            var arrImage : [UIImage] = []
            var arrVideo : [URL] = []
            
            //Show loader
            //if (assets.count != 0) { showHUD() }
            
            for objAsset in assets
            {
                if objAsset.mediaType == .image
                {
                    arrImage.append(objAsset.getOriginalImage())
                    arrSelectedContent.add(self.get_ImageObject(image: objAsset.getOriginalImage()))
                    if assets.count == arrSelectedContent.count
                    {
                        DispatchQueue.main.async(execute: {
                        self.upload_Status_Photo(arrSelectedContent:arrSelectedContent, arrImages: arrImage)
                        })
                    }
                }
                else if objAsset.mediaType == .video
                {
                    let options: PHVideoRequestOptions = PHVideoRequestOptions()
                    options.version = .original
                    PHImageManager.default().requestAVAsset(forVideo: objAsset, options: options, resultHandler: { (asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) in
                        if let urlAsset = asset as? AVURLAsset {
                            let localVideoUrl: URL = urlAsset.url as URL
                            //print("Video URL - \(localVideoUrl)")
                            arrVideo.append(localVideoUrl)
                            arrSelectedContent.add(self.get_VideoObject(strURL:localVideoUrl.absoluteString))
                            if assets.count == arrSelectedContent.count
                            {
                                DispatchQueue.main.async(execute: {
                                 self.upload_Status_Video(arrSelectedContent: arrSelectedContent)
                                })
                            }
                        } else {
                            //print("Video - Error.")
                        }
                    })
                }
            }
//            //print("arrSelectedContent: \(arrSelectedContent.count)")
//            if picker.allowedMediaTypes == [PHAssetMediaType.image]
//            {
//
//            }
//            else if picker.allowedMediaTypes == [PHAssetMediaType.video]
//            {
//                //print("------video")
//               self.upload_Status_Video(arrSelectedContent: arrSelectedContent)
////                runAfterTime(time: 0.30, block: {
////                if assets.count != arrSelectedContent.count {
////                    showHUD()
////                    runAfterTime(time: 0.30, block: {
////                        hideHUD()
////                        self.upload_Status_Video(arrSelectedContent: arrSelectedContent)
////                    })
////                } else { self.upload_Status_Video(arrSelectedContent: arrSelectedContent) }
////                })
//            }
//            else {
//                //print("------other")
//            }
        }
    }
    
    //MARK: UploadProgressDelegate Method
    func didReceivedProgress(progress: Float) {
        print(hudText);
        hudText = "Uploading \(Int(floor(progress*92)))% "
    }
    
    //MARK: PhotoEditorDelegate
    func doneEditing(image: UIImage,timeselected:String,isprivate:String)
    {
        let img = image
        img.accessibilityLabel = "IMAGE"
        let vc = loadVC(strStoryboardId: SB_STORIES, strVCId: "idStoryPreviewVC") as! StoryPreviewVC
        vc.arrimages = [img]
        vc.timechoosen = timeselected
        vc.isprivate = isprivate
        APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
    }
    
    func doneEditing(images: [UIImage], imagesProperty: NSArray)
    {
        //print("images : \(images)")
        if (images.count == 0   ) {
            showMessage("Something was wrong.\n Please select photo.")
        } else {
            self.API_UploadStoryMedia(images, imagesProperty, true,[])
        }
    }
    func doneEditing(videoURL: [URL], videoProperty: NSArray)
    {
        //print("videoURL : \(videoURL)")
        if (videoURL.count == 0) {
            showMessage("Problem while exporting video. Please try again.")
        }else{
            self.API_UploadStoryMedia([], videoProperty,false,videoURL)
        }
    }
    func canceledEditing() {
    }
}

extension CreateStoryVC {
    func addRecordButton() {
        cameraManager.cameraOutputMode = .videoWithMic
        recordButton = RecordButton(frame: CGRect(x: 0,y: 0,width: 70,height: 70))
        recordButton.center = self.view.center
        recordButton.buttonColor = .clear
        recordButton.progressColor = themeWakeUppColor
        recordButton.closeWhenFinished = false
        recordButton.addTarget(self, action: #selector(CreateStoryVC.record), for: .touchDown)
        recordButton.addTarget(self, action: #selector(CreateStoryVC.stop), for: UIControlEvents.touchUpInside)
        recordButton.center = btncapture.center
        vwbottom.addSubview(recordButton)
        vwbottom.bringSubview(toFront: recordButton)
        record()
    }
    @objc func record()
    {
        cameraManager.startRecordingVideo()
        self.progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(CreateStoryVC.updateProgress), userInfo: nil, repeats: true)
    }
    
    @objc func updateProgress() {
        
        let maxDuration = CGFloat(30) // Max duration of the recordButton
        
        progress = progress + (CGFloat(0.05) / maxDuration)
        recordButton.setProgress(progress)
        
        if progress >= 1 {
            progressTimer.invalidate()
        }
    }
    
    @objc func stop() {
        self.progressTimer.invalidate()
        progress = 0
        recordButton.setProgress(0)
        recordButton.removeFromSuperview()
    }
}

extension CreateStoryVC:VideoEditorVCDelegate {
    func exportvideonow(_ url: URL) {
        //        do
        //        {
        //            let asset = AVURLAsset(url: url , options: nil)
        //            let imgGenerator = AVAssetImageGenerator(asset: asset)
        //            imgGenerator.appliesPreferredTrackTransform = true
        //            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
        //            let thumbnail = UIImage(cgImage: cgImage)
        //            let img = thumbnail
        //            img.accessibilityLabel = url.absoluteString
        //            img.accessibilityValue = "\(asset.duration.seconds)"
        //            let actionSheet = UIAlertController.init(title: nil, message: "Choose an option to upload this video story.", preferredStyle: .actionSheet)
        //            let actionnow = UIAlertAction.init(title: "Publish now", style: .default) { (action) in
        //                self.uploadStoryMedia([img], "","0")
        //            }
        //            let actionlater = UIAlertAction.init(title: "Schedule", style: .default) { (action) in
        //                self.showdatepicker(uploadcontent: [img])
        //            }
        //
        //            let actioncancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
        //
        //            }
        //            actionSheet.addAction(actionnow)
        //            actionSheet.addAction(actionlater)
        //            actionSheet.addAction(actioncancel)
        //            self.present(actionSheet, animated: true, completion: nil)
        //        }
        //        catch let error
        //        {
        //            print(error)
        //        }
    }
}
