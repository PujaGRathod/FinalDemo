//
//  StructChatList.swift
//  WakeUppApp
//
//  Created by Admin on 31/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import Foundation

enum ChatType {
    case Personal
    case Group
    case Broadcast
}

struct StructChatList
{
    var UniqueID : String
    var Title : String
    var Message : String
    var strDate : String
    var Date : Date
    var Photo : String
    var IsRead : String
    var IsPinned : String
    var ChatType : ChatType
    var OriginalModel : Any
}
