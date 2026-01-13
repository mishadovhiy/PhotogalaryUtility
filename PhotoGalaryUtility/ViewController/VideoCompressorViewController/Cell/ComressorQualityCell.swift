//
//  ComressorQualityCell.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 13.01.2026.
//

import UIKit

class ComressorQualityCell: UITableViewCell {
    @IBOutlet private weak var checkmarkImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var contentBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkmarkImageView.superview?.layer.cornerRadius = 12
        checkmarkImageView.superview?.layer.masksToBounds = true
        checkmarkImageView.layer.borderColor = UIColor.accent.cgColor
        checkmarkImageView.layer.borderWidth = 2
        contentBackgroundView.backgroundColor = .white
        contentBackgroundView.layer.cornerRadius = 10
        contentBackgroundView.layer.masksToBounds = true
    }
    
    func set(type: CompressQualityType, isSelected: Bool) {
        titleLabel.text = type.rawValue.capitalized
        checkmarkImageView.tintColor = isSelected ? .white : .accent
        checkmarkImageView.backgroundColor = isSelected ? .accent : .clear
    }
}
