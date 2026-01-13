//
//  GalaryViewController.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import UIKit
import Photos
import Vision

class GalaryViewController: BaseViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var fetchAssetService: PHFetchManager!
    let mediaType: MediaGroupType = .similiarVideos
    var collectionData: [[GalaryItemPresentationModel]] = []
    var selectedVideoIdxPath: IndexPath?
    var navigationTransaction: NavigationTransactionDelegate?
    
    override var navigationTransactionAnimatedView: UIView? {
        guard let selectedVideoIdxPath else {
            return nil
        }

        return collectionView.cellForItem(at: selectedVideoIdxPath) as? PhotoCollectionViewCell
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fetchAssetService = .init(delegate: self, mediaType: mediaType)
    }
    
    override func loadView() {
        super.loadView()

        navigationItem.largeTitleDisplayMode = .always
        collectionView.contentInset.top = headerView.frame.height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(.init(nibName: .init(describing: PhotoCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: .init(describing: PhotoCollectionViewCell.self))
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        collectionView.isMultipleTouchEnabled = true
        if #available(iOS 13.0, *) {
            collectionView.automaticallyAdjustsScrollIndicatorInsets = false
        }
        if #available(iOS 14.0, *) {
            collectionView.isEditing = true
        }
        fetchAssetService.fetch()
        title = "screen rec"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationTransaction = nil
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
        switch self.mediaType {
        case .similiarVideos:
            self.selectedVideoIdxPath = indexPath
            navigationTransaction = .init()
            navigationController?.delegate = navigationTransaction
            navigationController?.pushViewController(VideoCompressorViewController.configure(), animated: true)
        default: break
            
        }
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
//        let assetArray = assetArray.filter({ phAsset in
//            !photosArrayDB.contains(where: {
//                $0.localIdentifier == phAsset.localIdentifier
//            })
//        })
        print(assetArray.count, " frewedas ", photos.count)
        let force = true
        if assetArray.isEmpty && !force {
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
//                    db.similiaritiesData.photos = dbData
                    completion(dict)
                }
            } else {
                completion([:])
            }
        }
    }
    
    
    func didCompleteFetching() {
        collectionData = [Array(_immutableCocoaArray: fetchAssetService.assets).compactMap({
            .init(asset: .phAsset($0))
        })]
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
//        photoSimiliaritiesCompletedAssetFetch()
    }
    
    func photoSimiliaritiesCompletedAssetFetch() {
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
                    self.collectionView.reloadData()
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
