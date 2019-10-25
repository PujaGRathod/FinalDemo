//
//  AssetFiltersVC.swift
//  WakeUppApp
//
//  Created by Admin on 24/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import IGRPhotoTweaks

class AssetFiltersVC: UIViewController {
    
    //MARK: - Constants
    let bottomViewsExpandedHeight:CGFloat  = 120.0
    let bottomViewCollapsedHeight:CGFloat = 38.0
    
    let animationDuration = 0.3
    
    let arrAdjustmentIcons = [#imageLiteral(resourceName: "brightness_filter"), #imageLiteral(resourceName: "contrast_filter"), #imageLiteral(resourceName: "structure_filter"), #imageLiteral(resourceName: "warm_filter"), #imageLiteral(resourceName: "fade_filter"), #imageLiteral(resourceName: "exposure_filter")]
    let arrAdjustmentLabels = ["Brightness", "Contrast", "Saturation", "Warmth", "Fade", "Exposure"]
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var btnPullUp: UIButton!
    @IBOutlet weak var collectionAssets: UICollectionView!
    @IBOutlet weak var collectionFilters: UICollectionView!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var adjustmentContainer: UIView!
    
    @IBOutlet weak var imgSelectedAdjustment: UIImageView!
    @IBOutlet weak var lblSelectedAdjustment: UILabel!
    @IBOutlet weak var slider: TNSlider!
    
    @IBOutlet weak var collectionAdjustment: UICollectionView!
    @IBOutlet weak var adjustmentControlsContainer: UIView!
    
    @IBOutlet weak var lblFilter: UILabel!
    @IBOutlet weak var lblAdjustment: UILabel!
    
    
    //MARK: - Properties
    var isBottomViewCollapsed = true

    var arrSelectedAssets = [FilterAssetModel]()
    
    var currentAssetIndex:Int = 0
    
    var filterUtils = FilterUtilities()
    
    var cropImageIndex:Int?
    
    var currentAdjustmentIndex = 0
    
    var arrFinalModels = [FilterAssetModel]()
    
    weak var delegate: AssetPickerDelegate?

    //MARK: - View Controller Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblFilter.textColor = themeTextColor
        
        adjustmentContainer.isHidden = true
        adjustmentControlsContainer.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        collapseBottomView()
        setupAnimation()
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
    
    //MARK: - Navigation Button Clicks
    @IBAction func btnBackClicked(_ sender: Any) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnNextClicked(_ sender: Any) {
        
        try? FileManager.default.removeItem(atPath: FileManager.default.getDocumentsDirectory().appendingPathComponent(FilterAssetsDirectory))
        
        if (FileManager.default.createDirectoryAtDocumentDirectoryName(directoryName: FilterAssetsDirectory)){
            //SHOW HUD BECAUSE VIDEO EXPORT MIGHT TAKE TIME
            /*for var filterAssetModel in arrSelectedAssets{
                filterAssetModel.exportLocally(completion: { url, image in
                    //print("Exported to : \(url)")
                    self.arrExportedURLs.append(url)
                    if self.arrSelectedAssets.count == self.arrExportedURLs.count{
                        //print("ALL ASSETS EXPORTED SUCCESSFULLY")
                        print(self.arrExportedURLs)
                        //DISMISS HUD
                        self.delegate?.assetPickerDidFinishSelectingAssets(withFilterAssetModels: self.arrSelectedAssets)
                    }
                })
            }*/
            
            arrFinalModels = [FilterAssetModel]()
            
            //print("Preparing Filtered Models")
            showHUD()
            perform(#selector(prepareFilteredModels), with: nil, afterDelay: 1.0)
            //prepareFilteredModels()
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
        
        var filterAssetModel = arrSelectedAssets[arrFinalModels.count]
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
    
    //MARK: - Bottom View Clicks
    @IBAction func btnPullUpClicked(_ sender: Any) {
        /*if isBottomViewCollapsed{
            isBottomViewCollapsed = false
            bottomViewHeight.constant = bottomViewsExpandedHeight
        }else{
            isBottomViewCollapsed = true
            bottomViewHeight.constant = bottomViewCollapsedHeight
        }
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }*/
        if arrSelectedAssets[currentAssetIndex].originalPHAsset.mediaType == .image{
            if isBottomViewCollapsed{
                expandBottomView()
            }else{
                collapseBottomView()
            }
        }
    }
    
    @IBAction func btnFilterClicked(_ sender: Any) {
        collapseBottomView()
        
        lblAdjustment.textColor = .darkGray
        lblFilter.textColor = themeTextColor
        
        adjustmentControlsContainer.isHidden = true
        collectionAdjustment.isHidden = false

        adjustmentContainer.isHidden = true
        collectionFilters.isHidden = false
    }
    
    @IBAction func btnAdjustmentClicked(_ sender: Any) {
        collapseBottomView()
        
        lblAdjustment.textColor = themeTextColor
        lblFilter.textColor = .darkGray
        
        adjustmentContainer.isHidden = false
        collectionFilters.isHidden = true
    }
    
    //MARK: - Adjustment View Button Clicks
    @IBAction func btnAdjustmentDoneClicked(_ sender: Any) {
        adjustmentControlsContainer.isHidden = true
        collectionAdjustment.isHidden = false
    }
    
    @IBAction func btnAdjustmentCancelClicked(_ sender: Any) {
        adjustmentControlsContainer.isHidden = true
        collectionAdjustment.isHidden = false
        
        var currentAsset = arrSelectedAssets[currentAssetIndex]
        switch currentAdjustmentIndex {
        case 0:
            currentAsset.brightnessValue = kBrightness
        case 1:
            currentAsset.contrastValue = kContrast
        case 2:
            currentAsset.saturationValue = kSaturation
        case 3:
            currentAsset.warmthValue = kWarmth
        case 4:
            currentAsset.fadeValue = kFade
        case 5:
            currentAsset.exposureValue = kExposure
        default:
            break
        }
        arrSelectedAssets[currentAssetIndex] = currentAsset
        applyFilterOnSelectedAsset()
    }
    
    //MARK: - Adjustment Slider
    @IBAction func adjustmentSliderChanged(_ slider: UISlider) {
        var currentAsset = arrSelectedAssets[currentAssetIndex]
        switch currentAdjustmentIndex {
        case 0:
            currentAsset.brightnessValue = slider.value
        case 1:
            currentAsset.contrastValue = slider.value
        case 2:
            currentAsset.saturationValue = slider.value
        case 3:
            currentAsset.warmthValue = slider.value
        case 4:
            currentAsset.fadeValue = slider.value
        case 5:
            currentAsset.exposureValue = slider.value
        default:
            break
        }
        arrSelectedAssets[currentAssetIndex] = currentAsset
        applyFilterOnSelectedAsset()
    }
    
    @IBAction func sliderChanged(_ slider: TNSlider) {
        var currentAsset = arrSelectedAssets[currentAssetIndex]
        switch currentAdjustmentIndex {
        case 0:
            currentAsset.brightnessValue = slider.value
        case 1:
            currentAsset.contrastValue = slider.value
        case 2:
            currentAsset.saturationValue = slider.value
        case 3:
            currentAsset.warmthValue = slider.value
        case 4:
            currentAsset.fadeValue = slider.value
        case 5:
            currentAsset.exposureValue = slider.value
        default:
            break
        }
        arrSelectedAssets[currentAssetIndex] = currentAsset
        applyFilterOnSelectedAsset()
    }
    
    //MARK: - Apply Filter
    func applyFilterOnSelectedAsset(){
        
        DispatchQueue.main.async {
            var currentAsset = self.arrSelectedAssets[self.currentAssetIndex]
            
            let filterParameters1 = [
                "inputBrightness"   : currentAsset.brightnessValue,
                "inputSaturation"   : currentAsset.saturationValue,
                "inputContrast"     : currentAsset.contrastValue
            ]
            
            var image = currentAsset.originalImage.imageFiltered(withCoreImageFilter: "CIColorControls", parameters: filterParameters1)
            
            let filterParameters2 = [
                "inputFade" : currentAsset.fadeValue,
            ]
            image = image.imageFiltered(withCoreImageFilter: "CIPhotoEffectFade", parameters: filterParameters2)
            
            let filterParameters3 = [
                "inputEV"   : currentAsset.exposureValue,
                ]
            image = image.imageFiltered(withCoreImageFilter: "CIExposureAdjust", parameters: filterParameters3)
            
            let filterParameters4 = [
                "inputIntensity"   : currentAsset.warmthValue
            ]
            image = image.imageFiltered(withCoreImageFilter: "CISepiaTone", parameters:  filterParameters4)
            
            currentAsset.croppedImage = image
            
            self.arrSelectedAssets[self.currentAssetIndex] = currentAsset
            self.reloadCollectionAssets(withDelay: false)
            self.reloadCollectionFilters()
        }
        
    }
    
    //MARK: - Bottom View Expand / Collapse
    func expandBottomView(){
        
        bottomViewHeight.constant = bottomViewsExpandedHeight
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
        isBottomViewCollapsed = false
        
    }
    
    @objc func collapseBottomView(){
        
        bottomViewHeight.constant = bottomViewCollapsedHeight
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
        isBottomViewCollapsed = true
        
    }
    
}

extension AssetFiltersVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
        case collectionAssets:
            
            let filterAssetModel = arrSelectedAssets[indexPath.row]
            let phAsset = filterAssetModel.originalPHAsset
            if phAsset?.mediaType == .video{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoPreviewCell
                
                cell.videoContainer.gravity = .aspectFit
                
                filterAssetModel.originalPHAsset.getURL(completionHandler: { (url) in
                    cell.videoContainer.videoURL = url
                    cell.videoContainer.videoComposition = filterAssetModel.currentVideoComposition
                })
                return cell
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImagePreviewCell
                
                let image = filterUtils.getFilteredImage(filterName: filterAssetModel.selectedFilter, originalImage: filterAssetModel.croppedImage)
                cell.imgView.image = image
                
                /*//print("brightnessValue  : \(filterAssetModel.brightnessValue)")
                //print("contrastValue    : \(filterAssetModel.contrastValue)")
                //print("saturationValue  : \(filterAssetModel.saturationValue)")
                //print("warmthValue      : \(filterAssetModel.warmthValue)")
                //print("fadeValue        : \(filterAssetModel.fadeValue)")
                //print("exposureValue    : \(filterAssetModel.exposureValue)")*/
                
                return cell
            }
            
        case collectionFilters:
            let filterAssetModel = arrSelectedAssets[currentAssetIndex]
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FilterPreviewCell
            cell.lblFilter.text = arrFilterNames[indexPath.row]
            
            cell.imgView.image = nil
            
            let filterUtils = FilterUtilities()
            
            let image = filterUtils.getFilteredImage(filterName: arrFilters[indexPath.row], originalImage: filterAssetModel.thumbnailImage)
            cell.imgView.image = image
            
            if filterAssetModel.selectedFilter == arrFilters[indexPath.row]{
                cell.lblFilter.textColor = UIColor.white
            }else{
                cell.lblFilter.textColor = UIColor.white.withAlphaComponent(0.65)
            }
            
            return cell
            
        case collectionAdjustment:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! AdjustmentCell
            cell.imgAdjustment.image = arrAdjustmentIcons[indexPath.row]
            cell.lblAdjustment.text = arrAdjustmentLabels[indexPath.row]
            return cell
        default:
            return UICollectionViewCell()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case collectionAssets:
            return arrSelectedAssets.count
        case collectionFilters:
            return arrFilters.count
        case collectionAdjustment:
            return arrAdjustmentIcons.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        collapseBottomView()

        switch collectionView {
        case collectionAssets:
            
            let filterAssetModel = arrSelectedAssets[indexPath.row]
            let phAsset = filterAssetModel.originalPHAsset
            if phAsset?.mediaType == .image{
                self.cropImageIndex = indexPath.row
                let imageCropper = loadVC(strStoryboardId: SB_ASSET_PICKER, strVCId: idImageCropperVC) as! ImageCropperVC
                imageCropper.image = phAsset?.getOriginalImage()
                imageCropper.delegate = self
                APP_DELEGATE.appNavigation?.pushViewController(imageCropper, animated: true)
            }
            
        case collectionFilters:
            let filter = arrFilters[indexPath.row]
            
            var filterAssetModel = arrSelectedAssets[currentAssetIndex]
            
            if filterAssetModel.selectedFilter != filter{
            
                filterAssetModel.originalPHAsset.getURL(completionHandler: { (url) in
                    let avAsset = AVAsset.init(url:url!)
                    filterAssetModel.selectedFilter = filter
                    filterAssetModel.currentVideoComposition = FilterUtilities().getVideoComposition(filterName: filter, asset: avAsset)
                    self.arrSelectedAssets[self.currentAssetIndex] = filterAssetModel
                    
                    if filterAssetModel.originalPHAsset.mediaType == .video{
                        showHUD()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                            hideHUD()
                            self.reloadCollectionAssets(withDelay: false)
                            self.reloadCollectionAssets(withDelay: true)
                        })
                    }else{
                        self.reloadCollectionAssets(withDelay: false)
                        self.reloadCollectionAssets(withDelay: true)
                    }
                    
                    self.reloadCollectionFilters()
                })
            }
            
        case collectionAdjustment:
            collectionAdjustment.isHidden = true
            adjustmentControlsContainer.isHidden = false
            
            lblSelectedAdjustment.text = arrAdjustmentLabels[indexPath.row]
            imgSelectedAdjustment.image = arrAdjustmentIcons[indexPath.row]
            
            currentAdjustmentIndex = indexPath.row
            
            let currentAsset = arrSelectedAssets[currentAssetIndex]
            switch currentAdjustmentIndex {
            case 0:
                slider.minimum = -0.5 //-1.0
                slider.maximum = 0.5  //1.0
                slider.value = currentAsset.brightnessValue
            case 1:
                slider.minimum = 1.5 //1.0
                slider.maximum = 4.0
                slider.value = currentAsset.contrastValue
            case 2:
                slider.minimum = 0.0
                slider.maximum = 2.0
                slider.value = currentAsset.saturationValue
            case 3:
                slider.minimum = 0.0
                slider.maximum = 2.0
                slider.value = currentAsset.warmthValue
            case 4:
                slider.minimum = 0.5
                slider.maximum = 1.0
                slider.value = currentAsset.fadeValue
            case 5:
                slider.minimum = -2.0 //-10
                slider.maximum = 2.0  //10
                slider.value = currentAsset.exposureValue
            default:
                break
            }
            
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case collectionAssets:
            let size = CGSize.init(width: collectionAssets.frame.size.width, height: collectionAssets.frame.size.height)
            return size//collectionView.frame.size
        case collectionFilters, collectionAdjustment:
            return CGSize.init(width: 80, height: collectionView.frame.height)
        default:
            return CGSize.zero
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionAssets{
            let x = scrollView.contentOffset.x
            let w = scrollView.bounds.size.width
            currentAssetIndex = Int(ceil(x/w))
            reloadCollectionFilters()
            
            if arrSelectedAssets[currentAssetIndex].originalPHAsset.mediaType == .video{
                collapseBottomView()
                btnFilterClicked(UIButton())
            }
            
        }
    }
    
    //MARK:- RELOAD COLLECTION VIEWS
    @objc func reloadCollectionAssets(withDelay:Bool){
        DispatchQueue.main.async {
            if withDelay{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: {
                    self.collectionAssets.reloadData()
                })
            }else{
                self.collectionAssets.reloadData()
            }
        }
    }
    
    @objc func reloadCollectionFilters(){
        DispatchQueue.main.async {
            self.collectionFilters.reloadData()
        }
    }
    
}

extension AssetFiltersVC: IGRPhotoTweakViewControllerDelegate {
    func photoTweaksController(_ controller: IGRPhotoTweakViewController, didFinishWithCroppedImage croppedImage: UIImage) {
        if let croppedImageIndex = self.cropImageIndex{
            arrSelectedAssets[croppedImageIndex].croppedImage = croppedImage
            arrSelectedAssets[croppedImageIndex].originalImage = croppedImage
            arrSelectedAssets[croppedImageIndex].thumbnailImage = croppedImage.resizeImage(targetSize: thumbnailImageSize)
            applyFilterOnSelectedAsset()
            //reloadCollectionAssets(withDelay: false)
            reloadCollectionFilters()
        }
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    func photoTweaksControllerDidCancel(_ controller: IGRPhotoTweakViewController) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
}

extension AssetFiltersVC : TNSliderDelegate{
    
    func slider(_ slider: TNSlider, displayTextForValue value: Float) -> String{
        return "         "
    }
    
}
