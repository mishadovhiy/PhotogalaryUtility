//
//  GalaryViewController.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import UIKit
import Photos
import Vision

class GalaryViewController: UIViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var galaryViewController: UICollectionView!
    var fetchAssetService: PHFetchManager!
    var collectionData: [[GalaryItemPresentationModel]] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fetchAssetService = .init(delegate: self)
    }
    
    override func loadView() {
        super.loadView()
        
        navigationItem.largeTitleDisplayMode = .always
        galaryViewController.contentInset.top = headerView.frame.height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        galaryViewController.register(.init(nibName: .init(describing: PhotoCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: .init(describing: PhotoCollectionViewCell.self))
        galaryViewController.delegate = self
        galaryViewController.dataSource = self
        galaryViewController.allowsMultipleSelection = true
        galaryViewController.isMultipleTouchEnabled = true
        if #available(iOS 14.0, *) {
            galaryViewController.allowsMultipleSelectionDuringEditing = true
        }
        if #available(iOS 14.0, *) {
            galaryViewController.isEditing = true
        }
        fetchAssetService.fetch()
        title = "screen rec"
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y + scrollView.contentInset.top + self.view.safeAreaInsets.top
        print(offsetY)
#warning("todo: update header constraint")
        if offsetY <= 0 {
            //            self.additionalSafeAreaInsets.top = offsetY * -1
        } else {
            //            self.additionalSafeAreaInsets.top = 0
        }
    }
}

extension GalaryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        collectionData.count
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionData[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .init(describing: PhotoCollectionViewCell.self), for: indexPath) as! PhotoCollectionViewCell
        let data = collectionData[indexPath.section][indexPath.row]
        cell.set(data)
        switch data.asset {
        case .phAsset(let asset):
            self.fetchAssetService.fetchThumb(asset) { image in
                cell.imageView.image = image
            }
        default: break
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.width / 2 - 10
        return .init(width: height, height: height)
    }
}

extension GalaryViewController: PHFetchManagerDelegate {
    
    func similiaritiesDictionary(assetArray: [PHAsset],
                                 completion: @escaping(_ dict: [String: [String]])->()) {
        let photos = FileManagerService().similiaritiesData.photos ?? [:]
        let photosArrayDB = photos.flatMap { (key: SimilarityDataBaseModel.AssetID, value: [SimilarityDataBaseModel.AssetID]) in
            [key] + value
        }
        let assetArray = assetArray.filter({ phAsset in
            !photosArrayDB.contains(where: {
                $0.localIdentifier == phAsset.localIdentifier
            })
        })
        print(assetArray.count, " frewedas ", photos.count)
        if assetArray.isEmpty {
            completion(.init(uniqueKeysWithValues: photos.compactMap({ (key: SimilarityDataBaseModel.AssetID, value: [SimilarityDataBaseModel.AssetID]) in
                (key.localIdentifier, value.compactMap({
                    $0.localIdentifier
                }))
            })))
        } else {
            if #available(iOS 13.0, *) {
                SimiliarDetectionService().buildSimilarAssetsDict(from: assetArray) { dict in
                    var db = FileManagerService()
                    var dbData = db.similiaritiesData.photos ?? [:]
                    dict.forEach { (key: String, value: [String]) in
                        dbData.updateValue(value.compactMap({
                            .init(localIdentifier: $0)
                        }), forKey: .init(localIdentifier: key))
                    }
                    db.similiaritiesData.photos = dbData
//                    db.similiaritiesData.photos = .init(uniqueKeysWithValues: dict.compactMap({ (key: String, value: [String]) in
//                        ( .init(localIdentifier: key), value.compactMap({
//                            .init(localIdentifier: $0)
//                        }))
//                    }))
                    completion(dict)
                }
            } else {
                completion([:])
            }
        }
    }
    
    
    func didCompleteFetching() {
        if #available(iOS 13.0, *) {
            let assetArray:[PHAsset] = Array(_immutableCocoaArray: self.fetchAssetService.assets)
            similiaritiesDictionary(assetArray: assetArray) { dict in
                self.collectionData.removeAll()
                
                dict.forEach { (key: String, value: [String]) in
                    if value.count >= 1 {
                        let asset = assetArray.first(where: {
                            $0.localIdentifier == key
                        })
                        var new: [GalaryItemPresentationModel] = [.init(asset: .phAsset(asset!))]
                        new.append(contentsOf: value.compactMap({ key in
                            let asset = assetArray.first(where: {
                                $0.localIdentifier == key
                            })
                            return .init(asset: .phAsset(asset!))
                        }))
                        self.collectionData.append(new)
                    }
                    
                }
                DispatchQueue.main.async {
                    self.galaryViewController.reloadData()
                }
            }
            
        }
    }
    
    
}

