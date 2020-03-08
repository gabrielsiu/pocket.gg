//
//  VideoGameViewController.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-12.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class VideoGamesViewController: UITableViewController {
    
    var preferredGames: [Int]
    var filteredGames: [VideoGame]?
    var searchBar = UISearchBar()
    
    // MARK: - Initialization
    
    init(preferredGames: [Int]) {
        self.preferredGames = preferredGames
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Video Game Selection"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: k.Identifiers.videoGameCell)
        
        searchBar.frame = CGRect(x: 0, y: 0, width: 0, height: searchBar.intrinsicContentSize.height)
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        tableView.tableHeaderView = searchBar
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UserDefaults.standard.set(preferredGames, forKey: k.UserDefaults.preferredVideoGames)
    }
    
    // MARK: - Actions
    
    @objc private func videoGameEnableSwitchTapped(_ sender: UISwitch) {
        let gameId = sender.tag
        if preferredGames.contains(gameId) {
            guard let index = preferredGames.firstIndex(of: gameId) else { return }
            preferredGames.remove(at: index)
        } else {
            preferredGames.append(gameId)
        }
    }
    
    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filteredGames = filteredGames {
            return filteredGames.count
        }
        return videoGames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.videoGameCell, for: indexPath)
        
        let id: Int
        let name: String
        if let filteredGames = filteredGames {
            id = filteredGames[indexPath.row].id
            name = filteredGames[indexPath.row].name
        } else {
            id = videoGames[indexPath.row].id
            name = videoGames[indexPath.row].name
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
}

// MARK: - Search Bar Delegate

extension VideoGamesViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText.count != 0 else {
            filteredGames = nil
            tableView.reloadData()
            return
        }
        
        filteredGames = videoGames.filter { (videoGame) -> Bool in
            return videoGame.name.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
