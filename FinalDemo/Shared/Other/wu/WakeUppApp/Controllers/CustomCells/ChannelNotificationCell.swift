//
//  ChannelNotificationCell.swift
//  WakeUppApp
//
//  Created by C025 on 04/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class ChannelNotificationCell: UITableViewCell {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblNotification: UILabel!
    @IBOutlet weak var lblTime: UILabel!
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
