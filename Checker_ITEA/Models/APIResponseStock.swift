//
//  File.swift
//  Checker_ITEA
//
//  Created by Anastasia Bilous on 2022-07-26.
//

import Foundation

struct APIResponseStock: Codable {
    let stock: [Stock]
}

struct Stock: Codable {
    let name: String
    let volume: Float
    let percent_change: Float
}

