//
//  HomeNavigationController.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import UIKit

class HomeNavigationController: UINavigationController {
    //holds primary button and toggles depending protocl
    override func loadView() {
        
        let vc3 = UIViewController()
        vc3.view.backgroundColor = .orange
        setViewControllers([vc3], animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            let vc2 = GalaryViewController.configure()
            vc2.navigationItem.largeTitleDisplayMode = .always
            vc2.navigationController?.navigationItem.largeTitleDisplayMode = .always
            self.setViewControllers([vc2], animated: true)
        })
        super.loadView()
        navigationItem.largeTitleDisplayMode = .always
    }
}

extension UIViewController {
    static func configure() -> Self {
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: .init(describing: Self.self)) as! Self
    }
}
