//
//  PhaseGroupListViewController.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-08-25.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class PhaseGroupListViewController: UITableViewController {
    
    var phase: Tournament.Phase
    var doneRequest = false

    // MARK: - Initialization
    
    init(_ phase: Tournament.Phase) {
        self.phase = phase
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = phase.name
        tableView.register(Value1Cell.self, forCellReuseIdentifier: k.Identifiers.value1Cell)
        loadPhaseDetails()
    }
    
    private func loadPhaseDetails() {
        guard let id = phase.id else {
            self.doneRequest = true
            let alert = UIAlertController(title: k.Error.genericTitle, message: k.Error.generateBracketMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        NetworkService.getPhaseDetailsById(id: id, numPhaseGroups: phase.numPhaseGroups ?? 100) { [weak self] (details) in
            guard let details = details else {
                self?.doneRequest = true
                let alert = UIAlertController(title: k.Error.requestTitle, message: k.Error.getBracketDetailsMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self?.present(alert, animated: true)
                return
            }
            
            self?.phase.numEntrants = details["numEntrants"] as? Int
            self?.phase.bracketType = details["bracketType"] as? String
            self?.phase.phaseGroups = details["phaseGroups"] as? [Tournament.PhaseGroup]
            
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
        case 0: return 1
        case 1: return phase.phaseGroups?.count ?? 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            
            cell.textLabel?.text = phase.name
            cell.textLabel?.font = UIFont.systemFont(ofSize: k.Sizes.largeFont)
            
            var detailTextStrings = [String]()
            if let numEntrants = phase.numEntrants {
                detailTextStrings.append("\(numEntrants) entrants")
            }
            if let numPools = phase.numPhaseGroups {
                detailTextStrings.append("\(numPools) pools")
            }
            if let bracketType = phase.bracketType {
                detailTextStrings.append(bracketType.replacingOccurrences(of: "_", with: " ").capitalized)
            }
            
            let detailText: String = detailTextStrings.enumerated().reduce("") { (accumulate, current) -> String in
                return accumulate + current.1 + (current.0 != detailTextStrings.endIndex - 1 ? " • " : "")
            }
            cell.detailTextLabel?.text = detailText
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
            
            return cell
            
        case 1:
            guard let phaseGroups = phase.phaseGroups else {
                return doneRequest ? UITableViewCell().setupDisabled("No pools found") : LoadingCell()
            }

            if let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.value1Cell, for: indexPath) as? Value1Cell {
                cell.accessoryType = .disclosureIndicator
                var text: String?
                if let poolId = phaseGroups[indexPath.row].name {
                    text = "Pool " + poolId
                }
                cell.updateLabels(text: text, detailText: phaseGroups[indexPath.row].state?.capitalized)
                return cell
            }
        default: break
        }
        
        return UITableViewCell()
    }
}
