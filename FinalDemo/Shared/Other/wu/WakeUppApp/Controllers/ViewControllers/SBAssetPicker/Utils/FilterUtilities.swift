//
//  FilterUtilities.swift
//  ImageFilter
//
//  Created by Admin on 12/05/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import Foundation
import UIKit
import CoreImage
import AVFoundation

class FilterUtilities{
    
    func getFilteredImage(filterName:String, originalImage:UIImage) -> UIImage{

        if filterName == arrFilters[0]{
            return originalImage
        }
        
        let context: CIContext = CIContext(options: nil)
        
        let appliedFilter = CIFilter(name: filterName)!
        
        let beginImage = CIImage(image: originalImage)
        appliedFilter.setValue(beginImage, forKey: kCIInputImageKey)
        let inputKeys = appliedFilter.inputKeys
        let intensity = 0.5
        
        if inputKeys.contains(kCIInputIntensityKey) {
            appliedFilter.setValue(intensity, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            appliedFilter.setValue(intensity * 200, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
            appliedFilter.setValue(intensity * 10, forKey: kCIInputScaleKey)
        }
        if inputKeys.contains(kCIInputCenterKey) {
            appliedFilter.setValue(CIVector(x: originalImage.size.width / 2, y: originalImage.size.height / 2), forKey: kCIInputCenterKey)
        }
        
        let cgImage = context.createCGImage(appliedFilter.outputImage!, from: appliedFilter.outputImage!.extent)
        let filteredImage = UIImage(cgImage: cgImage!)
        
        return filteredImage
    }
    
    func getVideoComposition(filterName:String, asset:AVAsset) -> AVVideoComposition?{
        
        if filterName == arrFilters[0]{
            return nil
        }
        
        let appliedFilter = CIFilter(name: filterName)!
        let composition = AVVideoComposition(asset: asset, applyingCIFiltersWithHandler: { request in
            
            if #available(iOS 11.0, *) {
                let filtered = request.sourceImage.applyingFilter(filterName)
                request.finish(with: filtered, context: nil)
            } else {
                // Clamp to avoid blurring transparent pixels at the image edges
                let source = request.sourceImage.clampedToExtent()
                appliedFilter.setValue(source, forKey: kCIInputImageKey)
                
                // Vary filter parameters based on video timing
                let seconds = CMTimeGetSeconds(request.compositionTime)
                appliedFilter.setValue(seconds * 10.0, forKey: kCIInputRadiusKey)
                
                // Crop the blurred output to the bounds of the original image
                let output = appliedFilter.outputImage!.cropped(to: request.sourceImage.extent)
                
                // Provide the filter output to the composition
                request.finish(with: output, context: nil)
            }
            
        })
        
        return composition
    }
    
}
