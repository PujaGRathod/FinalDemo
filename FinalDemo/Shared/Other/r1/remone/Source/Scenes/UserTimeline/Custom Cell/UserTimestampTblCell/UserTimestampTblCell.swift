//
//  UserTimestampTblCell.swift
//  remone
//
//  Created by Arjav Lad on 27/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit
import SDWebImage

protocol UserTimestampTblCellDelegate {
    func like(timestamp: RMTimestamp?)
    func comment(timestamp: RMTimestamp?)
    func showOption(timestamp: RMTimestamp?)
    func showLocation(timestamp: RMTimestamp?)
    func showUserProfile(timestamp: RMTimestamp?)
}

class UserTimestampTblCell: UITableViewCell {

    @IBOutlet weak var btnShowProfile: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblConfirmed: UILabel!
    @IBOutlet weak var imgViewProfile: UIImageView!
    @IBOutlet weak var viewTimeStampStatus: UIView!
    @IBOutlet weak var viewTimestampDetails: UIView!
    @IBOutlet weak var imgViewTimestamp: UIImageView!
    @IBOutlet weak var lblTimestamp: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnOptions: UIButton!
    @IBOutlet weak var btnLocation: UIButton!
    @IBOutlet weak var lblTimestampDetails: UILabel!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var viewSep: UIView!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnComment: UIButton!
//    @IBOutlet weak var conHeightLblConfirmed: NSLayoutConstraint!
    @IBOutlet weak var conTopViewBottom: NSLayoutConstraint!

    var timeStamp: RMTimestamp?
    var delegate: UserTimestampTblCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.imgViewProfile.layer.borderColor = #colorLiteral(red: 0.9254901961, green: 0.937254902, blue: 0.9450980392, alpha: 1)
        self.imgViewProfile.layer.borderWidth = 0.5
        self.imgViewProfile.layer.cornerRadius = 40 / 2
        self.imgViewProfile.clipsToBounds = true

        let buttons = [self.btnLike, self.btnComment, self.btnOptions, self.btnLocation]
        for btn in buttons {
            btn?.imageView?.contentMode = .scaleAspectFit
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(for timeStamp: RMTimestamp) {
        self.timeStamp = timeStamp

        // Show / Hide Confirmed text
        let text = timeStamp.getConfirmedText()
        if text != "" {
            self.lblConfirmed.isHidden = false
            self.lblConfirmed.text = text
//            self.conHeightLblConfirmed.constant = 20
        } else {
            self.lblConfirmed.isHidden = true
            self.lblConfirmed.text = ""
//            self.conHeightLblConfirmed.constant = 0
        }
        if timeStamp.status != TimeStampStatus.workFinish {
            self.btnLocation.isHidden = false
            self.viewTimeStampStatus.isHidden = false
        } else {
            self.btnLocation.isHidden = true
            self.viewTimeStampStatus.isHidden = true
        }
        self.lblTimestampDetails.text = timeStamp.details
        self.btnLocation.titleLabel?.numberOfLines = 1
        self.btnLocation.titleLabel?.lineBreakMode = .byTruncatingTail
        self.lblName.text = timeStamp.user.name
        self.btnLocation.setTitle(timeStamp.company.name, for: .normal)
        if timeStamp.company.locationType == .other {
            self.btnLocation.setTitleColor(.lightGray, for: .normal)
        } else {
            self.btnLocation.setTitleColor(APP_COLOR_THEME, for: .normal)
        }
        self.lblTimestamp.text = timeStamp.status?.text
        self.imgViewTimestamp.image = timeStamp.status?.miniIcon
        self.lblTimestamp.textColor = timeStamp.status?.color
        self.lblTime.text = timeStamp.time.toString(format: .custom("HH:mm"))
        self.imgViewProfile.sd_setImage(with: timeStamp.user.profilePicture) { (image, _, _, _) in
            if let image = image {
                self.imgViewProfile.image = image
            } else {
                self.imgViewProfile.image = #imageLiteral(resourceName: "iconProfileUnselected")
            }
        }
        self.btnLike.isSelected = timeStamp.isLiked
        self.btnLike.setTitle("\(timeStamp.likeCountString)", for: .normal)
        self.btnLike.setTitle("\(timeStamp.likeCountString)", for: .selected)
        self.btnComment.setTitle("\(timeStamp.commentCountString)", for: .normal)
//        self.contentView.layoutIfNeeded()
    }

    @IBAction func onCommentTap(_ sender: UIButton) {
        self.delegate?.comment(timestamp: self.timeStamp)
    }

    @IBAction func onLikeTap(_ sender: UIButton) {
        self.delegate?.like(timestamp: self.timeStamp)
    }
    
    @IBAction func onOptionsTap(_ sender: UIButton) {
        self.delegate?.showOption(timestamp: self.timeStamp)
    }

    @IBAction func onLocationTap(_ sender: UIButton) {
        self.delegate?.showLocation(timestamp: self.timeStamp)
    }

    @IBAction func onShowProfile(_ sender: UIButton) {
        self.delegate?.showUserProfile(timestamp: self.timeStamp)
    }

}
