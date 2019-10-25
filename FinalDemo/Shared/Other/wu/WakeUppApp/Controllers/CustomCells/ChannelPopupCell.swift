//
//  ChannelPopupCell.swift
//  WakeUppApp
//
//  Created by C025 on 31/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class ChannelPopupCell: UITableViewCell {

    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var imgPhoro: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var lc_btnAction_Width: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
