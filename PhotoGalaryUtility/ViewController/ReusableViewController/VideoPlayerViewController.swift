//
//  VideoPlayerViewController.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import UIKit
import Photos
import AVKit

class VideoPlayerViewController: UIViewController {

    var selectedAsset: PHAsset? {
        (parent as? VideoCompressorViewController)?.selectedAsset
    }
    
    override func loadView() {
        super.loadView()
        self.loadVideoPlayer()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        setPlayerItem()
    }

    func setPlayerItem() {
        guard let selectedAsset else {
            print(String(describing: parent.self))
            return
        }
        let options = PHVideoRequestOptions()
         options.isNetworkAccessAllowed = true
         options.deliveryMode = .automatic
         options.version = .current

         PHImageManager.default().requestPlayerItem(
             forVideo: selectedAsset,
             options: options
         ) { playerItem, info in
             DispatchQueue.main.async {
                 let vc = self.children.first(where: {
                     $0 is AVPlayerViewController
                 }) as? AVPlayerViewController
                 vc?.player = .init(playerItem: playerItem)
                 vc?.player?.play()
             }
         }
    }
}

fileprivate extension VideoPlayerViewController {
    func loadVideoPlayer() {
        let vc = AVPlayerViewController()
        if #available(iOS 14.2, *) {
            vc.canStartPictureInPictureAutomaticallyFromInline = true
        }
        vc.updatesNowPlayingInfoCenter = true
        vc.allowsPictureInPicturePlayback = true
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vc.view)
        NSLayoutConstraint.activate([
            vc.view.leadingAnchor.constraint(equalTo: vc.view.superview!.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: vc.view.superview!.trailingAnchor),
            vc.view.topAnchor.constraint(equalTo: vc.view.superview!.topAnchor),
            vc.view.bottomAnchor.constraint(equalTo: vc.view.superview!.bottomAnchor)
        ])
        addChild(vc)
        vc.didMove(toParent: self)
    }
}
