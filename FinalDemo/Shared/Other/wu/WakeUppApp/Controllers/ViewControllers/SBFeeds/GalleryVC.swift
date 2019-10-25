    
    //
    //  GalleryVC.swift
    //  WakeUppApp
    //
    //  Created by Admin on 24/03/18.
    //  Copyright © 2018 el. All rights reserved.
    //
    
    import UIKit
    import AssetsLibrary
    import Photos
    import CameraManager
    
    enum MediaType {
        case image
        case video
    }
    
    class GalleryVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
        
        @IBOutlet var lblnomedia: UILabel!
        @IBOutlet weak var collectionPhoto: UICollectionView!
        @IBOutlet weak var viewBottom: UIView!
        var arrImage = [UIImage]()
        var arrVideo = [URL]()
        var objMediaType:MediaType = .image
        var selectedImagePath = [IndexPath]()
        var selectedVideoPath = [IndexPath]()
        var selectedVideo = [UIImage]()
        var selectedImage = [UIImage]()
        //Camera View
        @IBOutlet weak var viewCamera: UIView!
        @IBOutlet weak var btnVideoCapture: UIButton!
        @IBOutlet weak var btnVideo: UIButton!
        @IBOutlet weak var btnPhoto: UIButton!
        @IBOutlet weak var btnGallery: UIButton!
        @IBOutlet weak var btnFlash: UIButton!
        @IBOutlet var lblmessage: UILabel!
        @IBOutlet weak var videoCaptureProgress: NSLayoutConstraint!
        @IBOutlet weak var viewProgress: UIView!
        var videoProgressTime: Timer?
        let cameraManager = CameraManager()
        let perSecondProgress = (SCREENWIDTH() - 20) / 20
        
        //Gallery View
        @IBOutlet weak var viewPermission: UIView!
        @IBOutlet weak var lblCamera: UILabel!
        @IBOutlet weak var lblGallery: UILabel!
        @IBOutlet weak var lblVideo: UILabel!
        @IBOutlet weak var viewGallery: UIView!
        
        @IBOutlet weak var bottomPaddingGalleryView: NSLayoutConstraint!
        @IBOutlet weak var bottomPaddingCameraView: NSLayoutConstraint!
        
        var selectedIndex:IndexPath!
        
        @IBOutlet weak var btnNext: UIButton!
        @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            selectedIndex = nil
            
            //        Fetch Photo From Gallery
            btnNext.isHidden = true
            showStatusBarMessage("Refreshing Photos...".localized())
            fetchPhotoFromGallery { (isComplete) in
                self.objMediaType = .image
                self.activityIndicator.stopAnimating()
                self.btnNext.isHidden = false
                self.collectionPhoto.delegate = self
                self.collectionPhoto.dataSource = self
                self.viewGallery.isHidden = false
                self.viewCamera.isHidden = true
                self.collectionPhoto.reloadData()
            }
            
        }
        
        //MARK:- Camera Manager
        
        func startCaptureVideo() {
            viewProgress.isHidden = false
            videoProgressTime = Timer.scheduledTimer(timeInterval: 1.0,
                                                     target: self,
                                                     selector: #selector(eventWith(timer:)),
                                                     userInfo: nil,
                                                     repeats: true)
        }
        
        @objc func eventWith(timer: Timer!) {
            UIView.animate(withDuration: 1.5, animations: {
                self.videoCaptureProgress.constant = self.videoCaptureProgress.constant + self.perSecondProgress
                self.view.layoutIfNeeded()
            }) { (isComplete) in
                if(self.videoCaptureProgress.constant >= SCREENWIDTH() - 10)
                {
                    self.videoProgressTime?.invalidate()
                    self.viewProgress.isHidden = true
                    self.videoCaptureProgress.constant = 0.0
                    self.cameraManager.stopVideoRecording({ (videoURL, error) in
                    })
                }
            }
        }
        
        func  showCamera()  {
            
            viewGallery.isHidden = true
            viewCamera.isHidden = false
            
            btnPhoto.isSelected = true
            btnGallery.isSelected = false
            btnVideo.isSelected = false
            btnFlash.isSelected = cameraManager.flashMode == .on ? true : false
            
            cameraManager.cameraOutputQuality = .medium
            let currentCameraState = cameraManager.currentCameraStatus()
            if currentCameraState == .notDetermined {
                self.askForCameraPermissions()
            } else if (currentCameraState == .ready) {
                addCameraToView()
            }
        }
        
        func askForCameraPermissions() {
            cameraManager.askUserForCameraPermission({ permissionGranted in
                if permissionGranted {
                    self.addCameraToView()
                }
            })
        }
        
        fileprivate func addCameraToView()
        {
            cameraManager.addPreviewLayerToView(viewCamera, newCameraOutputMode: CameraOutputMode.stillImage)
            cameraManager.showErrorBlock = { [weak self] (erTitle: String, erMessage: String) -> Void in
                let alertController = UIAlertController(title: erTitle, message: erMessage, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (alertAction) -> Void in  }))
                self?.present(alertController, animated: true, completion: nil)
            }
        }
        
        
        @IBAction func btnVideoCapture(_ sender: Any) {
            cameraManager.cameraOutputMode = .videoWithMic
            btnPhoto.isSelected = false
            btnGallery.isSelected = false
            btnVideo.isSelected = true
        }
        
        @IBAction func btnImageCapture(_ sender: Any) {
            self.viewProgress.isHidden = true
            self.videoCaptureProgress.constant = 0.0
            cameraManager.cameraOutputMode = .stillImage
            btnPhoto.isSelected = true
            btnGallery.isSelected = false
            btnVideo.isSelected = false
        }
        
        @IBAction func btnGallery(_ sender: Any)
        {
            viewGallery.isHidden = false
            viewCamera.isHidden = true
            
            lblGallery.isEnabled = true
            lblCamera.isEnabled = false
            lblVideo.isEnabled = false
            
            self.viewProgress.isHidden = true
            self.videoCaptureProgress.constant = 0.0
            
            UIView.animate(withDuration: 0.4, animations: {
                self.bottomPaddingCameraView.constant = -154
                self.bottomPaddingGalleryView.constant = -10
                self.view.layoutIfNeeded()
            }) { (isComplete) in
            }
        }
        
        @IBAction func btnbackclicked(_ sender: UIButton) {
            _ = APP_DELEGATE.appNavigation?.popViewController(animated: true)
        }
        @IBAction func btnSwitchCamera(_ sender: Any) {
            cameraManager.cameraDevice = cameraManager.cameraDevice == CameraDevice.front ? CameraDevice.back : CameraDevice.front
        }
        
        @IBAction func btnFlash(_ sender: Any) {
            switch cameraManager.flashMode {
            case .on:
                cameraManager.flashMode  = .off
                btnFlash.isSelected = false
                break
            case .off:
                cameraManager.flashMode  = .on
                btnFlash.isSelected = true
                break
            default:
                break
            }
            
        }
        
        @IBAction func btnCaptureTouchDown(_ sender: Any) {
            if(cameraManager.cameraOutputMode == .videoWithMic)
            {
                cameraManager.startRecordingVideo()
                self.startCaptureVideo()
            }
        }
        
        @IBAction func btnCapture(_ sender: Any) {
            switch (cameraManager.cameraOutputMode) {
            case .stillImage:
                cameraManager.capturePictureWithCompletion({ (image, error) -> Void in
                    if let errorOccured = error {
                        self.cameraManager.showErrorBlock("Error occurred", errorOccured.localizedDescription)
                    }
                    else
                    {
                        //Image Capture
                        let objFilter:FilterVC = loadVC(strStoryboardId: SB_FEEDS, strVCId:"FilterVC") as! FilterVC
                        objFilter.originalImage = fixOrientationOfImage(image: image!)
                        objFilter.isFromGallery = false
                        APP_DELEGATE.appNavigation?.pushViewController(objFilter, animated: true)
                    }
                })
            case .videoWithMic, .videoOnly:
                cameraManager.stopVideoRecording({ (videoURL, error) -> Void in
                    if let errorOccured = error {
                        self.cameraManager.showErrorBlock("Error occurred", errorOccured.localizedDescription)
                    }
                    else
                    {
                        DispatchQueue.main.async(execute: {
                            self.viewProgress.isHidden = true
                            self.videoCaptureProgress.constant = 0.0
                            self.videoProgressTime?.invalidate()
                            
                            let objFilter:FilterVC = loadVC(strStoryboardId: SB_FEEDS, strVCId:"FilterVC") as! FilterVC
                            objFilter.isFromGallery = false
                            objFilter.objMediaType = .video
                            objFilter.imgThumNail = getVideoThumbnail(videoURL: videoURL!)
                            objFilter.videoURL = videoURL
                            APP_DELEGATE.appNavigation?.pushViewController(objFilter, animated: true)
                        })
                    }
                })
            }
        }
        
        
        func setupUI()  {
            isStatusBarHidden = false
            self.lblnomedia.isHidden = true
            collectionPhoto.delegate = self
            collectionPhoto.dataSource = self
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        
        //MARK:- Collection View
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
        {
            return self.objMediaType == .image ? arrImage.count : arrVideo.count
        }
        
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
        {
            let cell:PhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath as IndexPath) as! PhotoCell
            if(objMediaType == .image)
            {
                cell.imgPic.image = arrImage[indexPath.row]
                cell.imgSelected.image = UIImage.init(named: "check_post")
                if selectedImagePath.contains(indexPath)
                {
                    cell.imgSelected.isHidden = false
                }
                else
                {
                    cell.imgSelected.isHidden = true
                }
//                if(selectedIndex != nil)
//                {
//                    cell.imgSelected.isHidden = indexPath == selectedIndex ? false : true
//                }
            }
            else
            {
                if selectedVideoPath.contains(indexPath)
                {
                    cell.imgSelected.isHidden = false
                }
                else
                {
                    cell.imgSelected.isHidden = true
                }
                //cell.imgSelected.isHidden = true
                cell.imgPic.image = getVideoThumbnail(videoURL: arrVideo[indexPath.row])
            }
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
        {
            let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
            
            if(objMediaType == .image)
            {
                if selectedImagePath.contains(indexPath)
                {
                      selectedImage.remove(at: selectedImagePath.index(of: indexPath)!)
                    selectedImagePath.remove(at: selectedImagePath.index(of: indexPath)!)
                  
                }
                else
                {
                    selectedImagePath.append(indexPath)
                    let tumb = cell.imgPic.image
                    tumb?.accessibilityLabel = "IMAGE"
                    selectedImage.append(tumb!)
                }
                collectionPhoto.reloadItems(at: [indexPath])
            }
            else
            {
                //Navigate to filter view
                if selectedVideoPath.contains(indexPath)
                {
                    selectedVideo.remove(at: selectedVideoPath.index(of: indexPath)!)
                    selectedVideoPath.remove(at: selectedVideoPath.index(of: indexPath)!)
                }
                else
                {
                    selectedVideoPath.append(indexPath)
                    let tumb = cell.imgPic.image
                    tumb?.accessibilityLabel = "\(arrVideo[indexPath.row])"
                    selectedVideo.append(tumb!)
                }
                collectionPhoto.reloadItems(at: [indexPath])
               // showStatusBarMessage("In Progress")
//                let objCurrentCell:PhotoCell = collectionPhoto.cellForItem(at: indexPath) as! PhotoCell
//                let objFilter:FilterVC = loadVC(strStoryboardId: SB_FEEDS, strVCId:"FilterVC") as! FilterVC
//                objFilter.isFromGallery = true
//                objFilter.objMediaType = .video
//                objFilter.imgThumNail = objCurrentCell.imgPic.image
//                objFilter.videoURL = arrVideo[indexPath.row]
//                APP_DELEGATE.appNavigation?.pushViewController(objFilter, animated: true)
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize.init(width: SCREENWIDTH()/4 - 6
                , height: SCREENWIDTH()/4 - 6)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 5, left: 5, bottom: 115, right: 5)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 3
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 3
        }
        
        
        @IBAction func btnCamera(_ sender: Any)
        {
            lblVideo.isEnabled = false
            lblCamera.isEnabled = true
            lblGallery.isEnabled = false
            lblnomedia.isHidden = true
            UIView.animate(withDuration: 0.4, animations: {
                self.bottomPaddingCameraView.constant = -10
                self.bottomPaddingGalleryView.constant = -154
                self.view.layoutIfNeeded()
            }) { (isComplete) in
                self.showCamera()
            }
        }
        
        @IBAction func btnVideo(_ sender: Any)
        {
            lblVideo.isEnabled = true
            lblCamera.isEnabled = false
            lblGallery.isEnabled = false
            
            btnNext.isHidden = true
            self.activityIndicator.startAnimating()
            showStatusBarMessage("Refreshing Videos...".localized())
            fetchVideoFromGallery { (isComplete) in
                DispatchQueue.main.async(execute: {
                    self.objMediaType = .video
                    self.activityIndicator.stopAnimating()
                    self.btnNext.isHidden = false
                    self.collectionPhoto.delegate = self
                    self.collectionPhoto.dataSource = self
                    if self.arrVideo.count == 0
                    {
                        self.lblnomedia.isHidden = false
                    }
                    else
                    {
                        self.lblnomedia.isHidden = true
                    }
                    self.collectionPhoto.reloadData()
                })
            }
            
        }
        
        @IBAction func btnPhoto(_ sender: Any) {
            lblVideo.isEnabled = false
            lblCamera.isEnabled = false
            lblGallery.isEnabled = true
            
            btnNext.isHidden = true
            self.activityIndicator.startAnimating()
            fetchPhotoFromGallery { (isComplete) in
                self.objMediaType = .image
                self.activityIndicator.stopAnimating()
                self.btnNext.isHidden = false
                self.collectionPhoto.delegate = self
                self.collectionPhoto.dataSource = self
                self.viewGallery.isHidden = false
                self.viewCamera.isHidden = true
                if self.arrImage.count == 0
                {
                    self.lblnomedia.isHidden = false
                }
                else
                {
                    self.lblnomedia.isHidden = true
                }
                self.collectionPhoto.reloadData()
            }
        }
        
        @IBAction func btnBack(_ sender: Any) {
        }
        
        @IBAction func btnNext(_ sender: Any)
        {
            let flattenArray = [selectedImage, selectedVideo].flatMap({ (element: [Any]) -> [Any] in
                return element
            })
        
           if flattenArray.count > 0
           {
                let objFilter:FilterVC = loadVC(strStoryboardId: SB_FEEDS, strVCId:"FilterVC") as! FilterVC
                objFilter.isFromGallery = true
                objFilter.objMediaType = .image
                objFilter.selectedmedia = flattenArray as! [UIImage]
                APP_DELEGATE.appNavigation?.pushViewController(objFilter, animated: true)
            }
            else
            {
                showStatusBarMessage("Please select media to post".localized())
            }
//            if(selectedIndex != nil)
//            {
//                let objCell:PhotoCell = collectionPhoto.cellForItem(at: selectedIndex) as! PhotoCell
//                let objFilter:FilterVC = loadVC(strStoryboardId: SB_FEEDS, strVCId:"FilterVC") as! FilterVC
//                objFilter.originalImage = objCell.imgPic.image
//                objFilter.isFromGallery = true
//                objFilter.objMediaType = .image
//                APP_DELEGATE.appNavigation?.pushViewController(objFilter, animated: true)
//            }
//            else
//            {
//                showStatusBarMessage("Please select media to post".localized())
//            }
        }
        
        @IBAction func btnPermission(_ sender: Any) {
            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
        }
        
        //MARK: - Fetch All Photos From Gallery
        
        func synchPhoto(complete:@escaping (_ isComplete:Bool)->()) {
            if(arrImage.count > 0)
            {
                complete(true)
            }
            else
            {
                var i = 1
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
                fetchOptions.fetchLimit = 100
                
                let collection:PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                if collection.count == 0
                {
                    self.lblnomedia.isHidden = false
                    complete(true)
                    return
                }
                else
                {
                    self.lblnomedia.isHidden = true
                }
                let imageManager = PHImageManager.default()
                
                collection.enumerateObjects({(object: AnyObject!,
                    count: Int,
                    stop: UnsafeMutablePointer<ObjCBool>) in
                    if object is PHAsset {
                        let asset = object as! PHAsset
                        
                        let imageSize = CGSize(width: 375,
                                               height: 500)
                        let options = PHImageRequestOptions()
                        options.deliveryMode = .fastFormat
                        options.isSynchronous = true
                        options.resizeMode = .exact
                        options.isNetworkAccessAllowed  =   true
                        imageManager.requestImage(for: asset,
                                                  targetSize: imageSize,
                                                  contentMode: .aspectFill,
                                                  options: options,
                                                  resultHandler: {
                                                    (image, info) -> Void in
                                                    self.arrImage.append(image!)
                                                    if(i == collection.count)
                                                    {
                                                        stop.pointee = true
                                                        complete(true)
                                                    }
                                                    else
                                                    {
                                                        i = i+1
                                                    }
                        })
                    }
                })
            }
            
        }
        
        func synchVideo(complete:@escaping (_ isComplete:Bool)->()) {
            
            if(self.arrVideo.count > 0)
            {
                complete(true)
            }
            else
            {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
                let collection:PHFetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                var i = 1
                if collection.count == 0
                {
                    self.lblnomedia.isHidden = false
                    complete(true)
                    return
                }
                else
                {
                    self.lblnomedia.isHidden = true
                }
                collection.enumerateObjects({(object: AnyObject!,
                    count: Int,
                    stop: UnsafeMutablePointer<ObjCBool>) in
                    if object is PHAsset {
                        let asset = object as! PHAsset
                        PHImageManager().requestAVAsset(forVideo: asset, options: nil, resultHandler: { (avurlAsset, audioMix, dict) in
                            let objVideo = avurlAsset as? AVURLAsset
                            
                            if(objVideo?.url != nil)
                            {
                                self.arrVideo.append((objVideo?.url)!)
                            }
                            
                            if(i == collection.count)
                            {
                                complete(true)
                            }
                            else
                            {
                                i = i+1
                            }
                            
                        })
                    }
                })
            }
        }
        
        func fetchVideoFromGallery(complete:@escaping (_ isComplete:Bool)->()) {
            
            // Get the current authorization state.
            let status = PHPhotoLibrary.authorizationStatus()
            if (status == PHAuthorizationStatus.authorized) {
                // Access has been granted.
                DispatchQueue.main.async(execute: {
                    self.viewPermission.isHidden = true
                })
                self.synchVideo(complete: { (isComplete) in
                    if(isComplete)
                    {
                        complete(true)
                    }
                })
            }
            if (status == PHAuthorizationStatus.denied) {
                // Access has been denied.
                //print("Denied")
                DispatchQueue.main.async(execute: {
                    self.viewPermission.isHidden = false
                })
            }
            if (status == PHAuthorizationStatus.notDetermined) {
                // Access has not been determined.
                PHPhotoLibrary.requestAuthorization({ (newStatus) in
                    if (newStatus == PHAuthorizationStatus.authorized) {
                        DispatchQueue.main.async(execute: {
                            self.viewPermission.isHidden = true
                        })
                        self.synchVideo(complete: { (isComplete) in
                            if(isComplete)
                            {
                                complete(true)
                            }
                        })
                    }
                    else {
                        //print("Not Getting...")
                        DispatchQueue.main.async(execute: {
                            self.viewPermission.isHidden = false
                        })
                    }
                })
            }
            if (status == PHAuthorizationStatus.restricted) {
                // Restricted access - normally won't happen.
                DispatchQueue.main.async(execute: {
                    self.viewPermission.isHidden = false
                })
            }
        }
        
        
        func fetchPhotoFromGallery(complete:@escaping (_ isComplete:Bool)->()) {
            
            // Get the current authorization state.
            let status = PHPhotoLibrary.authorizationStatus()
            if (status == PHAuthorizationStatus.authorized) {
                // Access has been granted.
                DispatchQueue.main.async(execute: {
                    self.viewPermission.isHidden = true
                })
                
                self.synchPhoto(complete: { (isComplete) in
                    if(isComplete)
                    {
                        complete(true)
                    }
                })
            }
                
            else if (status == PHAuthorizationStatus.denied) {
                // Access has been denied.
                //print("Denied")
                DispatchQueue.main.async(execute: {
                    self.viewPermission.isHidden = false
                })
            }
                
            else if (status == PHAuthorizationStatus.notDetermined) {
                
                // Access has not been determined.
                PHPhotoLibrary.requestAuthorization({ (newStatus) in
                    if (newStatus == PHAuthorizationStatus.authorized) {
                        DispatchQueue.main.async(execute: {
                            self.viewPermission.isHidden = true
                        })
                        self.synchPhoto(complete: { (isComplete) in
                            if(isComplete)
                            {
                                complete(true)
                            }
                        })
                    }
                    else {
                        //print("Not Getting...")
                        DispatchQueue.main.async(execute: {
                            self.viewPermission.isHidden = false
                        })
                    }
                })
            }
                
            else if (status == PHAuthorizationStatus.restricted) {
                // Restricted access - normally won't happen.
                DispatchQueue.main.async(execute: {
                    self.viewPermission.isHidden = false
                })
            }
            
            
            // Sort the images by creation date
            
        }
    }

