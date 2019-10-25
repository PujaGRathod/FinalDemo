//
//  FilterShowPartnerCell.swift
//  Remone_Office_Favorite
//
//  Created by Arjav Lad on 10/01/18.
//  Copyright © 2018 Arjav Lad. All rights reserved.
//

import UIKit

protocol FilterShowPartnerCellDelegate {
    func showPartner(_ show: Bool, at indexPath: IndexPath?)
}

class FilterShowPartnerCell: UITableViewCell {

    @IBOutlet weak var showPartner: UISwitch!

    var delegate: FilterShowPartnerCellDelegate?
    var indexpath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onShowPartner(_ sender: UISwitch) {
        self.delegate?.showPartner(sender.isOn, at: self.indexpath)
    }
}
