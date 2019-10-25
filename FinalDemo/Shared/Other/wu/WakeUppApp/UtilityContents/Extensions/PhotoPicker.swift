//
//  PhotoPicker.swift
//  WakeUppApp
//
//  Created by Admin on 30/04/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
import Photos

class PhotoPicker: NSObject {
    
    var controller = UIImagePickerController()
    var selectedImage: UIImage?
    var delegate: PhotoPickerDelegate? = nil
    
    override init() {
        super.init()
        controller.sourceType = .photoLibrary
        controller.delegate = self
    }
    
    func dismiss() {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension PhotoPicker {
    
    func cameraAsscessRequest() {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  AVAuthorizationStatus.authorized {
            delegate?.photoPickerDelegate(canUseCamera: true, delegatedForm: self)
        } else {
            AVCaptureDevice.requestAccess(for: .video) { granted -> Void in
                self.delegate?.photoPickerDelegate(canUseCamera: granted, delegatedForm: self)
            }
        }
    }
    
    func galleryAsscessRequest() {
        PHPhotoLibrary.requestAuthorization { [weak self] result in
            if let _self = self {
                var access = false
                if result == .authorized {
                    access = true
                }
                _self.delegate?.photoPickerDelegate(canUseGallery: access, delegatedForm: _self)
            }
        }
    }
}

extension PhotoPicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let imageName = "img_\(Date().timeIntervalSince1970)"
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            delegate?.photoPickerDelegate(didSelect: image, imageName: imageName,  delegatedForm: self)
        }
        else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            delegate?.photoPickerDelegate(didSelect: image, imageName: imageName, delegatedForm: self)
        } else{
            //print("Something went wrong")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        delegate?.photoPickerDelegate(didCancel: self)
    }
    
}


protocol PhotoPickerDelegate {
    func photoPickerDelegate(canUseCamera accessIsAllowed:Bool, delegatedForm: PhotoPicker)
    func photoPickerDelegate(canUseGallery accessIsAllowed:Bool, delegatedForm: PhotoPicker)
    func photoPickerDelegate(didSelect image: UIImage, imageName:String, delegatedForm: PhotoPicker)
    func photoPickerDelegate(didCancel delegatedForm: PhotoPicker)
}

extension PhotoPickerDelegate {
    func photoPickerDelegate(canUseCamera accessIsAllowed:Bool, delegatedForm: PhotoPicker) {}
    func photoPickerDelegate(canUseGallery accessIsAllowed:Bool, delegatedForm: PhotoPicker) {}
}
