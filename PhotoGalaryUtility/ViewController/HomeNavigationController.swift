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
    
    var assetFetch: PHFetchManager!
    var proccessingMediaType: MediaGroupType?
    var similarityManager: SimiliarDetectionService?
    
    override func loadView() {
        assetFetch = .init(delegate: self, mediaType: MediaGroupType.allCases.first(where: {
            $0.needAnalizeAI
        })!)
        self.proccessingMediaType = assetFetch.mediaType
        similarityManager = .init(type: assetFetch.mediaType)
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
                        self.assetFetch.fetch()
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
        let vc = (viewControllers.first as? BaseViewController)
        let data = [vc?.primaryButton ?? (viewControllers.first as? OnboardingPageViewController)?.primaryData, vc?.secondaryButton][sender.tag]
        print(data)
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
    func similiaritiesDictionary(assetArray: [PHAsset],
                                 completion: @escaping(_ dict: [String: [String]])->()) {
        let photos = FileManagerService().similiaritiesData(type: self.assetFetch.mediaType).photos ?? [:]
        let photosArrayDB = photos.flatMap { (key: SimilarityDataBaseModel.AssetID, value: [SimilarityDataBaseModel.AssetID]) in
            [key] + value
        }
        let assetArray = assetArray.filter({ phAsset in
            !photosArrayDB.contains(where: {
                $0.localIdentifier == phAsset.localIdentifier
            })
        })
        if assetArray.isEmpty {
            completion(.init(uniqueKeysWithValues: photos.compactMap({ (key: SimilarityDataBaseModel.AssetID, value: [SimilarityDataBaseModel.AssetID]) in
                (key.localIdentifier, value.compactMap({
                    $0.localIdentifier
                }))
            })))
        } else {
            if #available(iOS 13.0, *) {
                self.similarityManager?.buildSimilarAssetsDict(from: assetArray) { dict in
                    let db = FileManagerService()
                    var dbData = db.similiaritiesData(type: self.assetFetch.mediaType).photos ?? [:]
                    dict.forEach { (key: String, value: [String]) in
                        dbData.updateValue(value.compactMap({
                            .init(localIdentifier: $0)
                        }), forKey: .init(localIdentifier: key))
                    }
                    db.setSimiliarityData(type: self.assetFetch.mediaType, newValue: .init(photos: dbData))
                    completion(dict)
                }
            } else {
                completion([:])
            }
        }
    }
    
    
    func didCompleteFetching() {
        if assetFetch.mediaType.needAnalizeAI {
            photoSimiliaritiesCompletedAssetFetch()
        }
    }
    
    func photoSimiliaritiesCompletedAssetFetch() {
        if #available(iOS 13.0, *) {
            let assetArray:[PHAsset] = Array(_immutableCocoaArray: self.assetFetch.assets)
            similiaritiesDictionary(assetArray: assetArray) { dict in
                self.didCompleteSimiliarityProcessing()
            }
            
        }
    }
    
    func didCompleteSimiliarityProcessing() {
        let mediaTypes = MediaGroupType.allCases.filter({
            $0.needAnalizeAI
        })
        let index = mediaTypes.firstIndex(of: self.assetFetch.mediaType) ?? 0
        if (index + 1) > mediaTypes.count - 1 {
            print("completed processing similiarities")
            return
        } else {
            self.assetFetch.mediaType = mediaTypes[index + 1]
            print(self.assetFetch.mediaType, " gterfweda")
            self.similarityManager?.type = self.assetFetch.mediaType
            self.assetFetch.fetch()
        }
    }
}

extension UIViewController {
    static func configure(storyboardID: String? = nil) -> Self {
        return UIStoryboard(name: storyboardID ?? "Main", bundle: nil).instantiateViewController(withIdentifier: .init(describing: Self.self)) as! Self
    }
}
