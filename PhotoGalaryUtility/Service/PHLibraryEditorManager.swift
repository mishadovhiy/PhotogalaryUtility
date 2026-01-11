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
}
