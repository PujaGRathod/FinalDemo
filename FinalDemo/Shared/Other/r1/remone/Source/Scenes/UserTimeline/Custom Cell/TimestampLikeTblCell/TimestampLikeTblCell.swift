//
//  TimestampLikeTblCell.swift
//  remone
//
//  Created by Arjav Lad on 28/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit

protocol TimestampLikeTblCellDelegate {
    func followUser(at index: Int?)
}

class TimestampLikeTblCell: UITableViewCell {

    @IBOutlet weak var btnFollow: RMFollowButton!
    @IBOutlet weak var lblSameCompany: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imageViewProfile: UIImageView!

    var delegate: TimestampLikeTblCellDelegate?
    var index: Int?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lblSameCompany.layer.cornerRadius = 4
        self.lblSameCompany.clipsToBounds = true
        let color = #colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1)
        self.lblSameCompany.layer.borderColor = color.cgColor
        self.lblSameCompany.layer.borderWidth = 0.5


        self.imageViewProfile.layer.borderColor = #colorLiteral(red: 0.9254901961, green: 0.937254902, blue: 0.9450980392, alpha: 1)
        self.imageViewProfile.layer.borderWidth = 0.5
        self.imageViewProfile.layer.cornerRadius = 20
        self.imageViewProfile.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func loadUser(_ user: RMUser) {
        self.lblSameCompany.isHidden = !user.isInHouseMember
        self.lblSameCompany.text = "In-house".localized
        if user.isCurrentUser() {
            self.btnFollow.apply(theme: RMFollowButtonThemeUnknown())
        } else {
            self.btnFollow.apply(theme: user.followStatus.getTheme)
        }
        self.lblName.text = user.name
        self.selectionStyle = .default
        self.imageViewProfile.sd_setImage(with: user.profilePicture, completed: { (image, _, _, _) in
            if let image = image {
                self.imageViewProfile.image = image
            } else {
                self.imageViewProfile.image = #imageLiteral(resourceName: "iconProfileUnselected")
            }
        })
    }
    
    @IBAction func onFollowTap(_ sender: UIButton) {
        self.delegate?.followUser(at: self.index)
    }
}
