//
//  ParticipantCell.swift
//  WakeUppApp
//
//  Created by Admin on 21/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class ParticipantCell: UITableViewCell {

    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet weak var lblAdminWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
