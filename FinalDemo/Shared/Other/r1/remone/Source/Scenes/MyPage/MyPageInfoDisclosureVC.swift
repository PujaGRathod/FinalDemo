//
//  MyPageInfoDisclosureVC.swift
//  Remone_Office_Favorite
//
//  Created by Arjav Lad on 12/01/18.
//  Copyright © 2017 Inheritx. All rights reserved.
//

import UIKit

class MyPageInfoDisclosureVC: UIViewController {
    
    var adapter: InfoDisclosureAdapter!
    var reloadProfile: UserProfileReload?

    @IBOutlet weak var tblView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Information disclosure outside the company".localized

        let backButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "iconBack"), style: .plain, target: self, action: #selector(self.onBackTap(_:)))
        self.navigationItem.leftBarButtonItem = backButton

        self.adapter = InfoDisclosureAdapter(with: self.tblView, withDelegate: self)
        if let user = APIManager.shared.loginSession?.user {
            self.adapter.settings = user.settings
            self.adapter.loadLocalData {
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.shared.trackScreen(name: "Information disclosure outside the company")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("disclosue api\(self.adapter.settings)")
    }

    @IBAction func onBackTap(_ sender: UIBarButtonItem) {
        self.showLoader()
        APIManager.shared.updateUserSettings(setings:self.adapter.settings) { (result) in
            APIManager.shared.loginSession?.user.settings = self.adapter.settings
            APIManager.shared.loginSession?.save()
            self.reloadProfile?()
            self.hideLoader()
            self.navigationController?.popViewController(animated: true)
            print(result)
        }
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

}

extension MyPageInfoDisclosureVC: InfoDisclosureAdapterDelegate {
    
}

