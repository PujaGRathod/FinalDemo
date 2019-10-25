//
//  OfficeSearchVC.swift
//  remone
//
//  Created by Arjav Lad on 03/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class OfficeSearchVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var btnCloseInNearLocationView: UIButton!
    @IBOutlet var txtSearch: UITextField!
    @IBOutlet weak var btnCloseList: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var viewFloating: UIView!
    @IBOutlet weak var btnOfficeNearMe: UIButton!
    @IBOutlet weak var btnShowCurrentLocation: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnFavorite: UIBarButtonItem!
    @IBOutlet weak var btnFilter: UIBarButtonItem!
    @IBOutlet weak var appliedFilterView: AppliedFilterView!
    @IBOutlet weak var conHeightTableView: NSLayoutConstraint!
    
    private var mapAdapter: OfficeSearchMapAdapter!
    private var tableAdapter: OfficeSearchListAdapter!
    var appliedFilter: OfficeSearchFilter? = nil
    var selectedLocation: CLLocationCoordinate2D?
    //    private var searchText: String? = nil
    private var currentRequest: APIManager.APIRequest?
    private var selectedPlace: GMSPlace? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        Analytics.shared.trackScreen(name: "Office Search")
        let searchGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.showPlacesPicker))
        searchGesture.isEnabled = true
        searchGesture.numberOfTapsRequired = 1
        searchGesture.numberOfTouchesRequired = 1
        self.txtSearch.addGestureRecognizer(searchGesture)

        self.mapAdapter = OfficeSearchMapAdapter.init(with: self.mapView, delegate: self)
        self.tableAdapter = OfficeSearchListAdapter.init(with: self.tableView, delegate: self)
        self.setupButtons()
        self.appliedFilterView.alpha = 0
        self.appliedFilterView.isHidden = true
        self.appliedFilterView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.shared.trackScreen(name: "Office search")
        self.prepareSearchField()
        APIManager.shared.getDefaultOfficeSearchFilter()
        if let location = self.mapAdapter.userlocation.currentLocation {
            APIManager.shared.loginSession?.user.userLocation?.coordinates = location
            APIManager.shared.loginSession?.save()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func onCloseListTap(_ sender: UIButton) {
        self.showList(false)
    }
    
    @IBAction func onOfficeNearMeTap(_ sender: UIButton) {
        self.showList(true)
    }
    
    @IBAction func onShowCurrentLocationTap(_ sender: UIButton) {
        self.showList(false)
        self.mapAdapter.showUserLocation()
    }
    
    @IBAction func onFavoriteTap(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "segueShowFavoriteOfficeListVC", sender: nil)
    }
    
    @IBAction func onFilterTap(_ sender: UIBarButtonItem) {
        OfficeSearchFilterVC.showOfficeFiler(on: self, filter: self.appliedFilter) { (filter, searchHistory) in
            self.showFilterView()
            if let filter = filter {
                self.appliedFilter = filter
                self.getOfficeList()
            } else if let history = searchHistory {
                self.appliedFilter = history.filter
                self.txtSearch.text = history.filter?.text
                self.getOfficeList()
            } else {
//                self.getOfficeList(self.selectedLocation)
            }
        }
    }
    
    func showFilterView() {
        if let filter = self.appliedFilter {
            self.appliedFilterView.show(with: filter)
        } else {
            self.appliedFilterView.reset()
            self.appliedFilterView.hide()
        }
    }
    
    func setupButtons() {
        self.btnOfficeNearMe.layer.cornerRadius = 20
        self.btnShowCurrentLocation.layer.cornerRadius = 20
        self.btnShowCurrentLocation.clipsToBounds = true
    }
    
    func showList(_ show: Bool) {
        if show {
            self.btnCloseList.isHidden = false
            self.btnCloseInNearLocationView.isHidden = false
            UIView.animate(withDuration: 0.27, animations: {
                //                self.view.bringSubview(toFront: self.btnCloseList)
                self.btnOfficeNearMe.isHidden = true
                self.conHeightTableView.constant = self.tableAdapter.calculateTableHeight()
            }) { (finished) in
                
            }
        } else {
            self.btnOfficeNearMe.isHidden = false
            UIView.animate(withDuration: 0.27, animations: {
                //                self.view.sendSubview(toBack: self.btnCloseList)
                self.btnCloseList.isHidden = true
                self.btnCloseInNearLocationView.isHidden = true
                self.conHeightTableView.constant = 0
            }) { (finished) in
                
            }
        }
        self.view.layoutIfNeeded()
    }

    @objc func showPlacesPicker() {
        let placePickerController = GMSAutocompleteViewController()

        let filter = GMSAutocompleteFilter.init()
        filter.country = "jp"
        placePickerController.autocompleteFilter = filter
        placePickerController.tintColor = APP_COLOR_THEME
        placePickerController.tableCellBackgroundColor = .white
        placePickerController.delegate = self

        self.present(placePickerController, animated: true, completion: {
            placePickerController.navigationController?.navigationBar.backgroundColor = .white
            placePickerController.navigationController?.navigationBar.barStyle = .default
            placePickerController.navigationController?.navigationBar.isTranslucent = false
            placePickerController.navigationController?.navigationBar.tintColor = APP_COLOR_THEME
        })
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.showPlacesPicker()
        return false
    }

    func prepareSearchField() {
        self.txtSearch.delegate = self
        self.txtSearch.layer.cornerRadius = 16.5
        self.txtSearch.clipsToBounds = true
        let borderColor = #colorLiteral(red: 0.9254901961, green: 0.937254902, blue: 0.9450980392, alpha: 1)
        self.txtSearch.clearButtonMode = .whileEditing
        self.txtSearch.layer.borderColor = borderColor.cgColor
        self.txtSearch.layer.borderWidth = 1.0
        self.txtSearch.setLeftImage(#imageLiteral(resourceName: "icon_search"), withPadding: CGSize.init(width: 8, height: 5), tintColor: self.txtSearch.textColor)
        self.txtSearch.frame = CGRect.init(x: 0, y: 0, width: 263, height: 32)
        self.navigationItem.titleView = self.txtSearch
    }
    
    func getOfficeList(_ location: CLLocationCoordinate2D? = nil) {
        func cancelRequest() {
            if let request = self.currentRequest {
                request.cancel()
                self.currentRequest = nil
            }
        }
        cancelRequest()

        if let place = self.selectedPlace {
            Analytics.shared.trackOfficeSearch(keyword: place.name)
            if self.appliedFilter == nil {
                self.appliedFilter = OfficeSearchFilter.defaultOfficeSearchFilter.copy() as? OfficeSearchFilter
            }
            self.appliedFilter?.text = place.name
            self.appliedFilter?.latitude = place.coordinate.latitude
            self.appliedFilter?.longitude = place.coordinate.longitude
        }
        if let filter = self.appliedFilter {
            self.showLoader()
//            let filters = filter.getRawData()
//            if filters.keys.count == 1,
//                let onlyPartnerShop = filters["partnerShop"] as? Bool,
//                onlyPartnerShop == true {
//                filter.latitude = self.selectedLocation?.latitude
//                filter.longitude = self.selectedLocation?.longitude
//            }
//            else
//            {
//                filter.latitude = nil
//                filter.longitude = nil
//            }
            self.currentRequest = APIManager.shared.searchCompany(with: filter, { (officeList, error) in
                self.hideLoader()
                var list = [RMOffice]()
                if let location = self.selectedPlace?.coordinate {
                    list = APIManager.shared.sortOfficeWithDistance(from: location, list: officeList)
                } else {
                    list = APIManager.shared.sortOfficeWithDistance(from: nil, list: officeList)
                }
                self.tableAdapter.updateOfficeList(with: list, append: false)
                self.mapAdapter.loadMarkers(for: list, near: self.selectedPlace?.coordinate)
                self.showList(true)
                self.showFilterView()
                cancelRequest()
            })
        } else {
            self.showLoader()
            if let location = location {
                let applFilter: OfficeSearchFilter = OfficeSearchFilter()
                applFilter.latitude = location.latitude
                applFilter.longitude = location.longitude
                self.currentRequest = APIManager.shared.searchCompany(with: applFilter, { (officeList, error) in
                    let list = APIManager.shared.sortOfficeWithDistance(from: location, list: officeList)
                    self.mapAdapter.loadMarkers(for: list)
                    self.tableAdapter.updateOfficeList(with: list, append: false)
                    self.hideLoader()
                    cancelRequest()
                })
//                APIManager.shared.updateLocation(at: location.latitude, longitude: location.longitude, { (success) in
//                    self.currentRequest = APIManager.shared.getOfficeNearMe({ (officeList, error) in
//                        let list = APIManager.shared.sortOfficeWithDistance(from: location, list: officeList)
//                        self.hideLoader()
//                        self.mapAdapter.loadMarkers(for: list)
//                        self.tableAdapter.updateOfficeList(with: list, append: false)
//                        cancelRequest()
//                    })
//                })
            } else {
                self.hideLoader()
                self.mapAdapter.loadMarkers(for: [])
                self.tableAdapter.updateOfficeList(with:[], append: false)
//                self.showAlert("Error!".localized,
//                               message: "Failed to get your current location. Please check if \"Remone\" is allowed to access your location.".localized,
//                               actionTitles: [("Open Settings".localized, .default)],
//                               cancelTitle: "Cancel".localized,
//                               actionHandler: { (_, index) in
//                                if #available(iOS 10.0, *) {
//                                    UIApplication.shared.open(URL.init(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: { (success) in
//                                    })
//                                } else {
//                                    // Fallback on earlier versions
//                                    UIApplication.shared.openURL(URL.init(string: UIApplicationOpenSettingsURLString)!)
//                                }
//                },
//                               cancelActionHandler: { (_) in
//                })
//                self.currentRequest = APIManager.shared.getOfficeNearMe({ (officeList, error) in
//                    let list = APIManager.shared.sortOfficeWithDistance(from: nil, list: officeList)
//                    self.hideLoader()
//                    self.mapAdapter.loadMarkers(for: list)
//                    self.tableAdapter.updateOfficeList(with: list, append: false)
//                    cancelRequest()
//                })
            }
        }
    }
}

