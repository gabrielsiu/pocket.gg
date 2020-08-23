//
//  VideoGamesViewController.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-12.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

enum VideoGamesListState {
    case allGamesNotFiltered
    case allGamesFiltered
    case enabledGamesNotFiltered
    case enabledGamesFiltered
}

final class VideoGamesViewController: UITableViewController {
    
    var enabledGames: Set<Int>
    var enabledGamesArr: [Int]?
    var filteredGames: [VideoGame]?
    var filteredEnabledGames: [VideoGame]?
    var enabledVideoGamesControl: UISegmentedControl
    let searchController = UISearchController(searchResultsController: nil)
    var searchBarText: String? {
        return searchController.searchBar.text
    }
    var videoGamesListState: VideoGamesListState {
        if enabledVideoGamesControl.selectedSegmentIndex == 0 {
            return filteredGames == nil ? .allGamesNotFiltered : .allGamesFiltered
        } else {
            return filteredEnabledGames == nil ? .enabledGamesNotFiltered : .enabledGamesFiltered
        }
    }
    
    // MARK: - Initialization
    
    init() {
        // Load the list of enabled video games
        enabledGames = Set(UserDefaults.standard.array(forKey: k.UserDefaults.preferredVideoGames) as? [Int] ?? [1])
        
        enabledVideoGamesControl = UISegmentedControl(items: ["All Video Games", "Enabled Video Games"])
        enabledVideoGamesControl.selectedSegmentIndex = 0
        
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
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        enabledVideoGamesControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Save the list of enabled video games
        UserDefaults.standard.set(Array(enabledGames), forKey: k.UserDefaults.preferredVideoGames)
    }
    
    // MARK: - Actions
    
    @objc private func videoGameEnableSwitchTapped(_ sender: UISwitch) {
        let gameID = sender.tag
        if enabledGames.contains(gameID) {
            enabledGames.remove(gameID)
        } else {
            enabledGames.insert(gameID)
        }
    }
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            // We want to see all video games
            // Since we don't need a sorted list of enabled video games, invalidate it
            enabledGamesArr = nil
        } else {
            // We only want to see the enabled video games
            // Restore the sorted array of enabled games
            enabledGamesArr = Array(enabledGames).sorted()
            // If we are also filtering for a search term, update the array of filtered & enabled games
            if let filteredGames = filteredGames {
                filteredEnabledGames = filteredGames.filter { enabledGames.contains($0.id) }
            }
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch videoGamesListState {
        case .allGamesNotFiltered:
            return videoGames.count
        case .allGamesFiltered:
            guard let filteredGames = filteredGames else { return videoGames.count }
            return filteredGames.count
        case .enabledGamesNotFiltered:
            return enabledGames.count
        case .enabledGamesFiltered:
            guard let filteredEnabledGames = filteredEnabledGames else { return videoGames.count }
            return filteredEnabledGames.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.videoGameCell, for: indexPath)
        
        let id: Int
        let name: String
        
        // Determine the ID and name of the cell's game
        switch videoGamesListState {
        case .allGamesNotFiltered:
            id = videoGames[indexPath.row].id
            name = videoGames[indexPath.row].name
        case .allGamesFiltered:
            guard let filteredGames = filteredGames else { return cell }
            id = filteredGames[indexPath.row].id
            name = filteredGames[indexPath.row].name
        case .enabledGamesNotFiltered:
            guard let enabledGames = enabledGamesArr else { return cell }
            id = enabledGames[indexPath.row]
            name = videoGames.first(where: { $0.id == id })?.name ?? ""
        case .enabledGamesFiltered:
            guard let filteredEnabledGames = filteredEnabledGames else { return cell }
            id = filteredEnabledGames[indexPath.row].id
            name = filteredEnabledGames[indexPath.row].name
        }
        
        // Set up the cell
        cell.selectionStyle = .none
        cell.textLabel?.text = name
        let enabledSwitch = UISwitch()
        enabledSwitch.setOn(enabledGames.contains(id), animated: false)
        enabledSwitch.addTarget(self, action: #selector(videoGameEnableSwitchTapped(_:)), for: .valueChanged)
        enabledSwitch.tag = id
        cell.accessoryView = enabledSwitch
        
        return cell
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return enabledVideoGamesControl
    }
}

// MARK: - Search Controller Protocol

extension VideoGamesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchBarText, !(searchBarText?.isEmpty ?? true) else {
            // If the search bar has just become empty
            
            // We're not filtering anymore, so invalidate the filtered arrays
            filteredGames = nil
            filteredEnabledGames = nil
            // Restore the sorted array of enabled games if we only want to see the enabled games
            if enabledVideoGamesControl.selectedSegmentIndex == 1 {
                enabledGamesArr = Array(enabledGames).sorted()
            }
            
            tableView.reloadData()
            return
        }
        
        // Another character has been added/entered to the search bar
        
        // Update the array of filtered games by checking if each video game's name contains the search text
        filteredGames = videoGames.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        // Update the array of filtered & enabled games
        if let filteredGames = filteredGames {
            filteredEnabledGames = filteredGames.filter { enabledGames.contains($0.id) }
        }
        
        tableView.reloadData()
    }
}
