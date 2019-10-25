//
//  StructAssortedMsgs.swift
//  WakeUppApp
//
//  Created by Admin on 07/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import Foundation

struct AssortedMsgs
{
    var Date: String
    //var DtDate: Date
    var Msgs: [Any]
    
    init(date:String, msgs:[Any]) {
        self.Date = date
        self.Msgs = msgs
        
    }
}
