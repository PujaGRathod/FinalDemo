//
//  CommonGroupCell.swift
//  WakeUppApp
//
//  Created by Admin on 14/07/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class CommonGroupCell: UITableViewCell {

    @IBOutlet weak var imgGroupIcon: UIImageView!
    @IBOutlet weak var lblGroupName: UILabel!
    @IBOutlet weak var lblMembers: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
