//
//  CompressorCell.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import UIKit

class CompressorCell: UITableViewCell {
    @IBOutlet private weak var compressedSizeLabel: UILabel!
    @IBOutlet private weak var currentSizeLabel: UILabel!
    
    struct PresentationModel {
        let currentSize: Double
        let compressedSize: Double
    }
    
    func set(_ data: PresentationModel) {
        compressedSizeLabel.text = "\(data.compressedSize.formated) MB"
        currentSizeLabel.text = "\(data.currentSize.formated) MB"
    }
    
}
