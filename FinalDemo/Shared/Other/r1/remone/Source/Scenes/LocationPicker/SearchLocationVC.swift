//
//  SearchLocationVC.swift
//  remone
//
//  Created by Akshit Zaveri on 28/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit
import MapKit

protocol SearchLocationDelegate {
    func companySelected(_ location: RMCompany)
}

class SearchLocationVC: UITableViewController {
    
    var delegate: SearchLocationDelegate?
    
    private var companies: [RMCompany] = []
    private var userLocation: UserLocation?
    private var apiRequest: APIManager.APIRequest?
    
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")

        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = APP_COLOR_THEME

        var offset = self.tableView.contentOffset
        offset.y = -116
        self.tableView.contentOffset = offset
        
        self.searchTextField.layer.cornerRadius = 16.5
        self.searchTextField.layer.borderColor = #colorLiteral(red: 0.9254901961, green: 0.937254902, blue: 0.9450980392, alpha: 1)
        self.searchTextField.layer.borderWidth = 1
        
        NotificationCenter.default.addObserver(self, selector: #selector(SearchLocationVC.textDidChange), name:  NSNotification.Name.UITextFieldTextDidChange, object: self.searchTextField)
        
        self.setLeftPadding(12+22+12)
    }
    
    func setLeftPadding(_ padding: CGFloat) {
        var leftFrame : CGRect = self.searchTextField.frame
        leftFrame.origin = .zero
        leftFrame.size.width = padding
        let leftImageViewContainer = UIView.init(frame: leftFrame)
        
        self.searchTextField.leftViewMode = .always
        self.searchTextField.leftView = leftImageViewContainer
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.shared.trackScreen(name: "Search Location")
        self.filterContentForSearchText("")
    }

    @IBAction func currentLocationButtonTapped(_ sender: UIBarButtonItem) {
        self.userLocation = UserLocation()
        self.userLocation?.locationUpdatedBlock = { (location, error) in
            if let location = location {
                self.userLocation = location
                self.filterContentForSearchText("")
//                if let loc = location.currentLocation {
//                    self.showLoader()
//                    APIManager.shared.updateLocation(at: loc.latitude, longitude: loc.latitude, { (success) in
//                        self.hideLoader()

//                    })
//                }
            } else {
                self.userLocation = nil
                if error == .didRefuse {
                    self.showAlert("Error".localized, message: "Please allow Remone to access your location.".localized)
                } else {
                    self.showAlert("Error".localized, message: "failed to get your location!".localized)
                }
            }
        }
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true) {
        }
    }
    
}

extension SearchLocationVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.companies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var company: RMCompany!
        company = self.companies[indexPath.item]
        cell.textLabel?.text = company.name
        cell.textLabel?.font = HiraginoSansW3(withSize: 14)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var company: RMCompany!
        company = self.companies[indexPath.item]
        print("Company: \(company.name)")
        self.delegate?.companySelected(company)
        self.cancelTapped(UIBarButtonItem())
    }
}

extension SearchLocationVC {
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        var request = APIManager.CompanyModel.search.request()
        if let userLocation = self.userLocation,
            userLocation.hasValidLocation {
            request.latitude = userLocation.currentLocation?.latitude
            request.longitude = userLocation.currentLocation?.longitude
        }
        request.query = searchText
        self.apiRequest?.cancel()
        self.showLoader()
        self.apiRequest = APIManager.shared.searchCompany(request: request) { (response) in
                self.hideLoader()
                self.companies = response.companies
                self.tableView.reloadData()
        }
    }
}

extension SearchLocationVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.filterContentForSearchText(searchController.searchBar.text ?? "")
    }
}

extension SearchLocationVC: UITextFieldDelegate {
    @objc func textDidChange() {
        self.filterContentForSearchText(self.searchTextField.text ?? "")
    }
}
