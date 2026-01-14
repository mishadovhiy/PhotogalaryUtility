//
//  PHAsset.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 14.01.2026.
//

import Foundation
import Photos

extension PHAsset {
    var fileSize: Int64 {
        let resources = PHAssetResource.assetResources(for: self)
        let filterTargetResurces: [PHAssetResourceType]
        if self.duration == .zero  {
            filterTargetResurces = [.photo, .alternatePhoto, .alternatePhoto, .fullSizePhoto, .adjustmentBasePhoto]
        } else {
            filterTargetResurces = [.video, .fullSizeVideo]

        }
        
        let videoResources = resources.filter({
            filterTargetResurces.contains($0.type)
        })
        let size = videoResources.reduce(Int64(0)) { total, resource in
            let value = resource.value(forKey: "fileSize") as? Int64 ?? 0
            return total + value
        }
        
        return size
    }
    
}

extension BinaryInteger {
    var bytesToMegaBytes: Double {
        Double(self) / 1024 / 1024
    }
}

extension Double {
    var formated: String {
        .init(format: "%.2f", self)
    }
}
