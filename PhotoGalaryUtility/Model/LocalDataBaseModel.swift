//
//  LocalDataBaseModel.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 14.01.2026.
//

import Foundation

struct LocalDataBaseModel: Codable {
    var metadataHelper: MetadataHelper = .init()
    
    struct MetadataHelper: Codable {
        var fileSizes: [MediaGroupType: CGFloat] = [:]
        var filesCount: [MediaGroupType: Int] = [:]
    }
}
