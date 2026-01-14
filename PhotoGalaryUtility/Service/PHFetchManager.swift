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
    var mediaType: MediaGroupType
    var fetchTotalSize: CGFloat = 0
    
    init(delegate: PHFetchManagerDelegate? = nil, mediaType: MediaGroupType) {
        self.delegate = delegate
        self.mediaType = mediaType
    }
    
    deinit {
        self.delegate = nil
    }
    
    func fetch(type: MediaGroupType? = nil) {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                self.performFetch(type: type)
            }
        } else {
            self.performFetch(type: type)
        }
    }
    
    private func performFetch(type: MediaGroupType? = nil) {
        if let type {
            mediaType = type
        }
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        switch self.mediaType {
        case .screenshots, .screenRecordings, .livePhotos:
            let subtype: PHAssetCollectionSubtype?
            switch self.mediaType {
            case .screenshots:
                subtype = .smartAlbumScreenshots
            case .screenRecordings:
                if #available(iOS 14, *) {
                    subtype = .smartAlbumScreenRecordings
                } else {
                    subtype = nil
                }
            case .livePhotos:
                subtype = .smartAlbumLivePhotos
            default:
                subtype = nil
                
            }
            guard let subtype else {
                return
            }
            let collections = PHAssetCollection.fetchAssetCollections(
                with: .smartAlbum,
                subtype: subtype,
                options: nil
            )

            guard let screenshotsAlbum = collections.firstObject else {
                return
            }
            assets = PHAsset.fetchAssets(
                in: screenshotsAlbum,
                options: fetchOptions
            )
        default:
            switch mediaType.assetType {
            case .image:
                assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            case .video:
                assets = PHAsset.fetchAssets(with: .video, options: fetchOptions)
            }
        }
        

        self.delegate?.didCompleteFetching()
    }
    
    func calculateAssetsSize(completion: @escaping(_ result: CGFloat)->()) {
        let array: [PHAsset] = Array(_immutableCocoaArray: assets)
        DispatchQueue.global(qos: .utility).async {
            let result = array.reduce(0, { partialResult, asset in
                partialResult + asset.fileSize
            }).bytesToMegaBytes
            DispatchQueue.main.async {
                completion(result)
            }
        }
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
