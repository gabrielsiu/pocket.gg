//
//  TournamentListViewController.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-01-31.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class TournamentListViewController: UITableViewController {
    
    var tournaments = [Tournament]()
    var doneRequest = false

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tournaments"
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: k.Identifiers.tournamentCell)
        tableView.rowHeight = 75
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshTournamentList), for: .valueChanged)
        
        refreshTournamentList()
    }
    
    // MARK: - Actions
    
    @objc private func refreshTournamentList() {
        NetworkService.getTournamentsByVideogames(pageNum: 1) { [weak self] (result) in
            guard let result = result else {
                self?.doneRequest = true
                let alert = UIAlertController(title: k.Error.requestTitle, message: k.Error.getTournamentsMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self?.present(alert, animated: true)
                self?.refreshControl?.endRefreshing()
                return
            }
            self?.tournaments = result
            self?.doneRequest = true
            self?.tableView.reloadData()
            self?.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doneRequest ? tournaments.count : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard doneRequest else { return LoadingCell() }
        if let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.tournamentCell, for: indexPath) as? SubtitleCell {
            guard let tournament = tournaments[safe: indexPath.row] else {
                return UITableViewCell()
            }
            cell.accessoryType = .disclosureIndicator
            cell.setPlaceholder("placeholder")
            cell.updateView(text: tournament.name, imageInfo: (tournament.logoUrl, nil), detailText: tournament.date)
            return cell
        }
        return UITableViewCell()
    }

    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tournament = tournaments[safe: indexPath.row] else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        navigationController?.pushViewController(TournamentViewController(tournament), animated: true)
    }
}
