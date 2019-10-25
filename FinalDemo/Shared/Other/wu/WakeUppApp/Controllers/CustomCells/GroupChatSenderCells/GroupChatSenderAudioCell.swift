//
//  GroupChatSenderAudioCell.swift
//  WakeUppApp
//
//  Created by Admin on 17/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

protocol GroupChatSenderAudioCellDelegate:class
{
    func btnPlayAudioClicked(_ sender: UIButton)
}

class GroupChatSenderAudioCell: UITableViewCell {

    weak var groupChatSenderAudioCellDelegate: GroupChatSenderAudioCellDelegate?
    @IBOutlet var imgbubble: UIImageView!
    
    @IBOutlet weak var btnPlay : UIButton!
    @IBOutlet weak var audioSlider : UISlider!
    @IBOutlet weak var lbltime: UILabel!
    @IBOutlet weak var imgUser : UIImageView!
    @IBOutlet var widthImgUser: NSLayoutConstraint!
    @IBOutlet weak var lblSender: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func btnPlayClicked(_ sender: UIButton) {
        self.groupChatSenderAudioCellDelegate?.btnPlayAudioClicked(sender)
    }

}
