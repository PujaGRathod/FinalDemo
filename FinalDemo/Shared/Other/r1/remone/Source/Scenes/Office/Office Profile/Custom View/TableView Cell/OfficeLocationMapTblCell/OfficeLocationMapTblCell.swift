//
//  OfficeLocationMapTblCell.swift
//  remone
//
//  Created by Arjav Lad on 20/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit
import GoogleMaps

class OfficeLocationMapTblCell: UITableViewCell {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var btnOpenMap: UIButton!

    var openMaps: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.mapView.isUserInteractionEnabled = false
        self.btnOpenMap.layer.cornerRadius = 4
        self.btnOpenMap.clipsToBounds = true
        self.btnOpenMap.layer.borderColor = self.btnOpenMap.tintColor.cgColor
        self.btnOpenMap.layer.borderWidth = 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state

    }

    func loadMapView(for location: OfficeLocation) {
        let coordinates = location.coordinates
        let marker = GMSMarker.init(position: coordinates)
        marker.icon = GMSMarker.markerImage(with: .red)
        marker.map = self.mapView
        let camera = GMSCameraPosition.camera(withTarget: coordinates, zoom: 12)
        self.mapView.animate(to: camera)
        self.btnOpenMap.isHidden = false
        self.lblAddress.text = location.address
    }
    
    @IBAction func onOpenMapsTap(_ sender: UIButton) {
        self.openMaps?()
    }

}
