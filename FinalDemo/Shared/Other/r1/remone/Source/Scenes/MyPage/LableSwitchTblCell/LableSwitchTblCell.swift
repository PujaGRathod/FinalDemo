//
//  LableSwitchTblCell.swift
//  Remone_Office_Favorite
//
//  Created by Arjav Lad on 12/01/18.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit

protocol LableSwitchTblCellDelegate {
    func updateSettings(for indexPath: IndexPath, value: Bool)
}

class LableSwitchTblCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var onOffSwitch: UISwitch!

    var delegate: LableSwitchTblCellDelegate?
    var indexPath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    @IBAction func onOffAction(_ sender: UISwitch) {
        if let index = self.indexPath {
            self.delegate?.updateSettings(for: index, value: sender.isOn)
        }
    }

}
