//
//  TournamentSearchVC.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2021-05-23.
//  Copyright © 2021 Gabriel Siu. All rights reserved.
//

import UIKit

final class TournamentSearchVC: UITableViewController {
    
    let searchBar: UISearchBar
    var recentSearches: [String]
    
    // MARK: - Initialization
    
    init() {
        searchBar = UISearchBar(frame: .zero)
        recentSearches = UserDefaults.standard.array(forKey: k.UserDefaults.recentSearches) as? [String] ?? []
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBar.placeholder = "Search for tournaments on smash.gg"
        navigationItem.titleView = searchBar
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return recentSearches.isEmpty ? 1 : 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return recentSearches.count
        case 1: return 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: return UITableViewCell().setupActive(textColor: .label, text: recentSearches[indexPath.row])
        case 1:
            let cell = UITableViewCell()
            cell.textLabel?.textColor = .systemRed
            cell.textLabel?.text = "Clear recent searches"
            return cell
        default: return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return searchBar.isFirstResponder ? section == 0 ? "Recent Searches" : nil : "Recently Viewed Tournaments"
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            guard let text = recentSearches[safe: indexPath.row] else {
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
            let preferredGameIDs = PreferredGamesService.getEnabledGames().map { $0.id }
            navigationController?.pushViewController(TournamentSearchResultsVC(searchTerm: text, preferredGameIDs: preferredGameIDs), animated: true)
        case 1:
            recentSearches.removeAll()
            tableView.reloadData()
            UserDefaults.standard.setValue([], forKey: k.UserDefaults.recentSearches)
        default:
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

// MARK: - Search Bar Delegate

extension TournamentSearchVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        guard let text = searchBar.text, text != "" else { return }
        
        let preferredGameIDs = PreferredGamesService.getEnabledGames().map { $0.id }
        navigationController?.pushViewController(TournamentSearchResultsVC(searchTerm: text, preferredGameIDs: preferredGameIDs), animated: true)
        
        if recentSearches.count >= 5 {
            recentSearches.removeLast()
        }
        recentSearches.insert(text, at: 0)
        tableView.reloadData()
        UserDefaults.standard.setValue(recentSearches, forKey: k.UserDefaults.recentSearches)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.endEditing(true)
    }
}
