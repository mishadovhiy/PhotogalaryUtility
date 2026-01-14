//
//  OnboardingDetailViewController.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import UIKit

class OnboardingDetailViewController: UIViewController {

    @IBOutlet private weak var childImageOverlay: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    var type: OnboardingPageViewController.DetailContentType?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setViewContent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.children.isEmpty {
            loadChild()
        }
        
    }
}

fileprivate
extension OnboardingDetailViewController {
    func setViewContent() {
        switch type {
        case .clearStorage:
            titleLabel.text = "Clean your Storage"
            descriptionLabel.text = "Pick the best & delete the rest"
        case .similiarPhotosDetection:
            titleLabel.text = "Detect Similar Photos"
            descriptionLabel.text = "Clean similar photos & videos, save your storage space on your phone."
        case .videoCompressor:
            titleLabel.text = "Video Compressor"
            descriptionLabel.text = "Find large videos or media files and compress them to free up storage space"
        default: break
        }
    }
    
    func loadChild() {
        guard let vc = childVC,
              let containerView = childImageOverlay.superview
        else {
            return
        }
        vc.isDemo = true
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.prefersLargeTitles = true
        containerView.insertSubview(nav.view, at: 0)
        nav.view.translatesAutoresizingMaskIntoConstraints = false

        var imageSize = self.childImageOverlay.image?.size ?? .zero
        imageSize.width -= 40
        imageSize.height -= 40
        let superSize = containerView.frame.size
        nav.view.layer.setAffineTransform( nav.view.layer.affineTransform().scaledBy(x: imageSize.width / superSize.width, y: imageSize.width / superSize.width) )
        NSLayoutConstraint.activate([
            nav.view.leadingAnchor.constraint(equalTo: nav.view.superview!.leadingAnchor),
            nav.view.trailingAnchor.constraint(equalTo: nav.view.superview!.trailingAnchor),
            nav.view.topAnchor.constraint(equalTo: nav.view.superview!.topAnchor, constant: -(imageSize.height / superSize.height) * 120),
            nav.view.bottomAnchor.constraint(equalTo: nav.view.superview!.bottomAnchor, constant: (imageSize.height / superSize.height) * 120)
        ])
        nav.view.layer.masksToBounds = true
        nav.view.layer.cornerRadius = 30
        nav.view.alpha = 0
        addChild(nav)
        nav.didMove(toParent: self)
        UIView.animate(withDuration: 0.3) {
            nav.view.alpha = 1
        }
    }
    
    var childVC: BaseViewController? {
        switch type {
        case .clearStorage:
            HomeGalaryViewController.configure()
        case .similiarPhotosDetection:
            GalaryViewController.configure()
        case .videoCompressor:
            VideoCompressorViewController.configure()
        default: nil
        }
    }
}

extension OnboardingDetailViewController {
    static func configure() -> Self {
        return self.configure(storyboardID: "Onboarding")
    }
}
