//
//  RMUserTimestampView.swift
//  remone
//
//  Created by Akshit Zaveri on 08/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

class RMUserTimestampView: UIView {

    @IBOutlet var containerView: UIView!
    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.nibSetup()
    }
    
    private func nibSetup() {
        Bundle.main.loadNibNamed("RMUserTimestampView", owner: self, options: nil)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.frame = self.bounds
        self.containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(self.containerView)
        self.layoutIfNeeded()
    }
    
    func set(timestamp: TimeStampStatus) {
        self.iconImageView.image = timestamp.miniIcon
        self.titleLabel.text = timestamp.text
        self.titleLabel.textColor = timestamp.color
    }
}
