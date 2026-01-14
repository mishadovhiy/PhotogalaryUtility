//
//  CompressQualityType.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 13.01.2026.
//

import Foundation
import AVFoundation

enum CompressQualityType: String, CaseIterable {
    case low, medium, high
    
    var presetName: String {
        switch self {
        case .low:
              AVAssetExportPresetLowQuality
        case .medium:
              AVAssetExportPresetMediumQuality
        case .high:
              AVAssetExportPresetHEVCHighestQuality
        }
    }
}
