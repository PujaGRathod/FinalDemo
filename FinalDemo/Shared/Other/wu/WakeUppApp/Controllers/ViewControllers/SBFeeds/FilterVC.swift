
//
//  FilterVC.swift
//  WakeUppApp
//
//  Created by Admin on 24/03/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import AVKit


class FilterVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate  {
    
    @IBOutlet var collSelectedImages: UICollectionView!
    @IBOutlet var heightfilter: NSLayoutConstraint!
    @IBOutlet var heightfilterbtn: NSLayoutConstraint!
    @IBOutlet weak var imgPhoto: UIImageView!
    var imgPrevious: UIImage!
    var selectedFilter = "No Filter"
    var objMediaType:MediaType = .image
    var videoURL:URL!
    var player = AVPlayer.init()
    var currentIndex:Int = 0
    var playerLayer = AVPlayerLayer.init()
    var imgThumNail: UIImage!
    var selectedmedia = [UIImage]()
    var playbtn = UIButton()
    var adjustmentgiven = false
    @IBOutlet weak var collectionFilter: UICollectionView!
    @IBOutlet weak var collectionCustomFilter: UICollectionView!
    
    @IBOutlet weak var imgCurrentFilter: UIImageView!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var sliderValue: UISlider!
    @IBOutlet weak var viewCustomFilter: UIView!
    @IBOutlet weak var lblFilterName: UILabel!
    
    var aCIImage = CIImage()
    var brightnessFilter: CIFilter!
    var contrastFilter: CIFilter!
    var saturationFilter: CIFilter!
    var warmthFilter: CIFilter!
    var vignetteFilter: CIFilter!
    var exposureFilter: CIFilter!
    
    var context = CIContext()
    var outputImage = CIImage()
    var newUIImage = UIImage()
    
    var currentBrightNess:Float = 0.0
    var currentContrast:Float = 75.0
    var currentSaturation:Float = 75.0
    var currentWarmth:Float = 0.0
    var currentFade:Float = 0.0
    var currentExposure:Float = 0.0
    
    var tempBrightNess:Float = 0.0
    var tempContrast:Float = 75.0
    var tempSaturation:Float = 75.0
    var tempWarmth:Float = 0.0
    var tempFade:Float = 0.0
    var tempExposure:Float = 0.0
    
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    fileprivate let customeFilterImage = [
        "brightness_filter",
        "contrast_filter",
        "structure_filter",
        "warm_filter",
        "fade_filter",
        "exposure_filter"
    ]
    
    fileprivate let customeFilterDisplayName = [
        "Brightness",
        "Contrast",
        "Saturation",
        "Warmth",
        "Fade",
        "Exposure"
    ]
    
    fileprivate let filterNameList = [
        "No Filter",
        "CIPhotoEffectChrome",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTransfer",
        "CILinearToSRGBToneCurve",
        "CISRGBToneCurveToLinear",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectMono",
        "CIPhotoEffectNoir",
        "CIPhotoEffectTonal"
    ]
    
    fileprivate let filterDisplayNameList = [
        "Normal",
        "Chrome",
        "Process",
        "Transfer",
        "Tone",
        "Linear",
        "Fade",
        "Instant",
        "Mono",
        "Noir",
        "Tonal"
    ]
    
    var originalImage:UIImage!
    var isFromGallery:Bool!
    var currentFilter:Int = 0
    
    var blurFilterMask: CAShapeLayer?
    var blurFilterOrigin = CGPoint.zero
    var blurFilterDiameter: CGFloat = 0.0
    
