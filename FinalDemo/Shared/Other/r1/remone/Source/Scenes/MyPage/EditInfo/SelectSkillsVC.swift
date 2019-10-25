//
//  SelectSkillsVC.swift
//  Remone_Office_Favorite
//
//  Created by Arjav Lad on 17/01/18.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit

class SelectSkillsVC: UITableViewController {

    var selectionMandatory: Bool = true

    var skills: [RMSkill] = []
    var selectedSkills: [RMSkill] = []
    var backClosure: (([RMSkill])-> Void)?
    var filteredSkills = [RMSkill]()
    
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Skill".localized
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        self.tableView.estimatedRowHeight = 44
        self.searchTextField.layer.cornerRadius = 16.5
        self.searchTextField.layer.borderColor = #colorLiteral(red: 0.9254901961, green: 0.937254902, blue: 0.9450980392, alpha: 1)
        self.searchTextField.layer.borderWidth = 1
        
        let backButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "iconBack"), style: .plain, target: self, action: #selector(self.onBackTap(_:)))
        backButton.tintColor = APP_COLOR_THEME
        self.navigationItem.leftBarButtonItem = backButton
        
        self.setLeftPadding(12+22+12)
        
        self.getAllSkillList()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SearchLocationVC.textDidChange), name:  NSNotification.Name.UITextFieldTextDidChange, object: self.searchTextField)
    }

    override func viewWillAppear(_ animated: Bool) {
        Analytics.shared.trackScreen(name: "Select Skills")
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
    
    func getAllSkillList()  {
        self.showLoader()
        APIManager.shared.fetchSkillList { (result, error) in
            self.hideLoader()
            if let error = error {
                self.showAlert("Error".localized, message: error.localizedDescription)
            } else {
                self.skills = result
                self.filterContentForSearchText("")
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func onBackTap(_ sender: UIBarButtonItem) {
        if self.selectionMandatory {
            if self.selectedSkills.count <= 0 {
                self.showAlert("Required".localized, message: "Please select skill".localized)
                return;
            }
        }
        self.backClosure?(self.selectedSkills)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredSkills.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.tintColor = APP_COLOR_THEME
        let skill = self.filteredSkills[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        if self.selectedSkills.contains(skill) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.selectionStyle = .default
        cell.textLabel?.text =  skill.name
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let skill = self.filteredSkills[indexPath.row]
        if self.selectedSkills.contains(skill),
            let index = self.selectedSkills.index(of: skill) {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            self.selectedSkills.remove(at: index)
        } else {
            self.selectedSkills.append(skill)
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        if searchText.count == 0 {
            self.filteredSkills = self.skills
        } else {
            self.filteredSkills = self.skills.filter({ $0.name.lowercased().contains(searchText.lowercased())})
        }
        self.tableView.reloadData()
    }
    
}

extension SelectSkillsVC {
    
    @objc func textDidChange() {
        self.filterContentForSearchText(self.searchTextField.text ?? "")
    }
}
