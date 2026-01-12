//
//  similarityDataBaseModel.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 12.01.2026.
//

import Foundation

struct SimilarityDataBaseModel: Codable {
    var photos: [AssetID: [AssetID]]?
    
    struct AssetID: Codable, Hashable {
        let localIdentifier: String
    }
}

