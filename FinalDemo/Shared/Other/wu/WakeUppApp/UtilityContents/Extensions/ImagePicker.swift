//
//  ImagePicker.swift
//  CookerCustomerApp
//
//  Created by Admin on 29/12/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
protocol ImagePickerDelegate {
    func pickImageComplete(_ imageData: UIImage,sender:String)
}

class ImagePicker: NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var delegate: ImagePickerDelegate?
    var senderName = String()
    let imagePicker = UIImagePickerController()
    var alertVC = UIAlertController()
    static let sharedInstance: ImagePicker = {
        let instance = ImagePicker()
        return instance
    }()
    
    override init() {
        super.init()
        
    }
    func selectImage(sender:String,presentComplete:@escaping (Bool)->())
    {
        alertVC = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        senderName = sender
        let lblTitle:UILabel = UILabel(frame: CGRect(x: 0, y: 15.0, width: SCREENWIDTH() - 20, height: 25))
        lblTitle.font = FontWithSize(FT_Regular, 20)
        lblTitle.textAlignment = .center
        lblTitle.text = "Select Image"
        alertVC.view.addSubview(lblTitle)
        let margin:CGFloat = 10.0
        let rect = CGRect(x: margin, y: margin, width: alertVC.view.bounds.size.width - margin * 4.0, height: 120)
        let customView = UIView(frame: rect)
        
        let btnGalleryImage:UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        btnGalleryImage.setBackgroundImage(UIImage(named: "gallery_chat"), for: .normal)
        btnGalleryImage.addTarget(self, action: #selector(ImagePicker.btnGalleryImage), for: UIControlEvents.touchUpInside)
        let btnCameraImage:UIButton = UIButton(frame: CGRect(x: 90, y: 0, width: 70, height: 70))
        btnCameraImage.setBackgroundImage(UIImage(named: "camera_chat"), for: .normal)
        btnCameraImage.addTarget(self, action: #selector(ImagePicker.btnCameraImage), for: UIControlEvents.touchUpInside)
        
        customView.addSubview(btnGalleryImage)
        customView.addSubview(btnCameraImage)
        alertVC.view.addSubview(customView)
        
        let alertControllerHeight:NSLayoutConstraint = NSLayoutConstraint(item: alertVC.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 250)
        alertVC.view.addConstraint(alertControllerHeight);
        mostTopViewController?.present(alertVC, animated: true, completion: {
            presentComplete(true)
        })
    }
    func selectImage(sender:String)
    {
        alertVC = UIAlertController(title: "Select image option", message: "", preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        senderName = sender
        let margin:CGFloat = 10.0
        let rect = CGRect(x: alertVC.view.center.x/4, y: margin + 30, width: 200 , height: 90)
        let customView = UIView(frame: rect)
        customView.backgroundColor = UIColor.clear
        let btnGalleryImage:UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: customView.frame.size.width/2, height: 70))
        btnGalleryImage.backgroundColor = UIColor.clear
        btnGalleryImage.setImage(UIImage(named: "gallery_chat"), for: .normal)
        btnGalleryImage.addTarget(self, action: #selector(ImagePicker.btnGalleryImage), for: UIControlEvents.touchUpInside)
        
        let lblgalerry:UILabel = UILabel(frame: CGRect(x: btnGalleryImage.frame.origin.x, y: btnGalleryImage.frame.size.height + 5, width: btnGalleryImage.frame.size.width, height: 15))
        lblgalerry.font = FontWithSize(FT_Medium, 12)
        lblgalerry.textAlignment = .center
        lblgalerry.text = "GALLERY"
        lblgalerry.backgroundColor = UIColor.clear
        lblgalerry.textColor = UIColor.darkGray
        let btnCameraImage:UIButton = UIButton(frame: CGRect(x: customView.frame.size.width/2 , y: 0, width: customView.frame.size.width/2, height: 70))
        btnCameraImage.setImage(UIImage(named: "camera_chat"), for: .normal)
        btnCameraImage.backgroundColor = UIColor.clear
        btnCameraImage.addTarget(self, action: #selector(ImagePicker.btnCameraImage), for: UIControlEvents.touchUpInside)
        
        let lblcam:UILabel = UILabel(frame: CGRect(x: btnCameraImage.frame.origin.x, y: btnCameraImage.frame.size.height + 5, width: btnCameraImage.frame.size.width, height: 15))
        lblcam.font = FontWithSize(FT_Medium, 12)
        lblcam.textColor = UIColor.darkGray
        lblcam.textAlignment = .center
        lblcam.text = "CAMERA"
        lblcam.backgroundColor = UIColor.clear
        
        customView.addSubview(btnGalleryImage)
        customView.addSubview(lblgalerry)
        customView.addSubview(btnCameraImage)
        customView.addSubview(lblcam)
        customView.center = CGPoint.init(x: alertVC.view.center.x - margin, y: 90)
        alertVC.view.addSubview(customView)
        
        let alertControllerHeight:NSLayoutConstraint = NSLayoutConstraint(item: alertVC.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 220)
        alertVC.view.addConstraint(alertControllerHeight);
        mostTopViewController?.present(alertVC, animated: true)
    }
    
    @objc func btnGalleryImage() {
        alertVC.dismiss(animated: true) {
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            mostTopViewController?.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    @objc func btnCameraImage() {
        alertVC.dismiss(animated: true) {
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .camera
            mostTopViewController?.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            let imgData : NSData = UIImageJPEGRepresentation(pickedImage,uploadImageCompression)! as NSData
            delegate?.pickImageComplete(UIImage.init(data: imgData as Data!)!,sender: senderName)
        }
        mostTopViewController?.dismiss(animated: true, completion: nil)
    }
}
