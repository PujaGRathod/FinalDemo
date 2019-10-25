//
//  ForwardMessageCell.swift
//  WakeUppApp
//
//  Created by Admin on 09/07/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class ForwardMessageCell: UITableViewCell {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgCheck: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
