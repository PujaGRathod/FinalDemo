//
//  OfficeReportTblCell.swift
//  remone
//
//  Created by Arjav Lad on 20/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

class OfficeReportTblCell: UITableViewCell {

    @IBOutlet weak var btnReport: UIButton!
    @IBOutlet weak var lblRemark: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btnReport.layer.cornerRadius = 4
        self.btnReport.clipsToBounds = true
        self.btnReport.layer.borderWidth = 1
        self.btnReport.layer.borderColor = self.btnReport.tintColor.cgColor

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
