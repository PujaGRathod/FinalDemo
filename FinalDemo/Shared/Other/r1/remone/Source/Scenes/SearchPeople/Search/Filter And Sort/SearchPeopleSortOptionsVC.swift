//
//  SearchPeopleSortOptionsVC.swift
//  remone
//
//  Created by Arjav Lad on 31/01/18.
//  Copyright © 2018 Inheritx. All rights reserved.
//

import UIKit

protocol SearchPeopleSortOptionsVCDelegate {
    func sort(with option: SortingOptions)
}

class SearchPeopleSortOptionsVC: UITableViewController {

    var selectedOption: SortingOptions = .name
    var options: [SortingOptions] = [.name,.status,.distance,.position,.department,.comapnyname,.skill,.covergence]

    var delegate: SearchPeopleSortOptionsVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        Analytics.shared.trackScreen(name: "Search People Sort By")
        self.tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.delegate?.sort(with: self.selectedOption)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell
        if let cellDeq = tableView.dequeueReusableCell(withIdentifier: "SortingOptionsTblCell") {
            cell = cellDeq
        } else {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "SortingOptionsTblCell")
        }

        let option = self.options[indexPath.row]
        cell.textLabel?.text = option.title
        if option == self.selectedOption {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedOption = self.options[indexPath.row]
        tableView.reloadData()
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
