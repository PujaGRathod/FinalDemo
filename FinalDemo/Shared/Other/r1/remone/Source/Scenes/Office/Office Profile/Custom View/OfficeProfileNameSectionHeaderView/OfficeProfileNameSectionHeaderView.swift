//
//  OfficeProfileNameSectionHeaderView.swift
//  remone
//
//  Created by Arjav Lad on 23/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

class OfficeProfileNameSectionHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var lblPartnerShop: UILabel!
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var btnOfficeUrl: UIButton!

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func showPartnerShop(_ show: Bool) {
        self.lblPartnerShop.layer.cornerRadius = 8
        self.lblPartnerShop.clipsToBounds = true
        self.lblPartnerShop.isHidden = !show
    }

}
