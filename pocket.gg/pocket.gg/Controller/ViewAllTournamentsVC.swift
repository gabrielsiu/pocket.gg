//
//  ViewAllTournamentsVC.swift
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

final class ViewAllTournamentsVC: TournamentListViewController {
    
    let info: GetTournamentsByVideogamesInfo
    var currentTournamentsPage: Int
    
    // MARK: - Initialization
    
    init(_ tournaments: [Tournament], info: GetTournamentsByVideogamesInfo, title: String?) {
        self.info = info
        currentTournamentsPage = 1
        
        super.init(tournaments, title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("ViewAllTournamentsVC deinit")
        tournaments.removeAll()
    }
    
    // MARK: - Additional Tournament Loading
    
    override func loadTournaments() {
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
            
            // If no tournaments were returned, then there are no more tournaments to load
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
}
