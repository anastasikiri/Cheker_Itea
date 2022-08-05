//
//  File.swift
//  Checker_ITEA
//
//  Created by Anastasia Bilous on 2022-07-22.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    struct Constants {
        static let topHeadlinesURL = URL(string: "https://newsapi.org/v2/top-headlines?country=us&apiKey=899c7275b7b248bf8b057765be65cd11")
        static let searchUrlString = "https://newsapi.org/v2/everything?sortedBy=popularity&apiKey=899c7275b7b248bf8b057765be65cd11&q="
        static let stocksURL = URL(string: "http://phisix-api3.appspot.com/stocks.json")
    }
    
    private init() {}
    
    public func getTopStories(completion:@escaping (Result<[Article], Error>) -> Void) {
        guard let url = Constants.topHeadlinesURL else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, error  in
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data {
                
                do {
                    let result = try JSONDecoder().decode(APIResponseArticle.self, from: data)
                    completion(.success(result.articles))
                }
                catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
        
    public func search(with query: String, completion:@escaping (Result<[Article], Error>) -> Void) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        let urlString = Constants.searchUrlString + query
                guard let url = URL(string: urlString) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error  in
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data {
                
                do {
                    let result = try JSONDecoder().decode(APIResponseArticle.self, from: data)
                    completion(.success(result.articles))
                }
                catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    public func getStocks(completion:@escaping (Result<[Stock], Error>) -> Void) {
        guard let url = Constants.stocksURL else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, error  in
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data {
                
                do {
                    let result = try JSONDecoder().decode(APIResponseStock.self, from: data)
                    completion(.success(result.stock))
                }
                catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
