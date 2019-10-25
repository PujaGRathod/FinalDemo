//
//  SearchPeopleMapAdapter.swift
//  remone
//
//  Created by Inheritx on 31/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps

protocol SearchPeopleMapAdapterDelegate {
    func userProfileSelected(_ userModel: SearchPeopleModel)
    func foundUserLocation(_ location: CLLocationCoordinate2D?)
    func showAlert(title: String?, message: String?)
}

class SearchPeopleMapAdapter: NSObject {

    private let mapView: GMSMapView
    private let delegate: SearchPeopleMapAdapterDelegate
    private var selectedMarker: PeopleMapMarker?
    private var userMarkers = [PeopleMapMarker]()
    let userlocation: UserLocation

    init(with map: GMSMapView, delegate: SearchPeopleMapAdapterDelegate) {
        self.mapView = map
        self.delegate = delegate
        self.userlocation = UserLocation.init()
        super.init()
        self.mapView.delegate = self
        self.mapView.isMyLocationEnabled = true
        self.updateLocationSetup()
    }

    private func updateLocationSetup() {
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
//                self.zoomToLocation(location)
            } else {
                self.delegate.foundUserLocation(nil)
                print("location not found")
            }
        }
    }

    func clearMapView() {
        self.mapView.clear()
        for marker in self.userMarkers {
            marker.map = nil
        }
        self.selectedMarker = nil
        self.userMarkers.removeAll()
    }

    func loadMarkers(for userList: [SearchPeopleModel],isRequiredZoom:Bool) {
        self.clearMapView()
        self.userMarkers = [PeopleMapMarker]()
        let otherLocaitions = RMCompany.getOtherLocationList()
        for userModel in userList {
            if userModel.user.shouldShowUser {
                //                if userModel.user.isInHouseMember, //MARK: change of inhouse
                   if let company = userModel.timestamp?.company,
                    userModel.timestamp?.status != TimeStampStatus.workFinish,
                    !otherLocaitions.contains(company) {
                    if let location = company.location {
                        let marker = PeopleMapMarker.init(with: userModel)
                        marker.position = location
                        if self.userMarkers.contains(marker) {
                            continue
                        }
                        let iconView = SearchPeopleMarkerView.init(with: userModel.user.profilePicture)
                        iconView.selected = false
                        marker.iconView = iconView
                        iconView.loadprofileImage(with: userModel.user.profilePicture, { () in
                        })
                        marker.map = self.mapView
                        self.userMarkers.append(marker)
                    } else {
                        print("Wrong Location data: \(String(describing: company.location))")
                    }
                } else {
                    print("No company found! or other company")
                }
            } else {
                print("Don't show location: \(String(describing: userModel.timestamp?.company.id))")
            }
        }
        print("showing marker at location: \(String(describing: self.userMarkers.first?.position))")
        print("Total Pins: \(self.userMarkers.count)")
        if isRequiredZoom {
            self.zoomToPins()
        }
    }

    func showUserLocation() {
        if let currentLocation = self.userlocation.currentLocation {
            self.zoomToLocation(currentLocation)
        }
        self.userlocation.getUserlocation()
//        else {
//            self.userlocation.getUserlocation()
//        }
    }

    func zoomToLocation(_ location: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withTarget: location, zoom: 15)
        self.mapView.animate(to: camera)
    }
    
    func zoomToPins() {
        if self.userMarkers.count > 0 {
            let bounds = self.userMarkers.reduce(GMSCoordinateBounds()) {
                $0.includingCoordinate($1.position)
            }
            self.mapView.animate(with: .fit(bounds, withPadding: 10.0))
        } else {
            if let currentLocation = self.userlocation.currentLocation {
                self.zoomToLocation(currentLocation)
            }
        }
    }
    
}

extension SearchPeopleMapAdapter: GMSMapViewDelegate {
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            if let markerData = marker as? PeopleMapMarker {
                if let oldMarker = self.selectedMarker {
//                    oldMarker.map = nil
                    oldMarker.selectMarker(false)
//                    oldMarker.map = self.mapView
                }
//                markerData.map = nil
                markerData.selectMarker(true)
//                markerData.map = self.mapView
                self.selectedMarker = markerData
                self.delegate.userProfileSelected(markerData.model)
            } else {
                let camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude, longitude: marker.position.longitude, zoom: 17)
                self.mapView.animate(to: camera)
            }
            return true
        }
}

class PeopleMapMarker: GMSMarker {
    let model: SearchPeopleModel
    init(with model: SearchPeopleModel) {
        self.model = model
    }

    func selectMarker(_ select: Bool) {
        if let view = self.iconView as? SearchPeopleMarkerView {
            view.selected = select
        }
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let marker = object as? PeopleMapMarker {
            if marker.position.isEqual(to:self.position) {
                return true
            }
        }
        return false
    }
}

