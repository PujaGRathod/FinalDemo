//
//  ImgCell.swift
//  NewDemo
//
//  Created by Elaunch7 on 05/07/18.
//  Copyright © 2018 Elaunch7. All rights reserved.
//

import UIKit

class ImgCell: UICollectionViewCell {

    @IBOutlet weak var canvasViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var canvasView: UIView!
    //To hold the image
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var canvasImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
        
    override func prepareForReuse() {
        imageView.image = nil
        canvasImageView.image = nil
        //clear stickers and textviews
        for subview in canvasImageView.subviews {
            subview.removeFromSuperview()
        }
        super.prepareForReuse()
    }
    
    func setImageView(image: UIImage,subviews:[String:Any?]?) {
        
        imageView.image = nil
        canvasImageView.image = nil
        
        //clear stickers and textviews
        for subview in canvasImageView.subviews {
            subview.removeFromSuperview()
        }
        
        imageView.image = image
        let size = image.suitableSize(widthLimit: UIScreen.main.bounds.width)
        imageViewHeightConstraint.constant = (size?.height)!
        
        if let sub = subviews {
            if sub.count > 0 {
                if let img = sub["image"] as? UIImage {
                    canvasImageView.image = img
                }
                if let subV =  sub["subViews"] as? [Any] {
                    for obj in subV {
                        if  let objsV =  obj as? [Any] {
                            for i in objsV {
                                if let emoji = i as? UIView {
                                    canvasImageView.addSubview(emoji)
                                }
                            }
                        }
                    }
                }
            }
        }
        self.layoutIfNeeded()
    }
}
