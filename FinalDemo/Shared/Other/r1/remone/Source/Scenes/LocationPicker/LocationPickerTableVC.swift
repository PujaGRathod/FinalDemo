//
//  LocationPickerTableVC.swift
//  remone
//
//  Created by Akshit Zaveri on 28/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit
import MapKit

protocol LocationPickerTableDelegate {
    func companySelected(_ location: RMCompany)
}

class LocationPickerTableVC: UITableViewController {

    var delegate: LocationPickerTableDelegate?

    var originalCompanies: [RMCompany] = []

    var companies: [RMCompany] = []
    
    var suggestedCompanies: [RMCompany] = []
    
    var selectedLocation: RMCompany?
    var userLocation: UserLocation = UserLocation.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = APP_COLOR_THEME

        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        
        self.companies = self.originalCompanies

        if let location = self.selectedLocation {
            _ = self.removeLocationFromList(location)
        }
        self.userLocation.locationUpdatedBlock = { (location, _) in
            if let currentLocation = location?.currentLocation {
                self.loadSuggestedLocations(with: currentLocation)
            }
        }
        self.loadOtherLocations()
        self.tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        Analytics.shared.trackScreen(name: "Select Location")
        super.viewWillAppear(animated)
    }

    private func loadOtherLocations() {
        self.originalCompanies = RMCompany.getOtherTimeStampLocationList()
        self.companies = self.originalCompanies
        self.tableView.reloadData()
    }
    
    private func loadSuggestedLocations(with location: CLLocationCoordinate2D) {
        self.showLoader()
        let appliedFilter: OfficeSearchFilter = OfficeSearchFilter()
        appliedFilter.latitude = location.latitude
        appliedFilter.longitude = location.longitude
        _ = APIManager.shared.searchCompany(with: appliedFilter, { (officeList, error) in
            self.hideLoader()
            let list = APIManager.shared.sortOfficeWithDistance(from: location, list: officeList)
            self.suggestedCompanies = [RMCompany]()
            for office in list {
                if let comp = office.convertToCompany() {
                    self.suggestedCompanies.append(comp)
                }
            }
//            self.suggestedCompanies = APIManager.shared.sortCompanyWithDistance(list: self.suggestedCompanies)
            self.tableView.reloadData()
        })
        
        //        APIManager.shared.updateLocation(at: location.latitude, longitude: location.longitude, { (success) in
        //        _ = APIManager.shared.getOfficeNearMe({ (officeList, error) in
        //            self.hideLoader()
        //            let list = APIManager.shared.sortOfficeWithDistance(from: nil, list: officeList)
        //            self.suggestedCompanies = [RMCompany]()
        //            for office in list {
        //                if let comp = office.convertToCompany() {
        //                    self.suggestedCompanies.append(comp)
        //                }
        //            }
        //            self.tableView.reloadData()
        //        })
        //            })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueSearchLocationVC" {
            if let navController = segue.destination as? UINavigationController,
                let vc = navController.viewControllers.first as? SearchLocationVC {
                
                vc.delegate = self
            }
        }
    }
    
    func removeLocationFromList(_ location: RMCompany) -> Int? {
        if let index = self.companies.index(of: location) {
            self.companies.remove(at: index)
            return index
        }
        return nil
    }
    
    @IBAction func suggestedLocationTapped(_ sender: UIButton) {
        let suggestedLocation: RMCompany = self.suggestedCompanies[sender.tag]
        print("selected :\(suggestedLocation.name)")
        self.updateUI(for: suggestedLocation)
    }
    
    private func updateUI(for location: RMCompany) {
        self.companies = self.originalCompanies
        self.selectedLocation = location
        
        self.tableView.beginUpdates()
        if let location = self.selectedLocation,
            let index = self.companies.index(of: location) {
            
            self.tableView.insertRows(at: [IndexPath.init(item: index, section: 2)], with: UITableViewRowAnimation.fade)
        }
        
        let indexPath = IndexPath(item: 0, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        
        self.tableView.reloadSections(IndexSet(integer: 2), with: UITableViewRowAnimation.none)
        self.tableView.endUpdates()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        guard let location = self.selectedLocation else {
            self.showAlert("Error".localized, message: "Please select a location".localized)
            return
        }
        
        self.delegate?.companySelected(location)
        self.dismiss(animated: true) {
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 60
        case 1:
            return 18
        case 2:
            return 18
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            
            let scrollView: UIScrollView = UIScrollView()
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 32)
            
            let stackview: UIStackView = UIStackView()
            scrollView.addSubview(stackview)
            
            // align stackview from the left and right
            scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": stackview]));
            
            // align stackview from the top and bottom
            scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-6-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": stackview]));
            
            stackview.axis = .horizontal
            stackview.translatesAutoresizingMaskIntoConstraints = false
            stackview.distribution = .fill
            stackview.spacing = 8
            for (index, location) in self.suggestedCompanies.enumerated() {
                let button: UIButton = UIButton(type: UIButtonType.system)
                button.titleLabel?.font = HiraginoSansW6(withSize: 12)
                button.setTitleColor(#colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1), for: UIControlState.normal)
                button.contentEdgeInsets = UIEdgeInsetsMake(5, 12, 5, 12)
                button.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
                button.layer.cornerRadius = 16
                button.layer.borderColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
                button.layer.borderWidth = 0.5
                button.setTitle(location.name, for: UIControlState.normal)
                button.addTarget(self, action: #selector(LocationPickerTableVC.suggestedLocationTapped(_:)), for: UIControlEvents.touchUpInside)
                button.tag = index
                
                stackview.addArrangedSubview(button)
                
                // height constraint
                stackview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view(==32)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": button]));
            }
            
            return scrollView
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Office location".localized
        case 2:
            return "Other".localized
        default:
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0,1:
            return 1
        case 2:
            return self.companies.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.accessoryType = .none
        cell.textLabel?.textColor = UIColor.black
        cell.selectionStyle = .default
        switch indexPath.section {
        case 0:
            cell.selectionStyle = .none
            if let location = self.selectedLocation {
                cell.accessoryType = .checkmark
                cell.textLabel?.text = location.name
            } else {
                cell.textLabel?.textColor = #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
                cell.textLabel?.text = "Please choose a location".localized
            }
            
        case 1:
            cell.textLabel?.text = "Add other place information".localized
            cell.accessoryType = .disclosureIndicator
        case 2:
            let location: RMCompany = self.companies[indexPath.item]
            cell.textLabel?.text = location.name
        default:
            print("Unknown section")
        }
        
        cell.textLabel?.font = HiraginoSansW3(withSize: 14)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            tableView.deselectRow(at: indexPath, animated: true)
        case 1:
            self.performSegue(withIdentifier: "segueSearchLocationVC", sender: nil)
        case 2:

            let location: RMCompany = self.companies[indexPath.item]
            self.selectedLocation = location
            
            self.companies = self.originalCompanies

            tableView.beginUpdates()
            
            if let index = self.removeLocationFromList(location) {
                self.tableView.deleteRows(at: [IndexPath(item: index, section: 2)], with: UITableViewRowAnimation.fade)
            }
            
            let indexPath = IndexPath(item: 0, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            self.tableView.reloadSections(IndexSet(integer: 2), with: UITableViewRowAnimation.none)
            
            tableView.endUpdates()
            
        //            tableView.reloadData()
        default:
            print("Unknown section selected")
        }
    }
}

extension LocationPickerTableVC: SearchLocationDelegate {
    
    func companySelected(_ location: RMCompany) {
        self.selectedLocation = location
        self.updateUI(for: location)
    }
}
