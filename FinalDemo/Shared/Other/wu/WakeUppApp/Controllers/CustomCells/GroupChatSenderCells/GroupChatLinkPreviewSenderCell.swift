//
//  GroupChatLinkPreviewSenderCell.swift
//  WakeUppApp
//
//  Created by Admin on 20/07/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

protocol GroupChatLinkPreviewSenderCellDelegate:class
{
    func btnLinkClicked(_ sender: UIButton)
}

class GroupChatLinkPreviewSenderCell: UITableViewCell {

    weak var groupChatLinkPreviewSenderCellDelegate: GroupChatLinkPreviewSenderCellDelegate?
    
    @IBOutlet var vwcontainer: UIView!
    @IBOutlet weak var lblmsg: UILabel!
    @IBOutlet var imgbubble: UIImageView!
    @IBOutlet var imgreadicon: UIImageView!
    @IBOutlet weak var lbltime: UILabel!
    @IBOutlet weak var lblSender: UILabel!
    @IBOutlet weak var btnSender_LinkMess : UIButton!
    
    @IBOutlet weak var heightReplyView: NSLayoutConstraint!
    @IBOutlet weak var lblNameReply: UILabel!
    @IBOutlet weak var lblMessageReply: UILabel!
    
    @IBOutlet weak var imgLinkPreview: UIImageView!
    @IBOutlet weak var widthImgLinkPreview: NSLayoutConstraint!
    @IBOutlet weak var lblLinkTitle: UILabel!
    @IBOutlet weak var lblLinkDescription: UILabel!
    @IBOutlet weak var lblLinkUrl: UILabel!
    @IBOutlet weak var btnLink: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    @IBAction func btnLinkClicked(_ sender: Any) {
        self.groupChatLinkPreviewSenderCellDelegate?.btnLinkClicked(sender as! UIButton)
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
        
        self.imgLinkPreview.backgroundColor = .clear
        self.lblLinkTitle.backgroundColor = .clear
        self.lblLinkDescription.backgroundColor = .clear
        self.lblLinkUrl.backgroundColor = .clear
        //self.imgreceipt.backgroundColor = .clear
        
        switch UserDefaultManager.getStringFromUserDefaults(key: kChatFontCurrentSize) {
        case kChatFontSizeSmall:
            self.lbltime.font = kChatFont.withSize(kChatFontSmallForTime)
            self.lblSender.font = kChatFont.withSize(kGroupChatFontSmallForSenderName)
            self.lblNameReply.font = kChatFont.withSize(kChatFontSmallForNameReply)
            self.lblMessageReply.font = kChatFont.withSize(kChatFontSmallForMsgReply)
            self.lblmsg.font = kChatFont.withSize(kChatFontSmallForMessage)
            
            self.lblLinkTitle.font = kChatFont.withSize(kChatFontSmallForLinkTitle)
            self.lblLinkDescription.font = kChatFont.withSize(kChatFontSmallForLinkDetails)
            self.lblLinkUrl.font = kChatFont.withSize(kChatFontSmallForLinkDetails)
        case kChatFontSizeMedium:
            self.lbltime.font = kChatFont.withSize(kChatFontMediumForTime)
            self.lblSender.font = kChatFont.withSize(kGroupChatFontMediumForSenderName)
            self.lblNameReply.font = kChatFont.withSize(kChatFontMediumForNameReply)
            self.lblMessageReply.font = kChatFont.withSize(kChatFontMediumForMsgReply)
            self.lblmsg.font = kChatFont.withSize(kChatFontMediumForMessage)
            
            self.lblLinkTitle.font = kChatFont.withSize(kChatFontMediumForLinkTitle)
            self.lblLinkDescription.font = kChatFont.withSize(kChatFontMediumForLinkDetails)
            self.lblLinkUrl.font = kChatFont.withSize(kChatFontMediumForLinkDetails)
        case kChatFontSizeLarge:
            self.lbltime.font = kChatFont.withSize(kChatFontLargeForTime)
            self.lblSender.font = kChatFont.withSize(kGroupChatFontLargeForSenderName)
            self.lblNameReply.font = kChatFont.withSize(kChatFontLargeForNameReply)
            self.lblMessageReply.font = kChatFont.withSize(kChatFontLargeForMsgReply)
            self.lblmsg.font = kChatFont.withSize(kChatFontLargeForMessage)
            
            self.lblLinkTitle.font = kChatFont.withSize(kChatFontLargeForLinkTitle)
            self.lblLinkDescription.font = kChatFont.withSize(kChatFontLargeForLinkDetails)
            self.lblLinkUrl.font = kChatFont.withSize(kChatFontLargeForLinkDetails)
        default:
            break
        }
    }
    
}
