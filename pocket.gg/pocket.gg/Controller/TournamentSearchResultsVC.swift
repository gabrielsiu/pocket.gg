//
//  TournamentSearchResultsVC.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2021-05-22.
//  Copyright © 2021 Gabriel Siu. All rights reserved.
//

import UIKit

final class TournamentSearchResultsVC: TournamentListVC {
    
    var searchTerm: String?
    var preferredGameIDs: [Int]
    var currentSearchResultsPage: Int
    
    let numTournamentsToLoad: Int
    let featured: Bool
    let sortBy: String
    
    // MARK: - Initialization
    
    init(searchTerm: String?, preferredGameIDs: [Int]) {
        self.searchTerm = searchTerm
        self.preferredGameIDs = preferredGameIDs
        currentSearchResultsPage = 0
        
        let longEdgeLength = UIScreen.main.bounds.height > UIScreen.main.bounds.width ? UIScreen.main.bounds.height : UIScreen.main.bounds.width
        //TODO: find actual num instead of 20
        numTournamentsToLoad = max(20, 2 * Int(longEdgeLength / k.Sizes.tournamentListCellHeight))
        featured = UserDefaults.standard.bool(forKey: k.UserDefaults.onlySearchFeatured)
        sortBy = UserDefaults.standard.bool(forKey: k.UserDefaults.showOlderTournamentsFirst) ? "startAt asc" : "startAt desc"
        
        super.init([], title: searchTerm)
        imageCache = .tournamentSearchResults
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("TournamentSearchResultsVC deinit")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadTournaments()
    }
    
    // MARK: - Tournament Loading
    
    override func loadTournaments() {
        guard doneRequest else { return }
        guard !noMoreTournaments else { return }
        
        currentSearchResultsPage += 1
        doneRequest = false
        
        NetworkService.searchForTournaments(searchTerm,
                                            gameIDs: preferredGameIDs,
                                            featured: featured,
                                            sortBy: sortBy,
                                            perPage: numTournamentsToLoad,
                                            page: currentSearchResultsPage) { [weak self] (tournaments) in
            guard let tournaments = tournaments else {
                self?.doneRequest = true
                // TODO: Make error popup
                self?.tableView.reloadData()
                return
            }
            
            // If no tournaments were returned, then there are no more tournaments to load
            guard !tournaments.isEmpty else {
                self?.doneRequest = true
                self?.noMoreTournaments = true
                // Only reload the table view if no tournaments were ever returned
                // (To change the LoadingCell to a "No tournaments found" cell)
                if let noTournaments = self?.tournaments.isEmpty, noTournaments {
                    self?.tableView.reloadData()
                }
                return
            }
            
            self?.doneRequest = true
            if let startIndex = self?.tournaments.count {
                let indexPaths = (startIndex..<(startIndex + tournaments.count)).map {
                    return IndexPath.init(row: $0, section: 0)
                }
                self?.tableView.performBatchUpdates({
                    if let deleteLoadingCell = self?.tournaments.isEmpty, deleteLoadingCell {
                        self?.tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                    }
                    self?.tournaments.append(contentsOf: tournaments)
                    self?.tableView.insertRows(at: indexPaths, with: .none)
                }, completion: nil)
            } else {
                self?.tableView.reloadData()
            }
            
            // If less tournaments than expected were returned, then there are no more tournaments to load
            guard let self = self else { return }
            if tournaments.count < self.numTournamentsToLoad {
                self.noMoreTournaments = true
            }
        }
    }
}
