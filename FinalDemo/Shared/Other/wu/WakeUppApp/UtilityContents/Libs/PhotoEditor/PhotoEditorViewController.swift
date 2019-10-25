//
//  ViewController.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

import AVFoundation
import MobileCoreServices
import Photos

import IQKeyboardManagerSwift

enum enumEditor : Int {
    case Editor_None = 0
    case Editor_Photo //Manage photo edit
    case Editor_Video //Manage video edit
}

public final class PhotoEditorViewController: UIViewController {
    //MARK:- Outlet
    //PV
    @IBOutlet weak var viewCollectionEditedList: UIView!
    @IBOutlet weak var collectionEditedList: UICollectionView!
    
    @IBOutlet weak var clsView: UICollectionView!
    
    /** holding the 2 imageViews original image and drawing & stickers */
    @IBOutlet weak var canvasView: UIView!
    
    //To hold the image
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var colorpickerheight: NSLayoutConstraint!
    //To hold the drawings and stickers
    @IBOutlet weak var canvasImageView: UIImageView!
    
    @IBOutlet weak var topToolbar: UIView!
    @IBOutlet weak var topToolbar_Done: UIView!
    @IBOutlet weak var bottomToolbar: UIView!
    
    @IBOutlet weak var topGradient: UIView!
    @IBOutlet weak var bottomGradient: UIView!
    @IBOutlet weak var txtCaptionMess: UITextField!
    
    @IBOutlet weak var imgeraon: UIImageView!
    @IBOutlet weak var btneraser: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var colorPickerView: UIView!
    @IBOutlet weak var colorPickerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var pencilview: UIView!
    @IBOutlet weak var processsize: UISlider!
    
    @IBOutlet weak var topbarheight: NSLayoutConstraint!
    @IBOutlet weak var progressopacity: UISlider!
    //Controls
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var stickerButton: UIButton!
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var cancelbtn: UIButton!
    @IBOutlet var btnprivacy: UIButton!
    @IBOutlet var btntimer: UIButton!
  
    @IBOutlet weak var widthtxtbtn: NSLayoutConstraint!
    @IBOutlet weak var widthdrawbtn: NSLayoutConstraint!
    
    @IBOutlet weak var widthcropbtn: NSLayoutConstraint!
    @IBOutlet weak var widthstickerbtn: NSLayoutConstraint!
    
    //MARK:- Variable
    var objEnumEditor : enumEditor = .Editor_None
    var canvasIndex = 0
    
    //Photo Related ------>
    //public var arrImage: [(UIImage,[String: Any?]?)]?
    //public var arrImageProperty: NSMutableArray?
    public var arrPhoto: [(UIImage,[String: Any?]?)]?
    public var arrPhotoProperty: NSMutableArray?
    
    //Video Related ------>
    //public var arrSelectedContent: NSMutableArray?
    public var arrVideoProperty: NSMutableArray?
    
    /**
    Array of Stickers -UIImage- that the user will choose from
    */
    public var stickers : [UIImage] = []
    /**
    Array of Colors that will show while drawing or typing
    */
    public var colors  : [UIColor] = []
    
    public var photoEditorDelegate: PhotoEditorDelegate?
    var colorsCollectionViewDelegate: ColorsCollectionViewDelegate!
    
    // list of controls to be hidden
    public var hiddenControls : [control] = []
    var isErasing = false
    var currentBrushSize: CGFloat = 5.0
    var currentColorOpacity: CGFloat = 1.0
    var stickersVCIsVisible = false
    var drawColor: UIColor = UIColor.black
    var textColor: UIColor = UIColor.white
    var isDrawing: Bool = false
    var lastPoint: CGPoint!
    var swiped = false
    var lastPanPoint: CGPoint?
    var lastTextViewTransform: CGAffineTransform?
    var lastTextViewTransCenter: CGPoint?
    var lastTextViewFont:UIFont?
    var activeTextView: UITextView?
    var imageViewToPan: UIImageView?
    var isTyping: Bool = false
    
