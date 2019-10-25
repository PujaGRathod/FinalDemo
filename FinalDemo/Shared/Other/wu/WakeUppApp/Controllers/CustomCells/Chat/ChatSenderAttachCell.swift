//
//  ChatSenderAttachCell.swift
//  LetsTalk
//
//  Created by Admin on 03/02/18.
//  Copyright © 2018 Vishwkarma. All rights reserved.
//

import UIKit

protocol ChatSenderAttachCellDelegate:class
{
    func btnZoomClicked(_ sender: UIButton)
}

class ChatSenderAttachCell: UITableViewCell
{
    weak var chatSenderAttachCellDelegate: ChatSenderAttachCellDelegate?
    @IBOutlet weak var vwcontainer: UIView!
    @IBOutlet var btnAttach: UIButton!
    @IBOutlet weak var lbltime: UILabel!
    @IBOutlet weak var imgreceived: UIImageView!
    @IBOutlet weak var imgBlurImage_Received: UIImageView!
    @IBOutlet weak var imgPlayVideo: UIImageView!
    
    @IBOutlet weak var heightReplyView: NSLayoutConstraint!
    @IBOutlet weak var lblNameReply: UILabel!
    @IBOutlet weak var lblMessageReply: UILabel!
    
    @IBOutlet weak var imgBubble: UIImageView!
    
    @IBOutlet weak var vwDownload: UIView!
    @IBOutlet weak var heightOfvwDownload: NSLayoutConstraint!
    
    @IBOutlet weak var lblDownload: UILabel!
    @IBOutlet weak var downloadIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var imgloaderbg: UIImageView!
    @IBOutlet weak var lblprogress: UILabel!
    @IBOutlet weak var vwloader: RPCircularProgress!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    @IBAction func btnZoomClicked(_ sender: UIButton) {
        self.chatSenderAttachCellDelegate?.btnZoomClicked(sender)
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
        self.imgreceived.backgroundColor = .clear
        
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
    
    func updateDisplay(progress: Float, totalSize : String)
    {
        // progressView.progress = progress
        //        if progress > 0.01 && progress < 0.06
        //        {
        self.imgloaderbg.isHidden = true
        self.lblDownload.text = ""
        self.vwloader.isHidden = false
        // self.vwloader.updateProgress(0.0, initialDelay: 0.6, duration: 4)
        //        }
        
        print(String(format: "Downloaddinngngg ------ %.1f%% of %@", progress * 100, totalSize))
        self.lblprogress.text = String(format: "%.0f%%", progress * 100)
        self.vwloader.updateProgress(CGFloat(progress))
        
    }

}
