//
//  StarredChatTextCell.swift
//  WakeUppApp
//
//  Created by Admin on 26/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class StarredChatTextCell: UITableViewCell {

    weak var starredChatClickedDeleate: StarredChatClickedDeleate?

    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func btnStarredChatClicked(_ sender:UIButton){
        if let delegate = starredChatClickedDeleate{
            delegate.btnStarredChatClicked(sender)
        }
    }

}
