//
//  AssetPickerVC.swift
//  WakeUppApp
//
//  Created by Admin on 23/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import Photos
import CameraManager

class AssetPickerVC: UIViewController {
    
    //MARK: - Constants
    let bottomViewsExpandedHeight:CGFloat  = 120.0
    let bottomViewCollapsedHeight:CGFloat = 38.0
    
    let animationDuration = 0.3

    let maxSelections : Int = 5 //10
    let maxVideoSelections : Int = 2
    
    let fetchOptions:PHFetchOptions = PHFetchOptions()
    let checkedImage = #imageLiteral(resourceName: "check_post")
    let uncheckedImage = #imageLiteral(resourceName: "uncheck_post")
    
    let maxVideoDuration = 30.0
    
    //MARK: - IBOutlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var cameraView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var btnPullUp: UIButton!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var galleryControlViewHeight: NSLayoutConstraint!
    @IBOutlet weak var cameraControlViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var galleryControlTopSpacing: NSLayoutConstraint!
    @IBOutlet weak var cameraControlTopSpacing: NSLayoutConstraint!
    
    @IBOutlet weak var lblCamera: UILabel!
    @IBOutlet weak var lblGallery: UILabel!
    @IBOutlet weak var lblVideo: UILabel!
    
    @IBOutlet weak var videoProgressContainerView: UIView!
    @IBOutlet weak var btnFlashLight: UIButton!
    @IBOutlet weak var btnCameraCapture: UIButton!
    @IBOutlet weak var btnSwitchToCapturePhoto: UIButton!
    @IBOutlet weak var btnSwitchToRecordVideo: UIButton!
    
    let cameraManager = CameraManager()

    
    //MARK: - Properties
    var isBottomViewCollapsed = true
    var isCameraControlViewDisplayed = false
    
    var isPhotoAccessPermitted = false

    var arrSelectedImageIndexes = [Int]()
    var arrSelectedVideoIndexes = [Int]()
    
    var allPHImages = PHFetchResult<PHAsset>()
    var allPHVideos = PHFetchResult<PHAsset>()
    
    var arrSelectedAssets = [PHAsset]()

    var isImagesCurrentlySelected = true
    
    lazy var imageManager = {
        return PHCachingImageManager()
    }()
    
    var videoProgress = UIView()
    var videoRecordingProgressTimer = Timer()
    var currentlyRecordedVideoDuration = 0.0
    
    var arrImageThumbnails = [UIImage]()
    var arrVideoThumbnails = [UIImage]()
    
    //var arrThumbnails = [ThumbnailCacheModel]()
    
    var shouldFilterAssets = false
    var delegate: AssetPickerDelegate?
    var arrFinalModels = [FilterAssetModel]()
    var filterUtils = FilterUtilities()
    var arrFilterAssetModels = [FilterAssetModel]()
    
    var initallyCameraSelected = false
    
    
    //MARK: - View Controller Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        //CONFIGURE COLLECTION VIEW
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        //PREPARE FETCH OPTIONS
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        //INITIALLY HIDDEN CAMERA CONTROLS
        cameraControlTopSpacing.constant = bottomViewsExpandedHeight
        
        //INITIALLY CAMERA SET TO PHOTO CAPTURE
        btnSwitchToCapturePhoto.isSelected = true
        btnSwitchToRecordVideo.isSelected = false
        
        //PERMISSIONS
        requestAssets()
        requestCamera()
        
