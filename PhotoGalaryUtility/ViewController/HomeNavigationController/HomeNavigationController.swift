//
//  HomeNavigationController.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import UIKit
import Photos

class HomeNavigationController: UINavigationController {
    
    private var buttonsStack: UIStackView? {
        view.subviews.first(where: {
            $0 is UIStackView
        }) as? UIStackView
    }
    
    var viewModel: HomeNavigationViewModel!
    
    override func loadView() {
        viewModel = .init(didCompleteSilimiaritiesProcessing: didCompleteSilimiaritiesProcessing)
        viewModel.assetFetch = .init(delegate: self, mediaType: MediaGroupType.allCases.first(where: {
            $0.needAnalizeAI
        })!)
        self.viewModel.proccessingMediaType = viewModel.assetFetch.mediaType
        viewModel.similarityManager = .init(type: viewModel.assetFetch.mediaType)
        self.navigationItem.largeTitleDisplayMode = .always
        super.loadView()
        setRefreshing()
        loadButtonsStack()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dbSetInitialViewController()
    }
    
    func setRefreshing(completion: (()->())? = nil) {
        let vc = RefreshViewController.configure()
        vc.appearedAction = completion
        setViewControllers([vc], animated: true)
    }
    
    func dbSetInitialViewController(test: Bool = false) {
        DispatchQueue(label: "db", qos: .background).async {
            DispatchQueue.main.async {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
//                    self.setViewControllers([test ? HomeGalaryViewController.configure() : OnboardingPageViewController.configure()], animated: true)
                    let vc = HomeGalaryViewController.configure()
                    self.setViewControllers([vc], animated: true)
                    if vc is HomeGalaryViewController {
                        self.viewModel.assetFetch.fetch()
                    }

                })
            }
        }
    }
    
    private func setupButtons(topViewController: UIViewController? = nil) {
//        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear)
        let vc = (topViewController ?? self.topViewController) as? BaseViewController
        var buttonData = [vc?.primaryButton, vc?.secondaryButton]
        if let onboardingVC = (topViewController ?? self.topViewController) as? OnboardingPageViewController {
            buttonData = [onboardingVC.primaryData, nil]
        }
        let lastView = self.buttonsStack?.arrangedSubviews.last
        var safeAreaHeight = buttonData.compactMap({
            $0 == nil ? 0 : 60
        }).reduce(0) { partialResult, new in
            partialResult + new
        }
        if safeAreaHeight > 0 {
            safeAreaHeight += 10
        }
        buttonsStack?.arrangedSubviews.forEach { view in
            let button = view as? UIButton
            let data = buttonData[button?.tag ?? 0]
            button?.setTitle(data?.title ?? "", for: .init())
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(self.delegate != nil && data != nil ? 500 : 0), execute: {
                UIView.animate(withDuration: 0.3, delay: 0, animations: {
                    if (button?.isHidden ?? false) != (data == nil) {
                        button?.isHidden = data == nil
                    }
                    
                    self.setButtonStyle(button, data: data)
                    
                }, completion: { _ in
                    if lastView == view {
                        UIView.animate(withDuration: 0.2) {
                            self.viewControllers.forEach {
                                $0.additionalSafeAreaInsets.bottom = CGFloat(safeAreaHeight)
                            }
                        }
                    }
                })
            })
            
        }
    }
    
    private func setButtonStyle(_ button: UIButton?, data: ButtonData?) {
        guard let button else {
            return
        }
        let data = data ?? .init(title: "", style: button.tag == 0 ? .primary : .link)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        switch data.style {
        case .link:
            button.tintColor = .blue
            button.backgroundColor = .clear
        case .primary:
            button.tintColor = .white
            button.backgroundColor = .blue
        }
        button.layer.cornerRadius = 10
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        print(#function, " yhegtrfds")
        self.setupButtons(topViewController: viewController)
        return super.popToViewController(viewController, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        print(#function, " yhegtrfds")

        let vc = super.popViewController(animated: animated)
        self.setupButtons()
        return vc

    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        print(#function, " yhegtrfds")

        self.setupButtons(topViewController: viewControllers.last)
        super.setViewControllers(viewControllers, animated: animated)

    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        print(#function, " yhegtrfds")
        self.setNavigationBarHidden(false, animated: true)
        super.pushViewController(viewController, animated: animated)
        self.setupButtons(topViewController: viewController)

    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        print(#function, " yhegtrfds")

        let vc = super.popToRootViewController(animated: animated)
        self.setupButtons(topViewController: vc?.last)
        return vc
    }
    
    @objc private func buttonDidPress(_ sender: UIButton) {
        let vc = (viewControllers.last as? BaseViewController)
        let data = [vc?.primaryButton ?? (viewControllers.last as? OnboardingPageViewController)?.primaryData, vc?.secondaryButton][sender.tag]
        print(data, " refwda ", vc?.primaryButton)
        data?.didPress?()
    }
}


fileprivate
extension HomeNavigationController {
    func loadButtonsStack() {
        let stack = UIStackView()
        stack.axis = .vertical
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: stack.superview!.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: stack.superview!.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: stack.superview!.safeAreaLayoutGuide.bottomAnchor, constant: -6)
        ])
        loadButtons()
        setupButtons()
    }
    
    func loadButtons() {
        Array(0..<2).forEach { i in
            let button = UIButton()
            button.addTarget(self, action: #selector(buttonDidPress(_:)), for: .touchUpInside)
            button.tag = i
            buttonsStack?.insertArrangedSubview(button, at: i)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 44 + (i == 0 ? 16 : 0)).isActive = true
        }
    }
}

extension HomeNavigationController: PHFetchManagerDelegate {
    func didCompleteFetching() {
        viewModel.didCompleteFetching()
    }
    
    func didCompleteSilimiaritiesProcessing() {
        viewControllers.forEach {
            ($0 as? BaseViewController)?.didCompleteSilimiaritiesProccessing()
        }
    }
}

extension UIViewController {
    static func configure(storyboardID: String? = nil) -> Self {
        return UIStoryboard(name: storyboardID ?? "Main", bundle: nil).instantiateViewController(withIdentifier: .init(describing: Self.self)) as! Self
    }
}
