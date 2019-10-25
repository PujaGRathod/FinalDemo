//
//  ChatStoryReplySenderCell.swift
//  WakeUppApp
//
//  Created by Admin on 08/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

protocol ChatSenderStoryReplyCellDelegate:class
{
    func btnStoryClicked(_ sender: UIButton)
}

class ChatStoryReplySenderCell: UITableViewCell {
    
    weak var chatSenderStoryReplyCellDelegate: ChatSenderStoryReplyCellDelegate?

    @IBOutlet var vwcontainer: UIView!
    @IBOutlet var imgbubble: UIImageView!
    @IBOutlet weak var lbltime: UILabel!
    @IBOutlet weak var lblmsg: UILabel!
    
    @IBOutlet weak var imgreceipt: UIImageView!
    @IBOutlet weak var lblStatus: UILabel!
    
    @IBOutlet weak var imgstoryThumbnail: UIImageView!
    @IBOutlet weak var btnView: UIButton!
    
    @IBOutlet weak var replyImage: UIImageView!
    @IBOutlet weak var replyImageHeight: NSLayoutConstraint!

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
        self.lblStatus.backgroundColor = .clear
        
        switch UserDefaultManager.getStringFromUserDefaults(key: kChatFontCurrentSize) {
        case kChatFontSizeSmall:
            self.lbltime.font = kChatFont.withSize(kChatFontSmallForTime)
            self.lblStatus.font = kChatFont.withSize(kChatFontSmallForNameReply)
            self.lblmsg.font = kChatFont.withSize(kChatFontSmallForMessage)
        case kChatFontSizeMedium:
            self.lbltime.font = kChatFont.withSize(kChatFontMediumForTime)
            self.lblStatus.font = kChatFont.withSize(kChatFontMediumForNameReply)
            self.lblmsg.font = kChatFont.withSize(kChatFontMediumForMessage)
        case kChatFontSizeLarge:
            self.lbltime.font = kChatFont.withSize(kChatFontLargeForTime)
            self.lblStatus.font = kChatFont.withSize(kChatFontLargeForNameReply)
            self.lblmsg.font = kChatFont.withSize(kChatFontLargeForMessage)
        default:
            break
        }
    }
    
    @IBAction func btnViewClicked(_ sender: UIButton) {
        self.chatSenderStoryReplyCellDelegate?.btnStoryClicked(sender)
    }
    
}
