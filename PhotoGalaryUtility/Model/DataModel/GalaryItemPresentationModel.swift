//
//  PhotogalaryPresentationModel.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import Foundation
import Photos

struct GalaryItemPresentationModel {
    let asset: AssetModel
    let checkmarkSelected: Bool?
    let topLabel: String
    let bottomLabel: String
    
    init(asset: AssetModel,
         checkmarkSelected: Bool? = nil,
         topLabel: String,
         bottomLabel: String) {
        self.checkmarkSelected = checkmarkSelected
        self.topLabel = topLabel
        self.bottomLabel = bottomLabel
        self.asset = asset
    }
    
    struct AssetModel {
        let phAsset: PHAsset?
        let bundleURL: URL?
        let serverURL: URL?
        
        init(phAsset: PHAsset? = nil, bundleURL: URL? = nil, serverURL: URL? = nil) {
            self.phAsset = phAsset
            self.bundleURL = bundleURL
            self.serverURL = serverURL
        }
    }
}
