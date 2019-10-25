//
//  RMFollowButton.swift
//  remone
//
//  Created by Arjav Lad on 25/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

protocol RMFollowButtonTheme {
    var titleColor: UIColor { get }
    var tintColor: UIColor { get }
    var borderColor: UIColor { get }
    var backgroundColor: UIColor { get }
    var title: String { get }
    var addBorder: Bool { get }
}

struct RMFollowButtonThemeFollowing: RMFollowButtonTheme {
    var titleColor: UIColor {
        return #colorLiteral(red: 0.05098039216, green: 0.2470588235, blue: 0.6196078431, alpha: 1)
    }

    var tintColor: UIColor {
        return #colorLiteral(red: 0.05098039216, green: 0.2470588235, blue: 0.6196078431, alpha: 1)
    }

    var borderColor: UIColor {
        return #colorLiteral(red: 0.05098039216, green: 0.2470588235, blue: 0.6196078431, alpha: 1)
    }
    var backgroundColor: UIColor {
        return .white
    }

    var title: String {
        return "following".localized
    }

    var addBorder: Bool {
        return true
    }
}

struct RMFollowButtonThemeUnknown: RMFollowButtonTheme {
    var titleColor: UIColor {
        return .white
    }
    var tintColor: UIColor {
        return .white
    }
    var borderColor: UIColor {
        return .clear
    }
    var backgroundColor: UIColor {
        return .white
    }

    var title: String {
        return ""
    }

    var addBorder: Bool {
        return false

    }
}


struct RMFollowButtonThemeUnfollow: RMFollowButtonTheme {
    var titleColor: UIColor {
        return .white
    }
    var tintColor: UIColor {
        return .white
    }
    var borderColor: UIColor {
        return .clear
    }
    var backgroundColor: UIColor {
        return #colorLiteral(red: 0.05098039216, green: 0.2470588235, blue: 0.6196078431, alpha: 1)
    }

    var title: String {
        return "follow".localized
    }

    var addBorder: Bool {
        return false

    }
}


struct RMFollowButtonThemeRequested: RMFollowButtonTheme {
    var titleColor: UIColor {
        return #colorLiteral(red: 0.05098039216, green: 0.2470588235, blue: 0.6196078431, alpha: 1)
    }
    var tintColor: UIColor {
        return #colorLiteral(red: 0.05098039216, green: 0.2470588235, blue: 0.6196078431, alpha: 1)
    }
    var borderColor: UIColor {
        return #colorLiteral(red: 0.05098039216, green: 0.2470588235, blue: 0.6196078431, alpha: 1)
    }
    var backgroundColor: UIColor {
        return .white
    }

    var title: String {
//        return "requested".localized
        return "In request".localized
    }

    var addBorder: Bool {
        return true
    }
}

class RMFollowButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func apply(theme: RMFollowButtonTheme) {
        if theme.title == "" {
            self.isHidden = true
        } else {
            self.isHidden = false
        }
        self.titleLabel?.font = HiraginoSansW5(withSize: 12)
        self.layer.cornerRadius = 14
        self.clipsToBounds = true
        self.setTitleColor(theme.titleColor, for: .normal)
        self.tintColor = theme.tintColor
        self.backgroundColor = theme.backgroundColor
        self.setTitle(theme.title, for: .normal)
        if theme.addBorder {
            self.layer.borderColor = theme.borderColor.cgColor
            self.layer.borderWidth = 0.5
        } else {
            self.layer.borderColor = UIColor.clear.cgColor
            self.layer.borderWidth = 0
        }
    }
}
