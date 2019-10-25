//
//  OfficeSearchFilterBusinessDayVC.swift
//  remone
//
//  Created by Arjav Lad on 03/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

protocol OfficeSearchFilterBusinessDayVCDelegate {
    func finishedSelectingDays(_ days: [OfficeWorkingDays])
}

class OfficeSearchFilterBusinessDayVC: UIViewController, BusinessDayAdepterDelegate {

    @IBOutlet weak var tableView: UITableView!

    var filter: OfficeSearchFilter!
    var adapter: OfficeSearchFilterBusinessDayAdapter!
    var delegate: OfficeSearchFilterBusinessDayVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        Analytics.shared.trackScreen(name: "Select Business Days")

        self.adapter = OfficeSearchFilterBusinessDayAdapter.init(with: self.tableView, withDelegate: self, withDays: self.filter.businessDays)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.finishedSelectingDays(self.adapter.businessDays)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    

}
