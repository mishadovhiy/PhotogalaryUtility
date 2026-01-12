//
//  HomeGalaryViewController.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import UIKit

class HomeGalaryViewController: UIViewController {

    @IBOutlet weak var collectionBackgroundView: UIView!
    @IBOutlet weak var statisticView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var collectionData: [[GalaryItemPresentationModel]] = [
        [.init(asset: .assetName("demo"))],
        [.init(asset: .assetName("demo")), .init(asset: .assetName("demo"))]
    ]
    
    override func loadView() {
        super.loadView()
        collectionBackgroundView.layer.cornerRadius = 30
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(.init(nibName: .init(describing: PhotoCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: .init(describing: PhotoCollectionViewCell.self))
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: .init(describing: UICollectionViewCell.self))
        collectionView.delegate = self
        collectionView.dataSource = self
        if #available(iOS 13.0, *) {
            collectionView.automaticallyAdjustsScrollIndicatorInsets = false
        }
        collectionView.contentInset.top = statisticView.frame.height
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let difference = (statisticView.frame.height) - (scrollView.contentOffset.y + statisticView.frame.height + view.safeAreaInsets.top)
        let constant = collectionBackgroundView.superview!.constraints.first(where: {
            $0.identifier == "collectionBackgroundTop"
        })!
        constant.constant = difference
        collectionBackgroundView.superview?.layoutIfNeeded()
    }
}

extension HomeGalaryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let count = collectionData[indexPath.section].count
        if count == 0 {
            return .init(width: 0, height: statisticView.frame.height)
        }
        let height = collectionView.frame.width / 2 - 10
        let width = count == 1 ? collectionView.frame.width : height
        return .init(width: width, height: height)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = collectionData[section].count
        return count == 0 ? 1 : count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionData = collectionData[indexPath.section]
        if sectionData.count == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .init(describing: UICollectionViewCell.self), for: indexPath) as! UICollectionViewCell
            cell.isUserInteractionEnabled = false
        
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .init(describing: PhotoCollectionViewCell.self), for: indexPath) as! PhotoCollectionViewCell
        cell.set(collectionData[indexPath.section][indexPath.row])
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        if collectionData[indexPath.row].isEmpty {
//            return .init()
//        }
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: .init(describing: HomeGalaryHeaderView.self), for: indexPath) as! HomeGalaryHeaderView
        view.set(.init(title: "some title \(indexPath.row)"))
        return view
    }
}

class HomeGalaryHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewAllButton: UIButton!
    
    struct HomeHeaderModel {
        let title: String
    }
    
    func set(_ data: HomeHeaderModel) {
        titleLabel.text = data.title
    }
}

class HomeGalaryCollectionCell: UICollectionViewCell {
    
}
