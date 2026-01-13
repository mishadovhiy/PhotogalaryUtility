//
//  VideoCompressorViewController.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import UIKit
import Photos

class VideoCompressorViewController: BaseViewController {

    @IBOutlet private weak var demoImageView: UIImageView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet weak var videoContainerView: UIView!
    var selectedAsset: PHAsset?
    override var navigationTransactionTargetView: UIView? {
        videoContainerView
    }
    var didCompress: Bool = false
    var selectedCompression: CompressQualityType = .low
    
    override var primaryButton: ButtonData? {
        if didCompress {
            return .init(title: "Keep Original Video", style: .primary)
        } else {
            return .init(title: "Compress")
        }
    }
    var count = 4
    
    override func loadView() {
        super.loadView()
        self.title = "Video Compressor"
        loadVideoChild()
        videoContainerView.layer.cornerRadius = 5
        videoContainerView.layer.masksToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.reloadData()
        updateTableViewConstraints()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            self.count = 7
            self.tableView.reloadData()
            self.updateTableViewConstraints()
        })
        
    }    

    func updateTableViewConstraints() {
        let constant = tableView.constraints.first(where: {
            $0.firstAttribute == .height
        })!
        constant.constant = tableView.contentSize.height + view.safeAreaInsets.bottom
        print(tableView.contentSize.height)
        let animation = UIViewPropertyAnimator(duration: 0.23, curve: .linear) {
            self.tableView.superview?.layoutIfNeeded()
            self.tableView.superview?.setNeedsLayout()
            self.view.layoutIfNeeded()
            self.view.setNeedsLayout()
        }
        animation.startAnimation()
    }

}

fileprivate
extension VideoCompressorViewController {
    func loadVideoChild() {
        if self.selectedAsset == nil {
            demoImageView.alpha = 1
            return
        } else {
            demoImageView.alpha = 0
        }
        let child = VideoPlayerViewController.configure()
        videoContainerView.addSubview(child.view)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.view.leadingAnchor.constraint(equalTo: child.view.superview!.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: child.view.superview!.trailingAnchor),
            child.view.topAnchor.constraint(equalTo: child.view.superview!.topAnchor),
            child.view.bottomAnchor.constraint(equalTo: child.view.superview!.bottomAnchor)
        ])
        self.addChild(child)
        child.didMove(toParent: self)
    }
}

extension VideoCompressorViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if didCompress {
                return 0
            } else {
                return CompressQualityType.allCases.count
            }
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: .init(describing: CompressorCell.self), for: indexPath) as! CompressorCell
            cell.set(.init(currentSize: 100, compressedSize: 4))
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: .init(describing: ComressorQualityCell.self), for: indexPath) as! ComressorQualityCell
            let type = CompressQualityType.allCases[indexPath.row]
            cell.set(type: type, isSelected: type == self.selectedCompression)
            return cell
        default: return .init()
        }
    }
}

extension VideoCompressorViewController {
    static func configure() -> Self {
        return self.configure(storyboardID: "Reusable")
    }
}
