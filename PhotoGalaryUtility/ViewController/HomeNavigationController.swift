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
        let vc1 = UIViewController()
        vc1.view.backgroundColor = .red
        
        let vc2 = UIViewController()
        vc2.view.backgroundColor = .green
        
        let vc3 = UIViewController()
        vc3.view.backgroundColor = .orange
        setViewControllers([vc3], animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            let vc2 = UIViewController()
            vc2.view.backgroundColor = .green
            self.setViewControllers([vc2], animated: true)
        })
        super.loadView()

    }
}

