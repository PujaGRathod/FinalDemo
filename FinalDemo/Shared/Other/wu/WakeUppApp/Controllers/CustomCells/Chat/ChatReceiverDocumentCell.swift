//
//  ChatReceiverDocumentCell.swift
//  HelpMe
//
//  Created by Admin on 06/04/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

protocol ChatReceiverDocumentCellDelegate:class
{
    func btnDocZoomMineClicked(_ sender: UIButton)
}

class ChatReceiverDocumentCell: UITableViewCell {
 
    weak var chatReceiverDocumentCellDelegate: ChatReceiverDocumentCellDelegate?
    
    @IBOutlet var vwcontainer1: UIView!
    @IBOutlet var vwcontainer2: UIView!
    @IBOutlet var vwcontainer3: UIView!
    
    @IBOutlet var imgbubble: UIImageView!
    @IBOutlet weak var lbltime: UILabel!
    @IBOutlet weak var imgsent: UIImageView!
    @IBOutlet var btnReceiverDocument: UIButton!
    @IBOutlet weak var lblFileType:UILabel!

    @IBOutlet weak var heightReplyView: NSLayoutConstraint!
    @IBOutlet weak var lblNameReply: UILabel!
    @IBOutlet weak var lblMessageReply: UILabel!
    
    @IBOutlet weak var imgreceipt: UIImageView!

    @IBOutlet weak var downloadIndicator: UIActivityIndicatorView!
    
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
        self.vwcontainer1.backgroundColor = .clear
        self.vwcontainer2.backgroundColor = .clear
        self.vwcontainer3.backgroundColor = .clear
        self.lbltime.backgroundColor = .clear
        self.lblFileType.backgroundColor = .clear
        
        switch UserDefaultManager.getStringFromUserDefaults(key: kChatFontCurrentSize) {
        case kChatFontSizeSmall:
            self.lbltime.font = kChatFont.withSize(kChatFontSmallForTime)
            self.lblNameReply.font = kChatFont.withSize(kChatFontSmallForNameReply)
            self.lblMessageReply.font = kChatFont.withSize(kChatFontSmallForMsgReply)
            self.lblFileType.font = kChatFont.withSize(kChatFontSmallForMessage)
        case kChatFontSizeMedium:
            self.lbltime.font = kChatFont.withSize(kChatFontMediumForTime)
            self.lblNameReply.font = kChatFont.withSize(kChatFontMediumForNameReply)
            self.lblMessageReply.font = kChatFont.withSize(kChatFontMediumForMsgReply)
            self.lblFileType.font = kChatFont.withSize(kChatFontMediumForMessage)
        case kChatFontSizeLarge:
            self.lbltime.font = kChatFont.withSize(kChatFontLargeForTime)
            self.lblNameReply.font = kChatFont.withSize(kChatFontLargeForNameReply)
            self.lblMessageReply.font = kChatFont.withSize(kChatFontLargeForMsgReply)
            self.lblFileType.font = kChatFont.withSize(kChatFontLargeForMessage)
        default:
            break
        }
    }
    
    @IBAction func btnZoomMineClicked(_ sender: UIButton) {
        self.chatReceiverDocumentCellDelegate?.btnDocZoomMineClicked(sender)
    }
    
}
