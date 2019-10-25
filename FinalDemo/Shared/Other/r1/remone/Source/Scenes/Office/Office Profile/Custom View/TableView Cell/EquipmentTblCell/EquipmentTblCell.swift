//
//  EquipmentTblCell.swift
//  remone
//
//  Created by Arjav Lad on 16/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

class EquipmentTblCell: UITableViewCell {

    @IBOutlet weak var viewSep: UIView!
    @IBOutlet weak var lblEquipmentDesc: UILabel!
    @IBOutlet weak var lblEquipmentName: UILabel!
    @IBOutlet weak var imageViewEquipment: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
