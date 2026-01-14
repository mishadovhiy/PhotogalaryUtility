//
//  LocalDataBaseService.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 14.01.2026.
//

import Foundation

struct LocalDataBaseService {
    static var db: LocalDataBaseModel {
        get {
            let data = UserDefaults.standard.data(forKey: .init(describing: Self.self) + "1")
            let dataBaseModel = try? JSONDecoder().decode(LocalDataBaseModel.self, from: data ?? .init())
            return dataBaseModel ?? .init()
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.setValue(data ?? .init(), forKey: .init(describing: Self.self) + "1")
        }
    }
}

