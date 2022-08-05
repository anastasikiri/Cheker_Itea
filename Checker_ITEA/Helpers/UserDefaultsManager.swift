//
//  UserDefaultsManager.swift
//  Checker_ITEA
//
//  Created by Anastasia Bilous on 2022-07-31.
//

import Foundation

class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
  
    func setValueForFavoritesStocks(value: [StocksTableViewCellViewModel]?) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(value), forKey: "SaveStock")
    }
    
    func getValueForFavoritesStocks() -> [StocksTableViewCellViewModel]? {
        var favoriteStocks = [StocksTableViewCellViewModel]()
        if let data = UserDefaults.standard.value(forKey:"SaveStock") as? Data {
            favoriteStocks = try! PropertyListDecoder().decode(Array<StocksTableViewCellViewModel>.self, from: data)
        }
        return favoriteStocks
    }
    
    func setValueForBookmarks(value: [NewsTableViewCellViewModel]?) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(value), forKey: "SaveBookmarks")
    }
    
    func getValueForBookmarks() -> [NewsTableViewCellViewModel]? {
        var bookmarks = [NewsTableViewCellViewModel]()
        if let data = UserDefaults.standard.value(forKey:"SaveBookmarks") as? Data {
            bookmarks = try! PropertyListDecoder().decode(Array<NewsTableViewCellViewModel>.self, from: data)
        }
        return bookmarks
    }
}
