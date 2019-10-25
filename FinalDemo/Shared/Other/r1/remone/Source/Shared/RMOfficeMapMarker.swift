//
//  RMOfficeMapMarker.swift
//  remone
//
//  Created by Arjav Lad on 09/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit
import GoogleMaps

class RMOfficeMapMarker: GMSMarker {
    let office: RMOffice

    init(with office: RMOffice) {
        self.office = office
    }
}
