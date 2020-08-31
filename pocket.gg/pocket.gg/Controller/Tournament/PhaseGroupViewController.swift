//
//  PhaseGroupViewController.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-08-26.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class PhaseGroupViewController: UITableViewController {
    
    var phaseGroup: PhaseGroup
    var doneRequest = false
    var phaseGroupViewControl: UISegmentedControl
    
    // MARK: - Initialization
    
    init(_ phaseGroup: PhaseGroup, title: String?) {
        self.phaseGroup = phaseGroup
        
        phaseGroupViewControl = UISegmentedControl(items: ["Standings", "Matches", "Bracket"])
        phaseGroupViewControl.selectedSegmentIndex = 0
        
        super.init(style: .insetGrouped)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(Value1Cell.self, forCellReuseIdentifier: k.Identifiers.value1Cell)
        phaseGroupViewControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        loadPhaseGroupDetails()
    }
    
    private func loadPhaseGroupDetails() {
        guard let id = phaseGroup.id else {
            self.doneRequest = true
            let alert = UIAlertController(title: k.Error.genericTitle, message: k.Error.generateEventMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        NetworkService.getPhaseGroupStandingsById(id: id) { [weak self] (result) in
            guard let result = result else {
                self?.doneRequest = true
                let alert = UIAlertController(title: k.Error.requestTitle, message: k.Error.getEventDetailsMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self?.present(alert, animated: true)
                return
            }
            
            self?.phaseGroup.progressionsOut = result["progressionsOut"] as? [Int]
            self?.phaseGroup.standings = result["standings"] as? [(name: String?, placement: Int?)]
            
            self?.doneRequest = true
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard phaseGroupViewControl.selectedSegmentIndex != 2 else { return 0 }
        return phaseGroup.standings?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let standings = phaseGroup.standings, standings.count != 0 else {
            return doneRequest ? UITableViewCell().setupDisabled("No standings found") : LoadingCell()
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.value1Cell, for: indexPath) as? Value1Cell {
            cell.selectionStyle = .none
            
            var placementText = ""
            var progressedText: String?
            if let placement = standings[indexPath.row].placement {
                placementText = "\(placement): "
                if let progressionsOut = phaseGroup.progressionsOut, progressionsOut.contains(placement) {
                    // TODO: If possible with the API, also display where the player has progressed to
                    progressedText = "Progressed"
                }
            }
            if let name = standings[indexPath.row].name {
                placementText += name
            }
            
            cell.updateLabels(text: placementText, detailText: progressedText)
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return phaseGroupViewControl
    }
}
