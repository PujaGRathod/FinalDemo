//
//  ChatReceiverAudioCell.swift
//  WakeUppApp
//
//  Created by Admin on 01/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

protocol ChatReceiverAudioCellDelegate:class
{
    func btnPlayAudioMineClicked(_ sender: UIButton)
}

class ChatReceiverAudioCell: UITableViewCell {

    weak var chatReceiverAudioCellDelegate: ChatReceiverAudioCellDelegate?
    
    @IBOutlet var vwcontainer1: UIView!
    @IBOutlet var vwcontainer2: UIView!
    @IBOutlet var vwcontainer3: UIView!
    
    @IBOutlet var imgbubble: UIImageView!
    @IBOutlet weak var btnPlay : UIButton!
    @IBOutlet weak var audioSlider : UISlider!
    @IBOutlet weak var lbltime: UILabel!
    @IBOutlet weak var imgUser : UIImageView!
    @IBOutlet var imgreadicon: UIImageView!
    @IBOutlet var widthImgUser: NSLayoutConstraint!

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
    }
    
    @IBAction func btnPlayMineClicked(_ sender: UIButton) {
        self.chatReceiverAudioCellDelegate?.btnPlayAudioMineClicked(sender)
    }
    
}
