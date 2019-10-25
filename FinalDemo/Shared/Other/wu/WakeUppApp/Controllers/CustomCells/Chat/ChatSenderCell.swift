//
//  ChatSenderCell.swift
//  LetsTalk
//
//  Created by Admin on 02/02/18.
//  Copyright © 2018 Vishwkarma. All rights reserved.
//

import UIKit
protocol ChatSenderCellDelegate:class
{
    func btnreactclicked(_ sender: UIButton)
}
class ChatSenderCell: UITableViewCell {
    weak var chatSenderCellDelegate: ChatSenderCellDelegate?

    @IBOutlet var vwcontainer: UIView!
    @IBOutlet weak var lblmsg: UILabel!
    @IBOutlet var imgbubble: UIImageView!
    @IBOutlet var imgreadicon: UIImageView!
    @IBOutlet weak var lbltime: UILabel!
    
    @IBOutlet weak var heightReplyView: NSLayoutConstraint!
    @IBOutlet weak var lblNameReply: UILabel!
    @IBOutlet weak var lblMessageReply: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        setupUI()
    }
    override func layoutSubviews()
    {
        super.layoutSubviews()
       // imgbubble.roundCorners([.topLeft,.bottomRight,.topRight], radius: 10)
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
            self.lblNameReply.font = kChatFont.withSize(kChatFontSmallForNameReply)
            self.lblMessageReply.font = kChatFont.withSize(kChatFontSmallForMsgReply)
            self.lblmsg.font = kChatFont.withSize(kChatFontSmallForMessage)
        case kChatFontSizeMedium:
            self.lbltime.font = kChatFont.withSize(kChatFontMediumForTime)
            self.lblNameReply.font = kChatFont.withSize(kChatFontMediumForNameReply)
            self.lblMessageReply.font = kChatFont.withSize(kChatFontSmallForMsgReply)
            self.lblmsg.font = kChatFont.withSize(kChatFontMediumForMessage)
        case kChatFontSizeLarge:
            self.lbltime.font = kChatFont.withSize(kChatFontLargeForTime)
            self.lblNameReply.font = kChatFont.withSize(kChatFontLargeForNameReply)
            self.lblMessageReply.font = kChatFont.withSize(kChatFontSmallForMsgReply)
            self.lblmsg.font = kChatFont.withSize(kChatFontLargeForMessage)
        default:
            break
        }
    }
}
