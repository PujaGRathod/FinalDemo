//
//  ArrayExtension.swift
//  WakeUppApp
//
//  Created by Admin on 18/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
