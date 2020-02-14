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
    
    // MARK: Initialization
    
    init(preferredGames: [Int]) {
        self.preferredGames = preferredGames
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Video Game Selection"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: videoGameCellIdentifier)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UserDefaults.standard.set(preferredGames, forKey: preferredVideoGames)
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
        return videoGames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: videoGameCellIdentifier, for: indexPath)
        let gameId = gameIds[indexPath.row]
        cell.textLabel?.text = videoGames[gameId]
        cell.selectionStyle = .none
        
        let enabledSwitch = UISwitch()
        enabledSwitch.setOn(preferredGames.contains(gameId), animated: false)
        enabledSwitch.addTarget(self, action: #selector(videoGameEnableSwitchTapped(_:)), for: .valueChanged)
        enabledSwitch.tag = gameId
        cell.accessoryView = enabledSwitch
        
        return cell
    }
}
