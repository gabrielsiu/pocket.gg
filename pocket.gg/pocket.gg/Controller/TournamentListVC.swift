//
//  TournamentListVC.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2021-05-15.
//  Copyright © 2021 Gabriel Siu. All rights reserved.
//

import UIKit

class TournamentListVC: UITableViewController {
    
    var tournaments = [Tournament]()
    var doneRequest: Bool
    var noMoreTournaments: Bool
    
    // MARK: - Initialization
    
    init(_ tournaments: [Tournament], title: String?) {
        self.tournaments = tournaments
        doneRequest = true
        noMoreTournaments = false
        
        super.init(style: .grouped)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(SubtitleCell.self, forCellReuseIdentifier: k.Identifiers.tournamentListCell)
        tableView.rowHeight = k.Sizes.tournamentListCellHeight
        tableView.separatorColor = .clear
    }
    
    // MARK: - Tournament Loading
    
    func loadTournaments() {
        fatalError("This implementation should never get called. Subclasses should override this method and use their own implementation")
    }
    
    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tournaments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // If we are approaching the end of the list, load more tournaments
        if indexPath.row == tournaments.count - 3 {
            loadTournaments()
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.tournamentListCell, for: indexPath) as? SubtitleCell {
            guard let tournament = tournaments[safe: indexPath.row] else {
                return UITableViewCell()
            }
            cell.accessoryType = .disclosureIndicator
            cell.setBackgroundColor(.systemGroupedBackground)
            cell.setImage("placeholder")
            cell.detailTextLabel?.numberOfLines = 2
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
        navigationController?.pushViewController(TournamentVC(tournament), animated: true)
    }
}