extension GalaryViewController {
    struct PresentionModel {
        //(height bigger when no)
        let needSections: Bool
        let needSize: Bool
    }
}
class SimiliarDetectionService {
    let options = PHImageRequestOptions()
    
    init() {
        options.deliveryMode = .fastFormat
        options.resizeMode = .fast
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
    }
    
    @available(iOS 13.0, *)
    func similarity(_ a: VNFeaturePrintObservation, _ b: VNFeaturePrintObservation) -> Float {
        var distance: Float = 0
        try? a.computeDistance(&distance, to: b)
        return distance
    }
    
    @available(iOS 13.0, *)
    func featurePrint(for asset: PHAsset, targetSize: CGSize = CGSize(width: 200, height: 200), completion: @escaping (VNFeaturePrintObservation?) -> Void) {
        fetchThumb(asset) { image in
            guard let image = image, let cgImage = image.cgImage else {
                completion(nil)
                return
            }
            print(Double((image.pngData() ?? .init()).count) / 1_000_000_000, " gknjukrnferf ")
            let request = VNGenerateImageFeaturePrintRequest { request, error in
                print(error?.localizedDescription, " fdsfdfds")
                guard let observation = request.results?.first as? VNFeaturePrintObservation else {
                    print("comdfdas dsfdfs")
                    
                    completion(nil)
                    return
                }
                print("comdfdas dsfdfs")
                completion(observation)
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage)
            do {
                try handler.perform([request])
            } catch {
                fatalError()
            }
            
        }
    }
    
    func fetchThumb(_ asset: PHAsset, completion:@escaping(_ image: UIImage?)->()) {
        
        
        
        let sizeWidth: CGFloat = 200
        if Thread.isMainThread {
            fatalError()
        }
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: .init(width: sizeWidth, height: sizeWidth),
            contentMode: .aspectFill,
            options: options
        ) { image, error in
            let data = image?.jpegData(compressionQuality: 0.8)
            let image = UIImage(data: data ?? .init())
            completion(image?.changeSize(newWidth: sizeWidth))
        }
    }
    
    @available(iOS 13.0, *)
    private func group(_ featureDict: [PHAsset: VNFeaturePrintObservation], completion: @escaping ([PHAsset: [PHAsset]]) -> Void) {
        var result: [PHAsset: [PHAsset]] = [:]
        
        for (keyAsset, keyFeature) in featureDict {
            var similar: [PHAsset] = []
            for (otherAsset, otherFeature) in featureDict {
                if keyAsset == otherAsset { continue }
                let distance = self.similarity(keyFeature, otherFeature)
                if distance <= 0.1 {
                    similar.append(otherAsset)
                    print(similar.count, " tgergfreg")
                }
            }
            result[keyAsset] = similar
        }
        
        completion(result)
    }
    
    @available(iOS 13.0, *)
    func buildSimilarAssetsDict(from assets: [PHAsset], completion: @escaping ([String: [String]]) -> Void) {
        
        
        DispatchQueue(label: "db", qos: .userInitiated).async {
            self.featPrint(from: assets, featureDict: [:]) { featureDict in
                self.group(featureDict) { dict in
                    completion(.init(uniqueKeysWithValues: dict.compactMap({
                        ($0.key.localIdentifier, $0.value.compactMap({
                            $0.localIdentifier
                        }))
                    })))
                }
            }
        }
        
        
    }
    
    @available(iOS 13.0, *)
    func featPrint(from assets: [PHAsset], featureDict:[PHAsset: VNFeaturePrintObservation], completion: @escaping ([PHAsset: VNFeaturePrintObservation]) -> Void) {
        print(assets.count)
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
            fatalError()
        }
    }
    
}
