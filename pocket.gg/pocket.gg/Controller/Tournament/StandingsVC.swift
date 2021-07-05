//
//  StandingsVC.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2021-07-04.
//  Copyright © 2021 Gabriel Siu. All rights reserved.
//

import UIKit

final class StandingsVC: UITableViewController {
    
    var standings = [Standing]()
    var eventID: Int?
    var doneRequest: Bool
    var noMoreStandings: Bool
    var currentStandingsPage: Int
    
    init(_ standings: [Standing], eventID: Int?) {
        self.standings = standings
        self.eventID = eventID
        doneRequest = true
        noMoreStandings = false
        currentStandingsPage = 1
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Standings"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: k.Identifiers.eventStandingCell)
    }
    
    private func loadStandings() {
        guard doneRequest else { return }
        guard !noMoreStandings else { return }
        guard let id = eventID else { return }
        
        currentStandingsPage += 1
        doneRequest = false
        
        NetworkService.getEventStandings(id, page: currentStandingsPage) { [weak self] standings in
            guard let standings = standings else {
                self?.doneRequest = true
                self?.tableView.reloadData()
                return
            }
            
            guard !standings.isEmpty else {
                self?.doneRequest = true
                self?.noMoreStandings = true
                return
            }
            
            self?.doneRequest = true
            if let startIndex = self?.standings.count {
                let indexPaths = (startIndex..<(startIndex + standings.count)).map {
                    return IndexPath.init(row: $0, section: 0)
                }
                self?.tableView.performBatchUpdates({
                    self?.standings.append(contentsOf: standings)
                    self?.tableView.insertRows(at: indexPaths, with: .none)
                }, completion: nil)
            } else {
                self?.tableView.reloadData()
            }
            
            // If less standings than expected were returned, then there are no more standings to load
            guard let self = self else { return }
            if standings.count < 65 {
                self.noMoreStandings = true
            }
        }
    }

    // MARK: - Table View Data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return standings.isEmpty ? 1 : standings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !standings.isEmpty else {
            // This should never get executed; this VC should only show if there were more than 8 standings
            let cell = UITableViewCell().setupDisabled("No standings found")
            cell.backgroundColor = .secondarySystemBackground
            return cell
        }
        
        // If we are approaching the end of the list, load more standings
        if indexPath.row == standings.count - 3 {
            loadStandings()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.eventStandingCell, for: indexPath)
        cell.selectionStyle = .none
        
        // COULD BE REPLACED
        var name = ""
        var teamNameLength: Int?
        if let teamName = standings[indexPath.row].entrant?.teamName, let entrantName = standings[indexPath.row].entrant?.name {
            name = teamName + " " + entrantName
            teamNameLength = teamName.count
        } else if let entrantName = standings[indexPath.row].entrant?.name {
            name = entrantName
        }
        
        var placement = ""
        if let placementNum = standings[indexPath.row].placement {
            placement = "\(placementNum): "
        }
        
        let attributedText = NSMutableAttributedString(string: placement)
        attributedText.append(SetUtilities.getAttributedEntrantText(name, bold: false, size: cell.textLabel?.font.pointSize ?? 10,
                                                                   teamNameLength: teamNameLength))
        cell.textLabel?.attributedText = attributedText
        //------------------
        
        return cell
    }
}
