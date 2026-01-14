//
//  MediaGroupType.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 12.01.2026.
//

import Foundation

enum MediaGroupType: String, Codable, CaseIterable {
    case dublicatedPhotos
    case similiarPhotos
    case screenshots
    case livePhotos
    case screenRecordings
    case similiarVideos
    case allVideos
    case allPhotos
    
    var assetType: AssetType {
        switch self {
        case .allVideos, .similiarVideos: .video
        default: .image
        }
    }
    nonisolated
    enum AssetType: String, Codable, CaseIterable {
        case image, video
    }
    
    var needAnalizeAI: Bool {
        switch self {
        case .similiarPhotos, .similiarVideos, .dublicatedPhotos: true
        default: false
        }
    }
    
    var presentingOnPicker: Bool {
        switch self {
        case .allVideos, .allPhotos: false
        default: true
        }
    }
    
    var image: ImageResource {
        switch self {
        case .dublicatedPhotos:
                .image
        case .similiarPhotos:
                .video
        case .screenshots:
                .screenshots
        case .livePhotos:
                .lifePhotos
        case .screenRecordings:
                .screenRecordings
        case .similiarVideos:
                .video
        case .allVideos:
                .video
        case .allPhotos:
                .image
        }
    }
}
