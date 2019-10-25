//
//  FeedImageCell.swift
//  WakeUppApp
//
//  Created by Admin on 01/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
//import  SimpleImageViewer
class FeedImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    
    var post : PostImages!{
        didSet{
            imgView.sd_setImage(with: URL.init(string:post.imagePath!), placeholderImage: SquarePlaceHolderImage)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        if imgView != nil
        {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imagePostClicked(_:)))
            imgView.isUserInteractionEnabled = true
            imgView.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    @objc func imagePostClicked(_ sender:UITapGestureRecognizer){
        let configuration = ImageViewerConfiguration { config in
            config.imageView = sender.view as? UIImageView
        }
        let imageViewerController = ImageViewerController(configuration: configuration)
        APP_DELEGATE.appNavigation?.present(imageViewerController, animated: false, completion: nil)
    }
}
