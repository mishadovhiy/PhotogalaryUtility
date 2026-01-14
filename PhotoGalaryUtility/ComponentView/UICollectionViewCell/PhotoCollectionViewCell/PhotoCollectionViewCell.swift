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
    @IBOutlet private weak var topLeftLabel: UILabel!
    
    @IBOutlet private weak var checkmarkIndicator: UIImageView!
    @IBOutlet private weak var bottomRightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        [
            topLeftLabel.superview,
            bottomRightLabel.superview?.superview,
            checkmarkIndicator.superview
        ].forEach {
            $0?.layer.cornerRadius = 5
            $0?.layer.masksToBounds = true
        }
        checkmarkIndicator.superview?.layer.cornerRadius = 5
        checkmarkIndicator.superview?.layer.borderColor = UIColor(resource: .darkBlue).cgColor
        checkmarkIndicator.superview?.layer.borderWidth = 2
    }
    
    func set(_ data: GalaryItemPresentationModel) {
        switch data.asset {
        case .assetName(let name):
            self.imageView.image = .init(named: name)
        case .phAsset(let asset):
            if !(data.topLabel?.isEmpty ?? true) {
                topLeftLabel.text = "\(Int(asset.fileSize.bytesToMegaBytes)) MB"
            }
            break
        default:
            self.imageView.image = nil
        }
        bottomRightLabel.superview?.superview?.isHidden = data.bottomLabel?.isEmpty ?? true
        checkmarkIndicator.superview?.isHidden = data.checkmarkSelected == nil
        checkmarkIndicator.tintColor = data.checkmarkSelected ?? false ? .white : .clear
        checkmarkIndicator.superview?.backgroundColor = data.checkmarkSelected ?? false ? .darkBlue : .clear
        topLeftLabel.superview?.isHidden = data.topLabel?.isEmpty ?? true
    }
    
}
