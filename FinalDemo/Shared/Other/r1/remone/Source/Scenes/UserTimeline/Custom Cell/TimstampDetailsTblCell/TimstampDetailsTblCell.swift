//
//  TimstampDetailsTblCell.swift
//  remone
//
//  Created by Arjav Lad on 28/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit
import SDWebImage


protocol TimstampDetailsTblCellDelegate {
    func like(timestamp: RMTimestamp?)
    func comment(timestamp: RMTimestamp?)
    func showOption(timestamp: RMTimestamp?)
    func showLocation(timestamp: RMTimestamp?)
    func showLikeDetails(timestamp: RMTimestamp?)
    func showUserProfile(timestamp: RMTimestamp?)
}

class TimstampDetailsTblCell: UITableViewCell {

    @IBOutlet weak var viewTimeStampStatus: UIView!
    @IBOutlet weak var btnLikeDetails: UIButton!
    @IBOutlet weak var viewLikeDetails: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblConfirmed: UILabel!
    @IBOutlet weak var imgViewProfile: UIImageView!
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

    var timeStamp: RMTimestamp?
    var delegate: TimstampDetailsTblCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imgViewProfile.layer.cornerRadius = 40 / 2
        self.imgViewProfile.clipsToBounds = true
        self.imgViewProfile.layer.borderColor = #colorLiteral(red: 0.9254901961, green: 0.937254902, blue: 0.9450980392, alpha: 1)
        self.imgViewProfile.layer.borderWidth = 0.5

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

        self.lblTimestampDetails.text = timeStamp.details
        self.btnLocation.titleLabel?.numberOfLines = 1
        self.btnLocation.titleLabel?.lineBreakMode = .byTruncatingTail
        self.lblName.text = timeStamp.user.name
        self.btnLocation.setTitle(timeStamp.company.name, for: .normal)
        if timeStamp.status != TimeStampStatus.workFinish {
            self.btnLocation.isHidden = false
            self.viewTimeStampStatus.isHidden = false
        } else {
            self.btnLocation.isHidden = true
            self.viewTimeStampStatus.isHidden = false
        }
        if timeStamp.company.locationType == .other {
            self.btnLocation.setTitleColor(.lightGray, for: .normal)
        } else {
            self.btnLocation.setTitleColor(APP_COLOR_THEME, for: .normal)
        }
        self.lblTimestamp.text = timeStamp.status?.text.localized
        self.imgViewTimestamp.image = timeStamp.status?.miniIcon
        self.lblTimestamp.textColor = timeStamp.status?.color
        self.lblTime.text = timeStamp.time.toString(format: .custom("HH:mm"))
        self.imgViewProfile.sd_setImage(with: timeStamp.user.profilePicture) { (image, _, _, _) in
            if let image = image {
                self.imgViewProfile.image = image
            } else {
                self.imgViewProfile.image =  #imageLiteral(resourceName: "iconProfileUnselected")
            }
        }
        if timeStamp.likeCountString != "" &&
            timeStamp.likeCountString != "0" {
            self.viewLikeDetails.isHidden = false
            self.btnLikeDetails.setTitle("\(timeStamp.likeCountString) \("How nice".localized)", for: .normal)
        } else {
            self.btnLikeDetails.setTitle("", for: .normal)
            self.viewLikeDetails.isHidden = true
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

    @IBAction func onLIkeDetailsTap(_ sender: UIButton) {
        self.delegate?.showLikeDetails(timestamp: self.timeStamp)
    }

    @IBAction func onShowProfile(_ sender: UIButton) {
        self.delegate?.showUserProfile(timestamp: self.timeStamp)
    }

}


