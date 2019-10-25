//
//  PhotoEditor+Controls.swift
//  Pods
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import Foundation
import UIKit
import AVFoundation

import IQKeyboardManagerSwift

// MARK: - Control
public enum control {
    case crop
    case sticker
    case draw
    case text
    case save
    case share
    case clear
}

extension PhotoEditorViewController {
    
    //MARK: Top Toolbar
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        switch objEnumEditor {
        case .Editor_Photo:
            
            break
        case .Editor_Video:
            //Stop Play Video
            let cell:VideoCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! VideoCell
            cell.player?.pause()
            cell.player?.pause()
            cell.player?.pause()            
            break
        default:
            break
        }
        
        photoEditorDelegate?.canceledEditing()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func cropButtonTapped(_ sender: UIButton) {
        /*let controller = CropViewController()
        controller.delegate = self
        controller.image = image
        self.pencilview.isHidden = true
        btneraser.isHidden = true
        let navController = UINavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
        colorpickerheight.constant = 50*/
        
        //PV - Done
        let controller = CropViewController()
        controller.delegate = self
        controller.toolbarHidden = true
        controller.rotationEnabled = false
        
        let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
        controller.image = cell.imageView.image //Send Original Image
        //controller.image = cell.canvasView.toImage() // Send Edited Image
        let navController = UINavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
    }
    
    @IBAction func stickersButtonTapped(_ sender: Any) {
        self.btnprivacy.isHidden = true
        self.btntimer.isHidden = true
        colorpickerheight.constant = 50
        addStickersViewController()
        
        //PV - Done
    }
    
    @IBAction func drawButtonTapped(_ sender: Any) {
        /*isDrawing = true
        self.btnprivacy.isHidden = true
        self.btntimer.isHidden = true
        colorpickerheight.constant = 150
        canvasImageView.isUserInteractionEnabled = false
        doneButton.isHidden = false
        cancelbtn.isHidden = true
        colorPickerView.isHidden = false
        self.pencilview.isHidden = false
        btneraser.isHidden = false
        hideToolbar(hide: true)
        */

        //PV - Done
        isDrawing = true
        self.isErasing = false
        
        self.btnprivacy.isHidden = true
        self.btntimer.isHidden = true
        colorpickerheight.constant = 150
        
        let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
        cell.canvasImageView.isUserInteractionEnabled = false
        self.clsView.isUserInteractionEnabled = false
        
        //addGestures(view: cell.canvasImageView)
        
        doneButton.isHidden = false
        cancelbtn.isHidden = true
        colorPickerView.isHidden = false
        self.pencilview.isHidden = false
        btneraser.isHidden = false
        imgeraon.isHidden = false
        hideToolbar(hide: true)
    }
    
    @IBAction func eraserButtonTapped(_ sender: Any) {
        isErasing = true
        self.btneraser.backgroundColor = .clear
        self.imgeraon.backgroundColor = themeWakeUppColor
    }
    
    @IBAction func opacitySliderValueChanged(sender: UISlider) {
        let currentValue = sender.value
        sender.setValue(currentValue, animated: true)
        currentColorOpacity = CGFloat(currentValue)
        //textColor = textColor.withAlphaComponent(currentColorOpacity)
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        let currentValue = sender.value
        //print("currentValue :\(currentValue)")
        sender.setValue(currentValue, animated: true)
        currentBrushSize = CGFloat(currentValue)
    }
    
    @IBAction func textButtonTapped(_ sender: Any) {
        /*self.btnprivacy.isHidden = true
        self.btntimer.isHidden = true
        isTyping = true
        let textView = UITextView(frame: CGRect(x: 0, y: canvasImageView.center.y, width: UIScreen.main.bounds.width, height: 30))
        
        textView.textAlignment = .center
        textView.font = UIFont(name: "Helvetica", size: 30)
        textView.textColor = textColor
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
        textView.layer.shadowOpacity = 0.2
        textView.layer.shadowRadius = 1.0
        textView.layer.backgroundColor = UIColor.clear.cgColor
        textView.autocorrectionType = .no
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.keyboardType = .asciiCapable
        textView.keyboardAppearance = .dark
        self.pencilview.isHidden = true
        btneraser.isHidden = true
        self.canvasImageView.addSubview(textView)
        addGestures(view: textView)
        textView.becomeFirstResponder()
        colorpickerheight.constant = 50*/
        
        //PV
        self.btnprivacy.isHidden = true
        self.btntimer.isHidden = true
        self.pencilview.isHidden = true
        btneraser.isHidden = true
        imgeraon.isHidden = true
        colorpickerheight.constant = 50
        colorPickerView.isHidden = false
        
        isTyping = true
        
        let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
        let textView = UITextView(frame: CGRect(x: 0, y: cell.canvasImageView.frame.size.height/2 - 15, width: UIScreen.main.bounds.width, height: 30))
        
        textView.textAlignment = .center
        textView.font = UIFont(name: "Helvetica", size: 30)
        textView.textColor = textColor
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
        textView.layer.shadowOpacity = 0.2
        textView.layer.shadowRadius = 1.0
        textView.layer.backgroundColor = UIColor.clear.cgColor
        //textView.layer.backgroundColor = UIColor.white.cgColor
        textView.autocorrectionType = .no
        textView.isScrollEnabled = false
        textView.delegate = self
        
        cell.canvasImageView.addSubview(textView)
        addGestures(view: textView)
        
        textView.becomeFirstResponder()
        textView.isUserInteractionEnabled = true
        
        //Manage Hide Keyboard Top possition view (Done view)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        view.endEditing(true)
        doneButton.isHidden = true
        cancelbtn.isHidden = false
        colorPickerView.isHidden = true
        canvasImageView.isUserInteractionEnabled = true
        self.pencilview.isHidden = true
        btneraser.isHidden = true
        imgeraon.isHidden = true
        hideToolbar(hide: false)
        isDrawing = false
        colorpickerheight.constant = 50
        self.btnprivacy.isHidden = false
        self.btntimer.isHidden = false
        
        //PV
        let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
        cell.canvasImageView.isUserInteractionEnabled = true
        self.clsView.isUserInteractionEnabled = true
    }
    
