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
    #warning("todo: fetch thumb and video")
    var selectedAsset: PHAsset?
    override var navigationTransactionTargetView: UIView? {
        videoContainerView
    }
    var count = 4
    
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
        tableView.superview?.layoutIfNeeded()
        tableView.superview?.setNeedsLayout()
        view.layoutIfNeeded()
        view.setNeedsLayout()
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
