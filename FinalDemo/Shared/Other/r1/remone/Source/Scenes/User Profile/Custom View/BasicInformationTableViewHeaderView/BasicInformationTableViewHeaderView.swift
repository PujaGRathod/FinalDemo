//
//  BasicInformationTableViewHeaderView.swift
//  remone
//
//  Created by Akshit Zaveri on 10/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

protocol BasicInformationTableViewHeaderViewDelegate {
    func editButtonTapped(for section: BasicInformationTableViewAdapter.Section)
}

class BasicInformationTableViewHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topLineView: UIView!
    
    private var section: BasicInformationTableViewAdapter.Section?
    var delegate: BasicInformationTableViewHeaderViewDelegate?
    
    func set(section: BasicInformationTableViewAdapter.Section) {
        self.section = section
        self.titleLabel.text = section.title
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        if let section = self.section {
            self.delegate?.editButtonTapped(for: section)
        }
    }

    func hideEdit(_ hide: Bool) {
        self.btnEdit.isHidden = hide
    }
    
    func showTopLine(_ show: Bool) {
        self.topLineView.isHidden = !show
    }
}
