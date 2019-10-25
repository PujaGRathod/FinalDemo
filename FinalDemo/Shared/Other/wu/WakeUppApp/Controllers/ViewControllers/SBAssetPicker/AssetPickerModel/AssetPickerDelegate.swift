//
//  AssetPickerDelegate.swift
//  WakeUppApp
//
//  Created by Admin on 30/05/18.
//  Copyright © 2018 el. All rights reserved.
//

import Foundation

protocol AssetPickerDelegate:class {
    func assetPickerDidFinishSelectingAssets(withFilterAssetModels filterAssetModels:[FilterAssetModel])
    func assetPickerDidCancelSelectingAssets()
}
