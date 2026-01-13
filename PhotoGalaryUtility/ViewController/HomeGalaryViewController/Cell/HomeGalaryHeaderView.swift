//
//  HomeGalaryHeaderView.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 13.01.2026.
//

import UIKit

class HomeGalaryHeaderView: UICollectionReusableView {
    
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var topLeftIconView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var topRightIconSuperView: UIView!
    @IBOutlet weak var viewAllButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        [topRightIconSuperView, topLeftIconView.superview].forEach {
            $0?.layer.cornerRadius = 5
            $0?.layer.masksToBounds = true
        }
        topRightIconSuperView.layer.cornerRadius = 12
        topRightIconSuperView.backgroundColor = UIColor(resource: .red).withAlphaComponent(0.3)
        
    }
    
    func set(_ data: HomeGalaryViewController.GalaryCollectionModel.SectionModel) {
        titleLabel.text = data.sectionTitle
        subtitleLabel.text = data.subtitle
        topLeftIconView.image = .init(resource: data.leftIconAssetName)
        topLeftIconView.tintColor = .init(resource: data.tint)
        topLeftIconView.superview?.backgroundColor = .init(resource: data.tint).withAlphaComponent(0.09)
        if viewAllButton.superview?.isHidden != !data.needViewAllButton {
            viewAllButton.superview?.isHidden = !data.needViewAllButton
        }
    }
}
