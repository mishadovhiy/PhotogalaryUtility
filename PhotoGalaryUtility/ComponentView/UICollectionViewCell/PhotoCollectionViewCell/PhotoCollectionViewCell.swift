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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func set(_ data: GalaryItemPresentationModel) {
        switch data.asset {
        case .assetName(let name):
            self.imageView.image = .init(named: name)
        case .phAsset(let asset):
            break
        default:
            self.imageView.image = nil
        }
        bottomRightLabel.superview?.superview?.isHidden = data.bottomLabel?.isEmpty ?? true
        checkmarkIndicator.superview?.isHidden = !(data.checkmarkSelected ?? false)
        topLeftLabel.superview?.isHidden = data.topLabel?.isEmpty ?? true
    }
}
