//
//  SearchPeopleMarkerView.swift
//  remone
//
//  Created by Arjav Lad on 06/02/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

class SearchPeopleMarkerView: UIView {

    var selected: Bool = false {
        didSet {
            if self.selected {
                self.imageViewBackground.image = #imageLiteral(resourceName: "iconSearchPeoplePinSelected")
            } else {
                self.imageViewBackground.image = #imageLiteral(resourceName: "iconSearchPeoplePin")
            }
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    private let imageViewBackground: UIImageView
    private let imageViewProfile: UIImageView

    init(with profileURL: URL?) {
        let frame = CGRect.init(x: 0, y: 0, width: 64, height: 72)
        self.imageViewBackground = UIImageView.init(frame: frame)
        self.imageViewProfile = UIImageView.init(frame: CGRect.init(x: 7, y: 7, width: 50, height: 50))
        super.init(frame: frame)
        self.frame = frame
        self.imageViewBackground.contentMode = .scaleAspectFill
        self.imageViewProfile.contentMode = .scaleAspectFill
        self.imageViewProfile.clipsToBounds = true
        self.imageViewProfile.layer.masksToBounds = true
        self.imageViewProfile.layer.cornerRadius = 50 / 2
        self.imageViewProfile.image = #imageLiteral(resourceName: "ic_userprofile_56pt")
        self.addSubview(self.imageViewBackground)
        self.addSubview(self.imageViewProfile)
//        self.loadprofileImage(with: profileURL)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadprofileImage(with imageURL: URL?, _ completion: @escaping ()-> Void) {
//        self.imageViewProfile.image = #imageLiteral(resourceName: "iconAdd")
        self.imageViewProfile.sd_setImage(with: imageURL, placeholderImage: #imageLiteral(resourceName: "ic_userprofile_56pt")) { (image, _, _, _) in
            DispatchQueue.main.async {
                if let image = image {
                    self.imageViewProfile.image = image
                } else {
                    self.imageViewProfile.image = #imageLiteral(resourceName: "ic_userprofile_56pt")
                }
                completion()
            }
        }
    }
}
