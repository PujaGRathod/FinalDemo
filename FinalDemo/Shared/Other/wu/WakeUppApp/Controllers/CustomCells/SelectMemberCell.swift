//
//  SelectMemberCell.swift
//  WakeUppApp
//
//  Created by Admin on 14/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class SelectMemberCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblBio: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
