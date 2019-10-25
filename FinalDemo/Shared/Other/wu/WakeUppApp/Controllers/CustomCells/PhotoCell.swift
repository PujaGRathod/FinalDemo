//
//  PhotoCell.swift
//  ClassicMaids
//
//  Created by DB on 3/21/18.
//  Copyright © 2018 Delegate. All rights reserved.
//

import UIKit
//import SimpleImageViewer
class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var imgPic: UIImageView!
    @IBOutlet weak var lblPhotoCount: UILabel!
    @IBOutlet weak var imgSelected: UIImageView!
    
    @IBOutlet weak var btnPlay: UIButton!
    
    @IBOutlet weak var btnCount: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        /*if imgPic != nil
        {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imagePostClicked(_:)))
            imgPic.isUserInteractionEnabled = true
            imgPic.addGestureRecognizer(tapGestureRecognizer)
        }*/
    }
    @objc func imagePostClicked(_ sender:UITapGestureRecognizer){
        let configuration = ImageViewerConfiguration { config in
            config.imageView = sender.view as? UIImageView
        }
        let imageViewerController = ImageViewerController(configuration: configuration)
        APP_DELEGATE.appNavigation?.present(imageViewerController, animated: false, completion: nil)
    }
}
