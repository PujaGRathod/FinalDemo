//
//  HeaderFooterCell.swift
//  Remone_Office_Favorite
//
//  Created by Arjav Lad on 12/01/18.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit

class HeaderFooterCell: UITableViewHeaderFooterView {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblFooter: UILabel!

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func setTitle(title:String) {
        self.lblTitle.text = title
    }
}
