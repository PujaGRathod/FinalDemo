//
//  OfficeUsersTblCell.swift
//  remone
//
//  Created by Arjav Lad on 19/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

protocol OfficeUsersTblCellDelegate {
    func showMoreUsers()
    func followUser(at index: Int?)
    func openProfile(at index: Int?)
}

class OfficeUsersTblCell: UITableViewCell {

    @IBOutlet weak var lblNoUsers: UILabel!
    @IBOutlet weak var btnShowMore: UIButton!
    @IBOutlet weak var viewProfile: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblInHouse: UILabel!
    @IBOutlet weak var btnFollow: RMFollowButton!
    @IBOutlet weak var imageViewProfile: UIImageView!

    var index: Int? = nil
    var delegate: OfficeUsersTblCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imageViewProfile.layer.cornerRadius = 20
        self.imageViewProfile.clipsToBounds = true
        self.imageViewProfile.layer.borderColor = #colorLiteral(red: 0.9254901961, green: 0.937254902, blue: 0.9450980392, alpha: 1)
        self.imageViewProfile.layer.borderWidth = 0.5

        self.lblInHouse.layer.cornerRadius = 4
        self.lblInHouse.clipsToBounds = true
        self.lblInHouse.layer.borderColor = self.lblInHouse.textColor.cgColor
        self.lblInHouse.layer.borderWidth = 0.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func loadProfile(for user: RMUser) {
        self.lblName.text = user.name
        self.lblInHouse.text = "In-house".localized
        if user.isInHouseMember {
            self.lblInHouse.isHidden = false
        } else {
            self.lblInHouse.isHidden = true
        }

        if user.isCurrentUser() {
            self.btnFollow.apply(theme: RMFollowButtonThemeUnknown())
        } else {
            self.btnFollow.apply(theme: user.followStatus.getTheme)
        }
        self.imageViewProfile.sd_setImage(with: user.profilePicture) { (image, _, _, _) in
            if let image = image {
                self.imageViewProfile.image = image
            } else {
                self.imageViewProfile.image = #imageLiteral(resourceName: "iconProfileUnselected")
            }
        }
        
    }

    @IBAction func openUserProfile(_ sender: UIButton) {
        self.delegate?.openProfile(at: self.index)
    }

    @IBAction func onFollowTap(_ sender: UIButton) {
        self.delegate?.followUser(at: self.index)
    }

    @IBAction func onShowMoreTap(_ sender: UIButton) {
        self.delegate?.showMoreUsers()
    }

}
