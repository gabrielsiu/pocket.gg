//
//  MainVC.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-01-31.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class MainVC: UITableViewController {
    
    var tournaments: [[Tournament]]
    var preferredGames: [VideoGame]
    var doneRequest: [Bool]
    let numTournamentsToLoad: Int
    
    var showFeatured: Bool
    var showUpcoming: Bool
    var numTopSections: Int {
        return (showFeatured ? 1 : 0) + (showUpcoming ? 1 : 0)
    }
    var numSections: Int {
        return numTopSections + preferredGames.count
    }
    
    // MARK: - Initialization
    
    override init(style: UITableView.Style) {
        tournaments = []
        preferredGames = []
        doneRequest = []
        let longEdgeLength = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        numTournamentsToLoad = 2 * Int(longEdgeLength / k.Sizes.tournamentListCellHeight)
        showFeatured = UserDefaults.standard.bool(forKey: k.UserDefaults.featuredTournaments)
        showUpcoming = UserDefaults.standard.bool(forKey: k.UserDefaults.upcomingTournaments)
        
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tournaments"
        tableView.register(ScrollableRowCell.self, forCellReuseIdentifier: k.Identifiers.tournamentsRowCell)
        
        tableView.rowHeight = k.Sizes.tournamentCellHeight
        tableView.separatorColor = .clear
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshTournamentList), for: .valueChanged)
        
        preferredGames = PreferredGamesService.getEnabledGames()
        doneRequest = [Bool](repeating: false, count: numSections)
        tournaments = [[Tournament]](repeating: [], count: numSections)
        
        getTournaments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ImageCacheService.clearCache(.viewAllTournaments)
    }
    
    // MARK: - Actions
    
    @objc private func refreshTournamentList() {
        showFeatured = UserDefaults.standard.bool(forKey: k.UserDefaults.featuredTournaments)
        showUpcoming = UserDefaults.standard.bool(forKey: k.UserDefaults.upcomingTournaments)
        
        preferredGames = PreferredGamesService.getEnabledGames()
        doneRequest = [Bool](repeating: false, count: numSections)
        tournaments = [[Tournament]](repeating: [], count: numSections)
        tableView.reloadData()
        getTournaments()
    }
    
    private func getTournaments() {
        guard !preferredGames.isEmpty else {
            doneRequest = [Bool](repeating: true, count: numSections)
            refreshControl?.endRefreshing()
            tableView.reloadData()
            return
        }
        
        let dispatchGroup = DispatchGroup()
        let gameIDs = preferredGames.map { $0.id }
        
        for _ in 0..<numSections {
            dispatchGroup.enter()
        }
        for i in 0..<numSections {
            let featured = showFeatured && i == 0
            let gameIDs = i < numTopSections ? gameIDs : [gameIDs[i - numTopSections]]
            
            NetworkService.getTournamentsByVideogames(perPage: numTournamentsToLoad,
                                                      pageNum: 1,
                                                      featured: featured,
                                                      upcoming: true,
                                                      gameIDs: gameIDs) { [weak self] (tournaments) in
                guard let tournaments = tournaments else {
                    self?.doneRequest[i] = true
                    dispatchGroup.leave()
                    return
                }
                self?.tournaments[i] = tournaments
                self?.doneRequest[i] = true
                
                self?.tableView.reloadSections([i], with: .automatic)
                dispatchGroup.leave()
            }
        }
        
        // Hide the refresh control once all the requests have finished
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.refreshControl?.endRefreshing()
        }
    }
    
    private func sectionHeaderTitle(for section: Int) -> String? {
        switch section {
        case 0:
            if showFeatured { return "Featured Tournaments" }
            if showUpcoming { return "Upcoming Tournaments" }
            return preferredGames[section].name
        case 1:
            if showFeatured && showUpcoming { return "Upcoming Tournaments" }
            guard section - numTopSections < preferredGames.count else { return nil }
            return preferredGames[section - numTopSections].name
        default:
            guard section - numTopSections < preferredGames.count else { return nil }
            return preferredGames[section - numTopSections].name
        }
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return numSections
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: .zero)
        
        let textLabel = UILabel(frame: .zero)
        textLabel.text = sectionHeaderTitle(for: section)
        textLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        headerView.addSubview(textLabel)
        textLabel.setEdgeConstraints(top: headerView.topAnchor,
                                     bottom: headerView.bottomAnchor,
                                     leading: headerView.leadingAnchor,
                                     padding: UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 0))
        
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        headerView.addSubview(button)
        button.setEdgeConstraints(top: headerView.topAnchor,
                                  bottom: headerView.bottomAnchor,
                                  trailing: headerView.trailingAnchor,
                                  padding: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 16))
        // If there are more than 10 tournaments in a section, show the "View All" button
        // To make the vertical spacing consistent, the "View All" button is always added (just not visible when there are 10 or less tournaments)
        if tournaments[section].count > 10 {
            button.setTitle("View All", for: .normal)
            button.setTitleColor(.systemRed, for: .normal)
            button.addTarget(self, action: #selector(viewAllTournaments(sender:)), for: .touchUpInside)
            button.tag = section
            button.leadingAnchor.constraint(greaterThanOrEqualTo: textLabel.trailingAnchor, constant: 5).isActive = true
        } else {
            textLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16).isActive = true
        }
        
        return headerView
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ScrollableRowCell else { return }
        cell.setCollectionViewProperties(self, forSection: indexPath.section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard doneRequest[indexPath.section] else { return LoadingCell(color: .secondarySystemBackground) }
        guard !preferredGames.isEmpty else { return NoEnabledGamesCell() }
        guard !tournaments[indexPath.section].isEmpty else { return NoTournamentsCell() }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.tournamentsRowCell, for: indexPath) as? ScrollableRowCell {
            return cell
        }
        
        return UITableViewCell()
    }
}

// MARK: - Collection View Data Source & Delegate

extension MainVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard doneRequest[collectionView.tag] else { return 0 }
        // If more than 10 tournaments were returned, only show the first 10 and show a "View All" button in the header view
        return tournaments[collectionView.tag].count > 10 ? 10 : tournaments[collectionView.tag].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: k.Identifiers.tournamentCell, for: indexPath) as? ScrollableRowItemCell {
            guard let tournament = tournaments[safe: collectionView.tag]?[safe: indexPath.row] else { return cell }
            
            cell.imageView.image = nil
            cell.setLabelsStyle()
            var detailText = tournament.date ?? ""
            detailText += tournament.isOnline ?? true ? "\nOnline" : ""
            cell.updateView(text: tournament.name, imageURL: tournament.logoUrl, detailText: detailText)
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: k.Sizes.tournamentCellWidth, height: k.Sizes.tournamentCellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tournament = tournaments[safe: collectionView.tag]?[safe: indexPath.row] else { return }
        navigationController?.pushViewController(TournamentVC(tournament, cacheForLogo: .viewAllTournaments), animated: true)
    }
    
    @objc private func viewAllTournaments(sender: UIButton) {
        let section = sender.tag
        let gameIDs = section < numTopSections ? preferredGames.map { $0.id } : [preferredGames.map({ $0.id })[section - numTopSections]]
        let info = GetTournamentsByVideogamesInfo(perPage: numTournamentsToLoad,
                                                  featured: section == 0,
                                                  gameIDs: gameIDs)
        navigationController?.pushViewController(ViewAllTournamentsVC(tournaments[section],
                                                                      info: info,
                                                                      title: sectionHeaderTitle(for: section)), animated: true)
    }
}
