//
//  TournamentListViewController.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2021-05-15.
//  Copyright © 2021 Gabriel Siu. All rights reserved.
//

import UIKit

struct GetTournamentsByVideogamesInfo {
    let perPage: Int
    let featured: Bool
    let gameIDs: [Int]
}

final class TournamentListViewController: UITableViewController {
    
    var tournaments = [Tournament]()
    let info: GetTournamentsByVideogamesInfo
    var currentTournamentsPage = 1
    var doneRequest = true
    var noMoreTournaments = false
    
    // MARK: - Initialization
    
    init(_ tournaments: [Tournament], info: GetTournamentsByVideogamesInfo, title: String?) {
        self.tournaments = tournaments
        self.info = info
        super.init(style: .plain)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("TournamentListViewController deinit")
        tournaments.removeAll()
    }
    
    // MARK: - Additional Tournament Loading
    
    private func loadMoreTournaments() {
        guard doneRequest else { return }
        guard !noMoreTournaments else { return }
        
        currentTournamentsPage += 1
        doneRequest = false
        
        NetworkService.getTournamentsByVideogames(perPage: info.perPage,
                                                  pageNum: currentTournamentsPage,
                                                  featured: info.featured,
                                                  upcoming: true,
                                                  gameIDs: info.gameIDs) { [weak self] (tournaments) in
            guard let tournaments = tournaments else {
                self?.doneRequest = true
                // TODO: Make error popup
                return
            }
            
            // If no tournaments than expected were returned, then there are no more tournaments to load
            guard !tournaments.isEmpty else {
                self?.doneRequest = true
                self?.noMoreTournaments = true
                return
            }
            
            self?.tournaments.append(contentsOf: tournaments)
            self?.doneRequest = true
            self?.tableView.reloadData()
            
            // If less tournaments than expected were returned, then there are no more tournaments to load
            guard let self = self else { return }
            if tournaments.count < self.info.perPage {
                self.noMoreTournaments = true
            }
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(SubtitleCell.self, forCellReuseIdentifier: k.Identifiers.tournamentListCell)
        tableView.rowHeight = k.Sizes.tournamentListCellHeight
    }
    
    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tournaments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // If we are approaching the end of the list, load more tournaments
        if indexPath.row == tournaments.count - 3 {
            loadMoreTournaments()
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.tournamentListCell, for: indexPath) as? SubtitleCell {
            guard let tournament = tournaments[safe: indexPath.row] else {
                return UITableViewCell()
            }
            cell.accessoryType = .disclosureIndicator
            cell.setImage("placeholder")
            var detailText = tournament.date ?? ""
            detailText += tournament.isOnline ?? true ? "\nOnline" : ""
            cell.updateView(text: tournament.name, imageInfo: (tournament.logoUrl, nil), detailText: detailText)
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
