//
//  RMUserInfoView.swift
//  remone
//
//  Created by Akshit Zaveri on 08/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

class RMUserInfoView: UIView {

    @IBOutlet weak var lblInhouse: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet private weak var inhouseIndicatorView: UIView!
    @IBOutlet private weak var inhouseLabel: UILabel!
    @IBOutlet private weak var timestampView: RMUserTimestampView!
    @IBOutlet private weak var locationButton: UIButton!
    @IBOutlet weak var iconLocation: UIImageView!

    var delegate: RMUserInfoViewDelegate?
    private var timeStamp: RMTimestamp?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.nibSetup()
    }
    
    private func nibSetup() {
        Bundle.main.loadNibNamed("RMUserInfoView", owner: self, options: nil)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.frame = self.bounds
        self.containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(self.containerView)
        self.layoutIfNeeded()
        
        self.inhouseIndicatorView.layer.cornerRadius = 4
        self.inhouseIndicatorView.layer.borderWidth = 0.5
        self.inhouseIndicatorView.layer.borderColor = #colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1)
    }

    @IBAction func onLocationTap(_ sender: UIButton) {
        if let timeStamp = self.timeStamp {
            self.delegate?.openOfficeProfile(for: timeStamp.company.id)
        }
    }

    func isFromTeam(_ sameTeam: Bool) {
        self.inhouseIndicatorView.isHidden = !sameTeam
    }

    func set(name: String) {
        self.nameLabel.text = name
    }

    func set(timestamp: RMTimestamp?, user: RMUser) {
        self.timeStamp = timestamp
        if let timestamp = timestamp {
            self.iconLocation.isHidden = false
            self.locationButton.isHidden = false
            self.locationButton.setTitle(timestamp.company.name, for: .normal)
            if timestamp.company.locationType == .other {
                self.locationButton.setTitleColor(.lightGray, for: .normal)
            } else {
                self.locationButton.setTitleColor(APP_COLOR_THEME, for: .normal)
            }
            self.timestampView.isHidden = false
            if let status = timestamp.status {
                self.timestampView.set(timestamp: status)
            }
        } else {
            self.timestampView.isHidden = true
            self.iconLocation.isHidden = true
            self.locationButton.isHidden = true
        }
//        self.nameLabel.text = user.name
    }
}
