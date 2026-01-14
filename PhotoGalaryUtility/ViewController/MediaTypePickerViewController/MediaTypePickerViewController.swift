//
//  MediaTypePickerViewController.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 11.01.2026.
//

import UIKit

class MediaTypePickerViewController: BaseViewController {
   
    @IBOutlet private weak var collectionView: UICollectionView!
    let collectionData: [MediaGroupType] = MediaGroupType.allCases.filter({
        $0.presentingOnPicker
    })
    var db: LocalDataBaseModel?
    let fileManager: FileManagerService = .init()
    var fileManagerFileCounts: [MediaGroupType: Int] = [:]
    override func loadView() {
        super.loadView()
        title = "Media"
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset.left = 16
        collectionView.contentInset.right = 16

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        didCompleteSilimiaritiesProccessing()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didCompleteSilimiaritiesProccessing()
    }
    
    override func didCompleteSilimiaritiesProccessing() {
        super.didCompleteSilimiaritiesProccessing()
        DispatchQueue(label: "db", qos: .background).async {
            self.db = LocalDataBaseService.db
            MediaGroupType.allCases.forEach { type in
                let fileManagerDict = self.fileManager.similiaritiesData(type: type).photos ?? [:]
                let combinedArray = fileManagerDict.flatMap { (key, values) in
                    [key] + values
                }
                self.fileManagerFileCounts.updateValue(combinedArray.count, forKey: type)
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
}

extension MediaTypePickerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .init(describing: MediaTypeCell.self), for: indexPath) as! MediaTypeCell
        let type = collectionData[indexPath.row]
        let count: Int
        if type.needAnalizeAI {
            count = self.fileManagerFileCounts[type] ?? 0
        } else {
            count = db?.metadataHelper.filesCount[type] ?? 0
        }
        cell.set(type: collectionData[indexPath.row], dataCount: count)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: collectionView.frame.width / 2 - 20, height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = GalaryViewController.configure()
        vc.mediaType = collectionData[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MediaTypePickerViewController {
    static func configure() -> Self {
        return self.configure(storyboardID: "Reusable")
    }
}
