//
//  ButtonData.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import Foundation

struct ButtonData {
    let title: String
    var didPress: ()->()
}

extension ButtonData {
    enum Style {
        case primary
        case link
    }
}
