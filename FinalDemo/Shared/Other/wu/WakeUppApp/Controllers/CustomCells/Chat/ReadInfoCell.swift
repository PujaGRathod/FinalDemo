//
//  ReadInfoCell.swift
//  WakeUppApp
//
//  Created by Payal Umraliya on 25/06/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class ReadInfoCell: UITableViewCell {

    @IBOutlet var imgpic: UIImageView!
    @IBOutlet var lblname: UILabel!
    @IBOutlet var lblreadtime: UILabel!
    @IBOutlet var lblreceivetime: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
