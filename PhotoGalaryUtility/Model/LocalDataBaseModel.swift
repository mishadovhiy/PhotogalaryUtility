//
//  LocalDataBaseModel.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 14.01.2026.
//

import Foundation

struct LocalDataBaseModel: Codable {
    var metadataHelper: MetadataHelper = .init()
    var general: General = .init()
    
    struct General: Codable {
        var onboardingCompleted: Bool = false
    }
    
    struct MetadataHelper: Codable {
        var fileSizes: [MediaGroupType: CGFloat] = [:]
        var filesCount: [MediaGroupType: Int] = [:]
        var proccessedFilesCount: [MediaGroupType: Int] = [:]
    }
}
