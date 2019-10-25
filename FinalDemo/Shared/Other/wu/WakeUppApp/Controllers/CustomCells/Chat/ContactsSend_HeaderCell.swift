//
//  ContactsSend_HeaderCell.swift
//  WakeUppApp
//
//  Created by PiyushVyas on 22/09/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class ContactsSend_HeaderCell: UITableViewCell {

    @IBOutlet var viewMain: UIView!
    
    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnAction: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
