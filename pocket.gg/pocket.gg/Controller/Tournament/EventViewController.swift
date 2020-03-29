//
//  EventViewController.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-03-15.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit
import SafariServices

final class EventViewController: UITableViewController {
    
    var event: Tournament.Event
    var doneRequest = false
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
            self?.doneRequest = true
            guard let details = details else {
                let alert = UIAlertController(title: k.Error.requestTitle, message: k.Error.getEventDetailsMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self?.present(alert, animated: true)
                return
            }
            self?.event.topStandings = details["topStandings"] as? [(String, Int)]
            self?.event.slug = details["slug"] as? String
            self?.tableView.reloadSections([1], with: .automatic)
        }
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return numTopStandings
        default: fatalError("Invalid number of sections")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return UITableViewCell().setupActive(textColor: view.tintColor, text: "View brackets on smash.gg")
        case 1:
            guard numTopStandings != 1 else {
                return doneRequest ? UITableViewCell().setupDisabled("No standings found") : LoadingCell()
            }
            
            if indexPath.row == 8 {
                return UITableViewCell().setupActive(textColor: view.tintColor, text: "View all standings")
            }
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.standingCell, for: indexPath) as? StandingCell {
                guard let standing = event.topStandings?[safe: indexPath.row] else {
                    return UITableViewCell()
                }
                guard let placementNum = standing.placement else {
                    cell.updateView(text: standing.name ?? "", detailText: nil)
                    return cell
                }
                
                let placement: String
                switch placementNum {
                case 0: placement = ""
                case 1: placement = "🥇 "
                case 2: placement = "🥈 "
                case 3: placement = "🥉 "
                default: placement = " \(placementNum):  "
                }
                cell.updateView(text: placement + (standing.name ?? ""), detailText: nil)
                return cell
            }
        default: return UITableViewCell()
        }
        return UITableViewCell()
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Brackets"
        case 1: return "Standings"
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            guard let slug = event.slug else { return }
            guard let url = URL(string: "https://smash.gg/\(slug)/brackets") else {
                debugPrint(k.Error.urlGeneration, "https://smash.gg/\(slug)/brackets")
                return
            }
            present(SFSafariViewController(url: url), animated: true)
        default: return
        }
    }
}
