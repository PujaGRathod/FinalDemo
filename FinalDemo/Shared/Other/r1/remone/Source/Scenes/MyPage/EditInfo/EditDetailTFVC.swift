//
//  EditDetailTFVC.swift
//  Remone_Office_Favorite
//
//  Created by Arjav Lad on 17/01/18.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit

class EditDetailTFVC: UITableViewController {

    var data: (Int, String, String)!
    var onBackClick: ((Int, String, String)->Void)?

    @IBOutlet weak var tfDetail: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = data.1
        self.tfDetail.text = data.2
    }

    override func viewWillAppear(_ animated: Bool) {
        Analytics.shared.trackScreen(name: "Edit Basic Information")
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.onBackClick?(self.data.0, (self.tfDetail.text?.trimString() ?? "") ,"")
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