        //RECORD VIDEO ON LONG PRESS OF CAPTURE BUTTON
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(btnCaptureLongPressed))
        btnCameraCapture.addGestureRecognizer(longPress)
        
        //INITIALLY GALLERY (PHOTOS) DISPLAYED
        lblGallery.textColor = themeTextColor
        lblTitle.text = "Select Photo"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupAnimation()
        
        if initallyCameraSelected{
            btnGotoCameraClicked(UIButton())
            initallyCameraSelected = false
        }else{
            collapseBottomView()
        }
    }
    
    func setupAnimation(){
        if let animationKeys = btnPullUp.layer.animationKeys(){
            if animationKeys.contains("position"){
               btnPullUp.layer.removeAnimation(forKey: "position")
            }
        }
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.3
        animation.repeatCount = .greatestFiniteMagnitude//Float.infinity
        animation.fromValue = NSValue(cgPoint: btnPullUp.center)
        animation.toValue = NSValue(cgPoint: CGPoint(x: btnPullUp.center.x, y: btnPullUp.center.y - 3))
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.autoreverses = true
        animation.isRemovedOnCompletion = false
        btnPullUp.layer.add(animation, forKey: "position")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Methods
    func reloadCollectionView(){
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func requestAssets(){
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                self.isPhotoAccessPermitted = true
                
                if self.isImagesCurrentlySelected{
                    self.loadPhotos()
                }else{
                    self.loadVideos()
                }
                
                //print("authorized")
            case .denied, .restricted:
                //print("Not allowed")
                break
            case .notDetermined:
                //print("Not determined yet")
                break
            }
        }
    }
    
    func requestCamera() {
        cameraManager.askUserForCameraPermission({ permissionGranted in
            if permissionGranted {
                self.addCameraToView()
            }
        })
    }
    
    func loadPhotos() {
        if isPhotoAccessPermitted {
            allPHImages = PHAsset.fetchAssets(with: .image, options: self.fetchOptions)
            //print("TOTAL PHOTO COUNT : \(allPHImages.count)")
            reloadCollectionView()
        }
    }
    
    func loadVideos(){
        if isPhotoAccessPermitted{
            let options = self.fetchOptions.copy() as! PHFetchOptions
            options.predicate = NSPredicate(format: "duration <= \(maxVideoDuration)")
            allPHVideos = PHAsset.fetchAssets(with: .video, options: options)
            //print("TOTAL VIDEO COUNT : \(allPHVideos.count)")
            reloadCollectionView()
        }
    }
    
    func addCameraToView() {
        cameraManager.addPreviewLayerToView(cameraView, newCameraOutputMode: CameraOutputMode.stillImage)
        cameraManager.showErrorBlock = { [weak self] (erTitle: String, erMessage: String) -> Void in
            let alertController = UIAlertController(title: erTitle, message: erMessage, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (alertAction) -> Void in  }))
            self?.present(alertController, animated: true, completion: nil)
        }
    }
    
    //MARK: - Top Navigation Button Clicks
    @IBAction func btnBackClicked(_ sender: Any) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnNextClicked(_ sender: Any) {
        if arrSelectedAssets.count > 0{
            arrFilterAssetModels = [FilterAssetModel]()
            for asset in arrSelectedAssets{
                
                var image = asset.getOriginalImage()
                if image.sd_imageData() != nil {
                    image = image.fixedOrientation()
                    image = image.cropsToSquare() //INITIALLY CROPPED TO SQUARE
                }
                
                let filterAssetModel = FilterAssetModel(
                    originalPHAsset: asset,
                    thumbnailImage: image.resizeImage(targetSize: thumbnailImageSize),
                    croppedImage: image,
                    originalImage: image,
                    currentVideoComposition: nil,
                    selectedFilter: arrFilters[0],
                    brightnessValue: kBrightness,
                    contrastValue: kContrast,
                    saturationValue: kSaturation,
                    warmthValue: kWarmth,
                    fadeValue: kFade,
                    exposureValue: kExposure,
                    exportedFileURL: nil
                )
                
                arrFilterAssetModels.append(filterAssetModel)
            }
            
            if shouldFilterAssets{
                let assetFilterVC = loadVC(strStoryboardId: SB_ASSET_PICKER, strVCId: idAssetFiltersVC) as! AssetFiltersVC
                assetFilterVC.arrSelectedAssets = arrFilterAssetModels
                assetFilterVC.delegate = delegate
                APP_DELEGATE.appNavigation?.pushViewController(assetFilterVC, animated: true)
            }else{
                
                try? FileManager.default.removeItem(atPath: FileManager.default.getDocumentsDirectory().appendingPathComponent(FilterAssetsDirectory))
                
                if (FileManager.default.createDirectoryAtDocumentDirectoryName(directoryName: FilterAssetsDirectory)){
                    
                    arrFinalModels = [FilterAssetModel]()
                    
                    //print("Preparing Filtered Models")
                    showHUD()
                    //PV | Remove delay
                    //perform(#selector(prepareFilteredModels), with: nil, afterDelay: 1.0)
                    perform(#selector(prepareFilteredModels), with: nil, afterDelay: 0.00)
                }
            }
            
        }else{
            showMessage("Select Photos or Videos to Continue")
        }
    }
    
    @objc func prepareFilteredModels(){
        if arrSelectedAssets.count == arrFinalModels.count{
            //DISMISS HUD
            hideHUD()
            
            //print("Filter Models Ready to be posted")
            self.delegate?.assetPickerDidFinishSelectingAssets(withFilterAssetModels: self.arrFinalModels)
            return
        }
        
        var filterAssetModel = arrFilterAssetModels[arrFinalModels.count]
        filterAssetModel.croppedImage = filterUtils.getFilteredImage(filterName: filterAssetModel.selectedFilter, originalImage: filterAssetModel.croppedImage)
        if filterAssetModel.originalPHAsset.mediaType == .image{
            arrFinalModels.append(filterAssetModel)
            prepareFilteredModels()
        }else{
            filterAssetModel.originalPHAsset.getURL(completionHandler: { (url) in
                let avAsset = AVAsset.init(url:url!)
                let pathInDocumentsDirectory = FileManager.default.getDocumentsDirectory().appendingPathComponent(FilterAssetsDirectory.appendingPathComponent(String.random(ofLength: 10)))
                let exporter = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetMediumQuality)
                exporter!.outputURL = URL.init(fileURLWithPath: pathInDocumentsDirectory.appending(".mp4"))
                exporter!.outputFileType = AVFileType.mp4
                exporter?.videoComposition = filterAssetModel.currentVideoComposition
                exporter!.exportAsynchronously{
                    if exporter?.status == .failed{
                        print(exporter!.error!.localizedDescription)
                    }
                    filterAssetModel.exportedFileURL = exporter!.outputURL
                    self.arrFinalModels.append(filterAssetModel)
                    self.prepareFilteredModels()
                }
            })
        }
    }
    
    //MARK: - Bottom Gallery Control Button Clicks
    @IBAction func btnPullUpClicked(_ sender: Any) {
        if isBottomViewCollapsed{
            expandBottomView()
        }else{
            collapseBottomView()
        }
    }
    
    @IBAction func btnGotoCameraClicked(_ sender: Any) {
        
        //arrSelectedAssets = [PHAsset]()
        //arrSelectedImageIndexes = [Int]()
        //arrSelectedVideoIndexes = [Int]()
        
        reloadCollectionView()
        
        collectionView.isHidden = true
        galleryControlTopSpacing.constant = bottomViewsExpandedHeight
        cameraControlTopSpacing.constant = 8
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
        
        lblTitle.text = "Capture Photo"
    }
    
    @IBAction func btnGotoPhotosClicked(_ sender: Any) {
        perform(#selector(collapseBottomView), with: nil, afterDelay: 0.8)
        
        lblGallery.textColor = themeTextColor
        lblVideo.textColor = .darkGray
        
        isImagesCurrentlySelected = true
        requestAssets()
        reloadCollectionView()
        
        lblTitle.text = "Select Photo"
    }
    
    @IBAction func btnGotoVideosClicked(_ sender: Any) {
        perform(#selector(collapseBottomView), with: nil, afterDelay: 0.8)
        
        lblGallery.textColor = .darkGray
        lblVideo.textColor = themeTextColor
        
        isImagesCurrentlySelected = false
        requestAssets()
        reloadCollectionView()
        
        lblTitle.text = "Select Video"
    }
    
    
    //MARK: - Bottom Camera Control Button Clicks
    @IBAction func btnSwitchCameraClicked(_ sender: Any) {
        cameraManager.cameraDevice = cameraManager.cameraDevice == CameraDevice.front ? CameraDevice.back : CameraDevice.front
    }
    
    @IBAction func btnCameraShutterClicked(_ sender: Any) {
        if btnSwitchToCapturePhoto.isSelected{
            //print("PHOTO CAPTURE")
            cameraManager.capturePictureWithCompletion({ (image, error) -> Void in
                if let errorOccured = error {
                    self.cameraManager.showErrorBlock("Error occurred", errorOccured.localizedDescription)
                }
                else
                {
                    showStatusBarMessage("Photo Saved")
                }
            })
        }
    }
    
    @objc func btnCaptureLongPressed(_ gesture:UILongPressGestureRecognizer){
        if btnSwitchToRecordVideo.isSelected{
            switch gesture.state {
            case .began:
                //print("START VIDEO CAPTURE")
                startVideoRecording()
                break
            case .ended:
                //print("STOP VIDEO CAPTURE")
                stopVideoRecording()
                break
            case .cancelled:
                //print("CANCELLED LONG PRESS")
                break
            case .changed:
                //print("CHANGED LONG PRESS")
                break
            case .failed:
                //print("FAILED LONG PRESS")
                break
            case .possible:
                //print("POSSIBLE LONG PRESS")
                break
            }
        }
    }
    
    @IBAction func btnFlashLightClicked(_ sender: Any) {
        switch cameraManager.flashMode {
        case .on:
            cameraManager.flashMode  = .off
            btnFlashLight.isSelected = false
            break
        case .off:
            cameraManager.flashMode  = .on
            btnFlashLight.isSelected = true
            break
        default:
            break
        }
    }
    
    @IBAction func btnGoToGalleryClicked(_ sender: Any) {
        collectionView.isHidden = false
        cameraControlTopSpacing.constant = bottomViewsExpandedHeight
        galleryControlTopSpacing.constant = 8
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
        loadPhotos()
        loadVideos()
        
        lblTitle.text = "Select Photo"
    }
    
    @IBAction func btnSwitchToCapturePhotoClicked(_ sender: Any) {
        cameraManager.cameraOutputMode = .stillImage
        btnSwitchToCapturePhoto.isSelected = true
        btnSwitchToRecordVideo.isSelected = false
        
        lblTitle.text = "Capture Photo"
    }
    
    @IBAction func btnSwitchToRecordVideoClicked(_ sender: Any) {
        cameraManager.cameraOutputMode = .videoWithMic
        btnSwitchToCapturePhoto.isSelected = false
        btnSwitchToRecordVideo.isSelected = true
        
        lblTitle.text = "Record Video"
    }
    
    //MARK: - Bottom View Expand / Collapse
    func expandBottomView(){
        
        bottomViewHeight.constant = bottomViewsExpandedHeight
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
        isBottomViewCollapsed = false
        
    }
    
    @objc func collapseBottomView(){
        
        bottomViewHeight.constant = bottomViewCollapsedHeight
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
        isBottomViewCollapsed = true
        
    }
    
    //MARK: - Video Capture
    func startVideoRecording(){
        cameraManager.startRecordingVideo()

        videoProgressContainerView.subviews.forEach({$0.removeFromSuperview()})
        
        videoProgress = UIView.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 0, height: 3)))
        videoProgress.backgroundColor = .lightGray
        videoProgressContainerView.addSubview(videoProgress)
        
        videoRecordingProgressTimer = Timer.scheduledTimer(timeInterval: 0.05,
                                                           target: self,
                                                           selector: #selector(videoRecordingTimerHandler(timer:)),
                                                           userInfo: nil,
                                                           repeats: true)
    }
    
    func stopVideoRecording(){
        cameraManager.stopVideoRecording({ (videoURL, error) -> Void in
            if let errorOccured = error {
                self.cameraManager.showErrorBlock("Error occurred", errorOccured.localizedDescription)
            }
            else
            {
                DispatchQueue.main.async(execute: {
                    self.videoRecordingProgressTimer.invalidate()
                    self.currentlyRecordedVideoDuration = 0.0
                    self.videoProgressContainerView.subviews.forEach({$0.removeFromSuperview()})
                    self.videoProgress.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 0, height: 3))
                    showStatusBarMessage("Video Saved")
                })
                
            }
        })
        
    }
    
    @objc func videoRecordingTimerHandler(timer: Timer){
        currentlyRecordedVideoDuration += 0.05
        
        if currentlyRecordedVideoDuration >= maxVideoDuration {
            stopVideoRecording()
        }else{
            
            let percentFilled:CGFloat = CGFloat((currentlyRecordedVideoDuration * 100) / maxVideoDuration)
            let fillWidth = (percentFilled * videoProgressContainerView.frame.width) / 100
            //print("Fill Width :\(fillWidth)")
            videoProgress.frame = CGRect.init(origin: videoProgress.frame.origin, size: CGSize.init(width: fillWidth, height: 3))
        }
        
    }
    
}


