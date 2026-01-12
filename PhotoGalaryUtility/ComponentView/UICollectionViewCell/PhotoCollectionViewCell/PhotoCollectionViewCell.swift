//
//  PhotoCollectionViewCell.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import UIKit
 import Photos

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topLeftLabel: UILabel!
    
    @IBOutlet weak var checkmarkIndicator: UIImageView!
    @IBOutlet weak var bottomRightLabel: UILabel!
    
    func set(_ data: GalaryItemPresentationModel) {
        switch data.asset {
        case .assetName(let name):
            self.imageView.image = .init(named: name)
        case .phAsset(let asset):
            topLeftLabel.text = asset.localIdentifier
            self.imageView.image = nil
        default:
            self.imageView.image = nil
        }
        self.backgroundColor = .white
        bottomRightLabel.superview?.superview?.isHidden = true
        checkmarkIndicator.superview?.isHidden = true
        topLeftLabel.superview?.isHidden = false
    }
}