    var stickersViewController: StickersViewController!
   
    
    //MARK:-
    //Register Custom font before we load XIB
    public override func loadView() {
        // registerFont()
        super.loadView()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        //PV ------------>
        self.clsView.register(UINib.init(nibName: "ImgCell", bundle:nil), forCellWithReuseIdentifier: "ImgCell")
        self.clsView.register(UINib.init(nibName: "VideoCell", bundle:nil), forCellWithReuseIdentifier: "VideoCell")
        self.clsView.delegate = self
        self.clsView.dataSource = self
        self.clsView.reloadData()
        
        self.txtCaptionMess.text = ""
        self.txtCaptionMess.delegate = self
        
        self.setSelectedContent_in_Bottom_Collectionview()
        
        collectionEditedList.register(UINib(nibName: "StickerCollectionViewCell", bundle: Bundle(for: StickerCollectionViewCell.self)),
            forCellWithReuseIdentifier: "StickerCollectionViewCell")
        
        self.collectionEditedList.reloadData()
        //------------>
        
        self.btneraser.backgroundColor = UIColor.clear
         self.imgeraon.backgroundColor = self.btneraser.backgroundColor
        //self.setImageView(image: image!) //PV
        //PV
        self.imageView.isHidden = true
        
        //IQKeyboardManager.shared.enable = false
        deleteView.layer.cornerRadius = deleteView.bounds.height / 2
        deleteView.layer.borderWidth = 2.0
        deleteView.layer.borderColor = UIColor.white.cgColor
        deleteView.clipsToBounds = true
        
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .bottom
        edgePan.delegate = self
        self.view.addGestureRecognizer(edgePan)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillChangeFrame(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
        
        configureCollectionView()
        stickersViewController = StickersViewController(nibName: "StickersViewController", bundle: Bundle(for: StickersViewController.self))
        self.btnprivacy.accessibilityLabel = "0"
        self.btnprivacy.setImage(UIImage.init(named: "public_story"), for:.normal)
        hideControls()
        
        switch objEnumEditor {
        case .Editor_Photo:
            self.manange_PhotoEditor()
            break
        
        case .Editor_Video:
            self.manange_VideoEditor()
            break
        
        default:
            break
        }
    }
    
    //MARK:-
    func manange_PhotoEditor() {        
        self.widthtxtbtn.constant = 40
        self.widthcropbtn.constant = 40
        self.widthdrawbtn.constant = 40
        self.widthstickerbtn.constant = 40
    }
    
    func manange_VideoEditor() {
        self.widthtxtbtn.constant = 0
        self.widthcropbtn.constant = 0
        self.widthdrawbtn.constant = 0
        self.widthstickerbtn.constant = 0
    }
    
    func setSelectedContent_in_Bottom_Collectionview() {
        /*if (self.arrSelectedContent?.count == 0) {
            showMessage("Something was wrong.\n Please select again.")
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        self.arrSelectedContentProperty = NSMutableArray.init()
        for objContent in self.arrSelectedContent! {
            let objDic : NSMutableDictionary = objContent as! NSMutableDictionary
            let contentType : String = objDic.value(forKey: key_ContentType) as! String
         
            //Image
            if (contentType.uppercased() == "0".uppercased()) {
                let image = objDic.value(forKey: key_OriginalImage) as! UIImage
         
                let dic = NSMutableDictionary.init()
                dic.setValue(image.sd_imageData(), forKey: key_OriginalImage)
                dic.setValue(image.sd_imageData(), forKey: key_EditedImage)
                dic.setValue("0", forKey: key_IsPrivate)
                dic.setValue("", forKey: key_Timer)
                dic.setValue("", forKey: key_CaptionText)
                arrImageProperty?.add(dic)
            }
            // Video
            else if (contentType.uppercased() == "1".uppercased()) {
                let videoURL = objDic.value(forKey: key_VideoURL) as! URL
         
                let dic = NSMutableDictionary.init()
                dic.setValue(videoURL.absoluteString, forKey: key_VideoURL)
                dic.setValue("0", forKey: key_IsPrivate)
                dic.setValue("", forKey: key_Timer)
                dic.setValue("", forKey: key_CaptionText)
                arrImageProperty?.add(dic)
            }
        }*/
        //print("total Content : \(arrSelectedContentProperty?.count)")
        //print("Done")
        
        collectionEditedList.register(
            UINib(nibName: "StickerCollectionViewCell", bundle: Bundle(for: StickerCollectionViewCell.self)),
            forCellWithReuseIdentifier: "StickerCollectionViewCell")
        
        self.collectionEditedList.reloadData()
    }
    
    func configureCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 30, height: 30)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        colorsCollectionView.collectionViewLayout = layout
        colorsCollectionViewDelegate = ColorsCollectionViewDelegate()
        colorsCollectionViewDelegate.colorDelegate = self
        if !colors.isEmpty {
            colorsCollectionViewDelegate.colors = colors
        }
        colorsCollectionView.delegate = colorsCollectionViewDelegate
        colorsCollectionView.dataSource = colorsCollectionViewDelegate
        
