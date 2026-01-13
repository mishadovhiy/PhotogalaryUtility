//
//  PhotogalaryPresentationModel.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import Foundation
import Photos

struct GalaryItemPresentationModel {
    let asset: AssetType
    var checkmarkSelected: Bool?
    var topLabel: String?
    var bottomLabel: String?
    
    var needCheckmarkIndicator: Bool {
        checkmarkSelected != nil
    }
    
    init(asset: AssetType,
         checkmarkSelected: Bool? = nil,
         topLabel: String? = nil,
         bottomLabel: String? = nil) {
        self.checkmarkSelected = checkmarkSelected
        self.topLabel = topLabel
        self.bottomLabel = bottomLabel
        self.asset = asset
    }
    
    enum AssetType {
        case phAsset(PHAsset)
        case bundleURL(URL)
        case serverURL(URL)
        case assetName(String)
    }
}
