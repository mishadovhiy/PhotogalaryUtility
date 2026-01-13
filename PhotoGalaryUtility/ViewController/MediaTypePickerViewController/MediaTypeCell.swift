//
//  MediaTypeCell.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 13.01.2026.
//

import UIKit

class MediaTypeCell: UICollectionViewCell {
    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var containerBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerBackgroundView.layer.cornerRadius = 10
        containerBackgroundView.backgroundColor = .white
        containerBackgroundView.layer.shadowColor = UIColor.black.cgColor
        containerBackgroundView.layer.shadowOpacity = 0.15
        containerBackgroundView.layer.shadowOffset = .zero
        containerBackgroundView.layer.shadowRadius = 8
        iconView.superview?.layer.cornerRadius = 20
        iconView.superview?.layer.masksToBounds = true
        iconView.superview?.backgroundColor = iconView.tintColor.withAlphaComponent(0.2)
    }
    
    func set(type: MediaGroupType, dataCount: Int) {
        iconView.image = .init(resource: type.image)
        subtitleLabel.text = "\(dataCount) Items"
        titleLabel.text = type.rawValue.addingSpacesBeforeCapitalised.capitalized
    }
}
