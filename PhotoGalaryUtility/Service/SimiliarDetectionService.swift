//
//  SimiliarDetectionService.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 12.01.2026.
//

import Photos
import Vision
import UIKit

class SimiliarDetectionService {
    let imageRequestOptions = PHImageRequestOptions()
    let videoRequestOptions = PHVideoRequestOptions()
    var type: MediaGroupType
    let imageWidth: CGFloat = 25
    
    init(type: MediaGroupType) {
        self.type = type
        imageRequestOptions.deliveryMode = .fastFormat
        imageRequestOptions.resizeMode = .fast
        imageRequestOptions.isSynchronous = false
        imageRequestOptions.isNetworkAccessAllowed = true
        
        videoRequestOptions.isNetworkAccessAllowed = true
    }
    
    @available(iOS 13.0, *)
    private func similarity(_ a: [VNFeaturePrintObservation], _ b: [VNFeaturePrintObservation]) -> Float {
        var distance: Float = 0
        let primaryArray = a.count >= b.count ? a : b
        let secondaryArray = primaryArray == a ? b : a
        var count: Float = 0
        for aIdx in 0..<primaryArray.count {
            if secondaryArray.count - 1 >= aIdx {
                var new: Float = 0
                try? primaryArray[aIdx].computeDistance(&new, to: secondaryArray[aIdx])
                distance += new
                count += 1
            }

        }
//        a.forEach { a in
//            b.forEach { b in
//                var new: Float = 0
//                try? a.computeDistance(&new, to: b)
//                distance += new
//            }
//        }
        
        return distance / count
    }

    private func videoThumbs(
        from asset: PHAsset,
        completion: @escaping ([UIImage]) -> Void
    ) {
        print(asset.creationDate, " regfsdf ", asset.localIdentifier)
        PHImageManager.default().requestAVAsset(forVideo: asset, options: videoRequestOptions) { avAsset, _, _ in
            let frameCount: Int = 5

            guard let avAsset = avAsset else {
                completion([])
                return
            }

            let generator = AVAssetImageGenerator(asset: avAsset)
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = CGSize(width: self.imageWidth, height: self.imageWidth)

            let duration = CMTimeGetSeconds(avAsset.duration)

            let times = (1...frameCount).map {
                CMTime(
                    seconds: Double($0) * duration / Double(frameCount + 1),
                    preferredTimescale: 600
                )
            }

            var images: [UIImage] = []

            for time in times {
                if let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) {
                    images.append(.init(cgImage: cgImage).changeSize(newWidth: self.imageWidth))
                }
            }

            completion(images)
        }
    }
    
    @available(iOS 13.0, *)
    private func featurePrint(for asset: PHAsset, completion: @escaping ([VNFeaturePrintObservation]?) -> Void) {
        fetchThumb(asset) { images in
            let totalCount = images.count
            var observations: [VNFeaturePrintObservation] = []
            for i in 0..<images.count {
                let image = images[i]
                guard let image = image, let cgImage = image.cgImage else {
                    if i + 1 == totalCount {
                        completion(observations)
                    }
                    return
                }
                let request = VNGenerateImageFeaturePrintRequest { request, error in
                    print(error?.localizedDescription, " fdsfdfds")
                    guard let observation = request.results?.first as? VNFeaturePrintObservation else {
                        
                        if i + 1 == totalCount {
                            completion(observations)
                        }
                        return
                    }
                    observations.append(observation)
                    if i + 1 == totalCount {
                        completion(observations)
                    }
                }
                
                let handler = VNImageRequestHandler(cgImage: cgImage)
                do {
                    try handler.perform([request])
                } catch {
                    
                }
            }
            
            
        }
    }
    
    private func fetchThumb(_ asset: PHAsset, completion:@escaping(_ image: [UIImage?])->()) {
        switch self.type {
        case .similiarPhotos, .dublicatedPhotos:
            imageThumb(asset, completion: completion)

        case .similiarVideos:
            videoThumbs(from: asset, completion: completion)
        default:
            completion([])
        }
    }
    
    private func imageThumb(_ asset: PHAsset, completion:@escaping(_ image: [UIImage?])->()) {
        let sizeWidth: CGFloat = imageWidth
        print("requestimage")
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: .init(width: sizeWidth, height: sizeWidth),
            contentMode: .aspectFill,
            options: imageRequestOptions
        ) { image, error in
            print("requestimagecompletion")

            completion([image?.changeSize(newWidth: sizeWidth)])
        }
    }
    
    @available(iOS 13.0, *)
    private func group(_ featureDict: [PHAsset: [VNFeaturePrintObservation]], completion: @escaping ([PHAsset: [PHAsset]]) -> Void) {
        var result: [PHAsset: [PHAsset]] = [:]
        
        for (keyAsset, keyFeature) in featureDict {
            var similar: [PHAsset] = []
            if !result.values.flatMap({$0}).contains(keyAsset) {
                for (otherAsset, otherFeature) in featureDict {
                    if keyAsset == otherAsset { continue }
                    let distance = self.similarity(keyFeature, otherFeature)
                    if distance <= similirityDistance {
                        similar.append(otherAsset)
                    }
                }
                result[keyAsset] = similar
            }
            
        }
        
        completion(result)
    }
    
    var similirityDistance: Float {
        switch self.type {
        case .similiarPhotos, .similiarVideos: 0.35
        case .dublicatedPhotos: 0.1
        default: 0
        }
    }
    
    
    @available(iOS 13.0, *)
    func buildSimilarAssetsDict(type:MediaGroupType? = nil, from assets: [PHAsset], completion: @escaping ([String: [String]]) -> Void) {
        
        if let type {
            self.type = type
        }
        DispatchQueue(label: "db", qos: .userInitiated).async {
            self.featPrint(from: assets, featureDict: [:]) { featureDict in
                self.group(featureDict) { dict in
//                    let dict = self.removeKeysContainedInValues(dict)
                    completion(.init(uniqueKeysWithValues: dict.compactMap({
                        ($0.key.localIdentifier, $0.value.compactMap({
                            $0.localIdentifier
                        }))
                    })))
                }
            }
        }
        
        
    }
    
    func removeKeysContainedInValues(
        _ dict: [PHAsset: [PHAsset]]
    ) -> [PHAsset: [PHAsset]] {


        return dict.filter { key, values in
            !dict.contains { otherKey, otherValues in
                key != otherKey &&
                Set(values).isSubset(of: Set(otherValues))
            }
        }
    }
    
    @available(iOS 13.0, *)
    private func featPrint(from assets: [PHAsset], featureDict:[PHAsset: [VNFeaturePrintObservation]], completion: @escaping ([PHAsset: [VNFeaturePrintObservation]]) -> Void) {
        print(assets.count, " gerfedas ")
        if assets.isEmpty {
            completion(featureDict)
        } else if let asset = assets.first {
            self.featurePrint(for: asset, completion: { observation in
                autoreleasepool {
                    if let obs = observation {
                        var featureDict = featureDict
                        featureDict[asset] = obs
                        self.featPrint(from: Array(assets.dropFirst()), featureDict: featureDict, completion: completion)
                    }
                    else {
                        self.featPrint(from: Array(assets.dropFirst()), featureDict: featureDict, completion: completion)
                        
                    }
                }
            })
        } else {
        }
    }
    
}
