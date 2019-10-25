//
//  SelectLocationVC.swift
//  remone
//
//  Created by Arjav Lad on 05/02/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

class SelectLocationVC: UITableViewController {
    var selectionMandatory: Bool = true

    var companies: [RMOffice] = []
    var selectedCompany: RMOffice?
    var backClosure: ((RMOffice?)-> Void)?
    var filteredCompanies = [RMOffice]()

    @IBOutlet weak var searchTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Third Place Office".localized
        Analytics.shared.trackScreen(name: "Select Third Place Office")
        
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        self.tableView.estimatedRowHeight = 44
        self.searchTextField.layer.cornerRadius = 16.5
        self.searchTextField.layer.borderColor = #colorLiteral(red: 0.9254901961, green: 0.937254902, blue: 0.9450980392, alpha: 1)
        self.searchTextField.layer.borderWidth = 1

        let backButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "iconBack"), style: .plain, target: self, action: #selector(self.onBackTap(_:)))
        backButton.tintColor = APP_COLOR_THEME
        self.navigationItem.leftBarButtonItem = backButton

        self.setLeftPadding(12+22+12)
        self.getAllCompanyList()

        NotificationCenter.default.addObserver(self, selector: #selector(SearchLocationVC.textDidChange), name:  NSNotification.Name.UITextFieldTextDidChange, object: self.searchTextField)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setLeftPadding(_ padding: CGFloat) {
        var leftFrame : CGRect = self.searchTextField.frame
        leftFrame.origin = .zero
        leftFrame.size.width = padding
        let leftImageViewContainer = UIView.init(frame: leftFrame)

        self.searchTextField.leftViewMode = .always
        self.searchTextField.leftView = leftImageViewContainer
    }

    func getAllCompanyList()  {
        self.showLoader()
        APIManager.shared.fetchLocationList{ (result, error) in
            self.hideLoader()
            if let error = error {
                self.showAlert("Error".localized, message: error.localizedDescription)
            } else {
                self.companies = result
                self.filterContentForSearchText("")
                self.tableView.reloadData()
            }
        }
    }

    @IBAction func onBackTap(_ sender: UIBarButtonItem) {
        if self.selectionMandatory {
            if self.selectedCompany == nil {
                self.showAlert("Required".localized, message: "Please select company".localized)
                return;
            }
        }
        self.backClosure?(self.selectedCompany)
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredCompanies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.tintColor = APP_COLOR_THEME
        let company = self.filteredCompanies[indexPath.row]

        if self.selectedCompany == company {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        cell.selectionStyle = .default
        cell.textLabel?.text =  company.name
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let company = self.filteredCompanies[indexPath.row]
        if self.selectedCompany == company {
            if self.selectionMandatory {
                //                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            } else {
                self.selectedCompany = nil
                //                tableView.cellForRow(at: indexPath)?.accessoryType = .none
            }
        } else {
            self.selectedCompany = company
            //            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        tableView.reloadData()
    }

    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        if searchText.count == 0 {
            self.filteredCompanies = self.companies
        } else {
            self.filteredCompanies = self.companies.filter({ $0.name.lowercased().contains(searchText.lowercased())})
        }
        self.tableView.reloadData()
    }

    @objc func textDidChange() {
        self.filterContentForSearchText(self.searchTextField.text ?? "")
    }


}
