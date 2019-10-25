//
//  BasicInformationTblCell.swift
//  remone
//
//  Created by Akshit Zaveri on 10/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

class BasicInformationTblCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var bottomSeparatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(row: BasicInformationTableViewAdapter.Section.Row) {
        self.titleLabel.text = row.title
        self.valueLabel.text = row.value
    }

    func makeTitleBold(_ makeBold: Bool) {
        if makeBold {
            self.titleLabel.textColor = .black
        } else {
            self.titleLabel.textColor = #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
        }
    }

    func shouldShowBottomSeparator(_ show: Bool) {
        self.bottomSeparatorView.isHidden = !show
    }
}
