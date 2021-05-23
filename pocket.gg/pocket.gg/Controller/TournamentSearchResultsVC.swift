//
//  TournamentSearchResultsVC.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2021-05-22.
//  Copyright © 2021 Gabriel Siu. All rights reserved.
//

import UIKit

final class TournamentSearchResultsVC: TournamentListViewController {
    
    let searchBar: UISearchBar
    var preferredGameIDs: [Int]
    var currentSearchResultsPage: Int
    
    let numTournamentsToLoad: Int
    
    // MARK: - Initialization
    
    init() {
        searchBar = UISearchBar(frame: .zero)
        preferredGameIDs = []
        currentSearchResultsPage = 0
        let longEdgeLength = UIScreen.main.bounds.height > UIScreen.main.bounds.width ? UIScreen.main.bounds.height : UIScreen.main.bounds.width
        //TODO: find actual num instead of 20
        numTournamentsToLoad = max(20, 2 * Int(longEdgeLength / k.Sizes.tournamentListCellHeight))
        
        super.init([], title: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.placeholder = "Search for tournaments on smash.gg"
        
        navigationItem.titleView = searchBar
    }
    
    // MARK: - Tournament Loading
    
    override func loadTournaments() {
        guard doneRequest else { return }
        guard !noMoreTournaments else { return }
        
        currentSearchResultsPage += 1
        doneRequest = false
        
        NetworkService.searchForTournaments(searchBar.text,
                                            gameIDs: preferredGameIDs,
                                            perPage: numTournamentsToLoad,
                                            page: currentSearchResultsPage) { [weak self] (tournaments) in
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
            if tournaments.count < self.numTournamentsToLoad {
                self.noMoreTournaments = true
            }
        }
    }
}

// MARK: - Search Bar Delegate

extension TournamentSearchResultsVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        preferredGameIDs = PreferredGamesService.getEnabledGames().map { $0.id }
        currentSearchResultsPage = 0
        loadTournaments()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.endEditing(true)
    }
}
