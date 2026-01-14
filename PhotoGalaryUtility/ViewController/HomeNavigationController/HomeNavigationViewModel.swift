//
//  HomeNavigationViewModel.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 14.01.2026.
//

import Foundation
import Photos

class HomeNavigationViewModel {

    init(didCompleteSilimiaritiesProcessing: @escaping () -> Void) {

        self.didCompleteSilimiaritiesProcessing = didCompleteSilimiaritiesProcessing
    }
    var assetFetch: PHFetchManager!
    var proccessingMediaType: MediaGroupType?
    var similarityManager: SimiliarDetectionService?
    let didCompleteSilimiaritiesProcessing:()->()
    
    
    func checkLibraryChanged() {
        
    }
    
    func similiaritiesDictionary(assetArray: [PHAsset],
                                 completion: @escaping(_ dict: [String: [String]])->()) {
        let photos = FileManagerService().similiaritiesData(type: self.assetFetch.mediaType).photos ?? [:]
        let photosArrayDB = photos.flatMap { (key: SimilarityDataBaseModel.AssetID, value: [SimilarityDataBaseModel.AssetID]) in
            [key] + value
        }
        let assetArray = assetArray.filter({ phAsset in
            !photosArrayDB.contains(where: {
                $0.localIdentifier == phAsset.localIdentifier
            })
        })
        if assetArray.isEmpty {
            completion(.init(uniqueKeysWithValues: photos.compactMap({ (key: SimilarityDataBaseModel.AssetID, value: [SimilarityDataBaseModel.AssetID]) in
                (key.localIdentifier, value.compactMap({
                    $0.localIdentifier
                }))
            })))
        } else {
            if #available(iOS 13.0, *) {
                self.similarityManager?.buildSimilarAssetsDict(from: assetArray) { dict in
                    let db = FileManagerService()
                    var dbData = db.similiaritiesData(type: self.assetFetch.mediaType).photos ?? [:]
                    dict.forEach { (key: String, value: [String]) in
                        dbData.updateValue(value.compactMap({
                            .init(localIdentifier: $0)
                        }), forKey: .init(localIdentifier: key))
                    }
                    db.setSimiliarityData(type: self.assetFetch.mediaType, newValue: .init(photos: dbData))
                    completion(dict)
                }
            } else {
                completion([:])
            }
        }
    }
    
    func didCompleteFetching() {
        DispatchQueue(label: "db", qos: .userInitiated).async { [weak self] in
            guard let self else {
                return
            }
            let oldCount = LocalDataBaseService.db.metadataHelper.proccessedFilesCount[self.assetFetch.mediaType]
            if oldCount != self.assetFetch.assets.count {
                FileManagerService().writeData(SimilarityDataBaseModel(), type: .mediaGroupType(self.assetFetch.mediaType))
                LocalDataBaseService.db.metadataHelper.fileSizes.removeValue(forKey: self.assetFetch.mediaType)
            }
            if LocalDataBaseService.db.metadataHelper.fileSizes[assetFetch.mediaType] == nil {
                let mediaType = assetFetch.mediaType
                assetFetch.calculateAssetsSize { result in
                    LocalDataBaseService.db.metadataHelper.fileSizes.updateValue(result, forKey: mediaType)

                }
            }
            LocalDataBaseService.db.metadataHelper.proccessedFilesCount.updateValue(assetFetch.assets.count, forKey: self.assetFetch.mediaType)

            if !self.assetFetch.mediaType.needAnalizeAI {
                    var db = LocalDataBaseService.db
                    db.metadataHelper.filesCount.updateValue(self.assetFetch.assets.count, forKey: self.assetFetch.mediaType)
                    LocalDataBaseService.db = db
            }
            if assetFetch.mediaType.needAnalizeAI {
                photoSimiliaritiesCompletedAssetFetch()
            } else {
                self.fetchSecondaryMedaTypes()
            }
        }
        
    }
    
    func photoSimiliaritiesCompletedAssetFetch() {
        if #available(iOS 13.0, *) {
            let assetArray:[PHAsset] = Array(_immutableCocoaArray: self.assetFetch.assets)
            similiaritiesDictionary(assetArray: assetArray) { dict in
                self.didCompleteSimiliarityProcessing()
            }
            
        }
    }
    
    func didCompleteSimiliarityProcessing() {
        self.didCompleteSilimiaritiesProcessing()
        let mediaTypes = MediaGroupType.allCases.filter({
            $0.needAnalizeAI
        })
        let index = mediaTypes.firstIndex(of: self.assetFetch.mediaType) ?? 0
        if (index + 1) > mediaTypes.count - 1 {
            fetchSecondaryMedaTypes()

            return
        } else {
            self.assetFetch.mediaType = mediaTypes[index + 1]
            self.similarityManager?.type = self.assetFetch.mediaType
            self.assetFetch.fetch()
        }
    }
    
    private func fetchSecondaryMedaTypes() {
        let mediaTypes = MediaGroupType.allCases.filter({
            !$0.needAnalizeAI
        })
        let index = mediaTypes.firstIndex(of: self.assetFetch.mediaType) ?? 0
        if (index + 1) > mediaTypes.count - 1 {
            return
        }
        self.assetFetch.mediaType = mediaTypes[index + 1]
        self.assetFetch.fetch()
    }
    
    var fileSizes: [MediaGroupType.AssetType: Int] = [:]
    var fileCount: [MediaGroupType.AssetType: Int] = [:]

    
    func calculateAllMediaSizesFromDB(completion:@escaping()->()) {
        DispatchQueue(label: "db", qos: .userInitiated).async {
            let dataBase = LocalDataBaseService.db
            let dbSizes = dataBase.metadataHelper.fileSizes
            let dbCount = dataBase.metadataHelper.proccessedFilesCount
            self.fileCount.removeAll()
            self.fileCount.updateValue(dbCount[.allPhotos] ?? 0, forKey: .image)
            self.fileCount.updateValue(dbCount[.allVideos] ?? 0, forKey: .video)

            self.fileSizes.removeAll()
            dbSizes.forEach { (key: MediaGroupType, value: CGFloat) in
                let oldValue = (self.fileSizes[key.assetType] ?? 0)
                self.fileSizes.updateValue(oldValue + Int(value), forKey: key.assetType)
                
            }
            DispatchQueue.main.async {
                completion()
            }
        }
        
    }
    
    func deviceStorageStats() -> (total: Double, used: Double, free: Double)? {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
        do {
            let values = try fileURL.resourceValues(forKeys: [
                .volumeTotalCapacityKey,
                .volumeAvailableCapacityForImportantUsageKey
            ])
            
            if let total = values.volumeTotalCapacity,
               let free = values.volumeAvailableCapacityForImportantUsage {
                
                let totalGB = Double(total) / 1_073_741_824
                let freeGB = Double(free) / 1_073_741_824
                let usedGB = totalGB - freeGB
                
                return (total: totalGB, used: usedGB, free: freeGB)
            }
        } catch {
        }
        return nil
    }
}
