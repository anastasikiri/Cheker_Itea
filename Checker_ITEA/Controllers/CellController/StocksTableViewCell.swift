//
//  StocksTableViewCell.swift
//  Checker_ITEA
//
//  Created by Anastasia Bilous on 2022-07-26.
//

import UIKit

class StocksTableViewCellViewModel: Encodable, Decodable {
    let name: String
    let volume: Float
    let percent: Float
    
    init (
        name: String,
        volume: Float,
        percent: Float
    ) {
        self.name = name
        self.volume = volume
        self.percent = percent
    }
}

class StocksTableViewCell: UITableViewCell {
    
    @IBOutlet weak var stocksNameLabel: UILabel!
    @IBOutlet weak var stocksVolumeLabel: UILabel!
    @IBOutlet weak var stocksPercentLabel: UILabel!

    func configureStoks(with viewModel: StocksTableViewCellViewModel) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        stocksNameLabel.text = viewModel.name
        stocksNameLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        stocksVolumeLabel.text = formatter.string(for: viewModel.volume)
        stocksVolumeLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                
        if viewModel.percent < 0 {
            stocksPercentLabel.textColor = #colorLiteral(red: 1, green: 0.1921568627, blue: 0.3960784314, alpha: 1)
        } else {
            stocksPercentLabel.textColor = #colorLiteral(red: 0.5342506766, green: 0.8280531764, blue: 0.7813009024, alpha: 1)
        }
        stocksPercentLabel.text = String(format: "%.2f", viewModel.percent)+"%"
    }
}
