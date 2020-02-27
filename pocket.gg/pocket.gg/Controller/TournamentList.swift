//
//  TournamentList.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-01-31.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class TournamentList: UITableViewController {
    
    var tournaments = [Tournament]()

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TournamentCell.self, forCellReuseIdentifier: k.Identifiers.tournamentCellIdentifier)
        
        setupNavigationBar()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshTournamentList), for: .valueChanged)
        tableView.rowHeight = 75
        
        refreshTournamentList()
        refreshControl?.beginRefreshing()
    }

    // MARK: - UI Setup
    
    private func setupNavigationBar() {
        navigationItem.title = "Tournaments"
        navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .search, target: nil, action: nil), animated: false)
        navigationItem.setRightBarButton(UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: self, action: #selector(settingsTapped)), animated: false)
    }
    
    // MARK: - Actions
    
    @objc private func refreshTournamentList() {
        tournaments.removeAll()
        NetworkService.getUpcomingTournamentsByVideogames(pageNum: 1) { [weak self] (complete, tournaments) in
            guard let tournaments = tournaments, complete else {
                // TODO: Add failed request popup
                self?.refreshControl?.endRefreshing()
                return
            }
            self?.tournaments = tournaments
            self?.tableView.reloadData()
            self?.refreshControl?.endRefreshing()
        }
    }
    
    @objc private func settingsTapped() {
        present(UINavigationController(rootViewController: SettingsViewController(style: .grouped)), animated: true, completion: nil)
    }
    
    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tournaments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.tournamentCellIdentifier, for: indexPath) as? TournamentCell {
            guard let tournament = tournaments[safe: indexPath.row] else {
                return UITableViewCell()
            }
            cell.updateView(name: tournament.name, imageUrl: tournament.imageUrl, date: tournament.date)
            return cell
        }
        return UITableViewCell()
    }
}
