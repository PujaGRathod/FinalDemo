//
//  SearchPeopleVC.swift
//  remone
//
//  Created by Arjav Lad on 31/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit
import GoogleMaps

class SearchPeopleVC : UIViewController, SearchPeopleSortOptionsVCDelegate, AppliedSearchPeopleFilterViewDelegate,Refreshable {
    
    @IBOutlet weak var btnCloseUserList: UIButton!
    @IBOutlet weak var viewRattings: UIView!
    @IBOutlet weak var btnFavUsers: UIBarButtonItem!
    @IBOutlet weak var btnFilter: UIBarButtonItem!
    //    @IBOutlet weak var btnSortBy: UIBarButtonItem!
    @IBOutlet weak var conHeightMapView: NSLayoutConstraint!
    @IBOutlet weak var tableUsers: UITableView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var viewAppliedFilter: AppliedSearchPeopleFilterView!
    @IBOutlet weak var conHeightViewAppliedFilter: NSLayoutConstraint!
    @IBOutlet weak var btnShowCurrentLocation: UIButton!
    @IBOutlet weak var btnShowList: UIButton!
    @IBOutlet weak var btnCloseList: UIButton!
    private var appliedFilter: SearchPeopleFilter?
    private var adapter: SearchPeopleTableViewsAdapter!
    private var mapAdapter: SearchPeopleMapAdapter!
    private var lastLocation: CLLocationCoordinate2D?
    var isListVisible: Bool {
        if self.conHeightMapView.constant == 230 {
            return true
        }
        return false
    }
    var viewHeight: CGFloat = 200

    override func viewDidLoad() {
        super.viewDidLoad()
        self.adapter = SearchPeopleTableViewsAdapter.init(with: self.tableUsers, delegate: self)
        self.mapAdapter = SearchPeopleMapAdapter.init(with: mapView, delegate: self)
        self.viewAppliedFilter.delegate = self
        self.btnShowList.layer.cornerRadius = 20
        self.btnShowCurrentLocation.layer.cornerRadius = 20
        self.btnShowCurrentLocation.clipsToBounds = true
        self.btnShowList.setTitle("Show user list".localized, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Analytics.shared.trackScreen(name: "Search People")
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        if self.appliedFilter == nil {
        ////            self.searchPeople(self.lastLocation)
        if self.isListVisible {
            if self.adapter.allUsers.count > 0 {

            } else {
                self.showTable(false)
                //                    self.mapAdapter.showUserLocation()
            }
        } else {
            //                self.showTable(false)
            //                self.mapAdapter.showUserLocation()
        }
        //        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let optionsVC = segue.destination as? SearchPeopleSortOptionsVC {
            optionsVC.delegate = self
            //            optionsVC.selectedOption = self.adapter.selectedOption
        }
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.viewHeight = self.tableUsers.frame.height
    }

    func sort(with option: SortingOptions) {
        //        self.adapter.selectedOption = option
    }

    func refresh() {
        if let loc = self.lastLocation {
            self.searchPeople(loc, isRequiredZoom: false)
        }
    }
    
    func searchPeople(_ location: CLLocationCoordinate2D? = nil,isRequiredZoom:Bool) {
        func handleResponse(with usersList: [SearchPeopleModel], error: Error?) {
            self.mapAdapter.clearMapView()
            self.adapter.clearList()
            if let error = error {
                self.showAlert(title: "Error".localized, message: error.localizedDescription)
                self.showTable(false)
                //                self.btnSortBy.isEnabled = false
            } else {
                //                self.btnSortBy.isEnabled = usersList.count > 0
                self.showTable(true)
                if self.appliedFilter?.showOnlyGoodAffinityPeople ?? false {
                    self.adapter.loadUsersList(usersList, with: .covergence)
                } else {
                    self.adapter.loadUsersList(usersList, with: .name)
                }
                self.mapAdapter.loadMarkers(for: usersList, isRequiredZoom: isRequiredZoom)
            }
        }

        func handleNearOffice(with officeList: [RMOffice], error: Error?) {
            if let error = error {
                handleResponse(with: [SearchPeopleModel](), error: error)
            } else {
                //                for office in officeList {
                //
                //                }
            }
        }

        if let filter = self.appliedFilter {
            Analytics.shared.trackPeopleSearch(keyword: filter.searchKeyword)
            if !filter.otherFilterApplied() &&
                filter.showOnlyGoodAffinityPeople {
                handleResponse(with: self.adapter.allUsers, error: nil)
            } else {
                self.showLoader()
                APIManager.shared.searchPeople(with: filter) { (usersList, error) in
                    self.hideLoader()
                    handleResponse(with: usersList, error: error)
                }
            }
        } else if let location = location {
            self.showLoader()
            //            APIManager.shared.updateLocation(at: location.latitude, longitude: location.longitude, { (success) in
            print("New Location: \(location)")
            //                APIManager.shared.getOfficeNearMe({ (officeList, error) in
            //                    self.hideLoader()
            //                    handleNearOffice(with: officeList, error: error)
            //                })
            APIManager.shared.searchPeople(near: location.latitude, longitude: location.longitude, { (users, error) in
                self.hideLoader()
                handleResponse(with: users, error: error)
            })
            //            })
        } else {
            if isRequiredZoom {
                self.showTable(false)
                self.mapAdapter.clearMapView()
                self.adapter.clearList()
            }
        }
    }

    func showTable(_ show: Bool) {
        var frameHeader = self.tableUsers.tableHeaderView?.frame
        if show {
            self.conHeightMapView.constant = 230
            frameHeader?.size.height = 230
            self.btnShowList.isHidden = true
            self.btnCloseList.isHidden = false
            self.btnCloseUserList.isHidden = false
        } else {
            self.conHeightMapView.constant = self.viewHeight
            frameHeader?.size.height = self.viewHeight
            self.btnShowList.isHidden = false
            self.btnCloseList.isHidden = true
            self.btnCloseUserList.isHidden = true
        }
        if let frame = frameHeader {
            self.tableUsers.tableHeaderView?.frame = frame
        }
        self.tableUsers.tableHeaderView?.layoutIfNeeded()
        self.tableUsers.reloadData()
        self.view.layoutIfNeeded()
    }

    @IBAction func onShowCurrentLocationTap(_ sender: UIButton) {
//        self.showTable(false)
        self.mapAdapter.showUserLocation()
        self.showTable(false)
//        self.mapAdapter.zoomToPins()
//                if self.isListVisible {
////                    self.showTable(false)
//                    self.mapAdapter.showUserLocation()
//                } else {
////                    self.showTable(true)
//                    self.mapAdapter.zoomToPins()
//                }
    }

    @IBAction func onFilterTap(_ sender: UIBarButtonItem) {
        SearchPeopleFilterVC.showSearchPeopleFilter(on: self, filter: self.appliedFilter) { (filter) in
            if let filter = filter {
                self.appliedFilter = filter
                self.viewAppliedFilter.show(with: filter)
                self.searchPeople(isRequiredZoom: true)
            } else {

            }
        }
    }

    @IBAction func onCloseRattingsViewTap(_ sender: UIButton) {
        self.showRattings(false)
    }
    
    @IBAction func onCloseListTap(_ sender: Any) {
        self.showTable(false)
    }
    
    @IBAction func onbtnShowList(_ sender: UIButton) {
        if self.isListVisible {
            self.showTable(false)
        } else {
            self.showTable(true)
        }
    }


    func showRattings(_ show: Bool) {
        let alpha: CGFloat = show ? 1 : 0
        if show {
            self.view.bringSubview(toFront: self.viewRattings)
            self.viewRattings.isHidden = false
        }

        UIView.animate(withDuration: 0.27, animations: {
            self.viewRattings.alpha = alpha
        }) { (finished) in
            if !show {
                self.viewRattings.isHidden = true
                self.view.sendSubview(toBack: self.viewRattings)
            }
        }
    }
    
    func updateHeight(_ height: CGFloat) {
        self.conHeightViewAppliedFilter.constant = height
        self.view.layoutIfNeeded()
    }

    func clearFilter() {
        self.appliedFilter = nil
        //        self.btnSortBy.isEnabled = false
        self.showTable(false)
        self.adapter.clearList()
        self.mapAdapter.clearMapView()
        self.searchPeople(self.lastLocation, isRequiredZoom: true)
    }
}

extension SearchPeopleVC: SearchPeopleTableViewsAdapterDelegate, SearchPeopleMapAdapterDelegate {

