//
//  SearchPeopleFilterVC.swift
//  remone
//
//  Created by Arjav Lad on 03/02/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

typealias SearchPeopleFilterClosure = ((SearchPeopleFilter?) -> Void)

class SearchPeopleFilterVC: UITableViewController {

    var filter: SearchPeopleFilter!

    @IBOutlet weak var btnCancel: UIBarButtonItem!
    @IBOutlet weak var btnApply: UIBarButtonItem!
    @IBOutlet weak var switchOnlyGoodAffinityPeople: UISwitch!
    @IBOutlet weak var switchOnlyTeamMembers: UISwitch!
    @IBOutlet weak var switchOnlyInHouse: UISwitch!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var lblCompanyNameSelected: UILabel!
    @IBOutlet weak var lblDepartmentSelected: UILabel!
    @IBOutlet weak var lblPositionSelected: UILabel!
    @IBOutlet weak var lblPlaceSelected: UILabel!
    @IBOutlet weak var lblSkillsSelected: UILabel!

    var closure: SearchPeopleFilterClosure?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtSearch.autocorrectionType = .no
        Analytics.shared.trackScreen(name: "Search People Filter By")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.textDidChange(_:)), name: Notification.Name.UITextFieldTextDidChange, object: self.txtSearch)
        self.applyFilterValues()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowSelectSkillsVC" {
            if let selectSkillvc = segue.destination as? SelectSkillsVC {
                selectSkillvc.selectionMandatory = false
                selectSkillvc.selectedSkills = self.filter.skills
                selectSkillvc.backClosure = { (selectedSkills) in
                    self.filter.skills = selectedSkills
                    self.applyFilterValues()
                }
            }
        } else if segue.identifier == "segueShowSelectPositionVC"{
            if let selectPositionVc = segue.destination as? SelectPositionVC {
                if let mode = sender as? SelectPositionVC.SelectionMode {
                    selectPositionVc.selectionMandatory = false
                    selectPositionVc.selectionMode = mode
                    if mode == .position {
                        selectPositionVc.title = "Position".localized
                        selectPositionVc.selectedPosition = self.filter.position
                        selectPositionVc.backPositionClosure = { (position) in
                            if let position = position {
                                self.filter.position = position
                                self.applyFilterValues()
                            }
                        }
                    } else {
                        selectPositionVc.title = "Department".localized
                        selectPositionVc.selectedDepartment = self.filter.department
                        selectPositionVc.backDepartmentClosure = { (dept) in
                            if let dept = dept {
                                self.filter.department = dept
                                self.applyFilterValues()
                            }
                        }
                    }
                }
            }
        } else if segue.identifier == "segueShowSelectCompanyVC" {
            if let selectCompany = segue.destination as? SelectCompanyVC {
                selectCompany.selectionMandatory = false
                selectCompany.selectedCompany = self.filter.company
                selectCompany.backClosure = { (company) in
                    self.filter.company = company
                    self.applyFilterValues()
                }
            }
        } else if segue.identifier == "segueShowSelectLocationVC" {
            if let selectCompany = segue.destination as? SelectLocationVC {
                selectCompany.selectionMandatory = false
                selectCompany.selectedCompany = self.filter.location
                selectCompany.backClosure = { (company) in
                    self.filter.location = company
                    self.applyFilterValues()
                }
            }
        } else if segue.identifier == "segueShowSearchPeopleHistoryVC" {
            if let historyVC = segue.destination as? SearchPeopleHistoryVC {
                historyVC.closure = self.closure
            }
        }
    }

    class func showSearchPeopleFilter(on vc: UIViewController, filter: SearchPeopleFilter?, _ completion: @escaping SearchPeopleFilterClosure) {
        let storyBoard = UIStoryboard.init(name: "SearchPeople", bundle: nil)
        if let nav = storyBoard.instantiateViewController(withIdentifier: "navSearchPeopleFilter") as? UINavigationController {
            if let filterVC = nav.viewControllers.first as? SearchPeopleFilterVC {
                filterVC.closure = completion
                filterVC.filter = filter ?? SearchPeopleFilter.generateDefaultFilter()
                vc.present(nav, animated: true, completion: {

                })
            }
        }
    }

    @objc func textDidChange(_ notification: Notification) {
        self.filter.searchKeyword = self.txtSearch.text?.trimString() ?? ""
    }

    func applyFilterValues() {

        self.switchOnlyInHouse.isOn = self.filter.showInHouseOnly
        self.switchOnlyTeamMembers.isOn = self.filter.showTeamMembersOnly
        self.switchOnlyGoodAffinityPeople.isOn = self.filter.showOnlyGoodAffinityPeople

        self.txtSearch.text = self.filter.searchKeyword

        self.updateStatusSelection()

        self.lblPlaceSelected.text = self.filter.location?.name
        self.lblPositionSelected.text = self.filter.position?.name
        self.lblDepartmentSelected.text = self.filter.department?.name
        self.lblCompanyNameSelected.text = self.filter.company?.name
        let skills = self.filter.skills.map { (skill) -> String in
            return skill.name
        }
        self.lblSkillsSelected.text = skills.joined(separator: ",")
    }

    func selectOption(_ option: TimeStampStatus) {
        for status in self.filter.status {
            if status.key == option {
                if status.value == true {
                    self.filter.status[status.key] = false
                } else {
                    self.filter.status[status.key] = true
                }
            } else {
                self.filter.status[status.key] = false
            }
        }
        self.updateStatusSelection()
    }

    func updateStatusSelection() {
        for index in 0...3 {
            if let cell = self.tableView.cellForRow(at: IndexPath.init(row: index, section: 3)) {
                var value: Bool
                if index == 0 {
                    value = self.filter.status[.available] ?? false
                } else if index == 1 {
                    value = self.filter.status[.busy] ?? false
                } else if index == 2 {
                    value = self.filter.status[.away] ?? false
                } else {
                    value = self.filter.status[.workFinish] ?? false
                }
                if value {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            }
        }
    }

    @IBAction func onApplyTap(_ sender: UIBarButtonItem) {
        if !self.filter.isActive() {
            self.showAlert("Required!".localized, message: "Please select at least one filter option.".localized)
            return;
        }
        self.closure?(self.filter)
        self.navigationController?.dismiss(animated: true, completion: {
        })
    }

    @IBAction func onCancelTap(_ sender: UIBarButtonItem) {
        self.closure?(nil)
        self.navigationController?.dismiss(animated: true, completion: {
        })
    }

    @IBAction func onSwitchInhouseOnlyChange(_ sender: UISwitch) {
        self.filter.showInHouseOnly = sender.isOn
    }

    @IBAction func onSwitchTeamMembersOnlyChange(_ sender: UISwitch) {
        self.filter.showTeamMembersOnly = sender.isOn
    }

    @IBAction func onSwitchOnlyGoodAffinityPeopleChange(_ sender: UISwitch) {
        self.filter.showOnlyGoodAffinityPeople = sender.isOn
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 {
            // Search History
            self.performSegue(withIdentifier: "segueShowSearchPeopleHistoryVC", sender: nil)

        } else if indexPath.section == 1 {
            // Switch options
            if indexPath.row == 0 {
                self.switchOnlyInHouse.isOn = !self.switchOnlyInHouse.isOn
                self.onSwitchInhouseOnlyChange(self.switchOnlyInHouse)
            } else if indexPath.row == 1 {
                self.switchOnlyTeamMembers.isOn = !self.switchOnlyTeamMembers.isOn
                self.onSwitchTeamMembersOnlyChange(self.switchOnlyTeamMembers)
            } else if indexPath.row == 2 {
                self.switchOnlyGoodAffinityPeople.isOn = !self.switchOnlyGoodAffinityPeople.isOn
                self.onSwitchOnlyGoodAffinityPeopleChange(self.switchOnlyGoodAffinityPeople)
            }

        } else if indexPath.section == 2 {
            // Keyword
            self.txtSearch.becomeFirstResponder()

        } else if indexPath.section == 3 {
            // Status
            if indexPath.row == 0 {
                self.selectOption(.available)
            } else if indexPath.row == 1 {
                self.selectOption(.busy)
            } else if indexPath.row == 2 {
                self.selectOption(.away)
            } else if indexPath.row == 3 {
                self.selectOption(.workFinish)
            }

        } else if indexPath.section == 4 {
            // Basic Info
            if indexPath.row == 0 {
                self.performSegue(withIdentifier: "segueShowSelectPositionVC", sender: SelectPositionVC.SelectionMode.position)
            } else if indexPath.row == 1 {
                self.performSegue(withIdentifier: "segueShowSelectPositionVC", sender: SelectPositionVC.SelectionMode.department)
            } else if indexPath.row == 2 {
                self.performSegue(withIdentifier: "segueShowSelectCompanyVC", sender: nil)
            }

        } else if indexPath.section == 5 {
            // Skill
            self.performSegue(withIdentifier: "segueShowSelectSkillsVC", sender: nil)

        } else if indexPath.section == 6 {
            // Location
            self.performSegue(withIdentifier: "segueShowSelectLocationVC", sender: nil)
        }
    }

}
