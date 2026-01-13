//
//  OnboardingPageViewController.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import UIKit

class OnboardingPageViewController: UIPageViewController {

    var pageData: [DetailContentType] = DetailContentType.allCases
    
    var primaryData: ButtonData {
        .init(title: "Continioue", style: .primary) {
            print((self.viewControllers?.first?.view.tag ?? 0), " frewdqfw")
            if (self.viewControllers?.first?.view.tag ?? 0) + 1 >= self.pageData.count {
                let navigation = self.navigationController as? HomeNavigationController
                navigation?.setRefreshing {
                    navigation?.dbSetInitialViewController(test: true)
                }
                
            } else {
                let index = (self.viewControllers?.first?.view.tag ?? 0) + 1
                let firstVC = OnboardingDetailViewController.configure()
                firstVC.type = self.pageData[index]
                firstVC.view.tag = index
                self.setViewControllers([
                    firstVC
                ], direction: .forward, animated: true)
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        let firstVC = OnboardingDetailViewController.configure()
        firstVC.type = pageData.first
        setViewControllers([
            firstVC
        ], direction: .forward, animated: false)
        delegate = self
        dataSource = self
    }
}

extension OnboardingPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = viewController.view.tag

        if pageData.count - 1 >= index + 1 {
            let vc = OnboardingDetailViewController.configure()
            vc.view.tag = index + 1
            vc.type = pageData[vc.view.tag]
            return vc
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = viewController.view.tag
        if index == 0 {
            return nil
        }
        let vc = OnboardingDetailViewController.configure()
        vc.view.tag = index - 1
        vc.type = pageData[vc.view.tag]
        return vc
    }
}

extension OnboardingPageViewController {
    enum DetailContentType: CaseIterable {
        case clearStorage
        case similiarPhotosDetection
        case videoCompressor
    }
    
    static func configure() -> Self {
        return self.configure(storyboardID: "Onboarding")
    }
}
