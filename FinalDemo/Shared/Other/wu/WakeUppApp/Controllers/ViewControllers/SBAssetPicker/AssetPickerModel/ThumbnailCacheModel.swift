//
//  ThumbnailCacheModel.swift
//  WakeUppApp
//
//  Created by Admin on 25/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import Foundation

class ThumbnailCacheModel : NSObject, NSCoding{
    
    var photosAssetID = ""
    var thumbnailImage : UIImage
    
    init(assetID: String, image: UIImage) {
        self.photosAssetID = assetID
        self.thumbnailImage = image
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.photosAssetID, forKey: "photosAssetID")
        aCoder.encode(self.thumbnailImage, forKey: "thumbnailImage")
    }
    
    required init(coder aDecoder: NSCoder) {
        self.photosAssetID = aDecoder.decodeObject(forKey: "photosAssetID") as! String
        self.thumbnailImage = aDecoder.decodeObject(forKey: "thumbnailImage") as! UIImage
    }
    
}
