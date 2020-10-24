//
//  PhaseGroupViewController.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-08-26.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class PhaseGroupViewController: UIViewController {
    
    var phaseGroup: PhaseGroup
    var doneRequest = false
    let phaseGroupViewControl: UISegmentedControl
    let tableView: UITableView
    let bracketScrollView: UIScrollView
    
    // MARK: - Initialization
    
    init(_ phaseGroup: PhaseGroup, title: String?) {
        self.phaseGroup = phaseGroup
        
        phaseGroupViewControl = UISegmentedControl(items: ["Standings", "Matches", "Bracket"])
        phaseGroupViewControl.selectedSegmentIndex = 0
        
        tableView = UITableView(frame: .zero, style: .plain)
        
        bracketScrollView = UIScrollView(frame: .zero)
        
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        loadPhaseGroupDetails()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.addSubview(phaseGroupViewControl)
        view.addSubview(tableView)
        view.addSubview(bracketScrollView)
        phaseGroupViewControl.setEdgeConstraints(top: view.layoutMarginsGuide.topAnchor,
                                                 bottom: tableView.topAnchor,
                                                 leading: view.leadingAnchor,
                                                 trailing: view.trailingAnchor)
        tableView.setEdgeConstraints(top: phaseGroupViewControl.bottomAnchor,
                                     bottom: view.bottomAnchor,
                                     leading: view.leadingAnchor,
                                     trailing: view.trailingAnchor)
        bracketScrollView.setEdgeConstraints(top: phaseGroupViewControl.bottomAnchor,
                                             bottom: view.bottomAnchor,
                                             leading: view.leadingAnchor,
                                             trailing: view.trailingAnchor)
        
        tableView.register(Value1Cell.self, forCellReuseIdentifier: k.Identifiers.value1Cell)
        tableView.dataSource = self
        tableView.delegate = self
        
        bracketScrollView.isHidden = true
        
        phaseGroupViewControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
    }
    
    private func loadPhaseGroupDetails() {
        guard let id = phaseGroup.id else {
            doneRequest = true
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
            self?.phaseGroup.matches = result["sets"] as? [PhaseGroupSet]
            
            // TODO: Possibly slow, maybe replace with closure that returns frame size after it's done
            let bracketView = BracketView(sets: self?.phaseGroup.matches)
            self?.bracketScrollView.contentSize = bracketView.bounds.size
            self?.bracketScrollView.addSubview(bracketView)
            
            self?.doneRequest = true
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        tableView.isHidden = sender.selectedSegmentIndex == 2
        bracketScrollView.isHidden = sender.selectedSegmentIndex != 2
        
        if sender.selectedSegmentIndex != 2 {
            tableView.reloadData()
        }
    }
}

// MARK: - Table View Data Source & Delegate

extension PhaseGroupViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if phaseGroupViewControl.selectedSegmentIndex == 0 {
            return phaseGroup.standings?.count ?? 1
        } else {
            return phaseGroup.matches?.count ?? 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let standings = phaseGroup.standings, standings.count != 0 else {
            return doneRequest ? UITableViewCell().setupDisabled("No standings found") : LoadingCell()
        }
        
        switch phaseGroupViewControl.selectedSegmentIndex {
        case 0: return phaseGroupStandingCell(standings: standings, indexPath: indexPath)
        case 1: return phaseGroupMatchCell(standings: standings, indexPath: indexPath)
        default: return UITableViewCell()
        }
    }
    
    private func phaseGroupStandingCell(standings: [(name: String?, placement: Int?)], indexPath: IndexPath) -> UITableViewCell {
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
    
    private func phaseGroupMatchCell(standings: [(name: String?, placement: Int?)], indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.value1Cell, for: indexPath) as? Value1Cell {
            cell.selectionStyle = .none
            
            guard let set = phaseGroup.matches?[safe: indexPath.row] else {
                return UITableViewCell()
            }
            
            cell.updateLabels(text: nil, detailText: set.state?.capitalized)
            cell.textLabel?.attributedText = phaseGroupMatchText(set, cell.textLabel?.font.pointSize ?? UIFont.labelFontSize)
            return cell
        }
        return UITableViewCell()
    }
    
    private func phaseGroupMatchText(_ set: PhaseGroupSet, _ size: CGFloat) -> NSAttributedString {
        // TODO: Refactor sometime
        
        var text = (set.fullRoundText ?? "") + " Match " + (set.identifier ?? "") + "\n"
        
        guard let displayScore = set.displayScore else {
            return NSMutableAttributedString(string: text)
        }
        
        let names = [set.entrant1?.name, set.entrant2?.name].compactMap { $0 }
        
        let playerStrings = displayScore.components(separatedBy: " - ")
        guard playerStrings.count == 2 else {
            text += displayScore
            return NSMutableAttributedString(string: text)
        }
        
        let players = playerStrings.map { (playerString) -> (name: String, score: String) in
            for name in names where playerString.contains(name) {
                guard let index = playerString.lastIndex(of: " ") else {
                    return (name: playerString, score: "")
                }
                return (name: name, score: String(playerString[index...]).trimmingCharacters(in: .whitespacesAndNewlines))
            }
            return (name: playerString, score: "")
        }
        
        var winningScoreLocation: Int?
        var boldTextLength: Int?
        var winnerPresent = false
        var player0Won = false
        
        if players.count == 2 {
            if let score0 = Int(players[0].score), let score1 = Int(players[1].score) {
                winnerPresent = true
                player0Won = score0 > score1
            } else if players[0].score == "W" {
                winnerPresent = true
                player0Won = true
            } else if players[1].score == "W" {
                winnerPresent = true
            }
            
            if winnerPresent, player0Won {
                winningScoreLocation = text.count
                boldTextLength = players[0].name.count + 1 + players[0].score.count
            }
            text += players[0].name + " "
            text += players[0].score
            
            text += " - "
            if winnerPresent, !player0Won {
                winningScoreLocation = text.count
                boldTextLength = players[1].name.count + 1 + players[1].score.count
            }
            text += players[1].score
            text += " "
            text += players[1].name
        } else if players.count == 1 {
            text += players[0].name
        }
        
        let attributedText = NSMutableAttributedString(string: text)
        if let location = winningScoreLocation, let length = boldTextLength {
            attributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: size), range: NSRange(location: location, length: length))
            let scoreLocation = player0Won ? location + length - 1 : location
            attributedText.addAttribute(.foregroundColor, value: UIColor.systemGreen, range: NSRange(location: scoreLocation, length: 1))
        }
        return attributedText
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return phaseGroupViewControl.selectedSegmentIndex == 0 ? UITableView.automaticDimension : 60
    }
}
