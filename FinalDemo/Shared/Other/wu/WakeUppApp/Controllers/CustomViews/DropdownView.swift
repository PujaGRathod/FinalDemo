//
//  DropdownView.swift
//  WakeUppApp
//
//  Created by Admin on 18/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import UIKit

class DropdownView: UIView {
    
    @IBOutlet weak var tblView: UITableView!
    
    var arrMenus : [String]!
    
    var selectionHandler : ((_ result:Int)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tblView.register(UINib(nibName: "CellDropMenu", bundle: nil), forCellReuseIdentifier: "CellDropMenu")
    }
    
}

extension DropdownView : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellDropMenu") as! CellDropMenu
        let str = arrMenus[indexPath.row]
        if str == "Call History New"
        {
            cell.lbmenu.text = "Call History"
            cell.lblcount.text = ""
            cell.lblcount.isHidden = false
        }
        else
        {
            cell.lblcount.text = ""
            cell.lblcount.isHidden = true
            cell.lbmenu.text = arrMenus[indexPath.row]
        }
        
        cell.lbmenu?.font = UIFont.init(name: FT_Medium, size: 17)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMenus.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectionHandler!(indexPath.row)
    }
}

