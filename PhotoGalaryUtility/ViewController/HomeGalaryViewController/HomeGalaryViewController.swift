//
//  HomeGalaryViewController.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import UIKit

class HomeGalaryViewController: UIViewController {

    @IBOutlet private weak var storageUsedPercentLabel: UILabel!
    @IBOutlet private weak var storageCyclePercentView: UIView!
    @IBOutlet private weak var storageLabel: UILabel!
    @IBOutlet private weak var collectionBackgroundView: UIView!
    @IBOutlet private weak var statisticView: UIView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    var collectionData: [GalaryCollectionModel] = [
        .init(section: .init(sectionTitle: "Video Compressor", subtitle: "12267 Media • 54.7 GB ", leftIconAssetName: .video, needViewAllButton: false, tint: .pink), collectionData: [.init(asset: .assetName("demoVideoThumb"))]),
        .init(section: .init(sectionTitle: "Media", subtitle: "12267 Media • 54.7 GB ", leftIconAssetName: .image, needViewAllButton: true, tint: .darkBlue), collectionData: [.init(asset: .assetName("demoThumb")), .init(asset: .assetName("demoThumb2"))])
    ]
    
    override func loadView() {
        super.loadView()
        navigationController?.setNavigationBarHidden(true, animated: false)
        collectionView.register(.init(nibName: .init(describing: PhotoCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: .init(describing: PhotoCollectionViewCell.self))
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: .init(describing: UICollectionViewCell.self))
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionBackgroundView.layer.cornerRadius = 30
        if #available(iOS 13.0, *) {
            collectionView.automaticallyAdjustsScrollIndicatorInsets = false
        }
        loadStorageUsedProgressLayer(needPath: true)
        loadStorageUsedProgressLayer(needPath: false)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storageText: NSMutableAttributedString = .init(string: "iPhone Storage" + "\n")
        storageText.append(.init(string: "28.7 GB", attributes: [
            .font: UIFont.systemFont(ofSize: storageLabel.font.pointSize, weight: .semibold)
        ]))
        storageText.append(.init(string: " " + "of 128.0 GB"))
        storageLabel.attributedText = storageText
        storageUsedPercentLabel.text = "44%"
        setStoragePercentPath()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)

        if collectionView.contentInset.top != statisticView.frame.height {
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6) {
                self.collectionView.contentInset.top = self.statisticView.frame.height
            }
        }
        
        (navigationController as? HomeNavigationController)?.viewModel.assetFetch.fetch()
    }
    
    func setStoragePercentPath() {
        
        let percent = 0.8
        let startAngle: CGFloat = -.pi / 2
        let endAngle = (startAngle + .pi) * percent
        let radius: CGFloat = 40
        let center = CGPoint(x: 50 + radius, y: 50 + radius)
        
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: .pi / 2,
            clockwise: true
        )
        let layer = storageCyclePercentView.layer.sublayers?.first(where: {
            $0 is CAShapeLayer && $0.name != "backgroundOval"
        }) as? CAShapeLayer
        layer?.path = path.cgPath
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let difference = (statisticView.frame.height) - (scrollView.contentOffset.y + statisticView.frame.height + view.safeAreaInsets.top)
        let constant = collectionBackgroundView.superview!.constraints.first(where: {
            $0.identifier == "collectionBackgroundTop"
        })!
        constant.constant = difference
        collectionBackgroundView.superview?.layoutIfNeeded()
    }
    
    @objc private func headerViewAllDidPress(_ sender: UIButton) {
        self.navigationController?.pushViewController(MediaTypePickerViewController.configure(), animated: true)
    }
}

extension HomeGalaryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let count = collectionData[indexPath.section].collectionData.count
        if count == 0 {
            return .init(width: 0, height: statisticView.frame.height)
        }
        let height = collectionView.frame.width / 2 - 5
        let width = count == 1 ? collectionView.frame.width : height
        return .init(width: width, height: height)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = collectionData[section].collectionData.count
        return count == 0 ? 1 : count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .init(describing: PhotoCollectionViewCell.self), for: indexPath) as! PhotoCollectionViewCell
        cell.set(collectionData[indexPath.section].collectionData[indexPath.row])
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        .init(width: collectionView.frame.width, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionData = collectionData[indexPath.section].section
        let vc: UIViewController?
        if sectionData.leftIconAssetName == .video {
            let galaryVC = GalaryViewController.configure()
            galaryVC.mediaType = .allVideos
            vc = galaryVC
        } else if sectionData.leftIconAssetName == .image {
            vc = MediaTypePickerViewController.configure()
        } else {
            vc = nil
        }
        if let vc {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: .init(describing: HomeGalaryHeaderView.self), for: indexPath) as! HomeGalaryHeaderView
        view.viewAllButton.addTarget(self, action: #selector(headerViewAllDidPress(_:)), for: .touchUpInside)
        view.set(collectionData[indexPath.section].section)
        return view
    }
}

extension HomeGalaryViewController {
    func loadStorageUsedProgressLayer(needPath: Bool) {
        let shapeLayer = CAShapeLayer()
        if needPath {
            let startAngle: CGFloat = -.pi / 2
            let endAngle = (startAngle + .pi) * 1
            let radius: CGFloat = 40
            let center = CGPoint(x: 50 + radius, y: 50 + radius)
            
            let path = UIBezierPath(
                arcCenter: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: true
            )
            shapeLayer.name = "backgroundOval"
            shapeLayer.path = path.cgPath
        }
        shapeLayer.strokeColor = UIColor.systemBlue.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 8
        shapeLayer.lineCap = .round

        storageCyclePercentView.layer.addSublayer(shapeLayer)
    }
}

extension HomeGalaryViewController {
    struct GalaryCollectionModel {
        let section: SectionModel
        let collectionData: [GalaryItemPresentationModel]
        
        struct SectionModel {
            let sectionTitle: String
            let subtitle: String
            let leftIconAssetName: ImageResource
            let needViewAllButton: Bool
            let tint: ColorResource
        }
    }
}
