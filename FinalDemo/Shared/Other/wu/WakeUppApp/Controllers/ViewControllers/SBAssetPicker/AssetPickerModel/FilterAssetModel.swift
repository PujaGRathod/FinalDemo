//
//  FilterAssetModel.swift
//  ImageFilter
//
//  Created by Admin on 11/05/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Photos
import CoreImage

struct FilterAssetModel{
    
    var originalPHAsset : PHAsset!
    
    //var originalImage : UIImage?
    
    var thumbnailImage : UIImage!
    var croppedImage : UIImage!
    var originalImage : UIImage!
    
    //var filteredImages : FilteredImages?
    //var filterVideoCompositions : FilterVideoCompositions?
    
    var currentVideoComposition : AVVideoComposition?
    
    var selectedFilter = arrFilters[0]
    
    var brightnessValue : Float = kBrightness
    var contrastValue : Float = kContrast
    var saturationValue : Float = kSaturation
    var warmthValue : Float = kWarmth
    var fadeValue : Float = kFade
    var exposureValue : Float = kExposure

    var exportedFileURL : URL?
    
    mutating func exportLocally( completion: @escaping (_ exportedURL: URL, _ filteredCropImage: UIImage) -> Void ){
        var result = self
        let pathInDocumentsDirectory = FileManager.default.getDocumentsDirectory().appendingPathComponent(FilterAssetsDirectory.appendingPathComponent(String.random(ofLength: 10)))
        print(pathInDocumentsDirectory)
        if self.originalPHAsset.mediaType == .image{
            self.exportedFileURL = URL.init(fileURLWithPath: pathInDocumentsDirectory.appending(".png"))
            //FileManager.default.saveImageLocally(image: self.croppedImage, atPath: (self.exportedFileURL?.path)!)
            completion(self.exportedFileURL!, FilterUtilities().getFilteredImage(filterName: self.selectedFilter, originalImage: self.croppedImage))
        }else{
            self.originalPHAsset.getURL(completionHandler: { (url) in
                let avAsset = AVAsset.init(url:url!)
                
                /*var filters : [CIFilter] = []
                if result.selectedFilter.count > 0 && result.selectedFilter != arrFilterNames.first{
                    filters.append(CIFilter.init(name: result.selectedFilter)!)
                }
                let exporter = VideoFilterExporter(asset: avAsset, filters: filters)
                
                let url = URL.init(fileURLWithPath: pathInDocumentsDirectory.appending(".mp4"))
                
                exporter.export(toURL: url){(url: URL?) -> Void in
                    //print("EXPORTED")
                    // The filters have been applied and the new video is now at url
                    result.exportedFileURL = url
                    completion(result.exportedFileURL!)
                }*/
                
                let exporter = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetLowQuality)
                exporter!.outputURL = URL.init(fileURLWithPath: pathInDocumentsDirectory.appending(".mp4"))
                exporter!.outputFileType = AVFileType.mp4
                exporter?.videoComposition = result.currentVideoComposition
                exporter!.exportAsynchronously{
                    if exporter?.status == .failed{
                        print(exporter!.error!.localizedDescription)
                    }
                    result.exportedFileURL = exporter!.outputURL
                    completion(exporter!.outputURL!, FilterUtilities().getFilteredImage(filterName: result.selectedFilter, originalImage: result.croppedImage))
                }
            })
        }
    }
}
