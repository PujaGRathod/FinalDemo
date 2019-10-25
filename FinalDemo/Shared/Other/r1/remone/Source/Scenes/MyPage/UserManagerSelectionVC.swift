//
//  UserManagerSelectionVC.swift
//  remone
//
//  Created by Arjav Lad on 24/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

class UserManagerSelectionVC: UITableViewController {

    @IBOutlet weak var searchTextField: UITextField!
    
    private var filteredManagers = [RMUser]()
    private var allManagers = [RMUser]()
    var selectedManager: RMUser?
    var reloadProfile: UserProfileReload?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchTextField.layer.cornerRadius = 16.5
        self.searchTextField.layer.borderColor = #colorLiteral(red: 0.9254901961, green: 0.937254902, blue: 0.9450980392, alpha: 1)
        self.searchTextField.layer.borderWidth = 1

        let backButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "iconBack"), style: .plain, target: self, action: #selector(self.onBackTap(_:)))
        backButton.tintColor = APP_COLOR_THEME
        self.navigationItem.leftBarButtonItem = backButton
        
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        self.getManagers()
        
        self.setLeftPadding(12+22+12)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SearchLocationVC.textDidChange), name:  NSNotification.Name.UITextFieldTextDidChange, object: self.searchTextField)
    }

    override func viewWillAppear(_ animated: Bool) {
        Analytics.shared.trackScreen(name: "Select Manager")
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
    
    private func getManagers() {
        self.showLoader()
        _ = APIManager.shared.getManagers { (managers, error) in
            self.hideLoader()
            self.allManagers = managers
            self.filteredManagers = self.allManagers
            self.tableView.reloadData()
        }
    }
    
    private func updateManager() {
        if let manager = self.selectedManager {
            APIManager.shared.set(manager: manager, completion: { (error) in
                if let error = error {
                    self.showAlert("Error".localized, message: error.localizedDescription)
                } else {
                    APIManager.shared.loginSession?.user.manager = manager
                    APIManager.shared.loginSession?.save()
                    self.reloadProfile?()
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
    }
    
    @IBAction func onBackTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredManagers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let manager = self.filteredManagers[indexPath.row]
        if let selectedManager = self.selectedManager,
            manager.id == selectedManager.id {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        cell.textLabel?.text = manager.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let manager = self.filteredManagers[indexPath.row]
        if let selectedManager = self.selectedManager,
            let indexPath = self.indexPath(for: selectedManager) {
            
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
        self.selectedManager = manager
        if let indexPath = self.indexPath(for: manager) {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        self.updateManager()
    }

    private func indexPath(for manager: RMUser) -> IndexPath? {
        if let index = self.filteredManagers.index(of: manager) {
            return IndexPath(row: index, section: 0)
        }
        return nil
    }
}

extension UserManagerSelectionVC {
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        if searchText.count == 0 {
            self.filteredManagers = self.allManagers
        } else {
            self.filteredManagers = self.allManagers.filter({ $0.name.lowercased().contains(searchText.lowercased())})
        }
        self.tableView.reloadData()
    }
}
extension UserManagerSelectionVC: UITextFieldDelegate {
    @objc func textDidChange() {
        self.filterContentForSearchText(self.searchTextField.text ?? "")
    }
}
