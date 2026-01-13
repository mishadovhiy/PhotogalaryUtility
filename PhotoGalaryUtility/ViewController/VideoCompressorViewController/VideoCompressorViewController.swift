//
//  VideoCompressorViewController.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import UIKit
import Photos

class VideoCompressorViewController: BaseViewController {

    @IBOutlet private var tableView: UITableView!
    @IBOutlet weak var videoContainerView: UIView!
    var selectedAsset: PHAsset?
    override var navigationTransactionTargetView: UIView? {
        videoContainerView
    }
    var didCompress: Bool = false
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .init(describing: CompressorCell.self), for: indexPath) as! CompressorCell
        return cell
    }
}

extension VideoCompressorViewController {
    static func configure() -> Self {
        return self.configure(storyboardID: "Reusable")
    }
}
