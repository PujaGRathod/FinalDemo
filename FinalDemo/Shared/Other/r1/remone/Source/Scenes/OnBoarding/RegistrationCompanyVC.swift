
//
//  RegistrationCompanyVC.swift
//  remone
//
//  Created by Arjav Lad on 20/12/17.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit

class RegistrationCompanyVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtCompany: CustomTextField!
    @IBOutlet weak var txtDepartment: CustomTextField!
    @IBOutlet weak var txtPosition: CustomTextField!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var btnNext: UIBarButtonItem!
    @IBOutlet weak var pickerCompany: UIPickerView!
    @IBOutlet weak var pickerPosition: UIPickerView!
    @IBOutlet weak var pickerDepartment: UIPickerView!

    //var skills: [RMSkill] = [RMSkill]()
    var position: [RMPosition] = [RMPosition]()
    var department: [RMDepartment] = [RMDepartment]()
    var company: [RMCompany] = [RMCompany]()

    var selectedCompany: RMCompany?
    var selectedPosition: RMPosition?
    var selectedDepartment: RMDepartment?

    var departmentLoaded = false
    var companyLoaded = false
    var positionLoaded = false

    var error: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        Analytics.shared.trackScreen(name: "Register Company Info")

//        self.txtCompany.delegate = self
        self.txtCompany.isHidden = true
        self.txtPosition.delegate = self
        self.txtDepartment.delegate = self
//        self.txtCompany.inputView = self.pickerCompany
//        self.txtPosition.inputView = self.pickerPosition
//        self.txtDepartment.inputView = self.pickerDepartment

//        self.loadAllData()

        //        let session = APIManager.shared.loginSession

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.removeShadowFromNavigationbar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        if segue.identifier == "segueShowSelectPositionVC" {
            if let selectPositionVc = segue.destination as? SelectPositionVC {
                if let mode = sender as? SelectPositionVC.SelectionMode {
                    selectPositionVc.selectionMode = mode
                    if mode == .position {
                        selectPositionVc.title = "Position".localized
                        selectPositionVc.selectedPosition = self.selectedPosition
                        selectPositionVc.backPositionClosure = { (position) in
                            if let position = position {
                                self.selectedPosition = position
                                self.txtPosition.text = position.name
                            }
                        }
                    } else {
                        selectPositionVc.title = "Department".localized
                        selectPositionVc.selectedDepartment = self.selectedDepartment
                        selectPositionVc.backDepartmentClosure = { (dept) in
                            if let dept = dept {
                                self.selectedDepartment = dept
                                self.txtDepartment.text = dept.name
                            }
                        }
                    }
                }
            }
        }
     }
    
    @IBAction func onSelectPosition(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueShowSelectPositionVC", sender: SelectPositionVC.SelectionMode.position)
    }
    
    @IBAction func onSelectDepartment(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueShowSelectPositionVC", sender: SelectPositionVC.SelectionMode.department)
    }
    
    @IBAction func onNextTap(_ sender: UIBarButtonItem) {
        if  let pos = self.selectedPosition,
            let dep = self.selectedDepartment {
            if let session = APIManager.shared.loginSession {
//                session.user.company = comp
                session.user.department = dep
                session.user.position = pos
                session.save()
                self.showLoader()
                session.user.updateProfile({ (success) in
                    self.hideLoader()
                    if success {
                        self.performSegue(withIdentifier: "segueInfoDisclosureVC", sender: nil)
                    } else {
                        self.showAlert("Failed!".localized, message: "Data could not be saved!".localized)
                    }
                })
            }
        } else {
            self.showAlert("no data selected".localized,
                           message: "Please select data.".localized,
                            actionTitles: [("select".localized, .cancel), ("skip".localized, .default)],
                            cancelTitle: nil,
                            actionHandler: { (action, index) in
                                if index == 0 {
                                    self.txtPosition.becomeFirstResponder()
                                } else {
                                    self.performSegue(withIdentifier: "segueInfoDisclosureVC", sender: nil)
                                }
            })
        }
    }
    
    @IBAction func onSkipTap(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueInfoDisclosureVC", sender: nil)
    }

    func loadAllData() {
        self.showLoader("Loading Data".localized)
//        self.txtCompany.isEnabled = false
        self.txtPosition.isEnabled = false
        self.txtDepartment.isEnabled = false

        APIManager.shared.fetchPositionList { (positions, error) in
            self.positionLoaded = true
            if positions.count == 0 {
                self.error = true
            }
            self.position = positions
            self.pickerPosition.reloadAllComponents()
            self.checkIfDataLoaded()
        }

//        APIManager.shared.fetchCompanyList { (companies, error) in
//            self.companyLoaded = true
//            if companies.count == 0 {
//                self.error = true
//            }
//            self.company = companies
//            self.pickerCompany.reloadAllComponents()
//            self.checkIfDataLoaded()
//        }

        APIManager.shared.fetchDepartmentList { (departments, error) in
            self.departmentLoaded = true
            if departments.count == 0 {
                self.error = true
            }
            self.department = departments
            self.pickerDepartment.reloadAllComponents()
            self.checkIfDataLoaded()
        }
    }

    func updateTexts() {
        self.txtDepartment.text = self.selectedDepartment?.name
        self.txtPosition.text = self.selectedPosition?.name
    }

    func checkIfDataLoaded() {
        if self.departmentLoaded &&
            self.positionLoaded {
            self.hideLoader()
            if self.error {
                self.showAlert("Error".localized,
                               message: "Data not found!".localized,
                    actionTitles: [("retry".localized, .default)],
                    cancelTitle: "Cancel".localized,
                    actionHandler: { (action, index) in
                    self.loadAllData()
                }, cancelActionHandler: { (action) in

                })
            }
//            self.txtCompany.isEnabled = (self.company.count > 0)
            self.txtPosition.isEnabled = (self.position.count > 0)
            self.txtDepartment.isEnabled = (self.department.count > 0)
        } else {
//            self.txtCompany.isEnabled = false
            self.txtPosition.isEnabled = false
            self.txtDepartment.isEnabled = false
        }
    }
}

