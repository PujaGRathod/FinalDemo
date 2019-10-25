//
//  ViewController.swift
//  FinalDemo
//
//  Created by POOJA on 25/10/19.
//  Copyright © 2019 POOJA. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        /*
         userId          = "\(dictionary["userId"] ?? "")"
         userName
         */
        
        
        let dicData1 = ["userId":"1","userName":"Pujan"]
        let dicData2 = ["userId":"2","userName":"Punit"]
        
        let objData:UserModel = UserModel.init(dictionary: dicData1)
        //print("Get_ChatUsers - data: \(objData)")
        _ = CoreDbManager.sharedDatabase.saveUserInLocalDB(objFriend: objData)
        
        let objData2:UserModel = UserModel.init(dictionary: dicData2)
        //print("Get_ChatUsers - data: \(objData)")
        _ = CoreDbManager.sharedDatabase.saveUserInLocalDB(objFriend: objData2)
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func getData(_ sender: Any) {
        let arrUsers = CoreDbManager.sharedDatabase.getUserList(includeHiddens: false)
        print("Users--->\(arrUsers)")
    }
    


}

