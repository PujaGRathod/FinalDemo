//
//  GroupChatInitialCell.swift
//  WakeUppApp
//
//  Created by Admin on 19/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class GroupChatInitialCell: UITableViewCell {

    @IBOutlet weak var lblInitialMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //DEDUCTED 4 BECAUSE FONT SIZE WAS LARGER
        
        switch UserDefaultManager.getStringFromUserDefaults(key: kChatFontCurrentSize) {
        case kChatFontSizeSmall:
            self.lblInitialMessage.font = kChatFont.withSize(kChatFontSmallForMessage - 4)
        case kChatFontSizeMedium:
            self.lblInitialMessage.font = kChatFont.withSize(kChatFontMediumForMessage - 4)
        case kChatFontSizeLarge:
            self.lblInitialMessage.font = kChatFont.withSize(kChatFontLargeForMessage - 4)
        default:
            break
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupUI(){
        
    }

}
