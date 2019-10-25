//
//  SelectPositionVC.swift
//  Remone_Office_Favorite
//
//  Created by Arjav Lad on 17/01/18.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit

class SelectPositionVC: UITableViewController {

    enum SelectionMode {
        case position
        case department
    }

    var selectionMandatory: Bool = true

    private var positions = [RMPosition]()
    private var filteredPositions = [RMPosition]()
    private var departments = [RMDepartment]()
    private var filteredDepartments = [RMDepartment]()

    var selectedPosition: RMPosition?
    var selectedDepartment: RMDepartment?
    var selectionMode: SelectionMode!

    var backPositionClosure: ((RMPosition?)->Void)?
    var backDepartmentClosure: ((RMDepartment?)->Void)?

    var isPositionMode: Bool {
        return (self.selectionMode == .position)
    }
    
    @IBOutlet weak var searchTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        self.tableView.estimatedRowHeight = 44
        self.searchTextField.layer.cornerRadius = 16.5
        self.searchTextField.layer.borderColor = #colorLiteral(red: 0.9254901961, green: 0.937254902, blue: 0.9450980392, alpha: 1)
        self.searchTextField.layer.borderWidth = 1

        let backButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "iconBack"), style: .plain, target: self, action: #selector(self.onBackTap(_:)))
        backButton.tintColor = APP_COLOR_THEME
        self.navigationItem.leftBarButtonItem = backButton

        //        self.tableView.selectRow(at: self.selectedIndexPath, animated: false, scrollPosition: .none)
        if self.isPositionMode {
            self.fetchPositionData()
        } else {
            self.fetchDepartments()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(SearchLocationVC.textDidChange), name:  NSNotification.Name.UITextFieldTextDidChange, object: self.searchTextField)
        
        self.setLeftPadding(12+22+12)
    }

    override func viewWillAppear(_ animated: Bool) {
        Analytics.shared.trackScreen(name: "Select Position")
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }
    
    func setLeftPadding(_ padding: CGFloat) {
        var leftFrame : CGRect = self.searchTextField.frame
        leftFrame.origin = .zero
        leftFrame.size.width = padding
        let leftImageViewContainer = UIView.init(frame: leftFrame)
        
        self.searchTextField.leftViewMode = .always
        self.searchTextField.leftView = leftImageViewContainer
    }

    func fetchDepartments() {
        self.showLoader()
        APIManager.shared.fetchDepartmentList { (list, error) in
            self.departments = list
            self.filteredDepartments = self.departments
            self.hideLoader()
            
            //            if let selectedDepartment = self.data.3,
            //                let index = self.filteredDepartments.index(of: selectedDepartment) {
            //                self.selectedIndexPath = IndexPath(item: index, section: 0)
            //            }

            self.tableView.reloadData()
        }
    }

    func fetchPositionData()  {
        self.showLoader()
        APIManager.shared.fetchPositionList { (positions, error) in
            self.positions = positions
            self.filteredPositions = self.positions
            self.hideLoader()
            
            //            if let selectedDepartment = self.data.2,
            //                let index = self.filteredPositions.index(of: selectedDepartment) {
            //                self.selectedIndexPath = IndexPath(item: index, section: 0)
            //            }

            self.tableView.reloadData()
        }
    }
    
    @IBAction func onBackTap(_ sender: UIBarButtonItem) {
        if self.isPositionMode {
            if self.selectionMandatory &&
                self.selectedPosition == nil {
                self.showAlert("Required".localized, message: "Please select position".localized)
                return
            } else {
                self.backPositionClosure?(self.selectedPosition)
            }
        } else {
            if self.selectionMandatory &&
                self.selectedDepartment == nil {
                self.showAlert("Required".localized, message: "Please select department".localized)
                return
            } else {
                self.backDepartmentClosure?(self.selectedDepartment)
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isPositionMode {
            return self.filteredPositions.count
        }
        return self.filteredDepartments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.tintColor = APP_COLOR_THEME
        cell.selectionStyle = .default
        if self.isPositionMode {
            let position = self.filteredPositions[indexPath.row]
            if self.selectedPosition == position {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            cell.textLabel?.text = position.name
        } else {
            let department = self.filteredDepartments[indexPath.row]
            if department == selectedDepartment {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            cell.textLabel?.text = department.name
        }
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.isPositionMode {
            let position = self.filteredPositions[indexPath.row]
            if self.selectedPosition == position {
                if !self.selectionMandatory {
                    self.selectedPosition = nil
                }
            } else {
                self.selectedPosition = position
            }

        } else {
            let department = self.filteredDepartments[indexPath.row]
            if department == selectedDepartment {
                if !self.selectionMandatory {
                    self.selectedDepartment = nil
                }
            } else {
                self.selectedDepartment = department
            }
        }
        tableView.reloadData()
    }
}

extension SelectPositionVC {
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        if searchText.count == 0 {
            if self.isPositionMode {
                self.filteredPositions = self.positions
            } else {
                self.filteredDepartments = self.departments
            }
        } else {
            if self.isPositionMode {
                self.filteredPositions = self.positions.filter({ $0.name.lowercased().contains(searchText.lowercased())})
            } else {
                self.filteredDepartments = self.departments.filter({ $0.name.lowercased().contains(searchText.lowercased())})
            }
        }
        self.tableView.reloadData()
    }
}
extension SelectPositionVC: UITextFieldDelegate {
    @objc func textDidChange() {
        self.filterContentForSearchText(self.searchTextField.text ?? "")
    }
}
