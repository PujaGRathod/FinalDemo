//
//  PopupCell.swift
//  WakeUppApp
//
//  Created by C025 on 30/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class PopupCell: UITableViewCell {

    @IBOutlet weak var viewMain: UIView!
    
    @IBOutlet weak var imgPhoro: UIImageView!
    
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var lblUsername: UILabel!
    
    @IBOutlet weak var btnFollow: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
