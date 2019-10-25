//
//  ChannelCommentCell.swift
//  WakeUppApp
//
//  Created by C025 on 22/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class ChannelCommentCell: UITableViewCell {

    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblTime: UILabel!
    @IBOutlet var lblComment: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
