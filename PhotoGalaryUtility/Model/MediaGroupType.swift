//
//  MediaGroupType.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 12.01.2026.
//

import Foundation

enum MediaGroupType: String, CaseIterable {
    case dublicatedPhotos
    case similiarPhotos
    case screenshots
    case livePhotos
    case screenRecordings
    case similiarVideos
    case allVideos
    
    var presentingOnPicker: Bool {
        switch self {
        case .allVideos: false
        default: true
        }
    }
    
    var image: ImageResource {
        .image
    }
}
