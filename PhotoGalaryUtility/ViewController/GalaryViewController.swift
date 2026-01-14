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
    @IBOutlet weak var filesCountLabel: UILabel!
    var fetchAssetService: PHFetchManager!
    var mediaType: MediaGroupType!
    var collectionData: [[GalaryItemPresentationModel]] = []
    var selectedVideoIdxPath: IndexPath?
    var navigationTransaction: NavigationTransactionDelegate?
    var selectedAseetIDs: [String] = []
    
    override var navigationTransactionAnimatedView: UIView? {
        guard let selectedVideoIdxPath else {
            return nil
        }

        return collectionView.cellForItem(at: selectedVideoIdxPath) as? PhotoCollectionViewCell
    }
    
    override func loadView() {
        super.loadView()
        title = mediaType.rawValue.addingSpacesBeforeCapitalised.capitalized
        fetchAssetService = .init(delegate: self, mediaType: mediaType)

        navigationItem.largeTitleDisplayMode = .always
        collectionView.contentInset.top = headerView.frame.height
        collectionView.register(.init(nibName: .init(describing: PhotoCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: .init(describing: PhotoCollectionViewCell.self))
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsSelection = true
        collectionView.delaysContentTouches = true
        collectionView.allowsMultipleSelection = true
        collectionView.isMultipleTouchEnabled = true
        if #available(iOS 13.0, *) {
            collectionView.automaticallyAdjustsScrollIndicatorInsets = false
        }
        if #available(iOS 14.0, *) {
            collectionView.isEditing = true
        }
        loadTabBarItems()
        setupHeaderItems()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue(label: "phAssets", qos: .background).async {
            self.fetchAssetService.fetch()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationTransaction = nil
    }
    
    var presentationModel: GalaryPresentationModel {
        switch mediaType {
        case .allVideos:
                .init(needTotalStorageCalculation: false, needTotalItemCountCalculation: true, canSelectMultiple: false)
        default:
                .init(needTotalStorageCalculation: true, needTotalItemCountCalculation: true, canSelectMultiple: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y + scrollView.contentInset.top + self.view.safeAreaInsets.top
#warning("todo: update header constraint")

    }
    
    @objc func toggleSelectionsDidPress(_ sender: UIButton) {
        if sender.tag == 0 {
            sender.tag = 1
            let new: [PHAsset] = Array(_immutableCocoaArray: self.fetchAssetService.assets)
            selectedAseetIDs = new.compactMap({
                $0.localIdentifier
            })
        } else {
            sender.tag = 0
            selectedAseetIDs.removeAll()
        }
        UIView.transition(
            with: collectionView,
            duration: 0.25,
            options: .transitionCrossDissolve,
            animations: {
                self.collectionView.reloadData()
            }
        )
        updateSelectAllButton(sender: sender)
    }
    
    func updateSelectAllButton(sender: UIButton) {
        sender.setTitle(sender.tag == 1 ? "Deselect All" : "Select All", for: .init())
    }
    
    func checkSelectionCount() {
        if selectedAseetIDs.count == fetchAssetService.assets.count {
            guard let sender = navigationItem.rightBarButtonItem?.customView as? UIButton else {
                return
            }
            sender.tag = 1
            updateSelectAllButton(sender: sender)
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
        print(indexPath, " gefds ")
        let data = collectionData[indexPath.section][indexPath.row]
        switch self.mediaType {
        case .allVideos:
            self.selectedVideoIdxPath = indexPath
            navigationTransaction = .init()
            navigationController?.delegate = navigationTransaction
            let vc = VideoCompressorViewController.configure()
            switch data.asset {
            case .phAsset(let asset):
                vc.selectedAsset = asset
            default: break
            }
            navigationController?.pushViewController(vc, animated: true)
        default:
            switch data.asset {
            case .phAsset(let asset):
                if self.selectedAseetIDs.contains(asset.localIdentifier) {
                    selectedAseetIDs.removeAll(where: {
                        $0 == asset.localIdentifier
                    })
                } else {
                    selectedAseetIDs.append(asset.localIdentifier)
                }
                collectionView.reloadItems(at: [indexPath])
                self.checkSelectionCount()
            default: break
            }
            
        }
        print(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .init(describing: PhotoCollectionViewCell.self), for: indexPath) as! PhotoCollectionViewCell
        var data = collectionData[indexPath.section][indexPath.row]

        switch self.mediaType {
        case .dublicatedPhotos, .similiarPhotos, .similiarVideos:
            if indexPath.row == 0 {
                data.bottomLabel = "Best"
            }
        case .allVideos:
            data.topLabel = "10 MB"
        default: break
        }
        switch data.asset {
        case .phAsset(let asset):
            if self.mediaType != .allVideos {
                data.checkmarkSelected = self.selectedAseetIDs.contains(asset.localIdentifier)
            }
            self.fetchAssetService.fetchThumb(asset) { image in
                cell.imageView.image = image
            }
        default: break
        }
        cell.set(data)
        cell.isMultipleTouchEnabled = true
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.width / 2
        return .init(width: height, height: height)
    }
}

extension GalaryViewController {
    func setupHeaderItems() {
        var array = (headerView as? UIStackView)?.arrangedSubviews ?? []
        if let view = navigationItem.rightBarButtonItem?.customView {
            array.append(view)
        }
        array.forEach { view in
            view.backgroundColor = .white
            view.layer.cornerRadius = 5
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOffset = .zero
            view.layer.shadowRadius = 4
            view.layer.shadowOpacity = 0.22
        }
    }
    
    func loadTabBarItems() {
        if self.mediaType == .allVideos {
            return
        }
        let button = UIButton(type: .system)
        button.setTitle("Select All", for: .init())
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.2
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(.darkText, for: .init())
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        button.tag = 0
        button.addTarget(self, action: #selector(toggleSelectionsDidPress(_:)), for: .touchUpInside)

        let barButton = UIBarButtonItem(customView: button)
        
        if #available(iOS 26.0, *) {
            barButton.style = .prominent
            barButton.hidesSharedBackground = true
        }
        navigationItem.rightBarButtonItem = barButton
    }
}

extension GalaryViewController: PHFetchManagerDelegate {
    
    func similiaritiesDictionary(assetArray: [PHAsset],
                                 completion: @escaping(_ dict: [String: [String]])->()) {
        let photos = FileManagerService().similiaritiesData(type: self.mediaType).photos ?? [:]
        completion(.init(uniqueKeysWithValues: photos.compactMap({ (key: SimilarityDataBaseModel.AssetID, value: [SimilarityDataBaseModel.AssetID]) in
            (key.localIdentifier, value.compactMap({
                $0.localIdentifier
            }))
        })))
    }
    
    
    func didCompleteFetching() {
        DispatchQueue(label: "db", qos: .userInitiated).async { [weak self] in
            guard let self else {
                return
            }
            var db = LocalDataBaseService.db
            db.metadataHelper.fileSizes.updateValue(self.fetchAssetService.fetchTotalSize, forKey: self.fetchAssetService.mediaType)
            db.metadataHelper.filesCount.updateValue(self.fetchAssetService.assets.count, forKey: self.fetchAssetService.mediaType)
            LocalDataBaseService.db = db
            if mediaType.needAnalizeAI {
                photoSimiliaritiesCompletedAssetFetch()
            } else {
                collectionData = [Array(_immutableCocoaArray: fetchAssetService.assets).compactMap({
                    .init(asset: .phAsset($0))
                })]
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
        
        
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
    struct GalaryPresentationModel {
        let needTotalStorageCalculation: Bool
        let needTotalItemCountCalculation: Bool
        let canSelectMultiple: Bool
        
    }
}
