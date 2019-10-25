//
//  ChatReceiverAttachCell.swift
//  LetsTalk
//
//  Created by Admin on 03/02/18.
//  Copyright © 2018 Vishwkarma. All rights reserved.
//

import UIKit
protocol ChatReceiverAttachCellDelegate:class
{
    func btnZoomMineClicked(_ sender: UIButton)
}

class ChatReceiverAttachCell: UITableViewCell
{
    weak var chatReceiverAttachCellDelegate: ChatReceiverAttachCellDelegate?
    
    @IBOutlet weak var vwcontainer: UIView!
    @IBOutlet weak var lbltime: UILabel!
    @IBOutlet weak var imgsent: UIImageView!
    @IBOutlet weak var imgBlurImage_Send: UIImageView!
    
    @IBOutlet weak var imgPlayVideo: UIImageView!
    @IBOutlet var btnAttach: UIButton!
    
    @IBOutlet weak var imgreceipt: UIImageView!
    
    @IBOutlet weak var heightReplyView: NSLayoutConstraint!
    @IBOutlet weak var lblNameReply: UILabel!
    @IBOutlet weak var lblMessageReply: UILabel!
    
    @IBOutlet weak var imgBubble: UIImageView!
    
    @IBOutlet weak var vwDownload: UIView!
    @IBOutlet weak var heightOfvwDownload: NSLayoutConstraint!
    
    @IBOutlet weak var lblDownload: UILabel!
    @IBOutlet weak var downloadIndicator: UIActivityIndicatorView!
    
    //cell.Lbltime.text
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    @IBAction func btnZoomMineClicked(_ sender: UIButton) {
        self.chatReceiverAttachCellDelegate?.btnZoomMineClicked(sender)
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
        self.imgPlayVideo.backgroundColor = .clear
        self.btnAttach.backgroundColor = .clear
        self.imgsent.backgroundColor = .clear
        
        switch UserDefaultManager.getStringFromUserDefaults(key: kChatFontCurrentSize) {
        case kChatFontSizeSmall:
            self.lbltime.font = kChatFont.withSize(kChatFontSmallForTime)
            self.lblNameReply.font = kChatFont.withSize(kChatFontSmallForNameReply)
            self.lblMessageReply.font = kChatFont.withSize(kChatFontSmallForMsgReply)
        case kChatFontSizeMedium:
            self.lbltime.font = kChatFont.withSize(kChatFontMediumForTime)
            self.lblNameReply.font = kChatFont.withSize(kChatFontMediumForNameReply)
            self.lblMessageReply.font = kChatFont.withSize(kChatFontMediumForMsgReply)
        case kChatFontSizeLarge:
            self.lbltime.font = kChatFont.withSize(kChatFontLargeForTime)
            self.lblNameReply.font = kChatFont.withSize(kChatFontLargeForNameReply)
            self.lblMessageReply.font = kChatFont.withSize(kChatFontLargeForMsgReply)
        default:
            break
        }
    }
    
    func updateDisplay(progress: Float, totalSize : String) {
        // progressView.progress = progress
        print(String(format: "Downloaddinngngg ------ %.1f%% of %@", progress * 100, totalSize))
        
        if(totalSize != "upload") {
            self.lblDownload.text = String(format: "%.1f%%", progress * 100)
        }
        else {
            self.lblDownload.text = String(format: "%.1f%%", progress)
        }
    }
}
