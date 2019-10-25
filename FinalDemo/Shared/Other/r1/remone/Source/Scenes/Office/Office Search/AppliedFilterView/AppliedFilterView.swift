//
//  AppliedFilterView.swift
//  remone
//
//  Created by Arjav Lad on 12/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

protocol AppliedFilterViewDelegate {
    func clearFilter()
}

class AppliedFilterView: UIView {

    @IBOutlet var contentView: UIView!

    @IBOutlet weak var stackViewEquipments: UIStackView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblFilter: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!

    var delegate: AppliedFilterViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nibSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.nibSetup()
    }

    func reset() {
        for subView in self.stackViewEquipments.arrangedSubviews {
            self.stackViewEquipments.removeArrangedSubview(subView)
            subView.removeFromSuperview()
        }
        self.lblFilter.text = ""

    }

    func show(with filter: OfficeSearchFilter) {
        self.reset()

        var filterText: [String] = [String]()

        if let text = filter.text {
            filterText.append(text)
        }

        if filter.showOnlyPartnerStore {
            filterText.append("提携店だけ")
        }

        let allDays = filter.getSelectedBusinessDays.map { day -> String in
            return day.key.localized
        }

        filterText.append(contentsOf: allDays)
//        let allDaysText = allDays.joined(separator: ", ")
//        if allDays.count > 0 {
//            if filterText.count > 0 {
//                filterText.append(", ")
//            }
//            filterText.append(allDaysText)
//        }
        var strFilterText = ""
        if filter.openingTime != "00:00",
            filter.closingTime != "00:00" {
//            if filterText.count > 0 {
//                filterText.append(", ")
//            }
            strFilterText = "\(filter.openingTime) - \(filter.closingTime)"
            
        } else if filter.openingTime != "00:00",
            filter.closingTime == "00:00" {
            strFilterText = "\(filter.openingTime) - \(filter.closingTime)"
        } else if filter.closingTime != "00:00",
            filter.openingTime == "00:00" {
            strFilterText = "\(filter.openingTime) - \(filter.closingTime)"
        } else {}
        
        filterText.append(strFilterText)
        
        self.addEquipments(filter.getSelectedEquipments)
        self.lblFilter.text = filterText.joined(separator: ", ")

        self.isHidden = false
        UIView.animate(withDuration: 0.27, delay: 0, options: .curveEaseOut, animations: {
            self.alpha = 1
        }) { (finished) in

        }
    }

    private func nibSetup() {
        self.backgroundColor = .clear
        Bundle.main.loadNibNamed("AppliedFilterView", owner: self, options: nil)
        self.contentView.bounds = self.bounds
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(self.contentView)
    }

    private func addEquipments(_ equipments: [OfficeEquipment]) {
        for equipment in equipments {
            let imgView = self.generateImageView()
            imgView.layer.cornerRadius = 11
            imgView.layer.masksToBounds = true
            self.addImageView(imgView)
            imgView.sd_setImage(with: equipment.imageURL, completed: { (image, _, _, _) in
                if let image = image {
                    imgView.image = image
                }
            })
        }
    }

    private func addImageView(_ imageView: UIImageView) {
        self.stackViewEquipments.addArrangedSubview(imageView)
    }

    private func generateImageView() -> UIImageView {
        let imageView = UIImageView.init()
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalToConstant: 22.0).isActive = true
        return imageView
    }

    func hide() {
        UIView.animate(withDuration: 0.27, delay: 0, options: .curveEaseOut, animations: {
            self.alpha = 0
        }) { (finished) in
            self.isHidden = true
        }
    }

    @IBAction func onCloseTap(_ sender: UIButton) {
        self.hide()
        self.delegate?.clearFilter()
    }
}
