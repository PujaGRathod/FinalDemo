//
//  ChatAttachMedia_DocsCell.swift
//  WakeUppApp
//
//  Created by Admin on 16/08/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class ChatAttachMedia_DocsCell: UITableViewCell {
        
    @IBOutlet weak var viewMain: UIView!
    
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    @IBOutlet weak var lblDateTime: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