    @IBOutlet var blurView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI()
    {
        imgPhoto.image = originalImage
        isStatusBarHidden = false
        collectionFilter.isHidden = false
        collectionFilter.delegate = self
        collectionFilter.dataSource = self
        collSelectedImages.delegate = self
        collSelectedImages.dataSource = self
        self.heightfilterbtn.constant = 0
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        //        if(objMediaType == .video)
        //        {
        //            self.playVideo()
        //        }
        //        else
        //        {
        //            //Custom Filter
        let aUIImage:UIImage = selectedmedia[currentIndex]
        let aCGImage = aUIImage.cgImage!
        aCIImage = CIImage(cgImage: aCGImage)
        context = CIContext(options: nil)
        contrastFilter = CIFilter(name: "CIColorControls")
        contrastFilter.setValue(aCIImage, forKey: "inputImage")
        brightnessFilter = CIFilter(name: "CIColorControls")
        brightnessFilter.setValue(aCIImage, forKey: "inputImage")
        saturationFilter = CIFilter(name: "CIColorControls")
        saturationFilter.setValue(aCIImage, forKey: "inputImage")
        warmthFilter = CIFilter(name: "CISepiaTone")
        warmthFilter.setValue(aCIImage, forKey: "inputImage")
        exposureFilter = CIFilter(name: "CIExposureAdjust")
        exposureFilter.setValue(aCIImage, forKey: "inputImage")
        vignetteFilter = CIFilter(name: "CIGaussianBlur")
        vignetteFilter.setValue(aCIImage, forKey: "inputImage")
        //        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        //print("Video Finished")
        player.seek(to: kCMTimeZero)
        //        player.play()
        playbtn.setImage(UIImage.init(named: "playvideo"), for: .normal)
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer?) {
        blurFilterOrigin = (sender?.location(in: imgPhoto))!
        refreshBlurMask()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer?) {
        blurFilterOrigin = (sender?.location(in: imgPhoto))!
        refreshBlurMask()
    }
    
    @objc func handlePinch(_ sender: UIPinchGestureRecognizer?) {
        // Use some combination of sender.scale and sender.velocity to determine the rate at which you want the circle to expand/contract.
        blurFilterDiameter += (sender?.velocity)!
        refreshBlurMask()
    }
    
