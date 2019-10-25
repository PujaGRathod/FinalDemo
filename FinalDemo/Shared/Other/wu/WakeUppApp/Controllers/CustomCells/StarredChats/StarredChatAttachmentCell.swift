//
//  StarredChatAttachmentCell.swift
//  WakeUppApp
//
//  Created by Admin on 26/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class StarredChatAttachmentCell: UITableViewCell {
    
    weak var starredChatClickedDelegate: StarredChatClickedDeleate?
    @IBOutlet var btnStarredChat: UIButton!
    
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgPlay: UIImageView!
    @IBOutlet weak var imgAttachment: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func btnStarredChatClicked(_ sender:UIButton){
        if let delegate = starredChatClickedDelegate{
            delegate.btnStarredChatClicked(sender)
        }
    }
    
}
