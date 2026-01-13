//
//  BaseViewController.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import UIKit

class BaseViewController: UIViewController {
    var primaryButton: ButtonData? { nil }
    var secondaryButton: ButtonData? { nil }
    var navigationTransactionAnimatedView: UIView? { nil }
    var navigationTransactionTargetView: UIView? { nil }
    
    var getTransactionAnimationView: UIView? {
        navigationTransactionAnimatedView ?? navigationTransactionTargetView
    }
    
    var appearedAction: (()->())?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appearedAction?()
        appearedAction = nil
    }
}
