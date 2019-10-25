//
//  UserListCell.swift
//  Remone_Office_Favorite
//
//  Created by Arjav Lad on 11/01/18.
//  Copyright © 2018 Arjav Lad. All rights reserved.
//

import UIKit

protocol UserListCellDelegate {
    func followUser()
}

class UserListCell: UITableViewCell {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnFollow: RMFollowButton!
    @IBOutlet weak var btnInCompany: UIButton!

    var delegate: UserListCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        // Initialization code
    }
    
    func setupUI() {
        self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.width/2
        self.imgProfile.layer.masksToBounds = true
        
        self.btnInCompany.layer.cornerRadius = 4.0
        self.btnInCompany.layer.borderWidth = 0.5
        self.btnInCompany.layer.borderColor = UIColor(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1).cgColor
        self.btnInCompany.layer.masksToBounds = true
        self.btnFollow.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onFollowClick(_ sender: UIButton) {
        self.delegate?.followUser()
    }

}