    func showRattingsView() {
        self.showRattings(true)
    }

    func usersLoaded(_ users: [SearchPeopleModel]) {
        //        self.mapAdapter.loadMarkers(for: users)
    }

    func openUserProfile(_ user: RMUser) {
        UserProfileVC.loadUserProfile(for: user.id, on: self)
    }

    func openOfficeProfile(_ office: RMCompany) {
        if office.locationType != .other {
            OfficeProfileVC.openOfficeProfile(for: office.id, on: self)
        }
    }

    func userProfileSelected(_ userModel: SearchPeopleModel) {
        self.showTable(true)
        self.adapter.selectUser(userModel)
    }

    func foundUserLocation(_ location: CLLocationCoordinate2D?) {
        if let location = location {
            if let lastLoc = self.lastLocation {
                if lastLoc.isEqual(to: location)  {
                    return;
                } else {
                    self.searchPeople(location, isRequiredZoom: true)
                }
            } else {
                self.searchPeople(location, isRequiredZoom: true)
            }
            self.lastLocation = location
        } else {
            self.showAlert("Error!".localized,
                           message: "Failed to get your current location. Please check if \"Remone\" is allowed to access your location.".localized,
                           actionTitles: [("Open Settings".localized, .default)],
                           cancelTitle: "Cancel".localized,
                           actionHandler: { (_, index) in
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(URL.init(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: { (success) in
                                })
                            } else {
                                // Fallback on earlier versions
                                UIApplication.shared.openURL(URL.init(string: UIApplicationOpenSettingsURLString)!)
                            }
            },
                           cancelActionHandler: { (_) in

            })
        }
    }

    func showAlert(title: String?, message: String?) {
        self.showAlert(title, message: message)
    }

    func loadingData() {
        self.showLoader()
    }

    func dataLoadingFinished() {
        self.hideLoader()
    }

}

