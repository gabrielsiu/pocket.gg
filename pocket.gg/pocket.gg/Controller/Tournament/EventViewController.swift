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
    var numTopStandings: Int {
        guard let numStandings = event.topStandings?.count else { return 1 }
        guard numStandings != 0 else { return 1 }
        guard numStandings == 8 else { return numStandings }
        return numStandings + 1
    }
    
    // MARK: - Initialization
    
    init(_ event: Tournament.Event) {
        self.event = event
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = event.name
        tableView.register(StandingCell.self, forCellReuseIdentifier: k.Identifiers.standingCell)
        
        // TODO: Create cell with progress spinner
        loadEventDetails()
    }
    
    private func loadEventDetails() {
        guard let id = event.id else {
            let alert = UIAlertController(title: k.Error.genericTitle, message: k.Error.generateEventMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        NetworkService.getEventById(id: id) { [weak self] (details) in
            guard let details = details else {
                let alert = UIAlertController(title: k.Error.requestTitle, message: k.Error.getEventDetailsMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self?.present(alert, animated: true)
                
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
        case 0: return numTopStandings
        default: fatalError("Invalid number of sections")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard numTopStandings != 1 else {
            let cell = UITableViewCell()
            cell.isUserInteractionEnabled = false
            cell.textLabel?.text = "No standings found"
            return cell
        }
        
        if indexPath.row == 8 {
            let cell = UITableViewCell()
            cell.textLabel?.textColor = view.tintColor
            cell.textLabel?.text = "View all standings"
            return cell
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.standingCell, for: indexPath) as? StandingCell {
            guard let standing = event.topStandings?[safe: indexPath.row] else {
                return UITableViewCell()
            }
            guard let placementNum = standing.placement else {
                cell.updateView(text: standing.name ?? "", detailText: nil)
                return cell
            }
            guard placementNum != 0 else {
                cell.updateView(text: standing.name ?? "", detailText: nil)
                return cell
            }
            
            let placement: String
            switch indexPath.row {
            case 0: placement = "🥇 "
            case 1: placement = "🥈 "
            case 2: placement = "🥉 "
            default: placement = " \(placementNum):  "
            }
            cell.updateView(text: placement + (standing.name ?? ""), detailText: nil)
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
