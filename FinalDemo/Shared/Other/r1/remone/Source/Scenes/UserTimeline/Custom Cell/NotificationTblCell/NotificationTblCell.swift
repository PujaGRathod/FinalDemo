
//
//  NotificationTblCell.swift
//  remone
//
//  Created by Arjav Lad on 29/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit

class NotificationTblCell: UITableViewCell {

    @IBOutlet weak var imgViewNotificationIcon: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblNotificationtext: UILabel!
    @IBOutlet weak var imgViewProfile: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.imgViewProfile.layer.cornerRadius = 20
        self.imgViewProfile.clipsToBounds = true
        self.imgViewProfile.layer.borderColor = #colorLiteral(red: 0.9254901961, green: 0.937254902, blue: 0.9450980392, alpha: 1)
        self.imgViewProfile.layer.borderWidth = 0.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func loadNotification(_ notification: NotificationModel) {
        if notification.isRead {
            self.contentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        } else {
            self.contentView.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9450980392, blue: 0.9607843137, alpha: 1)
        }
        if let icon = notification.type.icon {
            self.imgViewNotificationIcon.isHidden = false
            self.imgViewNotificationIcon.image = icon
        } else {
            self.imgViewNotificationIcon.image = nil
            self.imgViewNotificationIcon.isHidden = true
        }
        self.imgViewProfile.sd_setImage(with: notification.profilePic, placeholderImage: #imageLiteral(resourceName: "ic_userprofile_56pt")) { (image, _, _, _) in
            self.imgViewProfile.image = image ?? #imageLiteral(resourceName: "ic_userprofile_56pt")
        }
        self.lblNotificationtext.text = notification.title
        self.lblTime.text = notification.time?.toStringWithRelativeTime()
    }
    
}
