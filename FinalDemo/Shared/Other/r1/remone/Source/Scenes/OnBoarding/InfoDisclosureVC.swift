//
//  InfoDisclosureVC.swift
//  remone
//
//  Created by Arjav Lad on 20/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit
import Eureka

class InfoDisclosureVC: FormViewController {

    @IBOutlet weak var btnNext: UIBarButtonItem!
    var settings: [UserSettings: Bool] = [ .disclosureInfo: true,
                                                 .name: true,
//                                                 .ruby: true,
                                                 .position: true,
                                                 .department: true,
                                                 .company: true ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        Analytics.shared.trackScreen(name: "Information Disclosure")

        form
            +++ Section(header: "", footer: "If you give permission, you will be displayed in \"Search People\".".localized)
            <<< SwitchRow(UserSettings.disclosureInfo.rawValue) { row in      // initializer
                row.title = "Information disclosure permission".localized
                }.onChange { row in
                    self.settings[.disclosureInfo] = row.value!
                    self.changeAll(row.value!)
                }.cellUpdate { cell, row in
                    cell.switchControl.isOn = self.settings[.disclosureInfo]!
                    row.value = self.settings[.disclosureInfo]
                    cell.switchControl.onTintColor = APP_COLOR_THEME
                    cell.textLabel?.font = HiraginoSansW3(withSize: 12)
            }
            +++ Section("Basic Information".localized)
            <<< SwitchRow(UserSettings.name.rawValue) { row in      // initializer
                row.title = "Name".localized
                }.onChange { row in
                    self.settings[.name] = row.value!
                }.cellUpdate { cell, row in
                    cell.switchControl.isEnabled = self.settings[.disclosureInfo]!
                    cell.switchControl.isOn = self.settings[.name]!
                    row.value = self.settings[.name]
                    cell.switchControl.onTintColor = APP_COLOR_THEME
                    cell.textLabel?.font = HiraginoSansW3(withSize: 12)
            }
//            <<< SwitchRow(UserSettings.ruby.rawValue) { row in      // initializer
//                row.title = "Ruby".localized
//                }.onChange { row in
//                    self.settings[.ruby] = row.value!
//                }.cellUpdate { cell, row in
//                    cell.switchControl.isOn = self.settings[.ruby]!
//                    cell.switchControl.isEnabled = self.settings[.disclosureInfo]!
//                    row.value = self.settings[.ruby]
//                    cell.switchControl.onTintColor = APP_COLOR_THEME
//                    cell.textLabel?.font = HiraginoSansW3(withSize: 12)
//            }

            <<< SwitchRow(UserSettings.position.rawValue) { row in      // initializer
                row.title = "Position".localized
                }.onChange { row in
                    self.settings[.position] = row.value!
                }.cellUpdate { cell, row in
                    cell.switchControl.isOn = self.settings[.position]!
                    row.value = self.settings[.position]
                    cell.switchControl.isEnabled = self.settings[.disclosureInfo]!
                    cell.switchControl.onTintColor = APP_COLOR_THEME
                    cell.textLabel?.font = HiraginoSansW3(withSize: 12)
            }
            <<< SwitchRow(UserSettings.department.rawValue) { row in      // initializer
                row.title = "Department".localized
                }.onChange { row in
                    self.settings[.department] = row.value!
                }.cellUpdate { cell, row in
                    cell.switchControl.isOn = self.settings[.department]!
                    row.value = self.settings[.department]
                    cell.switchControl.isEnabled = self.settings[.disclosureInfo]!
                    cell.switchControl.onTintColor = APP_COLOR_THEME
                    cell.textLabel?.font = HiraginoSansW3(withSize: 12)
            }
            <<< SwitchRow(UserSettings.company.rawValue) { row in      // initializer
                row.title = "Company".localized
                }.onChange { row in
                   self.settings[.company] = row.value!
                }.cellUpdate { cell, row in
                    cell.switchControl.isOn = self.settings[.company]!
                    row.value = self.settings[.company]
                    cell.switchControl.isEnabled = self.settings[.disclosureInfo]!
                    cell.switchControl.onTintColor = APP_COLOR_THEME
                    cell.textLabel?.font = HiraginoSansW3(withSize: 12)
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.addShadowToNavigationbar()
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

    func changeAll(_ show: Bool) {
        for var setting in self.settings {
            setting.value = show
            if let row = self.form.rowBy(tag: setting.key.rawValue) as? SwitchRow {
                row.value = show
                row.updateCell()
            }
        }
    }

    @IBAction func onNextTap(_ sender: UIBarButtonItem) {
        if let session = APIManager.shared.loginSession {
            session.user.settings = self.settings
            session.save()
            self.showLoader()
            APIManager.shared.updateUserSettings(setings: session.user.settings, { (success) in
                self.hideLoader()
                if success {
                    self.performSegue(withIdentifier: "segueShowImageIploaderVC", sender: nil)
                } else {
                    self.showAlert("Failed!".localized, message: "Settings could not be saved!".localized)
                }
            })
        }
    }
}
