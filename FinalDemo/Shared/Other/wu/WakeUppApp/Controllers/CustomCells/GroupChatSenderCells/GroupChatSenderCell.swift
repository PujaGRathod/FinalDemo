//
//  GroupChatSenderCell.swift
//  WakeUppApp
//
//  Created by Admin on 17/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit
protocol GroupChatSenderCellDelegate:class
{
    func btnreactclicked(_ sender: UIButton)
}
class GroupChatSenderCell: UITableViewCell {
    
    weak var groupChatSenderCellDelegate: GroupChatSenderCellDelegate?
    
    @IBOutlet var vwcontainer: UIView!
    @IBOutlet weak var lblmsg: UILabel!
    @IBOutlet var imgbubble: UIImageView!
    @IBOutlet var imgreadicon: UIImageView!
    @IBOutlet weak var lbltime: UILabel!
    @IBOutlet weak var lblSender: UILabel!
    @IBOutlet weak var btnSender_TextMess : UIButton!
    
    @IBOutlet weak var heightReplyView: NSLayoutConstraint!
    @IBOutlet weak var lblNameReply: UILabel!
    @IBOutlet weak var lblMessageReply: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        setupUI()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        setupUI()
    }
    
    func setupUI()
    {
        self.tintColor = themeWakeUppColor
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.vwcontainer.backgroundColor = .clear
        self.lbltime.backgroundColor = .clear
        self.lblmsg.backgroundColor = .clear
        
        switch UserDefaultManager.getStringFromUserDefaults(key: kChatFontCurrentSize) {
        case kChatFontSizeSmall:
            self.lbltime.font = kChatFont.withSize(kChatFontSmallForTime)
            self.lblSender.font = kChatFont.withSize(kGroupChatFontSmallForSenderName)
            self.lblNameReply.font = kChatFont.withSize(kChatFontSmallForNameReply)
            self.lblMessageReply.font = kChatFont.withSize(kChatFontSmallForMsgReply)
            self.lblmsg.font = kChatFont.withSize(kChatFontSmallForMessage)
        case kChatFontSizeMedium:
            self.lbltime.font = kChatFont.withSize(kChatFontMediumForTime)
            self.lblSender.font = kChatFont.withSize(kGroupChatFontMediumForSenderName)
            self.lblNameReply.font = kChatFont.withSize(kChatFontMediumForNameReply)
            self.lblMessageReply.font = kChatFont.withSize(kChatFontSmallForMsgReply)
            self.lblmsg.font = kChatFont.withSize(kChatFontMediumForMessage)
        case kChatFontSizeLarge:
            self.lbltime.font = kChatFont.withSize(kChatFontLargeForTime)
            self.lblSender.font = kChatFont.withSize(kGroupChatFontLargeForSenderName)
            self.lblNameReply.font = kChatFont.withSize(kChatFontLargeForNameReply)
            self.lblMessageReply.font = kChatFont.withSize(kChatFontSmallForMsgReply)
            self.lblmsg.font = kChatFont.withSize(kChatFontLargeForMessage)
        default:
            break
        }
    }

}
