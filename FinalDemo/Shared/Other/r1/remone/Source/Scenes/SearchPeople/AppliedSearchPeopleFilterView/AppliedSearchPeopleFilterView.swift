//
//  AppliedSearchPeopleFilterView.swift
//  remone
//
//  Created by Arjav Lad on 05/02/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

protocol AppliedSearchPeopleFilterViewDelegate {
    func clearFilter()
    func updateHeight(_ height: CGFloat)
}

class AppliedSearchPeopleFilterView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var lblFilterText: UILabel!
    @IBOutlet weak var btnClose: UIButton!

    var delegate: AppliedSearchPeopleFilterViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nibSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.nibSetup()
    }

    func reset() {
        self.lblFilterText.text = ""

    }


    func show(with filter: SearchPeopleFilter) {
        self.reset()

        let text = filter.displayText()
        self.lblFilterText.text = text

        var height = self.lblFilterText.height(withConstrainedWidth: self.frame.size.width - 76) + 20
        if height < 44 {
            height = 44
        }
        self.delegate?.updateHeight(height)

        self.isHidden = false
        UIView.animate(withDuration: 0.27, delay: 0, options: .curveEaseOut, animations: {
            self.alpha = 1
        }) { (finished) in

        }
    }

    private func nibSetup() {
//        self.backgroundColor = .clear
        Bundle.main.loadNibNamed("AppliedSearchPeopleFilterView", owner: self, options: nil)
        self.contentView.bounds = self.bounds
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        print(self.lblFilterText)
        self.addSubview(self.contentView)
    }

    func hide() {
        UIView.animate(withDuration: 0.27, delay: 0, options: .curveEaseOut, animations: {
            self.alpha = 0
        }) { (finished) in
            self.isHidden = true
        }
    }

    @IBAction func onCloseTap(_ sender: UIButton) {
        self.delegate?.clearFilter()
        self.hide()
    }

}
