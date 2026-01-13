//
//  HomeNavigationController.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import UIKit

class HomeNavigationController: UINavigationController {
    //holds primary button and toggles depending protocl
    
    private var buttonsStack: UIStackView? {
        view.subviews.first(where: {
            $0 is UIStackView
        }) as? UIStackView
    }
    
    override func loadView() {
        self.navigationItem.largeTitleDisplayMode = .always
        super.loadView()
        navigationItem.largeTitleDisplayMode = .always
        loadButtonsStack()
        setViewControllers([RefreshViewController.configure()], animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dbSetInitialViewController()
    }
    
    func dbSetInitialViewController() {
        DispatchQueue(label: "db", qos: .background).async {
            DispatchQueue.main.async {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    self.setViewControllers([GalaryViewController.configure()], animated: true)
                })
            }
        }
    }
    
    private func setupButtons(topViewController: UIViewController? = nil) {
//        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear)
        let vc = (topViewController ?? self.topViewController) as? BaseViewController
        let buttonData = [vc?.primaryButton, vc?.secondaryButton]
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

        super.pushViewController(viewController, animated: animated)
        self.setupButtons(topViewController: viewController)

    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        print(#function, " yhegtrfds")

        let vc = super.popToRootViewController(animated: animated)
        self.setupButtons(topViewController: vc?.last)
        return vc
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
//        let view = UIView()
//        view.backgroundColor = .clear
//        view.isUserInteractionEnabled = false
//        view.translatesAutoresizingMaskIntoConstraints = false
//        buttonsStack?.addArrangedSubview(view)
//        view.heightAnchor.constraint(equalToConstant: 10).isActive = true
        Array(0..<2).forEach { i in
            let button = UIButton()
            button.tag = i
            buttonsStack?.insertArrangedSubview(button, at: i)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 44 + (i == 0 ? 16 : 0)).isActive = true
        }
    }
}

extension UIViewController {
    static func configure() -> Self {
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: .init(describing: Self.self)) as! Self
    }
}
