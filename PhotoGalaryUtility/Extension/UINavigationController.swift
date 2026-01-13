//
//  UINavigationController.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 13.01.2026.
//

import UIKit

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.interactivePopGestureRecognizer?.delegate = self
        self.interactivePopGestureRecognizer?.isEnabled = true
    }
        
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
