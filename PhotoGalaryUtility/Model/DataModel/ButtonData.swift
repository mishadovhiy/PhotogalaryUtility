//
//  ButtonData.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import Foundation

struct ButtonData {
    let title: String
    let style: Style
    let didPress: (()->())?
    
    init(title: String,
         style: Style = .primary,
         didPress: (()->())? = nil) {
        self.title = title
        self.style = style
        self.didPress = didPress
    }
}

extension ButtonData {
    enum Style {
        case primary
        case link
    }
}
