//
//  VideoGamesVC.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-12.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class VideoGamesVC: UITableViewController {
    
    var headerView: UIView
    let searchBar: UISearchBar
    var enabledGames: [VideoGame]
    
    // MARK: - Initialization
    
    init() {
        // Load the list of enabled video games
        enabledGames = PreferredGamesService.getEnabledGames()
        headerView = UIView(frame: .zero)
        searchBar = UISearchBar(frame: .zero)
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Video Game Selection"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: k.Identifiers.videoGameCell)
        navigationItem.rightBarButtonItem = enabledGames.isEmpty ? nil : editButtonItem
        setupHeaderView()
    }
    
    private func setupHeaderView() {
        searchBar.delegate = self
        searchBar.placeholder = "Search Video Games"
        searchBar.searchBarStyle = .minimal
        
        let textLabel = UILabel(frame: .zero)
        textLabel.text = "Enabled Games"
        textLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        headerView.addSubview(searchBar)
        headerView.addSubview(textLabel)
        
        searchBar.setEdgeConstraints(top: headerView.topAnchor,
                                     bottom: textLabel.topAnchor,
                                     leading: headerView.leadingAnchor,
                                     trailing: headerView.trailingAnchor)
        textLabel.setEdgeConstraints(top: searchBar.bottomAnchor,
                                     bottom: headerView.bottomAnchor,
                                     leading: headerView.leadingAnchor,
                                     trailing: headerView.trailingAnchor,
                                     padding: UIEdgeInsets(top: 0, left: 16, bottom: 5, right: 0))
    }
    
    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return enabledGames.isEmpty ? 1 : enabledGames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !enabledGames.isEmpty else { return UITableViewCell().setupDisabled("No enabled games") }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.videoGameCell, for: indexPath)
        cell.textLabel?.text = enabledGames[indexPath.row].name
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    // TODO: Figure out why footer is slidable when only 1 game is added
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return """
        Use the search bar to find video games you are interested in. Tournaments that feature at least 1 of the games added here \
        will show up on the main screen.
        """
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !enabledGames.isEmpty
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return !enabledGames.isEmpty
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedVideoGame = enabledGames.remove(at: sourceIndexPath.row)
        enabledGames.insert(movedVideoGame, at: destinationIndexPath.row)
        PreferredGamesService.updateEnabledGames(enabledGames)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            enabledGames.remove(at: indexPath.row)
            tableView.reloadData()
            if enabledGames.isEmpty {
                navigationItem.rightBarButtonItem = nil
            }
            PreferredGamesService.updateEnabledGames(enabledGames)
        }
    }
}

// MARK: - Search Bar Delegate

extension VideoGamesVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        guard let text = searchBar.text, text != "" else { return }
        let videoGamesSearchResultsVC = VideoGamesSearchResultsVC(searchTerm: text, enabledGames: enabledGames)
        videoGamesSearchResultsVC.reloadEnabledGames = { [weak self] in
            // If the list of enabled games was changed in VideoGamesSearchResultsVC, reload the table view
            self?.enabledGames = PreferredGamesService.getEnabledGames()
            self?.tableView.reloadData()
            if let noEnabledGames = self?.enabledGames.isEmpty, noEnabledGames {
                self?.navigationItem.rightBarButtonItem = nil
            } else {
                self?.navigationItem.rightBarButtonItem = self?.editButtonItem
            }
        }
        navigationController?.pushViewController(videoGamesSearchResultsVC, animated: true)
    }
}
