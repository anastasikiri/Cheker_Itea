//
//  NewsTableViewCell.swift
//  Checker_ITEA
//
//  Created by Anastasia Bilous on 2022-07-21.
//

import UIKit

class NewsTableViewCellViewModel: Encodable, Decodable {
    let title: String
    let description: String
    let imageURL: URL?
    var imageData: Data? = nil
    let publishedAt: String
    let url: String
    
    init (
        title: String,
        description: String,
        imageURL: URL?,
        publishedAt: String,
        url: String
    ) {
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.publishedAt = publishedAt
        self.url = url
    }
}

protocol NewsTableViewCellDelegate: AnyObject {
    func didTapButton(cell: NewsTableViewCell)
    func didTapShareButton(cell: NewsTableViewCell)
}

class NewsTableViewCell: UITableViewCell {
    
    weak var delegate: NewsTableViewCellDelegate?

    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var publishedDataLabel: UILabel!
    @IBOutlet weak var cellViewInside: UIView!
    @IBOutlet weak var saveDeleteButtonOutlet: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        newsImage.layer.cornerRadius = 10
        cellViewInside.layer.cornerRadius = 10
    }

    func configure(with viewModel: NewsTableViewCellViewModel, imageButton: UIImage) {
        saveDeleteButtonOutlet.setImage(imageButton, for: .normal)
        saveDeleteButtonOutlet.setPreferredSymbolConfiguration(
            UIImage.SymbolConfiguration(pointSize: 12), forImageIn: .normal)
        
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
        
        if let data = viewModel.imageData {
            newsImage.image = UIImage(data: data)
        } else if let url = viewModel.imageURL {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                viewModel.imageData = data
                DispatchQueue.main.async {
                    self?.newsImage.image = UIImage(data: data)
                }
            }.resume()
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        let stringDate = viewModel.publishedAt
        let date = dateFormatter.date(from: stringDate)
        let currentDate = Date()
        let components = Calendar.current.dateComponents(
            [.month, .weekOfYear, .day, .hour, .minute], from: date!, to: currentDate)

        if components.month ?? 0 > 0 {
            if components.month ?? 0 == 1 {
                publishedDataLabel.text = "\(components.month ?? 0) month ago"
            } else {
                publishedDataLabel.text = "\(components.month ?? 0) months ago"
            }
        } else if components.weekOfYear ?? 0 > 0 {
            if components.weekOfYear ?? 0 == 1 {
                publishedDataLabel.text = "\(components.weekOfYear ?? 0) week ago"
            } else {
                publishedDataLabel.text = "\(components.weekOfYear ?? 0) weeks ago"
            }
        } else if components.day ?? 0 > 0 {
            if components.day ?? 0 == 1 {
                publishedDataLabel.text = "\(components.day ?? 0) day ago"
            } else {
                publishedDataLabel.text = "\(components.day ?? 0) days ago"
            }
        }  else if components.hour ?? 0 > 0 {
            if components.hour ?? 0 == 1 {
                publishedDataLabel.text = "\(components.hour ?? 0) hour ago"
            } else {
                publishedDataLabel.text = "\(components.hour ?? 0) hours ago"
            }
        } else {
            if components.minute ?? 0 == 1 {
                publishedDataLabel.text = "\(components.minute ?? 0) min ago"
            } else {
                publishedDataLabel.text = "\(components.minute ?? 0) mins ago"
            }
        }
    }
    
    @IBAction func shareButton(_ sender: UIButton) {
        delegate?.didTapShareButton(cell: self)
    }
    
    @IBAction func saveDeleteButton(_ sender: UIButton) {
        delegate?.didTapButton(cell: self)
    }
}