    //MARK:- Bottom Toolbar
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(canvasView.toImage(),self, #selector(PhotoEditorViewController.image(_:withPotentialError:contextInfo:)), nil)
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let activity = UIActivityViewController(activityItems: [canvasView.toImage()], applicationActivities: nil)
        present(activity, animated: true, completion: nil)
        
    }
    
    @IBAction func clearButtonTapped(_ sender: AnyObject) {
        /*//clear drawing
        //canvasImageView.image = nil
        //clear stickers and textviews
        for subview in canvasImageView.subviews {
            subview.removeFromSuperview()
        }
        */
        let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
        cell.canvasImageView.image = nil
        
        //clear stickers and textviews
        for subview in cell.canvasImageView.subviews {
            subview.removeFromSuperview()
        }
    }
    
    @IBAction func btnprivacyclicked(_ sender: UIButton) {
        //let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
        var optionmsg = ""
        var choosenoption = ""
        if get_Status_IsPrivate(objectIndex: self.canvasIndex) == "0" {
            optionmsg = "Make it Private"
            choosenoption = "1"
        }
        else {
            optionmsg = "Make it Public"
            choosenoption = "0"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let actionSheet = UIAlertController.init(title: "Story Privacy", message: "Lock the story will restrict the user for copy your story.", preferredStyle: .actionSheet)
            let actionnow = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
                //--> Dismiss action...
            }
            
            let actionlater = UIAlertAction.init(title: optionmsg, style: .default) { (action) in
                if choosenoption == "0" {
                    self.btnprivacy.setImage(UIImage.init(named: "public_story"), for:.normal)
                    self.Update_IsPrivate(status: "0", inObjectIndex: self.canvasIndex)
                }
                else {
                    self.btnprivacy.setImage(UIImage.init(named: "private_story"), for:.normal)
                    self.Update_IsPrivate(status: "1", inObjectIndex: self.canvasIndex)
                }
            }
            actionSheet.addAction(actionlater)
            actionSheet.addAction(actionnow)
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    @IBAction func btntimeclicked(_ sender: UIButton)
    {
        self.pencilview.isHidden = true
        btneraser.isHidden = true
        imgeraon.isHidden = true
        colorpickerheight.constant = 50
        //let img = self.canvasView.toImage()
        let objDatePicker: UIDatePicker = UIDatePicker()
        let lblTitle:UILabel = UILabel(frame: CGRect(x: 0, y: 15.0, width: SCREENWIDTH() - 20, height: 25))
        lblTitle.font = FontWithSize(FT_Regular, 18)
        lblTitle.textAlignment = .center
        lblTitle.text = title
        objDatePicker.datePickerMode = .dateAndTime
        objDatePicker.minimumDate = Date()
        objDatePicker.frame = CGRect(x: 0, y: 40, width: SCREENWIDTH() - 20, height: 220)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let actionSheet = UIAlertController.init(title: "Schedule story display time", message: "You can see your story immediately but your contacts can see it at given time.", preferredStyle: .alert)
            let actionnow = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
            }
            let actionlater = UIAlertAction.init(title: "Schedule", style: .default) { (action) in
                
                let alertController = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
                alertController.view.addSubview(lblTitle)
                alertController.view.addSubview(objDatePicker)
                
                let btnOk = UIAlertAction(title: "Schedule this time", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
                    //print("selectedDate : \(objDatePicker.date)")
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "YYYY-MM-dd hh:mm:ss"
                    let dateString = dateFormatter.string(from: objDatePicker.date)
                    let utcdt = DateFormater.getStringFromDate(givenDate: objDatePicker.date as NSDate)
                    //print("Actual Date : \(dateString) UTC : \(utcdt)")
                    self.Update_TimeSelected(time: "\(utcdt)", inObjectIndex: self.canvasIndex)
                })
                let btnCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(alert: UIAlertAction!) in
                })
                alertController.addAction(btnOk)
                alertController.addAction(btnCancel)
                let alertControllerHeight:NSLayoutConstraint = NSLayoutConstraint(item: alertController.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 380)
                alertController.view.addConstraint(alertControllerHeight);
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.present(alertController, animated: true)
                }
            }
            actionSheet.addAction(actionlater)
            actionSheet.addAction(actionnow)
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    
    func showdtpicker() {
        let objDatePicker: UIDatePicker = UIDatePicker()
        let lblTitle:UILabel = UILabel(frame: CGRect(x: 0, y: 15.0, width: SCREENWIDTH() - 20, height: 25))
        lblTitle.font = FontWithSize(FT_Regular, 18)
        lblTitle.textAlignment = .center
        lblTitle.text = title
        objDatePicker.datePickerMode = .dateAndTime
        objDatePicker.minimumDate = Date()
        objDatePicker.timeZone = TimeZone.current
        objDatePicker.frame = CGRect(x: 0, y: 40, width: SCREENWIDTH() - 20, height: 220)
        let alertController = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        alertController.view.addSubview(lblTitle)
        alertController.view.addSubview(objDatePicker)
        let btnOk = UIAlertAction(title: "Schedule this time", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
            let img = self.canvasView.toImage()
            self.dismiss(animated: true, completion: nil)
            self.photoEditorDelegate?.doneEditing(image: img,timeselected:"\(objDatePicker.date)",isprivate:"1")
        })
        alertController.addAction(btnOk)
        
        let btnCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(alert: UIAlertAction!) in
            //---->
        })
        alertController.addAction(btnCancel)
        
        let alertControllerHeight:NSLayoutConstraint = NSLayoutConstraint(item: alertController.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 380)
        alertController.view.addConstraint(alertControllerHeight);
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.present(alertController, animated: true)
        }
    }
    
    @IBAction func previousButtonPressed(_ sender: Any) {
        let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
        //Save Edited Image
        let img = cell.canvasView.toImage()
        self.Update_Image(image: img, inObjectIndex: self.canvasIndex)
        self.Update_CaptionMess(mess: self.txtCaptionMess.text!, inObjectIndex: self.canvasIndex)
        
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
        if self.canvasIndex > 0 {
            self.canvasIndex = self.canvasIndex - 1
        }
        self.clsView.scrollToItem(at: IndexPath.init(row: self.canvasIndex, section: 0), at: .centeredHorizontally, animated: true)
        view.layoutIfNeeded()
        
        set_VisibleImageProperty(ImgObjIndex: self.canvasIndex)
    }
    
    @IBAction func NextButtonPressed(_ sender: Any) {
        
        let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
        
        //Save Edited Image
        let img = cell.canvasView.toImage()
        self.Update_Image(image: img, inObjectIndex: self.canvasIndex)
        self.Update_CaptionMess(mess: self.txtCaptionMess.text!, inObjectIndex: self.canvasIndex)
        
        var Dictionary = [String: Any]()
        
        if let image = cell.canvasImageView.image {
            Dictionary["image"] = image
        }
        
        
        var arrSubviews:[Any] = []
        if cell.canvasImageView.subviews.count > 0 {
            arrSubviews.append(cell.canvasImageView.subviews)
        }
        
        if arrSubviews.count > 0 {
            Dictionary["subViews"] = arrSubviews
        }
        self.arrPhoto![IndexPath.init(row: self.canvasIndex, section: 0).item].1 = Dictionary
        if self.canvasIndex < ((self.arrPhoto?.count)!-1) {
            self.canvasIndex = self.canvasIndex + 1
        }
        
        self.clsView.scrollToItem(at: IndexPath.init(row: self.canvasIndex, section: 0), at: .centeredHorizontally, animated: true)
        view.layoutIfNeeded()
        
        set_VisibleImageProperty(ImgObjIndex: self.canvasIndex)
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        //self.NextButtonPressed(UIButton.init())
        
        /*
         // Manage Singal Image
         //-------------------------------->
         self.pencilview.isHidden = true
         btneraser.isHidden = true
         colorpickerheight.constant = 50
         let img = self.canvasView.toImage()
         self.dismiss(animated: true, completion: nil)
         
         if self.btnprivacy.accessibilityLabel == nil { self.btnprivacy.accessibilityLabel = "0" }
         if self.btntimer.accessibilityLabel == nil { self.btntimer.accessibilityLabel = "" }
         
         print(self.btntimer.accessibilityLabel!)
         print(self.btnprivacy.accessibilityLabel!)
         
         //self.photoEditorDelegate?.doneEditing(image: img,timeselected:self.btntimer.accessibilityLabel!,isprivate:self.btnprivacy.accessibilityLabel!)
         //<--------------------------------
         
         //-------> PV
         // Manage Multipul Image
         //-------------------------------->
         var arrEditedImages: [UIImage] = []
         for obj in self.arrImageProperty! {
         let dic : NSMutableDictionary = obj as! NSMutableDictionary
         
         let imgData : Data = dic.value(forKey: key_EditedImage) as! Data
         let img : UIImage = UIImage.init(data: imgData)!
         
         arrEditedImages.append(img)
         }
         //print("arrEditedImages : \(arrEditedImages)")
         //print("called Delegate")
         self.photoEditorDelegate?.doneEditing(images: arrEditedImages, imagesProperty: self.arrImageProperty!)
         */
        
        //Hide controller
        self.pencilview.isHidden = true
        btneraser.isHidden = true
        imgeraon.isHidden = true
        colorpickerheight.constant = 50
        
        self.dismiss(animated: true, completion: nil) //Dismiss editor viewcontroller
        
        switch objEnumEditor {
        case .Editor_Photo:
            self.done_PhotoEditor()
            break
        case .Editor_Video:
            self.done_VideoEditor()
            break
        default:
            break
        }
    }
    
    //MARK:- Done Editing
    func done_PhotoEditor() {
        
        //Saved Caption text
        self.Update_CaptionMess(mess: TRIM(string: self.txtCaptionMess.text ?? ""), inObjectIndex: self.canvasIndex)
        
        //Show Loader
        if (self.arrPhotoProperty?.count != 0) { showHUD() }
        
        var arrEditedImages: [UIImage] = []
        let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
        
        //Save Edited Image
        let img = cell.canvasView.toImage()
        self.Update_Image(image: img, inObjectIndex: self.canvasIndex)
        for obj in self.arrPhotoProperty!
        {
            let dic : NSMutableDictionary = obj as! NSMutableDictionary
            let imgData : Data = dic.value(forKey: key_EditedImage) as! Data
            let img : UIImage = UIImage.init(data: imgData)!
            arrEditedImages.append(img)
        }
        hideHUD()
        
        //print("arrEditedImages : \(arrEditedImages)")
        //print("called Delegate")
        self.photoEditorDelegate?.doneEditing(images: arrEditedImages, imagesProperty: self.arrPhotoProperty!)
    }
    
    func done_VideoEditor() {
        //Stop Play Video
        let cell:VideoCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! VideoCell
        cell.player?.pause()
        cell.player?.pause()
        cell.player?.pause()
        
        //Saved Caption text
        self.Update_CaptionMess(mess: TRIM(string: self.txtCaptionMess.text ?? ""), inObjectIndex: self.canvasIndex)
        
        var arrEditedVideoURL: [URL] = []
        
        //Show Loader
        if (self.arrVideoProperty?.count != 0) { showHUD() }
        
        for obj in self.arrVideoProperty! {
            
            let fileManager = FileManager.default
            /*let asset = videoselected!
            let length = Float(asset.duration.value) / Float(asset.duration.timescale)
            //print("video length: \(length) seconds")*/
            
            let objDic : NSMutableDictionary = obj as! NSMutableDictionary
            let strVideoURL : String = objDic.value(forKey: key_VideoURL) as! String
            let startTimeValue : CMTime = CMTime.init(seconds: objDic.value(forKey: key_Video_StartDuration) as! Double, preferredTimescale: CMTimeScale(CMTimeScale.bitWidth))
            let stopTimeValue : CMTime = CMTime.init(seconds: objDic.value(forKey: key_Video_StopDuration) as! Double, preferredTimescale: CMTimeScale(CMTimeScale.bitWidth))
            
            var fileURL: URL? = getDocumentsDirectoryURL()
            fileURL?.appendPathComponent((strVideoURL.url?.lastPathComponent)!)
            
            let outputURL = fileURL
            try? fileManager.removeItem(at: outputURL!)
        
            let asset = AVAsset.init(url: strVideoURL.url!)
            //guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
             guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetLowQuality) else { return }
            
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mp4
            
            let timeRange = CMTimeRange(start: startTimeValue, end:  stopTimeValue)
            
            exportSession.timeRange = timeRange
            exportSession.exportAsynchronously {
                switch exportSession.status {
                case .completed:
                    //print("exported at \(String(describing: outputURL))")
                    runOnMainThreadWithoutDeadlock {
                        //self.videoEditorVCDelegate?.exportvideonow(outputURL!)
                        /*let vc = loadVC(strStoryboardId: SB_STORIES, strVCId: "idStoryPreviewVC") as! StoryPreviewVC
                        vc.vdourl = outputURL
                        APP_DELEGATE.appNavigation?.pushViewController(vc, animated: true)
                        //APP_DELEGATE.appNavigation?.popViewController(animated: true)*/
                        
                        arrEditedVideoURL.append(outputURL!)
                    
                        if arrEditedVideoURL.count == self.arrVideoProperty?.count {
                            hideHUD()
                            //print("arrEditedVideoURL : \(arrEditedVideoURL)")
                            //print("called Delegate")
                            self.photoEditorDelegate?.doneEditing(videoURL: arrEditedVideoURL, videoProperty: self.arrVideoProperty!)
                        }
                    }
                case .failed:
                    hideHUD()
                    //print("failed \(exportSession.error.debugDescription)")
                case .cancelled:
                    hideHUD()
                    //print("cancelled \(exportSession.error.debugDescription)")
                default:
                    hideHUD()
                    break
                }
            }
        }
        //------------------------------>
        //------------------------------>
        //------------------------------>
        /*var arrEditedVideoURL: [URL] = []
        for obj in self.arrVideoProperty! {
            let dic : NSMutableDictionary = obj as! NSMutableDictionary
            
            let strVideoURL : String = dic.value(forKey: key_VideoURL) as! String
            let videoURL : URL = strVideoURL.url!
            
            arrEditedVideoURL.append(videoURL)
        }
        //print("arrEditedVideoURL : \(arrEditedVideoURL)")
        //print("called Delegate")
        self.photoEditorDelegate?.doneEditing(videoURL: arrEditedVideoURL, videoProperty: self.arrVideoProperty!)*/
        
    }
    
    //MARK:- helper methods
    @objc func image(_ image: UIImage, withPotentialError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        let alert = UIAlertController(title: "Image Saved", message: "Image successfully saved to Photos library", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func hideControls() {
        for control in hiddenControls {
            switch control {
                
            case .clear:
                clearButton.isHidden = true
            case .crop:
                cropButton.isHidden = true
            case .draw:
                drawButton.isHidden = true
            case .save:
                saveButton.isHidden = true
            case .share:
                shareButton.isHidden = true
            case .sticker:
                stickerButton.isHidden = true
            case .text:
                textButton.isHidden = true
            }
        }
    }
    
    /*func setPrivateButtonImage(objectIndex : Int) -> Void {
        if get_Status_IsPrivate(objectIndex: self.canvasIndex) == "0" {
            self.btnprivacy.setImage(UIImage.init(named: "public_story"), for:.normal)
        }
        else {
            self.btnprivacy.setImage(UIImage.init(named: "private_story"), for:.normal)
        }
    }*/
    
    func set_VisibleImageProperty(ImgObjIndex : Int) -> Void {
        //Private Status Image
        if get_Status_IsPrivate(objectIndex: self.canvasIndex) == "0" {
            self.btnprivacy.setImage(UIImage.init(named: "public_story"), for:.normal)
        }
        else {
            self.btnprivacy.setImage(UIImage.init(named: "private_story"), for:.normal)
        }
        
        //Caption Text
        let strCaptionText : String = get_CaptionText(objectIndex: ImgObjIndex)
        self.txtCaptionMess.text = strCaptionText
    }
    
    //MARK:- Manage Private & TimeSedual status
    
    func get_Status_IsPrivate(objectIndex : Int) -> String {
        /*if (self.arrImageProperty?.count == 0) { return "0" }
        
        let dicImgProperty : NSMutableDictionary = self.arrImageProperty![self.canvasIndex] as! NSMutableDictionary
        let strIsPrivateStatus : String = dicImgProperty.value(forKey: key_IsPrivate) as! String
        
        return strIsPrivateStatus*/
        
        /*if (self.arrSelectedContent?.count == 0) { return "0" }
        let objDic : NSMutableDictionary = self.arrSelectedContent![self.canvasIndex] as! NSMutableDictionary
        let contentType : String = objDic.value(forKey: key_ContentType) as! String
        
        if (contentType.uppercased() == "0".uppercased()) {
            let dicImgProperty : NSMutableDictionary = self.arrImageProperty![self.canvasIndex] as! NSMutableDictionary
            let strIsPrivateStatus : String = dicImgProperty.value(forKey: key_IsPrivate) as! String
            return strIsPrivateStatus
        }
        else if (contentType.uppercased() == "1".uppercased()) {
            let strIsPrivateStatus : String = objDic.value(forKey: key_IsPrivate) as! String
            return strIsPrivateStatus
        }
        return "0"*/
        
        
        var objDic : NSMutableDictionary = NSMutableDictionary.init()
        var contentType : String = ""
        
        switch objEnumEditor {
        case .Editor_Photo:
            objDic = self.arrPhotoProperty![objectIndex] as! NSMutableDictionary
            contentType = objDic.value(forKey: key_ContentType) as! String
            break
        case .Editor_Video:
            objDic = self.arrVideoProperty![objectIndex] as! NSMutableDictionary
            contentType = objDic.value(forKey: key_ContentType) as! String
            break
        default:
            break
        }
        
        if (contentType.uppercased() == "0".uppercased()) {
            let strIsPrivateStatus : String = objDic.value(forKey: key_IsPrivate) as! String
            return strIsPrivateStatus
        }
        else if (contentType.uppercased() == "1".uppercased()) {
            let strIsPrivateStatus : String = objDic.value(forKey: key_IsPrivate) as! String
            return strIsPrivateStatus
        }
        return "0"
    }
    
    func get_Time_ofTimeSedual(objectIndex : Int) -> String {
      
        
        var objDic : NSMutableDictionary = NSMutableDictionary.init()
        var contentType : String = ""
        
        switch objEnumEditor {
        case .Editor_Photo:
            objDic = self.arrPhotoProperty![objectIndex] as! NSMutableDictionary
            contentType = objDic.value(forKey: key_ContentType) as! String
            break
        case .Editor_Video:
            objDic = self.arrVideoProperty![objectIndex] as! NSMutableDictionary
            contentType = objDic.value(forKey: key_ContentType) as! String
            break
        default:
            break
        }
        
        if (contentType.uppercased() == "0".uppercased()) {
            let strTime : String = objDic.value(forKey: key_Timer) as! String
            return strTime
        }
        else if (contentType.uppercased() == "1".uppercased()) {
            let strTime : String = objDic.value(forKey: key_Timer) as! String
            return strTime
        }
        return ""
    }
    
    func get_CaptionText(objectIndex : Int) -> String {
        /*if (self.arrImageProperty?.count == 0) { return "0" }
        
        let dicImgProperty : NSMutableDictionary = self.arrImageProperty![self.canvasIndex] as! NSMutableDictionary
        let strCaptionText : String = dicImgProperty.value(forKey: key_CaptionText) as! String
        
        return strCaptionText*/
        
        /*
        if (self.arrSelectedContent?.count == 0) { return "" }
        let objDic : NSMutableDictionary = self.arrSelectedContent![self.canvasIndex] as! NSMutableDictionary
        let contentType : String = objDic.value(forKey: key_ContentType) as! String
        
        if (contentType.uppercased() == "0".uppercased()) {
            let dicImgProperty : NSMutableDictionary = self.arrImageProperty![self.canvasIndex] as! NSMutableDictionary
            let strCaptionText : String = dicImgProperty.value(forKey: key_CaptionText) as! String
            return strCaptionText
        }
        else if (contentType.uppercased() == "1".uppercased()) {
            let strCaptionText : String = objDic.value(forKey: key_CaptionText) as! String
            return strCaptionText
        }
        return ""*/
        
        var objDic : NSMutableDictionary = NSMutableDictionary.init()
        var contentType : String = ""
        
        switch objEnumEditor {
        case .Editor_Photo:
            objDic = self.arrPhotoProperty![objectIndex] as! NSMutableDictionary
            contentType = objDic.value(forKey: key_ContentType) as! String
            break
        case .Editor_Video:
            objDic = self.arrVideoProperty![objectIndex] as! NSMutableDictionary
            contentType = objDic.value(forKey: key_ContentType) as! String
            break
        default:
            break
        }
        
        if (contentType.uppercased() == "0".uppercased()) {
            let strCaptionText : String = objDic.value(forKey: key_CaptionText) as! String
            return strCaptionText
        }
        else if (contentType.uppercased() == "1".uppercased()) {
            let strCaptionText : String = objDic.value(forKey: key_CaptionText) as! String
            return strCaptionText
        }
        return ""
    }
    
    func get_Video_StartTime(objectIndex : Int) -> Double {
        var objDic : NSMutableDictionary = NSMutableDictionary.init()
        var contentType : String = ""
        
        switch objEnumEditor {
        case .Editor_Photo:
            break
        case .Editor_Video:
            objDic = self.arrVideoProperty![objectIndex] as! NSMutableDictionary
            contentType = objDic.value(forKey: key_ContentType) as! String
            break
        default:
            break
        }
        
        if (contentType.uppercased() == "0".uppercased()) {
            //--> Image
        }
        else if (contentType.uppercased() == "1".uppercased()) {
            let time : Double = objDic.value(forKey: key_Video_StartDuration) as? Double ?? 0.01
            return time
        }
        return 0.0
    }
    
    func get_Video_StopTime(objectIndex : Int) -> Double {
        var objDic : NSMutableDictionary = NSMutableDictionary.init()
        var contentType : String = ""
        
        switch objEnumEditor {
        case .Editor_Photo:
            break
        case .Editor_Video:
            objDic = self.arrVideoProperty![objectIndex] as! NSMutableDictionary
            contentType = objDic.value(forKey: key_ContentType) as! String
            break
        default:
            break
        }
        
        if (contentType.uppercased() == "0".uppercased()) {
            //--> Image
        }
        else if (contentType.uppercased() == "1".uppercased()) {
            let time : Double = objDic.value(forKey: key_Video_StopDuration) as? Double ?? 0.0
            
            if (time == 0.0) {
                let strVideoURL : String = objDic.value(forKey: key_VideoURL) as! String
                let asset = AVAsset(url: strVideoURL.url!)
                let duration = asset.duration
                let durationTime : Double = CMTimeGetSeconds(duration) as Double
                return durationTime
            }
            return time
        }
        return 0.0
    }
    
    func Update_Image(image: UIImage, inObjectIndex : Int) {
        /*if (self.arrImageProperty?.count == 0) { return }
        
        //Get Curret Visisble Img Property and Update
        let dicImgProperty : NSMutableDictionary = self.arrImageProperty![inObjectIndex] as! NSMutableDictionary
        dicImgProperty.setValue(image.sd_imageData(), forKey: key_EditedImage)
        
        //Replace Obj. in Propert array
        self.arrImageProperty?.replaceObject(at: inObjectIndex, with: dicImgProperty)*/
        
        var objDic : NSMutableDictionary = NSMutableDictionary.init()
        
        switch objEnumEditor {
        case .Editor_Photo:
            //Get Curret Visisble Img Property and Update
            objDic = self.arrPhotoProperty![inObjectIndex] as! NSMutableDictionary
            objDic.setValue(image.sd_imageData(), forKey: key_EditedImage)
            
            //Replace Obj. in Propert array
            self.arrPhotoProperty?.replaceObject(at: inObjectIndex, with: objDic)
            break
        case .Editor_Video:
            break
        default:
            break
        }
    }
    
    func Update_CaptionMess(mess: String, inObjectIndex : Int) {
        /*if (self.arrImageProperty?.count == 0) { return }
        
        //Get Curret Visisble Img Property and Update
        let dicImgProperty : NSMutableDictionary = self.arrImageProperty![inObjectIndex] as! NSMutableDictionary
        dicImgProperty.setValue(mess, forKey: key_CaptionText)
        
        //Replace Obj. in Propert array
        self.arrImageProperty?.replaceObject(at: inObjectIndex, with: dicImgProperty)*/
        
        /*
        if (self.arrSelectedContent?.count == 0) { return }
        let objDic : NSMutableDictionary = self.arrSelectedContent![self.canvasIndex] as! NSMutableDictionary
        let contentType : String = objDic.value(forKey: key_ContentType) as! String
        
        if (contentType.uppercased() == "0".uppercased()) {
            //Get Curret Visisble Img Property and Update
            let dicImgProperty : NSMutableDictionary = self.arrImageProperty![inObjectIndex] as! NSMutableDictionary
            dicImgProperty.setValue(mess, forKey: key_CaptionText)
            
            //Replace Obj. in Propert array
            self.arrImageProperty?.replaceObject(at: inObjectIndex, with: dicImgProperty)
        }
        else if (contentType.uppercased() == "1".uppercased()) {
            //Get Curret Visisble Img Property and Update
            let dicVideoProperty = objDic
            dicVideoProperty.setValue(mess, forKey: key_CaptionText)
            
            //Replace Obj. in Propert array
            self.arrSelectedContent?.replaceObject(at: inObjectIndex, with: dicVideoProperty)
        }*/
        
        var objDic : NSMutableDictionary = NSMutableDictionary.init()
        var contentType : String = ""
        
        switch objEnumEditor {
        case .Editor_Photo:
            objDic = self.arrPhotoProperty![inObjectIndex] as! NSMutableDictionary
            contentType = objDic.value(forKey: key_ContentType) as! String
            break
        case .Editor_Video:
            objDic = self.arrVideoProperty![inObjectIndex] as! NSMutableDictionary
            contentType = objDic.value(forKey: key_ContentType) as! String
            break
        default:
            break
        }
        
        if (contentType.uppercased() == "0".uppercased()) {
            //Get Curret Visisble Img Property and Update
            objDic.setValue(mess, forKey: key_CaptionText)
            
            //Replace Obj. in Propert array
            self.arrPhotoProperty?.replaceObject(at: inObjectIndex, with: objDic)
        }
        else if (contentType.uppercased() == "1".uppercased()) {
            //Get Curret Visisble Img Property and Update
            objDic.setValue(mess, forKey: key_CaptionText)
            
            //Replace Obj. in Propert array
            self.arrVideoProperty?.replaceObject(at: inObjectIndex, with: objDic)
        }
    }
    
    func Update_IsPrivate(status : String, inObjectIndex : Int) {
        /*if (self.arrImageProperty?.count == 0) { return }
        
        //Get Curret Visisble Img Property and Update
        let dicImgProperty : NSMutableDictionary = self.arrImageProperty![inObjectIndex] as! NSMutableDictionary
        dicImgProperty.setValue(status, forKey: key_IsPrivate)
        
        //Replace Obj. in Propert array
        self.arrImageProperty?.replaceObject(at: inObjectIndex, with: dicImgProperty)*/
        /*
        if (self.arrSelectedContent?.count == 0) { return }
        let objDic : NSMutableDictionary = self.arrSelectedContent![self.canvasIndex] as! NSMutableDictionary
         let contentType : String = objDic.value(forKey: key_ContentType) as! String
        
        if (contentType.uppercased() == "0".uppercased()) {
            //Get Curret Visisble Img Property and Update
            let dicImgProperty : NSMutableDictionary = self.arrImageProperty![inObjectIndex] as! NSMutableDictionary
            dicImgProperty.setValue(status, forKey: key_IsPrivate)
            
            //Replace Obj. in Propert array
            self.arrImageProperty?.replaceObject(at: inObjectIndex, with: dicImgProperty)
        }
        else if (contentType.uppercased() == "1".uppercased()) {
            //Get Curret Visisble Img Property and Update
            let dicVideoProperty = objDic
            dicVideoProperty.setValue(status, forKey: key_IsPrivate)
            
            //Replace Obj. in Propert array
            self.arrSelectedContent?.replaceObject(at: inObjectIndex, with: dicVideoProperty)
        }*/
        
        var objDic : NSMutableDictionary = NSMutableDictionary.init()
        var contentType : String = ""
        
        switch objEnumEditor {
        case .Editor_Photo:
            objDic = self.arrPhotoProperty![inObjectIndex] as! NSMutableDictionary
            contentType = objDic.value(forKey: key_ContentType) as! String
            break
        case .Editor_Video:
            objDic = self.arrVideoProperty![inObjectIndex] as! NSMutableDictionary
            contentType = objDic.value(forKey: key_ContentType) as! String
            break
        default:
            break
        }
        
        if (contentType.uppercased() == "0".uppercased()) {
            //Get Curret Visisble Img Property and Update
            objDic.setValue(status, forKey: key_IsPrivate)
            
            //Replace Obj. in Propert array
            self.arrPhotoProperty?.replaceObject(at: inObjectIndex, with: objDic)
        }
        else if (contentType.uppercased() == "1".uppercased()) {
            //Get Curret Visisble Img Property and Update
            objDic.setValue(status, forKey: key_IsPrivate)
            
            //Replace Obj. in Propert array
            self.arrVideoProperty?.replaceObject(at: inObjectIndex, with: objDic)
        }
    }
    
    func Update_TimeSelected(time : String, inObjectIndex : Int) {
        
        var objDic : NSMutableDictionary = NSMutableDictionary.init()
        var contentType : String = ""
        
        switch objEnumEditor {
        case .Editor_Photo:
            objDic = self.arrPhotoProperty![inObjectIndex] as! NSMutableDictionary
            contentType = objDic.value(forKey: key_ContentType) as! String
            break
        case .Editor_Video:
            objDic = self.arrVideoProperty![inObjectIndex] as! NSMutableDictionary
            contentType = objDic.value(forKey: key_ContentType) as! String
            break
        default:
            break
        }
        
        if (contentType.uppercased() == "0".uppercased()) {
            //Get Curret Visisble Img Property and Update
            objDic.setValue(time, forKey: key_Timer)
            
            //Replace Obj. in Propert array
            self.arrPhotoProperty?.replaceObject(at: inObjectIndex, with: objDic)
        }
        else if (contentType.uppercased() == "1".uppercased()) {
            //Get Curret Visisble Img Property and Update
            objDic.setValue(time, forKey: key_Timer)
            
            //Replace Obj. in Propert array
            self.arrVideoProperty?.replaceObject(at: inObjectIndex, with: objDic)
        }
    }
    
    func Update_Video_TrimmingTime(startTime: CMTime, endTime: CMTime, inObjectIndex : Int) {
        var objDic : NSMutableDictionary = NSMutableDictionary.init()
        var contentType : String = ""
        
        switch objEnumEditor {
        case .Editor_Photo:
            objDic = self.arrPhotoProperty![inObjectIndex] as! NSMutableDictionary
            contentType = objDic.value(forKey: key_ContentType) as! String
            break
        case .Editor_Video:
            objDic = self.arrVideoProperty![inObjectIndex] as! NSMutableDictionary
            contentType = objDic.value(forKey: key_ContentType) as! String
            break
        default:
            break
        }
        
        if (contentType.uppercased() == "0".uppercased()) {
            //--> Image
        }
        else if (contentType.uppercased() == "1".uppercased()) {
            //--> Image
            //Get Curret Visisble video Start-&-Stop Property Update
            /*objDic.setValue(startTime, forKey: key_Video_StartDuration)
            objDic.setValue(endTime, forKey: key_Video_StopDuration)*/
            
            objDic.setValue(startTime.seconds, forKey: key_Video_StartDuration)
            objDic.setValue(endTime.seconds, forKey: key_Video_StopDuration)
            
            //Replace Obj. in Propert array
            self.arrVideoProperty?.replaceObject(at: inObjectIndex, with: objDic)
        }
    }
}

