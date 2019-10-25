//
//  UserProfileTableViewSectionButtonsView.swift
//  remone
//
//  Created by Akshit Zaveri on 09/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

class UserProfileTableViewSectionButtonsView: UITableViewHeaderFooterView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var selectedSectionIndicatorView: UIView!
    @IBOutlet weak var timelineSectionButton: UIButton!
    @IBOutlet weak var basicInformationSectionButton: UIButton!
    @IBOutlet weak var selectedSectionIndicatorLeadingConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        self.nibSetup()
//    }
//
//    override init(reuseIdentifier: String?) {
//        super.init(reuseIdentifier: reuseIdentifier)
//        self.nibSetup()
//    }
    
    private func nibSetup() {
//        Bundle.main.loadNibNamed("UserProfileTableViewSectionButtonsView", owner: self, options: nil)
//        self.translatesAutoresizingMaskIntoConstraints = false
//        self.containerView.frame = self.bounds
//        self.containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        self.addSubview(self.containerView)
//        self.layoutIfNeeded()
    }

}
