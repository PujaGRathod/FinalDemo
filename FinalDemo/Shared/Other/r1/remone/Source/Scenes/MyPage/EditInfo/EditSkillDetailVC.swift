//
//  EditSkillDetailVC.swift
//  Remone_Office_Favorite
//
//  Created by Arjav Lad on 17/01/18.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit

class EditSkillDetailVC: UITableViewController {

    var skills : [RMSkill] = []
    var reloadProfile: UserProfileReload?

    @IBOutlet weak var btnComplete: UIBarButtonItem!
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = APIManager.shared.loginSession?.user {
            self.skills = user.skills
        }
        self.tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        Analytics.shared.trackScreen(name: "Edit Skills")
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onCancelClick(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCompletedClick(_ sender: UIBarButtonItem) {
        let skillIds = self.skills.map { $0.id }
        self.showLoader()
        APIManager.shared.updateUserSkills(with: skillIds) { (error) in
            self.hideLoader()
            if error != nil {
                self.showAlert("Error".localized, message: error?.localizedDescription)
            } else {
                APIManager.shared.loginSession?.user.skills = self.skills
                APIManager.shared.loginSession?.save()
                self.reloadProfile?()
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 1
        }
        return self.skills.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let lbl = cell.viewWithTag(100) as! UILabel

        if indexPath.row == self.skills.count {
            lbl.text = "Add skill".localized
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
        } else {
            cell.accessoryType = .none
            cell.selectionStyle = .none
            lbl.text = self.skills[indexPath.row].name
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row == self.skills.count {
            self.performSegue(withIdentifier: "segueShowSelectSkillsVC", sender: nil)
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 0.0001
        }
        return 36
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueShowSelectSkillsVC" {
            if let selectSkillvc = segue.destination as? SelectSkillsVC {
                selectSkillvc.selectedSkills = self.skills
                selectSkillvc.backClosure = { (selectedSkills) in
                    self.skills = selectedSkills
                    self.tableView.reloadData()
                }
            }
        }
    }
}
