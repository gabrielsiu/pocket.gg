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
        tableView.register(Value1Cell.self, forCellReuseIdentifier: k.Identifiers.value1Cell)
        loadEventDetails()
    }
    
    private func loadEventDetails() {
        guard let id = event.id else {
            self.doneRequest = true
            let alert = UIAlertController(title: k.Error.genericTitle, message: k.Error.generateEventMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        NetworkService.getEventById(id: id) { [weak self] (details) in
            guard let details = details else {
                self?.doneRequest = true
                let alert = UIAlertController(title: k.Error.requestTitle, message: k.Error.getEventDetailsMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self?.present(alert, animated: true)
                return
            }
            self?.event.phases = details["phases"] as? [Tournament.Phase]
            self?.event.topStandings = details["topStandings"] as? [(String, Int)]
            self?.event.slug = details["slug"] as? String
            
            self?.doneRequest = true
            self?.tableView.reloadData()
        }
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if !doneRequest {
                return 1
            } else {
                guard let numPhases = event.phases?.count, numPhases > 0 else { return 1 }
                return numPhases
            }
        case 1: return numTopStandings
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let phases = event.phases, phases.count != 0 else {
                return doneRequest ? UITableViewCell().setupDisabled("No phases found") : LoadingCell()
            }
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.value1Cell, for: indexPath) as? Value1Cell {
                cell.accessoryType = .disclosureIndicator
                cell.updateLabels(text: phases[indexPath.row].name, detailText: phases[indexPath.row].state?.capitalized)
                return cell
            }
            
        case 1:
            guard numTopStandings != 1 else {
                return doneRequest ? UITableViewCell().setupDisabled("No standings found") : LoadingCell()
            }
            if indexPath.row == 8 {
                return UITableViewCell().setupActive(textColor: view.tintColor, text: "View all standings")
            }
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.value1Cell, for: indexPath) as? Value1Cell {
                guard let standing = event.topStandings?[safe: indexPath.row] else {
                    return UITableViewCell()
                }
                guard let placementNum = standing.placement else {
                    cell.updateLabels(text: standing.name ?? "", detailText: nil)
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
                cell.selectionStyle = .none
                cell.updateLabels(text: placement + (standing.name ?? ""), detailText: nil)
                return cell
            }
        default: break
        }
        return UITableViewCell()
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Brackets"
        case 1: return "Standings"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            guard let phase = event.phases?[safe: indexPath.row] else {
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
            let numPhaseGroups = phase.numPhaseGroups ?? 1
            if numPhaseGroups > 1 {
                navigationController?.pushViewController(PhaseGroupListViewController(phase), animated: true)
            }
        case 1:
            guard indexPath.row == 8 else { return }
            guard let slug = event.slug else { return }
            guard let url = URL(string: "https://smash.gg/\(slug)/standings") else {
                debugPrint(k.Error.urlGeneration, "https://smash.gg/\(slug)/standings")
                return
            }
            present(SFSafariViewController(url: url), animated: true)
        default:
            return
        }
    }
}
