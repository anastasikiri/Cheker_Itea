//
//  StocksViewController.swift
//  Checker_ITEA
//
//  Created by Anastasia Bilous on 2022-07-23.
//

import UIKit

class StocksViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var underlineViewLeft: UIView!
    @IBOutlet weak var underlineViewRight: UIView!    
    @IBOutlet weak var searchStocksBar: UISearchBar!
    @IBOutlet weak var stocksTableView: UITableView!
    
    private var stocks = [Stock]()
    private var viewModelsAll = [StocksTableViewCellViewModel]()
    private var viewModelsFavorites = [StocksTableViewCellViewModel]()
    private var searchResultsAll = [StocksTableViewCellViewModel]()
    private var searchResultsFavorites = [StocksTableViewCellViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        stocksTableView.register(UINib(nibName:"StocksTableViewCell", bundle: nil),
                               forCellReuseIdentifier: "StocksTableViewCell")
        stocksTableView.delegate = self
        stocksTableView.dataSource = self
        searchStocksBar.delegate = self
        
        setTextProperties(color: UIColor.systemGray2, state: .normal)
        setTextProperties(color: UIColor.white, state: .selected)
        
        underlineViewLeft.isHidden = false
        underlineViewRight.isHidden = true
        
        fetchStocks()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchStocksBar.searchTextField.leftView = nil
        searchStocksBar.searchTextField.rightView = UIImageView.init(image: UIImage(named: "Zoom")!)
        searchStocksBar.searchTextField.rightViewMode = UITextField.ViewMode.always
    }
    
    private func setTextProperties(color: UIColor, state: UIControl.State) {
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)], for: state)
    }

    @IBAction func segmentedControlValue(_ sender: UISegmentedControl) {
        changeSegmentedControlLinePosition()
    }
    
    private func changeSegmentedControlLinePosition() {
        if segmentedControl.selectedSegmentIndex == 0 {
            underlineViewLeft.isHidden = false
            underlineViewRight.isHidden = true
            searchStocksBar.text = ""
            searchResultsAll = viewModelsAll
            stocksTableView.reloadData()
        } else if segmentedControl.selectedSegmentIndex == 1 {
            underlineViewLeft.isHidden = true
            underlineViewRight.isHidden = false
            searchStocksBar.text = ""
            viewModelsFavorites = UserDefaultsManager.shared.getValueForFavoritesStocks() ?? [StocksTableViewCellViewModel]()
            var tempArray = [StocksTableViewCellViewModel]()
            for nameStock in viewModelsFavorites {
                if let index = viewModelsAll.firstIndex(
                    where: { $0.name == nameStock.name }
                ){
                    tempArray.append(viewModelsAll[index])
                }
            }
            viewModelsFavorites = tempArray
            searchResultsFavorites = viewModelsFavorites
            stocksTableView.reloadData()
        }
    }
    
    private func fetchStocks() {
        APICaller.shared.getStocks { [weak self] result in
            switch result {
            case .success(let stocks):
                self?.stocks = stocks
                self?.viewModelsAll = stocks.compactMap({
                    StocksTableViewCellViewModel(
                        name: $0.name,
                        volume: $0.volume,
                        percent: $0.percent_change
                    )
                })
                DispatchQueue.main.async {
                    self?.searchResultsAll = self!.viewModelsAll
                    self?.stocksTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension StocksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            stocksTableView.deselectRow(at: indexPath, animated: true)
        }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            var menu = UIMenu()
            if self.segmentedControl.selectedSegmentIndex == 0 {
                let storeAction = UIAction(
                    title: NSLocalizedString("Add to Favorites", comment: ""),
                    image: UIImage(named: "pocket")
                ) { action in
                    if self.viewModelsFavorites.contains(where: { $0.name == self.searchResultsAll[indexPath.row].name }) {
                        Alert.showBasicWithTimer(title: "Already exist in Favorites",
                                        message: "",
                                        vc: self,
                                        color: #colorLiteral(red: 0.8002454199,
                                                             green: 0.7617848106,
                                                             blue: 0.005944696406,
                                                             alpha: 0.5))
                    } else {
                        self.viewModelsFavorites.append(self.searchResultsAll[indexPath.row])
                        UserDefaultsManager.shared.setValueForFavoritesStocks(value:self.viewModelsFavorites)
                        Alert.showBasicWithTimer(title: "Added to Favorites",
                                        message: "",
                                        vc: self,
                                        color: #colorLiteral(red: 0,
                                                             green: 0.7077700682,
                                                             blue: 0.02155686647,
                                                             alpha: 0.5))
                    }
                }
                menu = UIMenu(title: "", children: [storeAction])
            } else if self.segmentedControl.selectedSegmentIndex == 1 {
                let removeAction = UIAction(
                    title: NSLocalizedString("Remove from Favorites", comment: ""),
                    image: UIImage(systemName: "trash")
                ) { action in
                    let temp = self.searchResultsFavorites.remove(at:indexPath.row)
                    let index = self.viewModelsFavorites.firstIndex(
                        where: {$0.name == temp.name}
                    )
                    self.viewModelsFavorites.remove(at: index ?? 0)
                    UserDefaultsManager.shared.setValueForFavoritesStocks(value:self.viewModelsFavorites)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    Alert.showBasicWithTimer(title: "Removed from Favorites",
                                    message: "",
                                    vc: self,
                                    color: #colorLiteral(red: 0.8369857326,
                                                         green: 0.09360062793,
                                                         blue: 0,
                                                         alpha: 0.5))
                }
                menu = UIMenu(title: "", children: [removeAction])
            }
            return menu
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchStocksBar.endEditing(true)
    }
}

extension StocksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var stocksCount = Int()
        if segmentedControl.selectedSegmentIndex == 0 {
            stocksCount = searchResultsAll.count
        } else if segmentedControl.selectedSegmentIndex == 1 {
            stocksCount = searchResultsFavorites.count
        }
        return stocksCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "StocksTableViewCell",
            for: indexPath) as? StocksTableViewCell
        else {
            fatalError()
        }
        
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = #colorLiteral(red: 0.1176470588, green: 0.1215686275, blue: 0.1490196078, alpha: 1)
        } else {
            cell.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.09019607843, blue: 0.1098039216, alpha: 1)
        }
        
        if segmentedControl.selectedSegmentIndex == 0 {
            self.searchResultsAll = self.searchResultsAll.sorted(
                by: { $0.name < $1.name })
            cell.configureStoks(with: searchResultsAll[indexPath.row])
        } else if segmentedControl.selectedSegmentIndex == 1 {
            self.searchResultsFavorites = self.searchResultsFavorites.sorted(
                by: { $0.name < $1.name })
            cell.configureStoks(with: searchResultsFavorites[indexPath.row])
        }
        return cell
    }
}

extension StocksViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if segmentedControl.selectedSegmentIndex == 0  {
            searchResultsAll = []
            if searchText == "" {
                searchResultsAll = viewModelsAll
            } else {
                for stock in viewModelsAll {
                    if  stock.name.lowercased().contains(searchText.lowercased()) {
                        searchResultsAll.append(stock)
                    }
                }
            }
            stocksTableView.reloadData()
        } else if segmentedControl.selectedSegmentIndex == 1 {
            searchResultsFavorites = []
            if searchText == "" {
                searchResultsFavorites = viewModelsFavorites
            } else {
                for stock in viewModelsFavorites {
                    if  stock.name.lowercased().contains(searchText.lowercased()) {
                        searchResultsFavorites.append(stock)
                    }
                }
            }
            stocksTableView.reloadData()
        }
    }
}
