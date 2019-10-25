//
//  CommentCell.swift
//  WakeUppApp
//
//  Created by Payal Umraliya on 23/03/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet var imgrofile: UIImageView!
    
    @IBOutlet var lbltime: UILabel!
    @IBOutlet var lblcomment: UILabel!
    @IBOutlet var lbluname: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
