//
//  TwitterProfileHeaderView.swift
//  TwitterProfileViewController
//
//  Created by Roy Tang on 1/10/2016.
//  Copyright © 2016 NA. All rights reserved.
//

import Foundation
import UIKit

protocol RMUserInfoViewDelegate {
    func openOfficeProfile(for id: String)
}

class TwitterProfileHeaderView: UIView {

    var onFollowTap: (()->Void)?

    @IBOutlet weak var lblInHouse: UILabel!
    @IBOutlet weak var btnLocation: UIButton!
    @IBOutlet weak var lblTimeStamp: UILabel!
    @IBOutlet weak var viewTimeStamp: UIView!
    @IBOutlet weak var imgViewTimeStamp: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var btnFollowing: RMFollowButton!
    @IBOutlet private weak var coverImageView: RMUserCoverImageView!
    @IBOutlet private weak var userProfileImageView: RMUserProfileImageView!
    @IBOutlet private weak var userInfoView: RMUserInfoView!

    var delegate: RMUserInfoViewDelegate?
    var timeStamp: RMTimestamp?

    @IBAction func onFollowTap(_ sender: RMFollowButton) {
        self.onFollowTap?()
    }

    @IBAction func onLocationTap(_ sender: UIButton) {
        if let timestamp = self.timeStamp {
            if timestamp.company.locationType != .other {
                self.delegate?.openOfficeProfile(for: timestamp.company.id)
            }
        }
    }

    func setCoverImage(url: URL?) {
        self.coverImageView.set(url: url)
    }
    
    func setProfileImage(url: URL?) {
        self.userProfileImageView.set(url: url)
    }
     
    func isFromTeam(_ isFromTeam: Bool) {
        self.userInfoView.isFromTeam(isFromTeam)
    }

//    func set(name: String) {
//        self.userInfoView.set(name: name)
//        self.lblUserName.text = name
//    }

    func set(user: RMUser) {
        self.lblUserName.text = user.name
        self.lblInHouse.layer.cornerRadius = 4
        self.lblInHouse.clipsToBounds = true
        self.lblInHouse.layer.borderColor = self.lblInHouse.textColor.cgColor
        self.lblInHouse.layer.borderWidth = 0.5
        self.lblInHouse.text = "In-house".localized
        if user.isInHouseMember {
            self.lblInHouse.isHidden = false
        } else {
            self.lblInHouse.isHidden = true
        }
    }

    func set(timestamp: RMTimestamp?) {

        self.timeStamp = timestamp
        self.btnLocation.imageView?.contentMode = .scaleAspectFit
        if let timestamp = timestamp {
            if let status = timestamp.status,
                status == .workFinish {
                self.viewTimeStamp.isHidden = true
                self.btnLocation.isHidden = true
            } else {
                self.btnLocation.isHidden = false
                self.viewTimeStamp.isHidden = false
                self.lblTimeStamp.text = timestamp.status?.displayText
                self.imgViewTimeStamp.image = timestamp.status?.miniIcon
            }
            self.btnLocation.setTitle(timestamp.company.name, for: .normal)
            if timestamp.company.locationType == .other {
                self.btnLocation.setTitleColor(.lightGray, for: .normal)
            } else {
                self.btnLocation.setTitleColor(APP_COLOR_THEME, for: .normal)
            }
        } else {
            self.viewTimeStamp.isHidden = true
            self.btnLocation.isHidden = true
        }
//        self.userInfoView.set(timestamp: timestamp, user: user)
    }
    
    func set(delegate: RMUserInfoViewDelegate?) {
        self.delegate = delegate
//        self.userInfoView.delegate = delegate
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let height = self.lblUserName.height(withConstrainedWidth: size.width - 179)
        return CGSize(width: size.width, height: height + 210)
//        return CGSize(width: size.width, height: 228)
    }
}
