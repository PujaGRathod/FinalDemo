//
//  RMUserProfileImageView.swift
//  remone
//
//  Created by Akshit Zaveri on 08/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit
import SDWebImage

class RMUserProfileImageView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.nibSetup()
    }
    
    private func nibSetup() {
        self.set(url: nil)
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
        self.clipsToBounds = true
    }
    
    func set(url: URL?) {
        self.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "ic_userprofile_56pt")) { (image, error, cacheType, url) in
        }
    }
}
