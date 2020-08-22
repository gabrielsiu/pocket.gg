//
//  VideoGamesViewController.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-12.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class VideoGamesViewController: UITableViewController {
    
    var preferredGames: Set<Int>
    var preferredGamesArr: [Int]?
    var filteredGames: [VideoGame]?
    var filteredEnabledGames: [VideoGame]?
    let searchController = UISearchController(searchResultsController: nil)
    var searchBarText: String? {
        return searchController.searchBar.text
    }
    var enabledVideoGamesControl: UISegmentedControl
    
    // MARK: - Initialization
    
    init() {
        // Load the array of enabled video games
        preferredGames = Set(UserDefaults.standard.array(forKey: k.UserDefaults.preferredVideoGames) as? [Int] ?? [1])
        
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
        UserDefaults.standard.set(Array(preferredGames), forKey: k.UserDefaults.preferredVideoGames)
    }
    
    // MARK: - Actions
    
    @objc private func videoGameEnableSwitchTapped(_ sender: UISwitch) {
        let gameId = sender.tag
        if preferredGames.contains(gameId) {
            guard let index = preferredGames.firstIndex(of: gameId) else { return }
            preferredGames.remove(at: index)
        } else {
            preferredGames.insert(gameId)
        }
    }
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        // ternary
        if sender.selectedSegmentIndex == 1 {
            preferredGamesArr = Array(preferredGames).sorted()
            if let filteredGames = filteredGames {
                filteredEnabledGames = filteredGames.filter { preferredGames.contains($0.id) }
            }
        } else {
            preferredGamesArr = nil
        }
        tableView.reloadData()
    }
    
    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If we are currently filtering
        if let filteredGames = filteredGames {
            if enabledVideoGamesControl.selectedSegmentIndex == 1 {
                return filteredGames.filter { preferredGames.contains($0.id) }.count
            } else {
                return filteredGames.count
            }
        }
        // We are not filtering
        return enabledVideoGamesControl.selectedSegmentIndex == 1 ? preferredGames.count : videoGames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.videoGameCell, for: indexPath)
        
        let id: Int
        let name: String
        // switch order of ifs (if possible)
        if let filteredGames = filteredGames {
            if let filteredEnabledGames = filteredEnabledGames, enabledVideoGamesControl.selectedSegmentIndex == 1 {
                id = filteredEnabledGames[indexPath.row].id
                name = filteredEnabledGames[indexPath.row].name
            } else {
                id = filteredGames[indexPath.row].id
                name = filteredGames[indexPath.row].name
            }
        } else {
            if let preferredGames = preferredGamesArr, enabledVideoGamesControl.selectedSegmentIndex == 1 {
                id = preferredGames[indexPath.row]
                name = videoGames.first(where: { $0.id == id })?.name ?? "hi hand"
            } else {
                id = videoGames[indexPath.row].id
                name = videoGames[indexPath.row].name
            }
        }
        
        cell.selectionStyle = .none
        cell.textLabel?.text = name
        let enabledSwitch = UISwitch()
        enabledSwitch.setOn(preferredGames.contains(id), animated: false)
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
            filteredGames = nil
            filteredEnabledGames = nil
            if enabledVideoGamesControl.selectedSegmentIndex == 1 {
                preferredGamesArr = Array(preferredGames).sorted()
            }
            tableView.reloadData()
            return
        }
        filteredGames = videoGames.filter({ (videoGame) -> Bool in
            return videoGame.name.lowercased().contains(searchText.lowercased())
        })
        if let filteredGames = filteredGames {
            filteredEnabledGames = filteredGames.filter { preferredGames.contains($0.id) }
        }
        tableView.reloadData()
    }
}