extension OfficeSearchVC: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.txtSearch.text = place.name
        self.selectedPlace = place
        
        self.getOfficeList()
        viewController.dismiss(animated: true) {

        }
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        viewController.dismiss(animated: true) {

        }
    }

    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        viewController.dismiss(animated: true) {

        }
    }

}

extension OfficeSearchVC: OfficeSearchMapAdapterDelegate, OfficeSearchListAdapterDelegate, AppliedFilterViewDelegate {
    
    func foundUserLocation(_ location: CLLocationCoordinate2D?) {
        if let location = location {
            if let _ = self.appliedFilter {
                self.selectedLocation = location
                return;
            }
            if let lastLoc = self.selectedLocation {
                if lastLoc.isEqual(to: location)  {
                    return;
                } else {
                    self.getOfficeList(location)
                }
            } else {
                self.getOfficeList(location)
            }
            self.selectedLocation = location
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
    
    func openOfficeProfile(_ office: RMOffice) {
        if office.locationType != .other {
            OfficeProfileVC.openOfficeProfile(for: office.id, on: self)
        }
    }
    
    func showAlert(title: String?, message: String?) {
        self.showAlert(title, message: message)
    }
    
    func clearFilter() {
        self.txtSearch.text = ""
        self.appliedFilter = nil
        self.selectedPlace = nil
        self.showList(false)
        self.getOfficeList(self.selectedLocation)
    }
}

