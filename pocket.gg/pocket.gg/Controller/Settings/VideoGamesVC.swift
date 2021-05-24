//
//  VideoGamesVC.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-12.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class VideoGamesVC: UITableViewController {
    var displayedGames: [VideoGame]
    var enabledGames: [VideoGame]
    var enabledGameIDs: Set<Int>
    
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Initialization
    
    init() {
        // Load the list of enabled video games
        enabledGames = PreferredGamesService.getEnabledGames()
        enabledGameIDs = enabledGames.reduce(into: Set<Int>()) { $0.insert($1.id) }
        displayedGames = enabledGames
        
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
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for games to add"
        searchController.searchBar.delegate = self
        searchController.searchBar.setValue("Done", forKey: "cancelButtonText")
        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItem = editButtonItem
        
        definesPresentationContext = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Save the list of enabled video games
        PreferredGamesService.updateEnabledGames(enabledGames)
    }
    
    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedGames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.videoGameCell, for: indexPath)
        cell.textLabel?.text = displayedGames[indexPath.row].name
        cell.accessoryType = enabledGameIDs.contains(displayedGames[indexPath.row].id) ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // TODO: Add "No Search Results Found" and "No Enabled Games"
        
        // Not searching, 1 or more games are enabled
        if !searchController.isActive && !enabledGames.isEmpty {
            return "Enabled Games"
        }
        // Showing search results
        else if searchController.isActive && !displayedGames.isEmpty {
            return "Search Results"
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        // TODO: Complete wording
        return """
        Only tournaments that feature events with at least 1 of the video games selected here will show up on the main screen\n
        Use the search bar to search for games to add\n
        Use the Edit button to rearrange the order in which the games show up on the main screen
        """
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedVideoGame = enabledGames.remove(at: sourceIndexPath.row)
        enabledGames.insert(movedVideoGame, at: destinationIndexPath.row)
        displayedGames = enabledGames
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedID = displayedGames[indexPath.row].id
        
        // If the game was already enabled, disable it
        if enabledGameIDs.contains(selectedID) {
            enabledGameIDs.remove(selectedID)
            if let index = enabledGames.firstIndex(where: { $0.id == selectedID }) {
                enabledGames.remove(at: index)
            }
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        // Else, enable the game
        } else {
            enabledGameIDs.insert(selectedID)
            enabledGames.append(displayedGames[indexPath.row])
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
}

// MARK: - Search Bar Delegate

extension VideoGamesVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if !displayedGames.isEmpty {
            displayedGames.removeAll()
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        displayedGames = enabledGames
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // TODO: Maybe indicate loading
        do {
            displayedGames = try VideoGameDatabase.getVideoGamesForSearch(searchController.searchBar.text ?? "")
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
}
