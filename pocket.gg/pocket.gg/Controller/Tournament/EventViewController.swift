//
//  EventViewController.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-03-15.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class EventViewController: UITableViewController {
    
    var event: Tournament.Event
    
    // MARK: - Initialization
    
    init(_ event: Tournament.Event) {
        self.event = event
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = event.name
        tableView.register(StandingCell.self, forCellReuseIdentifier: k.Identifiers.standingCell)
        
        loadEventDetails()
    }
    
    private func loadEventDetails() {
        guard let id = event.id else {
            // TODO: Show nil id alert
            return
        }
        NetworkService.getEventById(id: id) { [weak self] (details) in
            guard let details = details else {
                // TODO: Add failed request popup
                return
            }
            self?.event.topStandings = details["standings"] as? [(String, Int)]
            self?.tableView.reloadSections([0], with: .automatic)
        }
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return event.topStandings?.count ?? 1
        default: fatalError("Invalid number of sections")
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.standingCell, for: indexPath) as? StandingCell {
            guard let standing = event.topStandings?[safe: indexPath.row] else {
                return UITableViewCell()
            }
            cell.updateView(text: standing.name, detailText: nil) // TODO
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Standings"
        default: return ""
        }
    }
}
