//
//  GalaryViewController.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import UIKit
import Photos

class GalaryViewController: UIViewController {
    
    @IBOutlet weak var galaryViewController: UICollectionView!
    var fetchAssetService: PHFetchManager!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fetchAssetService = .init(delegate: self)
    }
    
    override func loadView() {
        super.loadView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        galaryViewController.register(.init(nibName: .init(describing: PhotoCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: .init(describing: PhotoCollectionViewCell.self))
        galaryViewController.delegate = self
        galaryViewController.dataSource = self
        fetchAssetService.fetch()
    }
 
}

extension GalaryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fetchAssetService.assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .init(describing: PhotoCollectionViewCell.self), for: indexPath) as! PhotoCollectionViewCell
        cell.set(.init(asset: .assetName("")))
        self.fetchAssetService.fetchThumb(fetchAssetService.assets[indexPath.row]) { image in
            cell.imageView.image = image
        }
        return cell
    }
    
    
}

extension GalaryViewController: PHFetchManagerDelegate {
    func didCompleteFetching() {
        galaryViewController.reloadData()
    }
    
    
}

extension GalaryViewController {
    struct PresentionModel {
    //(height bigger when no)
        let needSections: Bool
        let needSize: Bool
    }
}
