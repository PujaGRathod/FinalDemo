//
//  OfficeSearchMapAdapter.swift
//  remone
//
//  Created by Arjav Lad on 03/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit
import GoogleMaps

protocol OfficeSearchMapAdapterDelegate {
    func openOfficeProfile(_ office: RMOffice)
    func foundUserLocation(_ location: CLLocationCoordinate2D?)
    func showAlert(title: String?, message: String?)
}

fileprivate let mile: CLLocationDistance = 1609.34

class OfficeSearchMapAdapter: NSObject {

    private let mapView: GMSMapView
    private let delegate: OfficeSearchMapAdapterDelegate
    let userlocation: UserLocation
    private var officesMarkers = [RMOfficeMapMarker]()

    init(with map: GMSMapView, delegate: OfficeSearchMapAdapterDelegate) {
        self.mapView = map
        self.delegate = delegate
        self.userlocation = UserLocation.init()
        super.init()
        self.mapView.delegate = self
        self.mapView.isMyLocationEnabled = true
        self.userlocation.getRealTimeUpates = false
        self.userlocation.locationUpdatedBlock = { (location, error) in
            if let _ = error {
//                if error == UserLocation.UserLocationError.didRefuse {
//                    self.delegate.showAlert(title: "Error".localized, message: "Please allow Remone to access your location.".localized)
//                } else {
////                    self.delegate.showAlert(title: "Error".localized, message: "failed to get your location!".localized)
//                    self.delegate.foundUserLocation(nil)
//                }
                self.delegate.foundUserLocation(nil)
            } else if let location = location?.currentLocation {
                print(location)
                self.delegate.foundUserLocation(location)
                self.zoomToLocation(location)
            } else {
                self.delegate.foundUserLocation(nil)
                print("location not found")
            }
        }
    }

    private func clearMapView() {
        for marker in self.officesMarkers {
            marker.map = nil
        }
    }

    func loadMarkers(for officeList: [RMOffice], near location: CLLocationCoordinate2D? = nil) {
        self.clearMapView()
        self.officesMarkers = [RMOfficeMapMarker]()
        for office in officeList {
            let location = office.location.coordinates
            let lat = location.latitude
            let lng = location.longitude
            let marker = RMOfficeMapMarker.init(with: office)
            if office.isPartnerShop {
                marker.icon = #imageLiteral(resourceName: "iconPinPartner")
            } else {
                marker.icon = #imageLiteral(resourceName: "iconPinNormal")
            }
            marker.position = CLLocationCoordinate2D.init(latitude:lat, longitude: lng)
            marker.map = self.mapView
            self.officesMarkers.append(marker)
        }
        print("showing marker at location: \(String(describing: self.officesMarkers.first?.position))")
        print("Total Pins: \(self.officesMarkers.count)")
        if let location = location {
            self.zoomMap(with: location)
        } else if let currentLocation = self.userlocation.currentLocation {
            self.zoomMap(with: currentLocation)
        } else {
            let bounds = self.officesMarkers.reduce(GMSCoordinateBounds()) {
                $0.includingCoordinate($1.position)
            }
            self.mapView.animate(with: .fit(bounds, withPadding: 50.0))
        }
    }

    private func zoomMap(with center: CLLocationCoordinate2D, radius: CLLocationDistance = (mile / 2)) {
        let circle = GMSCircle.init(position: center, radius: radius)
        self.mapView.animate(with: .fit(circle.bounds(), withPadding: 20.0))
    }

    func zoomToLocation(_ location: CLLocationCoordinate2D) {
        self.zoomMap(with: location)
//        let camera = GMSCameraPosition.camera(withTarget: location, zoom: 12)
//        self.mapView.animate(to: camera)
    }

    func showUserLocation() {
//        if let currentLocation = self.userlocation.currentLocation {
//            self.zoomToLocation(currentLocation)
//        }
        self.userlocation.getUserlocation()
//        else {
////            self.userlocation.getUserlocation()
//        }
    }

}

extension OfficeSearchMapAdapter: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let markerData = marker as? RMOfficeMapMarker {
            self.delegate.openOfficeProfile(markerData.office)
        } else {
            let camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude, longitude: marker.position.longitude, zoom: 17)
            self.mapView.animate(to: camera)
        }
        return true
    }

}

extension GMSCircle {
    func bounds () -> GMSCoordinateBounds {
        func locationMinMax(positive: Bool) -> CLLocationCoordinate2D {
            let sign: Double = positive ? 1 : -1
            let dx = sign * self.radius  / 6378000 * (180 / Double.pi)
            let lat = position.latitude + dx
            let lon = position.longitude + dx / cos(position.latitude * Double.pi / 180)
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }

        return GMSCoordinateBounds(coordinate: locationMinMax(positive: true),
                                   coordinate: locationMinMax(positive: false))
    }
}
