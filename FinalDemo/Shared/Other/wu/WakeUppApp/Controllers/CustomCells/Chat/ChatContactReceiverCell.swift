//
//  ChatContactReceiverCell.swift
//  WakeUppApp
//
//  Created by Admin on 21/04/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

protocol ChatReceiverContactCellDelegate:class {
    func btnReceiverContactClicked(_ sender: UIButton)
}

class ChatContactReceiverCell: UITableViewCell {

    weak var chatReceiverContactCellDelegate: ChatReceiverContactCellDelegate?
    
    @IBOutlet var vwcontainer1: UIView!
    @IBOutlet var vwcontainer2: UIView!
    @IBOutlet var vwcontainer3: UIView!
    
    @IBOutlet weak var imgbubble: UIImageView!
    @IBOutlet weak var imgContact: UIImageView!
    @IBOutlet weak var lblContact: UILabel!
    
    @IBOutlet weak var Lbltime: UILabel!
    
    @IBOutlet weak var btnContact: UIButton!

    @IBOutlet weak var heightReplyView: NSLayoutConstraint!
    @IBOutlet weak var lblNameReply: UILabel!
    @IBOutlet weak var lblMessageReply: UILabel!
    
    @IBOutlet weak var imgreceipt: UIImageView!

    @IBOutlet weak var downloadIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }

    @IBAction func btnContactClicked(_ sender: UIButton) {
        self.chatReceiverContactCellDelegate?.btnReceiverContactClicked(sender)
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
        self.vwcontainer1.backgroundColor = .clear
        self.vwcontainer2.backgroundColor = .clear
        self.vwcontainer3.backgroundColor = .clear
        self.Lbltime.backgroundColor = .clear
        self.lblContact.backgroundColor = .clear
        
        switch UserDefaultManager.getStringFromUserDefaults(key: kChatFontCurrentSize) {
        case kChatFontSizeSmall:
            self.Lbltime.font = kChatFont.withSize(kChatFontSmallForTime)
            self.lblNameReply.font = kChatFont.withSize(kChatFontSmallForNameReply)
            self.lblMessageReply.font = kChatFont.withSize(kChatFontSmallForMsgReply)
            self.lblContact.font = kChatFont.withSize(kChatFontSmallForMessage)
        case kChatFontSizeMedium:
            self.Lbltime.font = kChatFont.withSize(kChatFontMediumForTime)
            self.lblNameReply.font = kChatFont.withSize(kChatFontMediumForNameReply)
            self.lblMessageReply.font = kChatFont.withSize(kChatFontMediumForMsgReply)
            self.lblContact.font = kChatFont.withSize(kChatFontMediumForMessage)
        case kChatFontSizeLarge:
            self.Lbltime.font = kChatFont.withSize(kChatFontLargeForTime)
            self.lblNameReply.font = kChatFont.withSize(kChatFontLargeForNameReply)
            self.lblMessageReply.font = kChatFont.withSize(kChatFontLargeForMsgReply)
            self.lblContact.font = kChatFont.withSize(kChatFontLargeForMessage)
        default:
            break
        }
    }
    
}
