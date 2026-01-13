//
//  String.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 13.01.2026.
//

import Foundation

extension String {
    var addingSpacesBeforeCapitalised: String {
        self.replacingOccurrences(
            of: "(?<!^)([A-Z])",
            with: " $1",
            options: .regularExpression
        )
    }
}
