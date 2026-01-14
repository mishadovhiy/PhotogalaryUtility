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
    var navigationTransitionDelegateHolder: UINavigationControllerDelegate?
    let galaryEditorService: PHLibraryEditorManager = .init()
    
    var didCompress: Bool = false
    var selectedCompression: CompressQualityType = .low
    
    override var primaryButton: ButtonData? {
        if didCompress {
            return .init(title: "Keep Original Video", style: .primary, didPress: {
                self.navigationController?.popViewController(animated: true)
            })
        } else {
            return .init(title: "Compress", didPress: {
                self.startCompressingAnimation()
            })
        }
    }
    override var secondaryButton: ButtonData? {
        if didCompress {
            return .init(title: "Delete original", didPress: {
                self.galaryEditorService.delete([self.selectedAsset!]) {
                    self.navigationController?.popViewController(animated: true)
                }
            })
        } else {
            return nil
        }
    }
    
    func startCompressingAnimation() {
        let vc = RefreshViewController.configure()
        vc.presentationData = .init(title: "Compressing Video...", bottomSubtitle: "Please don’t close the app in order not to lose all progress", canCancel: true)
        vc.appearedAction = {
            self.loadAVAsset(from: self.selectedAsset!) { asset in
                self.galaryEditorService.saveVideo(asset: asset!) { ok in
                    self.didCompress = true
                    self.tableView.reloadData()
                    
                    vc.navigationController?.popViewController(animated: true)
                    self.navigationController?.delegate = self.navigationTransitionDelegateHolder
                    
                }
            }
            
        }
        self.navigationTransitionDelegateHolder = self.navigationController?.delegate
        self.navigationController?.delegate = nil
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateTableViewConstraints()
    }
    
    func updateTableViewConstraints() {
        let constant = tableView.constraints.first(where: {
            $0.firstAttribute == .height
        })!
        constant.constant = tableView.contentSize.height + view.safeAreaInsets.bottom + self.additionalSafeAreaInsets.bottom
        let animation = UIViewPropertyAnimator(duration: 0.23, curve: .linear) {
            self.tableView.superview?.layoutIfNeeded()
            self.tableView.superview?.setNeedsLayout()
            self.view.layoutIfNeeded()
            self.view.setNeedsLayout()
        }
        animation.startAnimation()
    }
    
    func loadAVAsset(
        from phAsset: PHAsset,
        completion: @escaping (AVAsset?) -> Void
    ) {
        guard phAsset.mediaType == .video else {
            completion(nil)
            return
        }
        
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        
        PHImageManager.default().requestAVAsset(
            forVideo: phAsset,
            options: options
        ) { avAsset, _, _ in
            completion(avAsset)
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.selectedCompression = CompressQualityType.allCases[indexPath.row]
            tableView.reloadData()
        }
    }
}

extension VideoCompressorViewController {
    static func configure() -> Self {
        return self.configure(storyboardID: "Reusable")
    }
}
