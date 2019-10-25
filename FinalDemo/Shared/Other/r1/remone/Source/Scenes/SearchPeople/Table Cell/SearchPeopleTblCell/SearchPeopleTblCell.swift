//
//  SearchPeopleTblCell.swift
//  remone
//
//  Created by Arjav Lad on 02/02/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

protocol SearchPeopleTblCellDelegate {
    func openOfficeProfile(at index: IndexPath)
    func openUserProfile(at index: IndexPath)
    func showRattings(at index: IndexPath)
}

class SearchPeopleTblCell: UITableViewCell {

    @IBOutlet weak var btnConvergenceRattings: UIButton!
    @IBOutlet weak var viewSelectionIndicator: UIView!
    @IBOutlet weak var btnLocation: UIButton!
    @IBOutlet weak var lblTimeStampStatus: UILabel!
    @IBOutlet weak var imageViewTimeStamp: UIImageView!
    @IBOutlet weak var viewTimeStamp: UIView!
    @IBOutlet weak var lblInhouse: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imageViewProfile: UIImageView!

    var delegate: SearchPeopleTblCellDelegate?
    var indexPath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.imageViewProfile.layer.cornerRadius = 20
        self.imageViewProfile.clipsToBounds = true
        self.imageViewProfile.layer.borderColor = #colorLiteral(red: 0.9254901961, green: 0.937254902, blue: 0.9450980392, alpha: 1)
        self.imageViewProfile.layer.borderWidth = 0.5

        self.lblInhouse.layer.cornerRadius = 4
        self.lblInhouse.clipsToBounds = true
        self.lblInhouse.layer.borderColor = self.lblInhouse.textColor.cgColor
        self.lblInhouse.layer.borderWidth = 0.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    @IBAction func onCovergenceRattingsTap(_ sender: UIButton) {
        if let index = self.indexPath {
            self.delegate?.showRattings(at: index)
        }
    }

    func loadProfile(for userModel: SearchPeopleModel) {
        self.lblName.text = userModel.user.name
        self.lblInhouse.text = "In-house".localized
        if userModel.user.isInHouseMember {
            self.lblInhouse.isHidden = false
        } else {
            self.lblInhouse.isHidden = true
        }

        if let timeStamp = userModel.timestamp {
            self.loadTimeStampDetails(timeStamp)
        } else {
            self.viewTimeStamp.isHidden = true
            self.btnLocation.isHidden = true
        }

        self.imageViewProfile.sd_setImage(with: userModel.user.profilePicture) { (image, _, _, _) in
            if let image = image {
                self.imageViewProfile.image = image
            } else {
                self.imageViewProfile.image = #imageLiteral(resourceName: "iconProfileUnselected")
            }
        }

    }

    private func loadTimeStampDetails(_ timeStamp: RMTimestamp) {
        self.viewTimeStamp.isHidden = false
        self.btnLocation.isHidden = (timeStamp.status == TimeStampStatus.workFinish)

        self.btnLocation.imageView?.contentMode = .scaleAspectFit
        self.btnLocation.setImage(#imageLiteral(resourceName: "iconLocationPin"), for: .normal)

        self.imageViewTimeStamp.image = timeStamp.status?.miniIcon

        self.btnLocation.titleLabel?.numberOfLines = 1
        self.btnLocation.titleLabel?.lineBreakMode = .byTruncatingTail
        if timeStamp.company.locationType == .other {
            self.btnLocation.setTitleColor(.lightGray, for: .normal)
        } else {
            self.btnLocation.setTitleColor(APP_COLOR_THEME, for: .normal)
        }
        self.btnLocation.setTitle(timeStamp.company.name, for: .normal)

        self.lblTimeStampStatus.text = timeStamp.status?.text
        self.lblTimeStampStatus.textColor = timeStamp.status?.color
    }

    @IBAction func onViewProfileTap(_ sender: UIButton) {
        if let index = self.indexPath {
            self.delegate?.openUserProfile(at: index)
        }
    }

    @IBAction func onLocationTap(_ sender: UIButton) {
        if let index = self.indexPath {
            self.delegate?.openOfficeProfile(at: index)
        }
    }
}
