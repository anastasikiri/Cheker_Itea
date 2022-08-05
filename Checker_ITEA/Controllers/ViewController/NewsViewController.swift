//
//  ViewController.swift
//  Checker_ITEA
//
//  Created by Anastasia Bilous on 2022-07-20.
//

import UIKit
import SafariServices

class NewsViewController: UIViewController, NewsTableViewCellDelegate {
    
    @IBOutlet weak var newsTableView: UITableView!
    @IBOutlet weak var searchNewsBar: UISearchBar!
    
    private var articles = [Article]()
    private var viewModels = [NewsTableViewCellViewModel]()
    private var viewModelsBookmarksFavorite = [NewsTableViewCellViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        newsTableView.register(UINib(nibName:"NewsTableViewCell", bundle: nil),
                               forCellReuseIdentifier: "cell")
        newsTableView.delegate = self
        newsTableView.dataSource = self
        searchNewsBar.delegate = self
        
        fetchTopStories()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchNewsBar.searchTextField.leftView = nil
        searchNewsBar.searchTextField.rightView = UIImageView.init(image: UIImage(named: "Zoom")!)
        searchNewsBar.searchTextField.rightViewMode = UITextField.ViewMode.always
    }
    
    private func fetchTopStories() {
        APICaller.shared.getTopStories { [weak self] result in
            switch result {
            case .success(let articles):
                self?.articles = articles
                self?.viewModels = articles.compactMap({
                    NewsTableViewCellViewModel(
                        title: $0.title,
                        description: $0.description ?? "No description",
                        imageURL: URL(string: $0.urlToImage ?? ""),
                        publishedAt: $0.publishedAt,
                        url: $0.url
                    )
                })
                DispatchQueue.main.async {
                    self?.newsTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func didTapButton(cell: NewsTableViewCell) {
        if let chosenIndex = newsTableView.indexPath(for: cell) {
            viewModelsBookmarksFavorite = UserDefaultsManager.shared.getValueForBookmarks() ?? [NewsTableViewCellViewModel]()
            if self.viewModelsBookmarksFavorite.contains(
                where: { $0.title == self.viewModels[chosenIndex.row].title}) {
                Alert.showBasicWithTimer(title: "Already exist in Bookmarks",
                                message: "",
                                vc: self,
                                color: #colorLiteral(red: 0.8002454199,
                                                     green: 0.7617848106,
                                                     blue: 0.005944696406,
                                                     alpha: 0.5))
            } else {
                viewModelsBookmarksFavorite.append(viewModels[chosenIndex.row])
                UserDefaultsManager.shared.setValueForBookmarks(value: viewModelsBookmarksFavorite)
                Alert.showBasicWithTimer(title: "Added to Bookmarks",
                                message: "",
                                vc: self,
                                color: #colorLiteral(red: 0,
                                                     green: 0.7077700682,
                                                     blue: 0.02155686647,
                                                     alpha: 0.5))
            }
        }
    }
    
    func didTapShareButton(cell: NewsTableViewCell) {
        if let chosenIndex = newsTableView.indexPath(for: cell) {
            guard let url = URL(string: viewModels[chosenIndex.row].url) else {
                return
            }
            let shareSheetVC = UIActivityViewController(activityItems: [url],
                                                        applicationActivities: nil)
            present(shareSheetVC, animated: true)
        }
    }
}

extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        newsTableView.deselectRow(at: indexPath, animated: true)
        let article = viewModels[indexPath.row].url
        guard let url = URL(string: article) else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchNewsBar.endEditing(true)        
    }
}

extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath) as? NewsTableViewCell
        else {
            fatalError()
        }
        self.viewModels = self.viewModels.sorted(by: { $0.publishedAt > $1.publishedAt })
        cell.configure(with: viewModels[indexPath.row],
                       imageButton: UIImage(named: "pocket")!)
        cell.delegate = self
        return cell
    }
}

extension NewsViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchNewsBar.searchTextField.endEditing(true)
        fetchTopStories()
        searchNewsBar.showsCancelButton = false
        searchNewsBar.searchTextField.leftView = nil
        searchNewsBar.searchTextField.rightView = UIImageView.init(
            image: UIImage(named: "Zoom")!)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else {
            searchNewsBar.showsCancelButton = false
            searchNewsBar.endEditing(true)
            fetchTopStories()
            return
        }
        APICaller.shared.search(with: text) { [weak self] result in
            switch result {
            case .success(let articles):
                self?.articles = articles
                self?.viewModels = articles.compactMap({
                    NewsTableViewCellViewModel(
                        title: $0.title,
                        description: $0.description ?? "No description",
                        imageURL: URL(string: $0.urlToImage ?? ""),
                        publishedAt: $0.publishedAt,
                        url: $0.url
                    )
                })
                DispatchQueue.main.async {
                    self?.newsTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
        searchNewsBar.showsCancelButton = true
    }
}

