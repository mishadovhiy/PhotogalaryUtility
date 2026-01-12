//
//  PHFetchManager.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import Foundation
import Photos
import UIKit

protocol PHFetchManagerDelegate {
    func didCompleteFetching()
}

class PHFetchManager {
    var delegate: PHFetchManagerDelegate?
    var assets: PHFetchResult<PHAsset> = .init()
    private let imageManager = PHCachingImageManager()
    
    init(delegate: PHFetchManagerDelegate? = nil) {
        self.delegate = delegate
    }
    
    deinit {
        self.delegate = nil
    }
    
    func fetch() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        delegate?.didCompleteFetching()
    }

    func fetchThumb(_ asset: PHAsset, completion: @escaping(_ image: UIImage?) -> ()) {
        DispatchQueue(label: "thumb", qos: .userInitiated).async {
            let sizeWidth: CGFloat = 200
            self.imageManager.requestImage(for: asset, targetSize: .init(width: sizeWidth, height: sizeWidth),
                                      contentMode: .aspectFill,
                                      options: nil) { image, _ in
                let data = image?.jpegData(compressionQuality: 0.8)
                let image = UIImage(data: data ?? .init())
                DispatchQueue.main.async {
                    completion(image?.changeSize(newWidth: sizeWidth))
                }
            }
        }
    }
}
