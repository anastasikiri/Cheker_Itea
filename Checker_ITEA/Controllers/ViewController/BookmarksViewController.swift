//
//  BookmarksViewController.swift
//  Checker_ITEA
//
//  Created by Anastasia Bilous on 2022-07-23.
//

import UIKit
import SafariServices

class BookmarksViewController: UIViewController, NewsTableViewCellDelegate {

    @IBOutlet weak var bookmarksTableView: UITableView!

    private var viewModelsBookmarks = [NewsTableViewCellViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        bookmarksTableView.register(
            UINib(nibName:"NewsTableViewCell", bundle: nil),
            forCellReuseIdentifier: "cell")
        bookmarksTableView.delegate = self
        bookmarksTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModelsBookmarks = UserDefaultsManager.shared.getValueForBookmarks() ?? [NewsTableViewCellViewModel]()
        bookmarksTableView.reloadData()
    }
    
    func didTapButton(cell: NewsTableViewCell) {
        if let chosenIndex = bookmarksTableView.indexPath(for: cell) {
            viewModelsBookmarks.remove(at: chosenIndex.row)            
            UserDefaultsManager.shared.setValueForBookmarks(value: viewModelsBookmarks)
            bookmarksTableView.reloadData()
            Alert.showBasicWithTimer(title: "Removed from Bookmarks",
                            message: "",
                            vc: self,
                            color: #colorLiteral(red: 0.8369857326,
                                                 green: 0.09360062793,
                                                 blue: 0,
                                                 alpha: 0.5))
        }
    }
    
    func didTapShareButton(cell: NewsTableViewCell) {
        if let chosenIndex = bookmarksTableView.indexPath(for: cell) {
            guard let url = URL(string: viewModelsBookmarks[chosenIndex.row].url) else {
                return
            }
            let shareSheetVC = UIActivityViewController(activityItems: [url],
                                                        applicationActivities: nil)
            present(shareSheetVC, animated: true)
        }
    }
}

extension BookmarksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        bookmarksTableView.deselectRow(at: indexPath, animated: true)
        let article = viewModelsBookmarks[indexPath.row].url
        guard let url = URL(string: article) else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
}

extension BookmarksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModelsBookmarks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell", for: indexPath) as? NewsTableViewCell
        else {
            fatalError()
        }
        self.viewModelsBookmarks = self.viewModelsBookmarks.sorted(
            by: { $0.publishedAt > $1.publishedAt })
        cell.configure(with: viewModelsBookmarks[indexPath.row],
                       imageButton: UIImage(systemName: "trash")!)
        cell.delegate = self
        return cell
    }
}
