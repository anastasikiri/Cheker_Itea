//
//  File.swift
//  Checker_ITEA
//
//  Created by Anastasia Bilous on 2022-07-22.
//

import Foundation

struct APIResponseArticle: Codable {
    let articles: [Article]
}

struct Article: Codable {
    let source: Source
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    
}
struct Source: Codable {
    let name: String
}