//MARK: - CollectionView Datasource & Delegate
extension AssetPickerVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! AssetSelectionCell
        
        if isImagesCurrentlySelected{
            
            let imageAsset = allPHImages.object(at: indexPath.row)
            
            cell.imgView.image = imageAsset.getThumbnail()
            
            if arrSelectedImageIndexes.contains(indexPath.row){
                cell.imgChecked.image = checkedImage
            }else{
                cell.imgChecked.image = uncheckedImage
            }
            cell.imgVideo.isHidden = true
        }else{
            
            let videoAsset = allPHVideos.object(at: indexPath.row)
            cell.imgView.image = videoAsset.getThumbnail()
            
            if arrSelectedVideoIndexes.contains(indexPath.row){
                cell.imgChecked.image = checkedImage
            }else{
                cell.imgChecked.image = uncheckedImage
            }
            cell.imgVideo.isHidden = false
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isImagesCurrentlySelected{
            return allPHImages.count
        }else{
            return allPHVideos.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collapseBottomView()
        
        var currentAsset : PHAsset!
        var currentSelectionArray = [Int]()
        if isImagesCurrentlySelected{
            currentAsset = allPHImages[indexPath.row]
            currentSelectionArray = arrSelectedImageIndexes
        }else{
            currentAsset = allPHVideos[indexPath.row]
            currentSelectionArray = arrSelectedVideoIndexes
        }
        
        if arrSelectedAssets.contains(currentAsset){
            currentSelectionArray.remove(at: currentSelectionArray.index(of: indexPath.row)!)
            arrSelectedAssets.remove(at: arrSelectedAssets.index(of: currentAsset)!)
        }else{
            if arrSelectedAssets.count < maxSelections{
                if isImagesCurrentlySelected == false{
                    if arrSelectedVideoIndexes.count < maxVideoSelections{
                        currentSelectionArray.append(indexPath.row)
                        arrSelectedAssets.append(currentAsset)
                    }else{
                        showAlertWithMessage(message: "You can select a maximum of \(maxVideoSelections) videos.")
                    }
                }else{
                    currentSelectionArray.append(indexPath.row)
                    arrSelectedAssets.append(currentAsset)
                }
            }else{
                showAlertWithMessage(message: "You can select a maximum of \(maxSelections) assets.")
            }
            
        }
        
        if isImagesCurrentlySelected{
            arrSelectedImageIndexes = currentSelectionArray
        }else{
            arrSelectedVideoIndexes = currentSelectionArray
        }
        
        collectionView.reloadItems(at: [indexPath])
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthAndHeight = collectionView.frame.width / 3
        return CGSize.init(width: widthAndHeight, height: widthAndHeight)
    }
    
}

//MARK: - Helper Extension
extension AssetPickerVC {
    
    func showAlertWithMessage(message:String){
        let alert = UIAlertController.init(title: nil, message: message, preferredStyle: .alert)
        let actionOk = UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(actionOk)
        present(alert, animated: true, completion: nil)
    }
    
}
