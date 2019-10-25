//
//  RMUserCoverImageView.swift
//  remone
//
//  Created by Akshit Zaveri on 24/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

class RMUserCoverImageView: UIImageView {

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
        self.clipsToBounds = true
        self.backgroundColor = #colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1)
    }
    
    func set(url: URL?) {
        self.sd_setImage(with: url) { (image, error, cacheType, url) in
            if image != nil {
                self.backgroundColor = UIColor.white
            }
        }
    }

}
