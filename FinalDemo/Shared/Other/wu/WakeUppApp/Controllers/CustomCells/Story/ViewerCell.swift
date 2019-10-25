//
//  ViewerCell.swift
//  WakeUppApp
//
//  Created by Payal Umraliya on 22/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class ViewerCell: UITableViewCell
{
    @IBOutlet var imgprofile: UIImageView!
    @IBOutlet var lblname: UILabel!
    @IBOutlet var lbltime: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

