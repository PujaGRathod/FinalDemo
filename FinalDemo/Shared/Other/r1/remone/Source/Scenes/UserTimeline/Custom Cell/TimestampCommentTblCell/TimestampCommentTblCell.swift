//
//  TimestampCommentTblCell.swift
//  remone
//
//  Created by Arjav Lad on 28/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit

class TimestampCommentTblCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblConfirmed: UILabel!
    @IBOutlet weak var imgViewProfile: UIImageView!
    @IBOutlet weak var viewTimestampDetails: UIView!
    @IBOutlet weak var imgViewTimestamp: UIImageView!
    @IBOutlet weak var lblTimestamp: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnLocation: UIButton!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var conHeightLblConfirmed: NSLayoutConstraint!

    var comment: RMTimestampComment?
    var showLocation: ((RMTimestampComment?)-> Void)?
    var showUserProfile: ((RMTimestampComment?)-> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.imgViewProfile.layer.cornerRadius = 40 / 2
        self.imgViewProfile.clipsToBounds = true
        self.imgViewProfile.clipsToBounds = true
        self.imgViewProfile.layer.borderColor = #colorLiteral(red: 0.9254901961, green: 0.937254902, blue: 0.9450980392, alpha: 1)
        self.imgViewProfile.layer.borderWidth = 0.5

        self.btnLocation.imageView?.contentMode = .scaleAspectFit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(for timeStampComment: RMTimestampComment) {
        self.comment = timeStampComment
        self.lblConfirmed.text = ""
        self.conHeightLblConfirmed.constant = 0
        self.lblName.text = timeStampComment.user.name
        
        self.btnLocation.titleLabel?.numberOfLines = 1
        self.btnLocation.titleLabel?.lineBreakMode = .byTruncatingTail
        
        if let timeStamp = timeStampComment.userTimeStamp {
            self.viewTimestampDetails.isHidden = false
            self.btnLocation.setTitle(timeStamp.company.name, for: .normal)
            if timeStamp.company.locationType == .other {
                self.btnLocation.setTitleColor(.lightGray, for: .normal)
            } else {
                self.btnLocation.setTitleColor(APP_COLOR_THEME, for: .normal)
            }
            self.lblTimestamp.text = timeStamp.status?.text
            self.imgViewTimestamp.image = timeStamp.status?.miniIcon
            self.lblTimestamp.textColor = timeStamp.status?.color
            self.btnLocation.isHidden = false
        } else {
            self.viewTimestampDetails.isHidden = true
            self.btnLocation.isHidden = true
        }
        self.lblTime.text = timeStampComment.time.toString(format: .custom("HH:mm"))
        self.lblComment.text = timeStampComment.text
        self.imgViewProfile.sd_setImage(with: timeStampComment.user.profilePicture) { (image, _, _, _) in
            if let image = image {
                self.imgViewProfile.image = image
            } else {
                self.imgViewProfile.image = #imageLiteral(resourceName: "iconProfileUnselected")
            }
        }
        
        self.contentView.layoutIfNeeded()
    }
    
    @IBAction func onLocationTap(_ sender: UIButton) {
        self.showLocation?(self.comment)
    }

    @IBAction func onShowProfile(_ sender: UIButton) {
        self.showUserProfile?(self.comment)
    }

    
}
