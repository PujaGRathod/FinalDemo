//
//  PHAsset_Extension.swift
//  ImageFilter
//
//  Created by Admin on 11/05/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import Foundation
import Photos

extension PHAsset {
    
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
    
    func getOriginalImage() -> UIImage{
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        
        options.isSynchronous = true
        options.deliveryMode = .fastFormat
        options.resizeMode = .exact
        
        var image = UIImage()
        /*if self.mediaType == .image{
            manager.requestImage(for: self, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: options, resultHandler: { (img, info) in
                image = img!
                image = image.scaled(to: maxImageSize)
            })
        }else{*/
            manager.requestImageData(for: self, options: options) { data, _, _, _ in
                if let data = data {
                    image = UIImage(data: data)!
                    //image = image.scaled(to: maxImageSize)
                    image = image.resize()
                }
            }
        /*}*/
        return image
    }
    
    func getThumbnail() -> UIImage{
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        
        options.isSynchronous = true
        options.deliveryMode = .fastFormat
        options.resizeMode = .exact
        
        var image = UIImage()
        manager.requestImage(for: self, targetSize: CGSize.init(width: 80, height: 80), contentMode: PHImageContentMode.aspectFill, options: options, resultHandler: { (img, info) in
            if let img = img{
                image = img
                image = image.scaled(to: maxImageSize)
            }
        })
        return image
    }
    
}
