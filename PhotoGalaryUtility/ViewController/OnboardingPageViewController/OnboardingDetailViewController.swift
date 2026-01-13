//
//  OnboardingDetailViewController.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import UIKit

class OnboardingDetailViewController: UIViewController {

    @IBOutlet weak var childImaeOverlay: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    var type: OnboardingPageViewController.DetailContentType?
    
    override func loadView() {
        super.loadView()
        loadChild()
    }
}

extension OnboardingDetailViewController {
    func loadChild() {
        
    }
}

extension OnboardingDetailViewController {
    static func configure() -> Self {
        return self.configure(storyboardID: "Onboarding")
    }
}