    func refreshBlurMask() {
        let blurFilterRadius: CGFloat = blurFilterDiameter * 0.5
        let blurRegionPath = CGMutablePath()
        blurRegionPath.addRect((imgPhoto?.bounds)!, transform: .identity)
        blurRegionPath.addEllipse(in: CGRect(x: blurFilterOrigin.x - blurFilterRadius, y: blurFilterOrigin.y - blurFilterRadius, width: blurFilterDiameter, height: blurFilterDiameter), transform: .identity)
        blurFilterMask?.path = blurRegionPath
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    //MARK:- Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if(collectionView == collSelectedImages)
        {
            return selectedmedia.count
        }
        else
        {
            if(objMediaType == .image)
            {
                if(collectionView == collectionFilter)
                {
                    return filterDisplayNameList.count
                }
                else
                {
                    return customeFilterImage.count
                }
            }
            else
            {
                return filterDisplayNameList.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if(collectionView == collectionFilter)
        {
            let cell:PhotoFilterCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoFilterCell", for: indexPath as IndexPath) as! PhotoFilterCell
            let img = selectedmedia[currentIndex]
            
            if(filterNameList[indexPath.row] != "No Filter")
            {
                
                cell.imgPhoto.image = createFilteredImage(filterName: filterNameList[indexPath.row], image: img)
                cell.imgOriginal.image = nil
            }
            else
            {
                cell.imgOriginal.isHidden = false
                cell.imgOriginal.image =  img
                cell.imgPhoto.image = nil
            }
            
            
            cell.lblFilterName.text = filterDisplayNameList[indexPath.row]
            return cell
        }
        else if(collectionView == collSelectedImages)
        {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imgCell", for: indexPath as IndexPath)
            currentIndex = indexPath.item
            let imgView = cell.viewWithTag(999) as! UIImageView
            let btn =  cell.viewWithTag(888) as! UIButton
            playbtn = btn
            let img = selectedmedia[indexPath.item]
            playbtn.addTarget(self, action: #selector(self.playvideclicked(_:)), for: .touchUpInside)
            playerLayer.removeFromSuperlayer()
            if img.accessibilityLabel == "IMAGE"
            {
                if(selectedFilter != "No Filter")
                {
                    imgView.image = createFilteredImage(filterName: selectedFilter, image: img)
                    imgView.image?.accessibilityLabel = "IMAGE"
                    selectedmedia[indexPath.item] = imgView.image!
                }
                else
                {
                    imgView.image =  img
                }
                btn.isHidden = true
                let aUIImage:UIImage = selectedmedia[currentIndex]
                let aCGImage = aUIImage.cgImage!
                aCIImage = CIImage(cgImage: aCGImage)
                context = CIContext(options: nil)
                contrastFilter = CIFilter(name: "CIColorControls")
                contrastFilter.setValue(aCIImage, forKey: "inputImage")
                brightnessFilter = CIFilter(name: "CIColorControls")
                brightnessFilter.setValue(aCIImage, forKey: "inputImage")
                saturationFilter = CIFilter(name: "CIColorControls")
                saturationFilter.setValue(aCIImage, forKey: "inputImage")
                warmthFilter = CIFilter(name: "CISepiaTone")
                warmthFilter.setValue(aCIImage, forKey: "inputImage")
                exposureFilter = CIFilter(name: "CIExposureAdjust")
                exposureFilter.setValue(aCIImage, forKey: "inputImage")
                vignetteFilter = CIFilter(name: "CIGaussianBlur")
                vignetteFilter.setValue(aCIImage, forKey: "inputImage")
                collectionCustomFilter.reloadData()
                self.heightfilterbtn.constant = 120
            }
            else
            {
                viewCustomFilter.isHidden = true
                collectionFilter.isHidden = false
                collectionCustomFilter.isHidden = true
                player.seek(to: kCMTimeZero)
                player.pause()
                playbtn.setImage(UIImage.init(named: "playvideo"), for: .normal)
                btn.isHidden = false
                self.heightfilterbtn.constant = 0
                if(selectedFilter != "No Filter")
                {
                    imgView.image = createFilteredImage(filterName: selectedFilter, image: img)
                    imgView.image?.accessibilityLabel = img.accessibilityLabel!
                    selectedmedia[indexPath.item] = imgView.image!
                    self.playVideoAtUrlToLayer(filterName: selectedFilter, urlval: img.accessibilityLabel!, imgvw: imgView)
                }
                else
                {
                    imgView.image = img
                    playerLayer.removeFromSuperlayer()
                }
                
            }
            collectionFilter.reloadData()
            return cell
        }
        else
        {
            
            let cell:PhotoFilterCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomeFilterCell", for: indexPath as IndexPath) as! PhotoFilterCell
            cell.imgPhoto.image = UIImage.init(named: customeFilterImage[indexPath.row])
            cell.lblFilterName.text = customeFilterDisplayName[indexPath.row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if(collectionView == collectionFilter)
        {
            selectedFilter = filterNameList[indexPath.row]
            collSelectedImages.reloadItems(at: [IndexPath.init(row: currentIndex, section: 0)])
        }
        else  if(collectionView == collSelectedImages)
        {
            
        }
        else
        {
            imgPrevious = imgPhoto.image
            imgCurrentFilter.image = UIImage.init(named: customeFilterImage[indexPath.row])
            lblFilterName.text = customeFilterDisplayName[indexPath.row]
            collectionCustomFilter.isHidden = true
            viewCustomFilter.isHidden = false
            switch indexPath.row {
            case 0:
                currentFilter = indexPath.row
                sliderValue.minimumValue = -80
                sliderValue.maximumValue = 80
                sliderValue.value = currentBrightNess
                break
            case 1:
                currentFilter = indexPath.row
                sliderValue.minimumValue = 0
                sliderValue.maximumValue = 150
                sliderValue.value = currentContrast
                break
            case 2:
                currentFilter = indexPath.row
                sliderValue.minimumValue = 0
                sliderValue.maximumValue = 150
                sliderValue.value = currentSaturation
                break
            case 3:
                currentFilter = indexPath.row
                sliderValue.minimumValue = 0
                sliderValue.maximumValue = 100
                sliderValue.value = currentWarmth
                break
            case 4:
                currentFilter = indexPath.row
                sliderValue.minimumValue = 0
                sliderValue.maximumValue = 10
                sliderValue.value = currentFade
                break
            case 5:
                currentFilter = indexPath.row
                sliderValue.minimumValue = -100
                sliderValue.maximumValue = 100
                sliderValue.value = currentExposure
                break
                
            default:
                break
            }
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if(collectionView == collSelectedImages)
        {
            return CGSize.init(width: collSelectedImages.frame.size.width, height: collSelectedImages.frame.size.height)
        }
        else
        {
            return CGSize.init(width: 80, height: 116)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if(collectionView == collSelectedImages)
        {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        else
        {
            return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        if(collectionView == collSelectedImages)
        {
            return 0
        }
        else
        {
            return 5
        }
    }
    
    
    @IBAction func sliderChange(_ sender: UISlider)
    {
        adjustmentgiven = true
        self.sliderValue.setValue(sender.value, animated: true)
        switch self.currentFilter {
        case 0:
            self.setupBrightNess(valBrightness: sender.value)
            break
        case 1:
            self.setupContrast(valContrast: sender.value)
            break
        case 2:
            self.setupSaturation(valSaturation: sender.value)
            break
        case 3:
            self.setupWarmth(valWarmth: sender.value)
            break
        case 4:
            self.setupBrightNess(valBrightness: sender.value)
            break
        case 5:
            self.setupExposure(valExposure: sender.value)
            break
            //     case 6:
            //         self.setupVignette(valBlure: sender.value)
        //         break
        default:
            break
        }
    }
    
    func setupVignette(valBlure:Float) {
        vignetteFilter.setValue(NSNumber(value: valBlure/10), forKey: kCIInputRadiusKey);
        outputImage = vignetteFilter.outputImage!;
        let imageRef:CGImage = context.createCGImage(outputImage, from: outputImage.extent)!
        newUIImage = UIImage(cgImage: imageRef)
        self.imgPhoto.image = newUIImage
        
    }
    
    func setupExposure(valExposure:Float)
    {
        self.tempExposure = valExposure
        exposureFilter.setValue(NSNumber(value: valExposure/100), forKey: kCIInputEVKey);
        outputImage = exposureFilter.outputImage!;
        let imageRef:CGImage = context.createCGImage(outputImage, from: outputImage.extent)!
        newUIImage = UIImage(cgImage: imageRef)
        self.imgPhoto.image = newUIImage
        newUIImage.accessibilityLabel = "IMAGE"
        selectedmedia[currentIndex] = newUIImage
        
        self.collSelectedImages.reloadItems(at: [IndexPath.init(row: currentIndex, section: 0)])
    }
    
    func setupWarmth(valWarmth:Float)
    {
        self.tempWarmth = valWarmth
        warmthFilter.setValue(NSNumber(value: valWarmth/100), forKey: kCIInputIntensityKey);
        outputImage = warmthFilter.outputImage!;
        let imageRef:CGImage = context.createCGImage(outputImage, from: outputImage.extent)!
        newUIImage = UIImage(cgImage: imageRef)
        self.imgPhoto.image = newUIImage
        newUIImage.accessibilityLabel = "IMAGE"
        selectedmedia[currentIndex] = newUIImage
        self.collSelectedImages.reloadItems(at: [IndexPath.init(row: currentIndex, section: 0)])
    }
    
    func setupSaturation(valSaturation:Float) {
        self.tempSaturation = valSaturation
        saturationFilter.setValue(NSNumber(value: valSaturation/100), forKey: kCIInputSaturationKey);
        outputImage = saturationFilter.outputImage!;
        let imageRef:CGImage = context.createCGImage(outputImage, from: outputImage.extent)!
        newUIImage = UIImage(cgImage: imageRef)
        self.imgPhoto.image = newUIImage
        newUIImage.accessibilityLabel = "IMAGE"
        selectedmedia[currentIndex] = newUIImage
        self.collSelectedImages.reloadItems(at: [IndexPath.init(row: currentIndex, section: 0)])
    }
    
    func setupContrast(valContrast:Float) {
        self.tempContrast = valContrast
        contrastFilter.setValue(NSNumber(value: valContrast/100), forKey: "inputContrast");
        outputImage = contrastFilter.outputImage!;
        let imageRef:CGImage = context.createCGImage(outputImage, from: outputImage.extent)!
        newUIImage = UIImage(cgImage: imageRef)
        self.imgPhoto.image = newUIImage
        newUIImage.accessibilityLabel = "IMAGE"
        selectedmedia[currentIndex] = newUIImage
        self.collSelectedImages.reloadItems(at: [IndexPath.init(row: currentIndex, section: 0)])
    }
    
    
    func setupBrightNess(valBrightness:Float) {
        self.tempBrightNess = valBrightness
        brightnessFilter.setValue(NSNumber(value: valBrightness/100), forKey: "inputBrightness");
        outputImage = brightnessFilter.outputImage!;
        let imageRef:CGImage = context.createCGImage(outputImage, from: outputImage.extent)!
        newUIImage = UIImage(cgImage: imageRef)
        self.imgPhoto.image = newUIImage;
        newUIImage.accessibilityLabel = "IMAGE"
        selectedmedia[currentIndex] = newUIImage
        self.collSelectedImages.reloadItems(at: [IndexPath.init(row: currentIndex, section: 0)])
    }
    @objc func playvideclicked(_ sender:UIButton)
    {
        let cell = self.collSelectedImages.cellForItem(at: IndexPath.init(row: currentIndex, section: 0))
        let imgView = cell?.viewWithTag(999) as! UIImageView
        let img = selectedmedia[currentIndex]
        playbtn.setImage(UIImage(), for: .normal)
        imgView.image = img
        
        playVideoAtUrlToLayer(filterName: selectedFilter, urlval: img.accessibilityLabel!, imgvw: imgView)
    }
    func playVideo()
    {
        let avAsset = AVAsset.init(url: videoURL)
        let playerItem = AVPlayerItem(asset: avAsset)
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        self.imgPhoto.layer.addSublayer(playerLayer)
        playerLayer.frame = self.view.bounds
        playerLayer.frame.origin.y = -70
        self.view.layoutIfNeeded()
        player.seek(to: kCMTimeZero)
        player.play()
    }
    func playVideoAtUrlToLayer(filterName:String,urlval:String,imgvw:UIImageView)
    {
        let avAsset = AVAsset.init(url: URL.init(string: urlval)!)
        let composition = AVVideoComposition(asset: avAsset, applyingCIFiltersWithHandler: { request in
            if #available(iOS 11.0, *) {
                let filtered = request.sourceImage.applyingFilter(filterName)
                request.finish(with: filtered, context: nil)
            } else {
                let filter = CIFilter(name: filterName)!
                let source = request.sourceImage.clampedToExtent()
                filter.setValue(source, forKey: kCIInputImageKey)
                let seconds = CMTimeGetSeconds(request.compositionTime)
                filter.setValue(seconds * 10.0, forKey: kCIInputRadiusKey)
                let output = filter.outputImage!.cropped(to: request.sourceImage.extent)
                request.finish(with: output, context: nil)
            }
        })
        
        let playerItem = AVPlayerItem(asset: avAsset)
        if(filterName != "No Filter")
        {
            playerItem.videoComposition = composition
        }
        playbtn.setImage(UIImage(), for: .normal)
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        imgvw.layer.sublayers = nil
        playerLayer.removeFromSuperlayer()
        imgvw.layer.addSublayer(playerLayer)
        playerLayer.frame = imgvw.bounds
        self.view.layoutIfNeeded()
        player.seek(to: kCMTimeZero)
        player.play()
    }
    func playVideoAtUrl(filterName:String,urlval:String)
    {
        let avAsset = AVAsset.init(url: URL.init(string: urlval)!)
        let composition = AVVideoComposition(asset: avAsset, applyingCIFiltersWithHandler: { request in
            if #available(iOS 11.0, *) {
                let filtered = request.sourceImage.applyingFilter(filterName)
                request.finish(with: filtered, context: nil)
            } else {
                let filter = CIFilter(name: filterName)!
                let source = request.sourceImage.clampedToExtent()
                filter.setValue(source, forKey: kCIInputImageKey)
                let seconds = CMTimeGetSeconds(request.compositionTime)
                filter.setValue(seconds * 10.0, forKey: kCIInputRadiusKey)
                let output = filter.outputImage!.cropped(to: request.sourceImage.extent)
                request.finish(with: output, context: nil)
            }
        })
        
        let playerItem = AVPlayerItem(asset: avAsset)
        if(filterName != "No Filter")
        {
            playerItem.videoComposition = composition
        }
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        self.imgPhoto.layer.sublayers = nil
        self.imgPhoto.layer.addSublayer(playerLayer)
        playerLayer.frame = self.view.bounds
        playerLayer.frame.origin.y = -70
        self.view.layoutIfNeeded()
        player.seek(to: kCMTimeZero)
        player.play()
    }
    func playVideo(filterName:String)
    {
        let avAsset = AVAsset.init(url: videoURL)
        let composition = AVVideoComposition(asset: avAsset, applyingCIFiltersWithHandler: { request in
            if #available(iOS 11.0, *) {
                let filtered = request.sourceImage.applyingFilter(filterName)
                request.finish(with: filtered, context: nil)
            } else {
                let filter = CIFilter(name: filterName)!
                let source = request.sourceImage.clampedToExtent()
                filter.setValue(source, forKey: kCIInputImageKey)
                let seconds = CMTimeGetSeconds(request.compositionTime)
                filter.setValue(seconds * 10.0, forKey: kCIInputRadiusKey)
                let output = filter.outputImage!.cropped(to: request.sourceImage.extent)
                request.finish(with: output, context: nil)
            }
        })
        
        let playerItem = AVPlayerItem(asset: avAsset)
        if(filterName != "No Filter")
        {
            playerItem.videoComposition = composition
        }
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        self.imgPhoto.layer.sublayers = nil
        self.imgPhoto.layer.addSublayer(playerLayer)
        playerLayer.frame = self.view.bounds
        playerLayer.frame.origin.y = -70
        self.view.layoutIfNeeded()
        player.seek(to: kCMTimeZero)
        player.play()
    }
    
    //MARK - FilterImage
    func createFilteredImage(filterName: String, image: UIImage) -> UIImage
    {
        let sourceImage = CIImage(image: image)
        let filter = CIFilter(name: filterName)
        filter?.setDefaults()
        filter?.setValue(sourceImage, forKey: kCIInputImageKey)
        let outputCGImage = context.createCGImage((filter?.outputImage!)!, from: (filter?.outputImage!.extent)!)
        let filteredImage = UIImage(cgImage: outputCGImage!)
        return filteredImage
    }
    
    func resizeImage(image: UIImage,complete:(_ image:UIImage)-> ()) {
        let ratio: CGFloat = 0.3
        let resizedSize = CGSize(width: Int(image.size.width * ratio), height: Int(image.size.height * ratio))
        UIGraphicsBeginImageContext(resizedSize)
        image.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        complete(resizedImage!)
    }
    
    @IBAction func btnFilter(_ sender: Any) {
        viewCustomFilter.isHidden = true
        collectionFilter.isHidden = false
        collectionCustomFilter.isHidden = true
    }
    
    @IBAction func btnAdjustMent(_ sender: Any) {
        collectionFilter.isHidden = true
        collectionCustomFilter.isHidden = false
        if(collectionCustomFilter.dataSource == nil)
        {
            collectionCustomFilter.dataSource = self
            collectionCustomFilter.delegate = self
        }
        
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        imgPhoto.image = imgPrevious
        collectionCustomFilter.isHidden = false
        viewCustomFilter.isHidden = true
    }
    
    @IBAction func btnDone(_ sender: Any) {
        self.currentBrightNess = tempBrightNess
        self.currentContrast = tempContrast
        self.currentSaturation = tempSaturation
        self.currentFade = tempFade
        self.currentWarmth = tempWarmth
        self.currentExposure = tempExposure
        collectionCustomFilter.isHidden = false
        viewCustomFilter.isHidden = true
    }
    
    @IBAction func btnBack(_ sender: Any) {
        APP_DELEGATE.appNavigation?.popViewController(animated: true)
    }
    
    @IBAction func btnNext(_ sender: Any)
    {
        let postvc = loadVC(strStoryboardId: SB_FEEDS, strVCId: idPostVC) as! PostVC
        postvc.mediaForUpload = selectedmedia as! NSArray
        APP_DELEGATE.appNavigation?.pushViewController(postvc, animated: true)
    }
}