        colorsCollectionView.register(
            UINib(nibName: "ColorCollectionViewCell", bundle: Bundle(for: ColorCollectionViewCell.self)),
            forCellWithReuseIdentifier: "ColorCollectionViewCell")
    }
    
    func setImageView(image: UIImage) {
        imageView.image = image
        //        let size = image.suitableSize(widthLimit: UIScreen.main.bounds.width)
        //        imageViewHeightConstraint.constant = (size?.height)!
    }
    
    
    func hideToolbar(hide: Bool)
    {
        topToolbar.isHidden = hide
        if hide == true
        {
            topbarheight.constant = 0
        }
        else
        {
            topbarheight.constant = 50
        }
        topGradient.isHidden = hide
        bottomToolbar.isHidden = hide
        bottomGradient.isHidden = hide
    }
}

extension PhotoEditorViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.txtCaptionMess.resignFirstResponder()
        
        //Saved Caption text
        self.Update_CaptionMess(mess: TRIM(string: self.txtCaptionMess.text ?? ""), inObjectIndex: self.canvasIndex)
        
        return true
    }
}

extension PhotoEditorViewController: ColorDelegate {
    func didSelectColor(color: UIColor) {
        if isDrawing
        {
            self.drawColor = color
            self.isErasing = false
            self.btneraser.backgroundColor = UIColor.clear
             self.imgeraon.backgroundColor = self.btneraser.backgroundColor
        }
        else if activeTextView != nil
        {
            activeTextView?.textColor = color
            textColor = color
        }
    }
}

extension PhotoEditorViewController:UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate,UICollectionViewDelegateFlowLayout, VideoCellDelegate {
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        //        view.endEditing(true)
        //        doneButton.isHidden = true
        //        colorPickerView.isHidden = true
        //        hideToolbar(hide: false)
        //        isDrawing = false
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        /*
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        self.canvasIndex = Int(pageNumber)
        */
        
