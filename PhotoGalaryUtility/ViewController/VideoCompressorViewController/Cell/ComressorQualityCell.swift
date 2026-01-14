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
        checkmarkImageView.superview?.layer.borderColor = UIColor.accent.cgColor
        checkmarkImageView.superview?.layer.borderWidth = 2
        contentBackgroundView.backgroundColor = .white
        contentBackgroundView.layer.cornerRadius = 10
        contentBackgroundView.layer.shadowColor = UIColor.black.cgColor
        contentBackgroundView.layer.shadowOffset = .zero
        contentBackgroundView.layer.shadowRadius = 3.8
        contentBackgroundView.layer.shadowOpacity = 0.15
    }
    
    func set(type: CompressQualityType, isSelected: Bool) {
        titleLabel.text = type.rawValue.capitalized
        checkmarkImageView.tintColor = isSelected ? .white : .accent
        checkmarkImageView.superview?.backgroundColor = isSelected ? .accent : .clear
    }
}