extension RegistrationCompanyVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.txtDepartment {
            if self.department.count > 0 {
                self.selectedDepartment = self.department[self.pickerDepartment.selectedRow(inComponent: 0)]
            }
        } else if textField == self.txtPosition {
            if self.position.count > 0 {
                self.selectedPosition = self.position[self.pickerPosition.selectedRow(inComponent: 0)]
            }
        }
        self.updateTexts()
    }
    
    func createView(with title: String, with width: CGFloat) -> UIView {
        let mainFrame = CGRect.init(x: 10, y: 0, width: width-20, height: 80)
        let view = UIView.init(frame: mainFrame)
        view.backgroundColor = .clear
        
        let frameLabel = CGRect.init(x: 0, y: 0, width: mainFrame.width, height: mainFrame.height)
        let label = UILabel.init(frame: frameLabel)
        label.backgroundColor = .clear
        label.font = HiraginoSansW4(withSize: 14)
        label.textColor = APP_COLOR_THEME
        label.text = title
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        view.addSubview(label)
        return view
    }
    
}

extension RegistrationCompanyVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.pickerDepartment {
            return self.department.count
        } else if pickerView == self.pickerPosition {
            return self.position.count
        } else if pickerView == self.pickerCompany {
            return self.company.count
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var dataString: String = ""
        if pickerView == self.pickerDepartment {
            let data = self.department[row]
            dataString = data.name
        } else if pickerView == self.pickerPosition {
            let data = self.position[row]
            dataString = data.name
        } else if pickerView == self.pickerCompany {
            let data = self.company[row]
            dataString = data.name
        }
//        let text = NSAttributedString.init(string: dataString, attributes: [.foregroundColor : self.pickerDepartment.tintColor])
        let view = self.createView(with: dataString, with: pickerView.frame.width)
        return view
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
//        var dataString: String = ""
//        if pickerView == self.pickerDepartment {
//            let data = self.department[row]
//            dataString = data.name
//        } else if pickerView == self.pickerPosition {
//            let data = self.position[row]
//            dataString = data.name
//        } else if pickerView == self.pickerCompany {
//            let data = self.company[row]
//            dataString = data.name
//        }
//        let height = dataString.height(withConstrainedWidth: pickerView.frame.width - 20, font: HiraginoSansW4(withSize: 14))
//        return height
        return 40
    }
    
//    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
//        var dataString: String = ""
//        if pickerView == self.pickerDepartment {
//            let data = self.department[row]
//            dataString = data.name
//        } else if pickerView == self.pickerPosition {
//            let data = self.position[row]
//            dataString = data.name
//        } else if pickerView == self.pickerCompany {
//            let data = self.company[row]
//            dataString = data.name
//        }
//        let text = NSAttributedString.init(string: dataString, attributes: [.foregroundColor : self.pickerDepartment.tintColor])
//        return text
//    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.pickerDepartment {
            if self.department.count > 0 {
                self.selectedDepartment = self.department[row]
            }
        } else if pickerView == self.pickerPosition {
            if self.position.count > 0 {
                self.selectedPosition = self.position[row]
            }
        } else if pickerView == self.pickerCompany {
            if self.company.count > 0 {
                self.selectedCompany = self.company[row]
            }
        }
        self.updateTexts()
    }
}

class CustomTextField: UITextField {

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) ||
            action == #selector(UIResponderStandardEditActions.cut(_:))  ||
            action == #selector(UIResponderStandardEditActions.copy(_:)) ||
            action == #selector(UIResponderStandardEditActions.delete(_:)) ||
            action == #selector(UIResponderStandardEditActions.select(_:)) ||
            action == #selector(UIResponderStandardEditActions.selectAll(_:)) {
            return false
        }
        if let _ = sender as? UIMenuController {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