        /*let cell:ImgCell = self.clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
         let img = cell.canvasView.toImage()
         self.Update_Image(image: img, inObjectIndex: self.canvasIndex)*/
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView == self.clsView) {
            return CGSize(width: UIScreen.main.bounds.size.width, height: self.clsView.frame.size.height)
        } else {
            let cell_height = self.collectionEditedList.frame.size.height
            return CGSize(width: cell_height, height: cell_height)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        /*if (collectionView == self.clsView) {
            if let img = self.arrImage { return img.count }
            else { return 0 }
        }
        else { return (arrSelectedContent?.count)! }*/
        //return (arrSelectedContent?.count)!
        
        var noOfCell : Int = 0
        switch objEnumEditor {
        case .Editor_Photo:
            noOfCell = (self.arrPhotoProperty?.count)!
            break
            
        case .Editor_Video:
            noOfCell = (self.arrVideoProperty?.count)!
            break
            
        default:
            noOfCell = 0
            break
        }
        return noOfCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == self.clsView) {
            /*if (self.arrSelectedContent?.count == 0) { return UICollectionViewCell.init() }
            
            let objDic : NSMutableDictionary = self.arrSelectedContent![indexPath.row] as! NSMutableDictionary
            let contentType : String = objDic.value(forKey: key_ContentType) as! String
            
            if (contentType.uppercased() == "0".uppercased()) {
                let cell:ImgCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImgCell", for: indexPath as IndexPath) as! ImgCell
                if let img = self.arrImage {
                    cell.setImageView(image: img[indexPath.item].0, subviews:img[indexPath.item].1)
                }
                return cell
            }
            else if (contentType.uppercased() == "1".uppercased()) {
                let cell_video:VideoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCell
                
                let strVideoURL : String = objDic.value(forKey: key_VideoURL) as! String
                
                cell_video.videoselected = AVAsset.init(url: strVideoURL.url!)
                cell_video.videourl = strVideoURL.url
                cell_video.setupUI()
                //cell_video.videoEditorVCDelegate = self
                
                return cell_video
            }
            return UICollectionViewCell.init()
            */
            
            var objDic : NSMutableDictionary = NSMutableDictionary.init()
            var contentType : String = ""
            
            switch objEnumEditor {
            case .Editor_Photo:
                objDic = self.arrPhotoProperty![indexPath.row] as! NSMutableDictionary
                contentType = objDic.value(forKey: key_ContentType) as! String
            case .Editor_Video:
                objDic = self.arrVideoProperty![indexPath.row] as! NSMutableDictionary
                contentType = objDic.value(forKey: key_ContentType) as! String
            default:
                return UICollectionViewCell.init()
            }
            
            if (contentType.uppercased() == "0".uppercased()) {
                let cell:ImgCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImgCell", for: indexPath as IndexPath) as! ImgCell
                if let img = self.arrPhoto {
                    cell.setImageView(image: img[indexPath.item].0, subviews:img[indexPath.item].1)
                }
                return cell
            }
            else if (contentType.uppercased() == "1".uppercased()) {
                let cell_video:VideoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCell
                
                let strVideoURL : String = objDic.value(forKey: key_VideoURL) as! String
                
                cell_video.delegate = self
                cell_video.videourl = strVideoURL.url
                cell_video.videoselected = AVAsset.init(url: strVideoURL.url!)
                cell_video.setupUI()
                //cell_video.set_Current_VideoTrimming(startTime: get_Video_StartTime(objectIndex: indexPath.row), endTime: get_Video_StopTime(objectIndex: indexPath.row))
                cell_video.set_Current_VideoTrimming(startTime: get_Video_StartTime(objectIndex: indexPath.row), endTime: get_Video_StopTime(objectIndex: indexPath.row))
                
                return cell_video
            }
            else { return UICollectionViewCell.init() }
            
        //} else {
        } else if (collectionView == self.collectionEditedList) {
            /*
            if (self.arrSelectedContent?.count == 0) { return UICollectionViewCell.init() }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickerCollectionViewCell", for: indexPath) as! StickerCollectionViewCell
            
            let objDic : NSMutableDictionary = self.arrSelectedContent![indexPath.row] as! NSMutableDictionary
            let contentType : String = objDic.value(forKey: key_ContentType) as! String*/
            
            var objDic : NSMutableDictionary = NSMutableDictionary.init()
            var contentType : String = ""
            
            switch objEnumEditor {
            case .Editor_Photo:
                objDic = self.arrPhotoProperty![indexPath.row] as! NSMutableDictionary
                contentType = objDic.value(forKey: key_ContentType) as! String
            case .Editor_Video:
                objDic = self.arrVideoProperty![indexPath.row] as! NSMutableDictionary
                contentType = objDic.value(forKey: key_ContentType) as! String
            default:
                return UICollectionViewCell.init()
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickerCollectionViewCell", for: indexPath) as! StickerCollectionViewCell
            self.manage_HideShow_EditedControllerButton(curretIndex: indexPath.row)
            
            //Image
            var img : UIImage = #imageLiteral(resourceName: "audio_player_image.png")
            if (contentType.uppercased() == "0".uppercased()) {
                let imgData : Data = objDic.value(forKey: key_OriginalImage) as! Data
                img = UIImage.init(data: imgData)!
                
                cell.imgTop.image = UIImage.init()
                cell.imgTop.isHidden = true
            }
            else if (contentType.uppercased() == "1".uppercased()) {
                let imgData : Data = objDic.value(forKey: key_OriginalImage) as! Data
                img = UIImage.init(data: imgData)!
                
                cell.imgTop.image = #imageLiteral(resourceName: "play_btn")
                cell.imgTop.isHidden = false
            }
            else { return UICollectionViewCell.init() }
            
            cell.stickerImage.image = img
            cell.stickerImage.contentMode = .scaleAspectFill
            cell.stickerImage.clipsToBounds = true
            
            return cell
        }
        return UICollectionViewCell.init()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView == self.clsView) {
            //---> No Code
        }
        else if (collectionView == self.collectionEditedList) {
            /*
            //---------------->
            //Save Edited Image
            let objDicPrv : NSMutableDictionary = self.arrSelectedContent![self.canvasIndex] as! NSMutableDictionary
            let prvContentType : String = objDicPrv.value(forKey: key_ContentType) as! String
            if (prvContentType.uppercased() == "0".uppercased()) {
                let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
                let img = cell.canvasView.toImage()
                self.saveImageEditedContent()
                self.Update_Image(image: img, inObjectIndex: self.canvasIndex)
                self.Update_CaptionMess(mess: self.txtCaptionMess.text!, inObjectIndex: self.canvasIndex)
            }
            else if (prvContentType.uppercased() == "1".uppercased()) {
                //let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
                //let img = cell.canvasView.toImage()
                //self.Update_Image(image: img, inObjectIndex: self.canvasIndex)
                self.Update_CaptionMess(mess: self.txtCaptionMess.text!, inObjectIndex: self.canvasIndex)
            }
            //<----------------
            
            let objDic : NSMutableDictionary = self.arrSelectedContent![indexPath.row] as! NSMutableDictionary
            let contentType : String = objDic.value(forKey: key_ContentType) as! String
            
            self.manage_HideShow_EditedControllerButton(curretIndex: indexPath.row)
            
            //Image
            if (contentType.uppercased() == "0".uppercased()) {
                self.canvasIndex = indexPath.row
                self.clsView.scrollToItem(at: IndexPath.init(row: self.canvasIndex, section: 0), at: .centeredHorizontally, animated: true)
                view.layoutIfNeeded()
            }
            //Video
            else if (contentType.uppercased() == "1".uppercased()) {
                self.canvasIndex = indexPath.row
                self.clsView.scrollToItem(at: IndexPath.init(row: self.canvasIndex, section: 0), at: .centeredHorizontally, animated: true)
                view.layoutIfNeeded()
            }
            set_VisibleImageProperty(ImgObjIndex: self.canvasIndex)*/
            
            //---------------->
            //Save Edited Image & Video content
            var objDicPrv : NSMutableDictionary = NSMutableDictionary.init()
            var prvContentType : String = ""
            
            switch objEnumEditor {
            case .Editor_Photo:
                //objDicPrv = self.arrPhotoProperty![indexPath.row] as! NSMutableDictionary
                objDicPrv = self.arrPhotoProperty![self.canvasIndex] as! NSMutableDictionary
                prvContentType = objDicPrv.value(forKey: key_ContentType) as! String
                break
            case .Editor_Video:
                //objDicPrv = self.arrVideoProperty![indexPath.row] as! NSMutableDictionary
                objDicPrv = self.arrVideoProperty![self.canvasIndex] as! NSMutableDictionary
                prvContentType = objDicPrv.value(forKey: key_ContentType) as! String
                break
            default:
                break
            }
            
            if (prvContentType.uppercased() == "0".uppercased()) {
                let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
                let img = cell.canvasView.toImage()
                self.saveImageEditedContent()
                self.Update_Image(image: img, inObjectIndex: self.canvasIndex)
                self.Update_CaptionMess(mess: self.txtCaptionMess.text!, inObjectIndex: self.canvasIndex)
            }
            else if (prvContentType.uppercased() == "1".uppercased()) {
                //let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
                //let img = cell.canvasView.toImage()
                //self.Update_Image(image: img, inObjectIndex: self.canvasIndex)
                self.Update_CaptionMess(mess: self.txtCaptionMess.text!, inObjectIndex: self.canvasIndex)
            }
            //<----------------
            
            var objDic : NSMutableDictionary = NSMutableDictionary.init()
            var contentType : String = ""
            
            switch objEnumEditor {
            case .Editor_Photo:
                objDic = self.arrPhotoProperty![indexPath.row] as! NSMutableDictionary
                contentType = objDic.value(forKey: key_ContentType) as! String
                break
            case .Editor_Video:
                objDic = self.arrVideoProperty![indexPath.row] as! NSMutableDictionary
                contentType = objDic.value(forKey: key_ContentType) as! String
                break
            default:
                break
            }
            
            //Image
            if (contentType.uppercased() == "0".uppercased()) {
                self.canvasIndex = indexPath.row
                self.clsView.scrollToItem(at: IndexPath.init(row: self.canvasIndex, section: 0), at: .centeredHorizontally, animated: true)
                view.layoutIfNeeded()
            }
            //Video
            else if (contentType.uppercased() == "1".uppercased()) {
                self.canvasIndex = indexPath.row
                self.clsView.scrollToItem(at: IndexPath.init(row: self.canvasIndex, section: 0), at: .centeredHorizontally, animated: true)
                view.layoutIfNeeded()
            }
            set_VisibleImageProperty(ImgObjIndex: self.canvasIndex)
        }
    }
    
    func saveImageEditedContent() {
        let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
        var Dictionary = [String: Any]()
        
        if let image = cell.canvasImageView.image { Dictionary["image"] = image }
        
        var arrSubviews:[Any] = []
        if cell.canvasImageView.subviews.count > 0 {
            arrSubviews.append(cell.canvasImageView.subviews)
        }
        
        if arrSubviews.count > 0 {
            Dictionary["subViews"] = arrSubviews
        }
        
        self.arrPhoto![IndexPath.init(row: self.canvasIndex, section: 0).item].1 = Dictionary
    }
    
    func manage_HideShow_EditedControllerButton(curretIndex : Int) {
        //let objDic : NSMutableDictionary = self.arrSelectedContent![curretIndex] as! NSMutableDictionary
        //let contentType : String = objDic.value(forKey: key_ContentType) as! String
        
        var objDic : NSMutableDictionary = NSMutableDictionary.init()
        var contentType : String = ""
        
        switch objEnumEditor {
        case .Editor_Photo:
            objDic = self.arrPhotoProperty![curretIndex] as! NSMutableDictionary
            contentType = objDic.value(forKey: key_ContentType) as! String
            break
        case .Editor_Video:
            objDic = self.arrVideoProperty![curretIndex] as! NSMutableDictionary
            contentType = objDic.value(forKey: key_ContentType) as! String
            break
        default:
            break
        }
        
        self.textButton.isHidden = true
        self.drawButton.isHidden = true
        self.stickerButton.isHidden = true
        self.cropButton.isHidden = true
        self.doneButton.isHidden = true
        self.btneraser.isHidden = true
        
        //Image
        if (contentType.uppercased() == "0".uppercased()) {
            self.textButton.isHidden = false
            self.drawButton.isHidden = false
            self.stickerButton.isHidden = false
            self.cropButton.isHidden = false
            //self.doneButton.isHidden = true
            //self.btneraser.isHidden = true
        }
        //Video
        else if (contentType.uppercased() == "1".uppercased()) {
            //---> Code
        }
    }
    
    /*func Update_Image(image: UIImage, inObjectIndex : Int) {
        if (self.arrImageProperty?.count == 0) { return }
        
        //Get Curret Visisble Img Property and Update
        let dicImgProperty : NSMutableDictionary = self.arrImageProperty![inObjectIndex] as! NSMutableDictionary
        dicImgProperty.setValue(image, forKey: key_EditedImage)
        
        //Replace Obj. in Propert array
        self.arrImageProperty?.replaceObject(at: inObjectIndex, with: dicImgProperty)
    }*/
    /*
    func addImageToImage(img1: UIImage, img2:UIImage, size : CGSize)-> UIImage {
        
        let topImage = img1
        let bottomImage = img2
        
        //let size = CGSize(width: topImage.size.width, height: topImage.size.height + bottomImage.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        topImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: topImage.size.height))
        //bottomImage.draw(in: CGRect(x: 0, y: topImage.size.height, width: size.width, height: bottomImage.size.height))
        bottomImage.draw(in: CGRect(x: 0, y: 0, width: size.width/2, height: topImage.size.height/2))
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }*/
    
    //MARK:- VideoCellDelegate Method
    public func current_VideoTrimming(videoAsset: AVAsset, startTime: CMTime, endTime: CMTime) {
        //print("videoAsset : \(videoAsset.duration)")
        //print("startTime : \(startTime.seconds)")
        //print("endTime : \(endTime.seconds)")
        
        self.Update_Video_TrimmingTime(startTime: startTime, endTime: endTime, inObjectIndex: self.canvasIndex)
    }
}
