//
//  ReceivedInfoCell.swift
//  WakeUppApp
//
//  Created by Admin on 18/07/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class ReceivedInfoCell: UITableViewCell {
    
    @IBOutlet var imgpic: UIImageView!
    @IBOutlet var lblname: UILabel!
    @IBOutlet var lblreceivedtime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
