//
//  PhotoEditor+Crop.swift
//  Pods
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import Foundation
import UIKit

// MARK: - CropView
extension PhotoEditorViewController: CropViewControllerDelegate {
    
    public func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage, transform: CGAffineTransform, cropRect: CGRect) {
        //controller.dismiss(animated: true, completion: nil)
        //self.setImageView(image: image)
        
        //PV
        controller.dismiss(animated: true, completion: nil)
        let cell:ImgCell = clsView.cellForItem(at: IndexPath.init(row: self.canvasIndex, section: 0)) as! ImgCell
        cell.setImageView(image: image, subviews: nil)
    }
    
    public func cropViewControllerDidCancel(_ controller: CropViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
