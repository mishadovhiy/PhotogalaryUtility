//
//  PHLibraryEditorManager.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import Foundation
import Photos

struct PHLibraryEditorManager {
    func save(data: Data,
              date: String,
              completion: @escaping(_ success: Bool)->()) {
        PHPhotoLibrary.shared().performChanges({
            
            let request = PHAssetCreationRequest.forAsset()
            request.creationDate = .init(string: date)
            request.addResource(with: .photo, data: data, options: nil)
        }) { success, error in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    
    func delete(
        _ assets: [PHAsset],
        completion:@escaping()->()) {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
            }, completionHandler: { success, error in
                DispatchQueue.main.async {
                    completion()
                }
            })
        }
    
    func saveVideo(asset: AVAsset, completion: @escaping(Bool)->()) {
        guard let export = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset1280x720) else {
            completion(false)
            return
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")

        export.outputURL = url
        export.outputFileType = .mp4
        export.shouldOptimizeForNetworkUse = true

        export.exportAsynchronously {
            guard export.status == .completed else {
                completion(false)
                return
            }

            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }) { success, _ in
                try? FileManager.default.removeItem(at: url)

                DispatchQueue.main.async {
                    completion(success)
                }
            }
        }
    }
}
