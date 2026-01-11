//
//  UITableViewCell_UICollectionViewCell.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import UIKit

extension UITableViewCell {
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.selectedBackgroundView = .init()
    }
}

extension UICollectionViewCell {
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.selectedBackgroundView = .init()
    }
}
