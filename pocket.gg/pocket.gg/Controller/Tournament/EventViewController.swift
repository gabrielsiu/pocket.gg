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
    
    var event: Event
    var doneRequest = false
    var requestSuccessful = true
    var numTopStandings: Int {
        guard let numStandings = event.topStandings?.count else { return 1 }
        guard numStandings != 0 else { return 1 }
        guard numStandings == 8 else { return numStandings }
        return numStandings + 1
    }
    
    // MARK: - Initialization
    
    init(_ event: Event) {
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
            doneRequest = true
            requestSuccessful = false
            let alert = UIAlertController(title: k.Error.genericTitle, message: k.Error.generateEventMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            present(alert, animated: true)
            tableView.reloadData()
            return
        }
        NetworkService.getEventById(id: id) { [weak self] (result) in
            guard let result = result else {
                self?.doneRequest = true
                self?.requestSuccessful = false
                let alert = UIAlertController(title: k.Error.requestTitle, message: k.Error.getEventDetailsMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self?.present(alert, animated: true)
                self?.tableView.reloadData()
                return
            }
            self?.event.phases = result["phases"] as? [Phase]
            self?.event.topStandings = result["topStandings"] as? [(String, Int)]
            self?.event.slug = result["slug"] as? String
            
            self?.doneRequest = true
            self?.tableView.reloadData()
        }
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1:
            if !doneRequest {
                return 1
            } else {
                guard let numPhases = event.phases?.count, numPhases > 0 else { return 1 }
                return numPhases
            }
        case 2: return numTopStandings
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = SubtitleCell()
            
            // Text Label
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: k.Sizes.largeFont)
            
            // Detail Text Label
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
            cell.detailTextLabel?.numberOfLines = 0
            
            var detailText = ""
            if let eventType = event.eventType {
                switch eventType {
                case 1: detailText = "Singles"
                case 2: detailText = "Doubles"
                case 5: detailText = "Teams"
                default: break
                }
            }
            if event.eventType != nil && event.videogameName != nil {
                detailText += " • "
            }
            if let videogameName = event.videogameName {
                detailText += videogameName
            }
            detailText += "\n"
            let dotPosition = detailText.count
            
            detailText += "● "
            detailText += DateFormatter.shared.dateFromTimestamp(event.startDate)
            
            let dotColor: UIColor
            switch event.state ?? "" {
            case "ACTIVE": dotColor = .systemGreen
            case "COMPLETED": dotColor = .systemGray
            default: dotColor = .systemBlue
            }
            
            let attributedDetailText = NSMutableAttributedString(string: detailText)
            attributedDetailText.addAttribute(.foregroundColor, value: dotColor, range: NSRange(location: dotPosition, length: 1))
            
            cell.selectionStyle = .none
            cell.setPlaceholder("game-controller")
            cell.updateView(text: event.name, imageInfo: event.videogameImage, detailText: nil, newRatio: k.Sizes.eventImageRatio)
            cell.detailTextLabel?.attributedText = attributedDetailText
            
            return cell
            
        case 1:
            guard requestSuccessful else {
                return UITableViewCell().setupDisabled("Unable to load brackets")
            }
            guard let phases = event.phases, phases.count != 0 else {
                return doneRequest ? UITableViewCell().setupDisabled("No brackets found") : LoadingCell()
            }
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.value1Cell, for: indexPath) as? Value1Cell {
                cell.accessoryType = .disclosureIndicator
                cell.updateLabels(text: phases[indexPath.row].name, detailText: phases[indexPath.row].state?.capitalized)
                return cell
            }
            
        case 2:
            guard requestSuccessful else {
                return UITableViewCell().setupDisabled("Unable to load standings")
            }
            guard numTopStandings != 1 else {
                return doneRequest ? UITableViewCell().setupDisabled("No standings found") : LoadingCell()
            }
            if indexPath.row == 8 {
                return UITableViewCell().setupActive(textColor: .systemRed, text: "View all standings")
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
        case 0: return "Summary"
        case 1: return "Brackets"
        case 2: return "Standings"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            guard let phase = event.phases?[safe: indexPath.row] else {
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
            let numPhaseGroups = phase.numPhaseGroups ?? 1
            if numPhaseGroups > 1 {
                // If there are multiple phase groups, then proceed to PhaseGroupListViewController as normal
                navigationController?.pushViewController(PhaseGroupListViewController(phase: phase), animated: true)
            } else if numPhaseGroups == 1 {
                // If there is only 1 phase group, jump straight to PhaseGroupViewController. The singular phase group's ID will be obtained using the phase's ID
                navigationController?.pushViewController(PhaseGroupViewController(nil, phase.id ?? nil, title: phase.name), animated: true)
            } else {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        case 2:
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
