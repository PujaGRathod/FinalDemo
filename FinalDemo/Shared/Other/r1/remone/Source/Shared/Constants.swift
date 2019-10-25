//
//  Constants.swift
//  remone
//
//  Created by Arjav Lad on 20/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import Foundation
import UIKit

// Blue like color
let APP_COLOR_THEME: UIColor = #colorLiteral(red: 0.05098039216, green: 0.2470588235, blue: 0.6196078431, alpha: 1)
//    UIColor.init(red: 13/255, green: 63/255, blue: 158/255, alpha: 1)

func HiraginoSansW0(withSize: CGFloat) -> UIFont {
    return UIFont.init(name: "HiraginoSans-W0", size: withSize)!
}

func HiraginoSansW1(withSize: CGFloat) -> UIFont {
    return UIFont.init(name: "HiraginoSans-W1", size: withSize)!
}

func HiraginoSansW2(withSize: CGFloat) -> UIFont {
    return UIFont.init(name: "HiraginoSans-W2", size: withSize)!
}

func HiraginoSansW3(withSize: CGFloat) -> UIFont {
    return UIFont.init(name: "HiraginoSans-W3", size: withSize)!
}

func HiraginoSansW4(withSize: CGFloat) -> UIFont {
    return UIFont.init(name: "HiraginoSans-W4", size: withSize)!
}

func HiraginoSansW5(withSize: CGFloat) -> UIFont {
    return UIFont.init(name: "HiraginoSans-W5", size: withSize)!
}

func HiraginoSansW6(withSize: CGFloat) -> UIFont {
    return UIFont.init(name: "HiraginoSans-W6", size: withSize)!
}

func HiraginoSansW7(withSize: CGFloat) -> UIFont {
    return UIFont.init(name: "HiraginoSans-W7", size: withSize)!
}

func HiraginoSansW8(withSize: CGFloat) -> UIFont {
    return UIFont.init(name: "HiraginoSans-W8", size: withSize)!
}

func HiraginoSansW9(withSize: CGFloat) -> UIFont {
    return UIFont.init(name: "HiraginoSans-W9", size: withSize)!
}

func PingFangSCRegular(withSize: CGFloat) -> UIFont {
    return UIFont.init(name: "PingFangSC-Regular", size: withSize)!
}

let LoginAPIURL = "auth/login"

func isiOS10() -> Bool {
    let os = ProcessInfo().operatingSystemVersion
    switch (os.majorVersion, os.minorVersion, os.patchVersion) {
    case (10, _, _):
        return true

    case (11, _, _):
        return false

    default:
        return false
    }

}
