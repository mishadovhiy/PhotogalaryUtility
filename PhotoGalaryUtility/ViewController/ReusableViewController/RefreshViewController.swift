//
//  RefreshViewController.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import UIKit

class RefreshViewController: BaseViewController {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    var presentationData: PresentationModel?
    
    override var primaryButton: ButtonData? {
        (presentationData?.canCancel ?? false) ? .init(title: "Cancel", didPress: {
            self.navigationController?.popViewController(animated: true)
        }) : nil
    }
    
    override func loadView() {
        super.loadView()
        titleLabel.text = presentationData?.title
        subtitleLabel.text = presentationData?.bottomSubtitle
        [titleLabel, subtitleLabel].forEach {
            if $0?.text?.isEmpty ?? true {
                $0?.isHidden = true
            }
        }
    }
}

extension RefreshViewController {
    
    struct PresentationModel {
        let title: String
        let bottomSubtitle: String
        let canCancel: Bool
    }
    
    static func configure() -> Self {
        return self.configure(storyboardID: "Reusable")
    }
}
