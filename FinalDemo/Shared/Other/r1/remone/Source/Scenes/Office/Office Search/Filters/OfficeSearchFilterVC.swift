//
//  OfficeSearchFilterVC.swift
//  remone
//
//  Created by Arjav Lad on 03/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

typealias OfficeSearchFilterClosure = ((OfficeSearchFilter?, OfficeSearchHistory?) -> Void)

class OfficeSearchFilterVC: UIViewController, OfficeSearchFilterBusinessDayVCDelegate {

    var adapter: OfficeSearchFilterAdapter!
    var selectedFilter: OfficeSearchFilter!
    private var closure: OfficeSearchFilterClosure? = nil
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Analytics.shared.trackScreen(name: "Office filter by")
        self.adapter = OfficeSearchFilterAdapter.init(with: self.tableView, withDelegate: self, withFilter: self.selectedFilter)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.adapter.resignfirstResponder()

    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueShowSelectWeekdaysVC" {
            if let businessDaysVC = segue.destination as? OfficeSearchFilterBusinessDayVC {
                businessDaysVC.filter = self.selectedFilter
                businessDaysVC.delegate = self
            }
        } else if segue.identifier == "segueShowOfficeSearchHistoryVC" {
            if let historyVC = segue.destination as? OfficeSearchHistoryVC {
                historyVC.closure = closure
            }
        }
    }


    @IBAction func onApplyTap(_ sender: UIBarButtonItem) {
        if !self.selectedFilter.isApplied {
            self.showAlert("Required!".localized, message: "Please select at least one filter option.".localized)
        } else {
            self.navigationController?.dismiss(animated: true, completion: {
                self.closure?(self.selectedFilter, nil)
            })
        }
    }

    @IBAction func onCancelTap(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: {
            self.closure?(nil, nil)
        })
    }

    class func showOfficeFiler(on vc: UIViewController, filter: OfficeSearchFilter?, _ completion: @escaping OfficeSearchFilterClosure) {
        let storyBoard = UIStoryboard.init(name: "OfficeSearch", bundle: nil)
        if let nav = storyBoard.instantiateViewController(withIdentifier: "navOfficeFilter") as? UINavigationController {
            if let filterVC = nav.viewControllers.first as? OfficeSearchFilterVC {
                filterVC.closure = completion
                if let filter = filter {
                    filterVC.selectedFilter = filter
                    vc.present(nav, animated: true, completion: {

                    })
                } else {
                    filterVC.selectedFilter = OfficeSearchFilter.defaultOfficeSearchFilter.copy() as! OfficeSearchFilter
                    vc.hideLoader()
                    vc.present(nav, animated: true, completion: {

                    })
                }
            }
        }
    }

    func finishedSelectingDays(_ days: [OfficeWorkingDays]) {
        self.selectedFilter.businessDays = days
        self.adapter.updateSelectedDays()
//        self.adapter = OfficeSearchFilterAdapter.init(with: self.tableView, withDelegate: self, withFilter: self.selectedFilter)
    }

}

extension OfficeSearchFilterVC: OfficeSearchFilterAdapterDelegate {

    func showSelectWeekDays() {
        self.performSegue(withIdentifier: "segueShowSelectWeekdaysVC", sender: self.selectedFilter)
    }

    func showSearchHistory() {
        self.performSegue(withIdentifier: "segueShowOfficeSearchHistoryVC", sender: self)
    }

}
