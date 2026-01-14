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

        let videoResources = resources.filter {
            $0.type == .video || $0.type == .fullSizeVideo
        }

        let size = videoResources.reduce(Int64(0)) { total, resource in
            let value = resource.value(forKey: "fileSize") as? Int64 ?? 0
            return total + value
        }

        return size//Double(size) / 1024 / 1024
    }

}

extension BinaryInteger {
    var bytesToMegaBytes: Double {
        Double(self) / 1024 / 1024
    }
}

extension String {
    var formated: String {
        .init(format: "%.2f", self)
    }
}
