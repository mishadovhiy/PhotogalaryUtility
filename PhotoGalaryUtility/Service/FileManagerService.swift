//
//  DataBaseService.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 12.01.2026.
//

import Foundation

struct FileManagerService {
    private var localURL: URL? {
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first
    }
    
    func writeData(_ data: Codable, type: DataType) {
        guard let dir = localURL else {
            print("iCloud not available")
            return
        }
        let url = dir.appendingPathComponent(type.rawValue)
        
        do {
            try FileManager.default.createDirectory(
                at: dir,
                withIntermediateDirectories: true
            )
            let dataModel = try JSONEncoder().encode(data)
            try dataModel.write(to: url, options: .atomic)
        } catch {
            print(error, " ", #function, #file, #line)
            return
        }
    }
    enum DataType {
        case similiarPhotos

        case mediaGroupType(MediaGroupType)
        
        var rawValue: String {
            switch self {
            case .mediaGroupType(let mediaGroupType):
                    .init(describing: self.self) + mediaGroupType.rawValue
            default:
                    .init(describing: self.self)
            }
        }
        
        var responseType: Codable.Type {
            switch self {
            case .similiarPhotos, .mediaGroupType:
                SimilarityDataBaseModel.self
            }
        }
    }
    
    func load(type: DataType) -> Codable? {
        guard let dir = localURL else {
            print("iCloud not available")
            return nil
        }

        let url = dir.appendingPathComponent(type.rawValue)
        do {
            let data = try Data(contentsOf: url)
//            let response = try JSONDecoder().decode(type.responseType.self, from: data)
            
            let result = try JSONDecoder().decode(type.responseType.self, from: data)
            return result
        }
        catch {
            print(error, " ", #function, #file, #line)
            return nil
        }
    }
    
    var similiaritiesData: SimilarityDataBaseModel {
        get {
            load(type: .similiarPhotos) as? SimilarityDataBaseModel ?? .init()
        }
        set {
            writeData(newValue, type: .similiarPhotos)
        }
    }
}
