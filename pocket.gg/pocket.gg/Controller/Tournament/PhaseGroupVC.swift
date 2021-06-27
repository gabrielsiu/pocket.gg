//
//  PhaseGroupVC.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-08-26.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class PhaseGroupVC: UIViewController {
    
    var phaseGroup: PhaseGroup?
    var phaseID: Int?
    var doneRequest = false
    let phaseGroupViewControl: UISegmentedControl
    let tableView: UITableView
    
    let bracketScrollView: UIScrollView
    var bracketView: BracketView?
    let bracketViewSpinner: UIActivityIndicatorView
    
    // MARK: - Initialization
    
    init(_ phaseGroup: PhaseGroup?, _ phaseID: Int? = nil, title: String?) {
        self.phaseGroup = phaseGroup
        self.phaseID = phaseID
        
        phaseGroupViewControl = UISegmentedControl(items: ["Standings", "Matches", "Bracket"])
        phaseGroupViewControl.selectedSegmentIndex = 0
        
        tableView = UITableView(frame: .zero, style: .plain)
        
        bracketScrollView = UIScrollView(frame: .zero)
        bracketViewSpinner = UIActivityIndicatorView(style: .medium)
        
        super.init(nibName: nil, bundle: nil)
        self.title = title
        
        bracketScrollView.delegate = self
        bracketScrollView.maximumZoomScale = 2
        bracketScrollView.minimumZoomScale = 0.5
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentSetVC(_:)),
                                               name: Notification.Name(k.Notification.didTapSet), object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        
        // phaseGroup should be nil only when the phase only has 1 phase group
        // In this case, the phase ID that was passed in will be used to fetch the phase group
        if phaseGroup == nil {
            getPhaseGroup { [weak self] in
                self?.loadPhaseGroupDetails()
            }
        } else {
            loadPhaseGroupDetails()
        }
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
                                             bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                             leading: view.leadingAnchor,
                                             trailing: view.trailingAnchor)
        
        tableView.register(Value1Cell.self, forCellReuseIdentifier: k.Identifiers.value1Cell)
        tableView.dataSource = self
        tableView.delegate = self
        
        bracketScrollView.isHidden = true
        
        bracketViewSpinner.startAnimating()
        bracketScrollView.addSubview(bracketViewSpinner)
        bracketViewSpinner.setAxisConstraints(xAnchor: bracketScrollView.centerXAnchor, yAnchor: bracketScrollView.centerYAnchor)
        
        phaseGroupViewControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
    }
    
    private func getPhaseGroup(_ complete: @escaping () -> Void) {
        guard let id = phaseID else { return }
        
        NetworkService.getPhaseGroupsById(id: id, numPhaseGroups: 1) { [weak self] (result) in
            guard let result = result, !result.isEmpty else {
                complete()
                return
            }
            self?.phaseGroup = result[safe: 0]
            complete()
        }
    }
    
    private func loadPhaseGroupDetails() {
        guard let id = phaseGroup?.id else {
            doneRequest = true
            let alert = UIAlertController(title: k.Error.genericTitle, message: k.Error.generateEventMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true)
            tableView.reloadData()
            return
        }
        
        NetworkService.getPhaseGroupById(id: id) { [weak self] (result) in
            guard let result = result else {
                self?.doneRequest = true
                let alert = UIAlertController(title: k.Error.requestTitle, message: k.Error.getEventDetailsMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self?.present(alert, animated: true)
                self?.tableView.reloadData()
                return
            }
            
            self?.phaseGroup?.bracketType = result["bracketType"] as? String
            self?.phaseGroup?.progressionsOut = result["progressionsOut"] as? [Int]
            self?.phaseGroup?.standings = result["standings"] as? [(entrant: Entrant?, placement: Int?)]
            self?.phaseGroup?.matches = result["sets"] as? [PhaseGroupSet]
            
            guard let standings = self?.phaseGroup?.standings, let matches = self?.phaseGroup?.matches else {
                self?.setupBracketView()
                self?.doneRequest = true
                self?.tableView.reloadData()
                return
            }
            
            // If 100 sets were returned, there may be more sets in total, so load the next page of sets
            if standings.count == 65 || matches.count == 100 {
                let nextStandingsPage: Int? = standings.count == 65 ? 2 : nil
                let nextSetsPage: Int? = matches.count == 100 ? 2 : nil
                self?.loadRemainingPhaseGroupData(id: id, standingsPage: nextStandingsPage, setsPage: nextSetsPage)
            } else {
                self?.setupBracketView()
                self?.doneRequest = true
                self?.tableView.reloadData()
            }
        }
    }
    
    private func loadRemainingPhaseGroupData(id: Int, standingsPage: Int?, setsPage: Int?) {
        let dispatchGroup = DispatchGroup()
        
        // If more data needs to be loaded, these will hold the next page number to load from. Else, they will be nil
        var numStandingsReturned: Int?
        var numSetsReturned: Int?
        
        // Enter block(s) to the dispatch group if more standings and/or sets need to be loaded
        if standingsPage != nil { dispatchGroup.enter() }
        if setsPage != nil { dispatchGroup.enter() }
        
        // If more standings need to be loaded, load them and leave the dispatch group once finished
        if let page = standingsPage {
            // Upper limit to prevent potential infinite recursive calls
            if page < 6 {
                NetworkService.getPhaseGroupStandings(id: id, page: page) { [weak self] (standings) in
                    guard let standings = standings, !standings.isEmpty else {
                        dispatchGroup.leave()
                        return
                    }
                    self?.phaseGroup?.standings?.append(contentsOf: standings)
                    
                    numStandingsReturned = standings.count
                    dispatchGroup.leave()
                }
            } else {
                dispatchGroup.leave()
            }
        }
        
        // If more sets need to be loaded, load them and leave the dispatch group once finished
        if let page = setsPage {
            // Upper limit to prevent potential infinite recursive calls
            if page < 6 {
                NetworkService.getPhaseGroupSets(id: id, page: page) { [weak self] (sets) in
                    guard let sets = sets, !sets.isEmpty else {
                        dispatchGroup.leave()
                        return
                    }
                    self?.phaseGroup?.matches?.append(contentsOf: sets)
                    
                    numSetsReturned = sets.count
                    dispatchGroup.leave()
                }
            } else {
                dispatchGroup.leave()
            }
        }
        
        // Callback for when the request(s) finishes
        dispatchGroup.notify(queue: .main) { [weak self] in
            var nextStandingsPage: Int?
            var nextSetsPage: Int?
            if let numStandingsReturned = numStandingsReturned, numStandingsReturned == 65 {
                if let standingsPage = standingsPage {
                    nextStandingsPage = standingsPage + 1
                }
            }
            if let numSetsReturned = numSetsReturned, numSetsReturned == 100 {
                if let setsPage = setsPage {
                    nextSetsPage = setsPage + 1
                }
            }
            
            // If more data needs to be loaded, recursively call this function until all of the data is loaded
            if nextStandingsPage != nil || nextSetsPage != nil {
                self?.loadRemainingPhaseGroupData(id: id, standingsPage: nextStandingsPage, setsPage: nextSetsPage)
            } else {
                self?.setupBracketView()
                self?.doneRequest = true
                self?.tableView.reloadData()
            }
        }
    }
    
    private func setupBracketView() {
        // TODO: Potentially improve performance by moving some of this work to a background thread
        switch phaseGroup?.bracketType ?? "" {
        case "SINGLE_ELIMINATION", "DOUBLE_ELIMINATION":
            bracketView = EliminationBracketView(sets: phaseGroup?.matches)
        case "ROUND_ROBIN":
            let entrants = phaseGroup?.standings?.compactMap { $0.entrant }
            bracketView = RoundRobinBracketView(sets: phaseGroup?.matches, entrants: entrants)
        default:
            break
        }
        
        if let bracketView = bracketView {
            if bracketView.isValid {
                bracketScrollView.contentSize = bracketView.bounds.size
                bracketScrollView.addSubview(bracketView)
            } else {
                showInvalidBracketView(cause: bracketView.invalidationCause ?? .bracketLayoutError)
            }
        } else {
            showInvalidBracketView(cause: .unsupportedBracketType, bracketType: phaseGroup?.bracketType)
        }
        bracketViewSpinner.isHidden = true
    }
    
    // MARK: - Actions
    
    @objc private func presentSetVC(_ notification: Notification) {
        if let set = notification.object as? PhaseGroupSet {
            present(UINavigationController(rootViewController: SetViewController(set)), animated: true, completion: nil)
        }
    }
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        tableView.isHidden = sender.selectedSegmentIndex == 2
        bracketScrollView.isHidden = sender.selectedSegmentIndex != 2
        
        if sender.selectedSegmentIndex != 2 {
            tableView.reloadData()
        }
    }
    
    private func showInvalidBracketView(cause: InvalidBracketViewCause, bracketType: String? = nil) {
        let invalidBracketView = InvalidBracketView(cause: cause, bracketType: bracketType)
        bracketScrollView.addSubview(invalidBracketView)
        invalidBracketView.setEdgeConstraints(top: bracketScrollView.safeAreaLayoutGuide.topAnchor,
                                              bottom: bracketScrollView.safeAreaLayoutGuide.bottomAnchor,
                                              leading: bracketScrollView.safeAreaLayoutGuide.leadingAnchor,
                                              trailing: bracketScrollView.safeAreaLayoutGuide.trailingAnchor)
    }
}

// MARK: - Table View Data Source & Delegate

extension PhaseGroupVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if phaseGroupViewControl.selectedSegmentIndex == 0 {
            guard let count = phaseGroup?.standings?.count, count != 0  else {
                return 1
            }
            return count
        } else {
            guard let count = phaseGroup?.matches?.count, count != 0  else {
                return 1
            }
            return count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let standings = phaseGroup?.standings, !standings.isEmpty else {
            let text = phaseGroupViewControl.selectedSegmentIndex == 0 ? "No standings found" : "No matches found"
            return doneRequest ? UITableViewCell().setupDisabled(text) : LoadingCell()
        }
        
        switch phaseGroupViewControl.selectedSegmentIndex {
        case 0: return phaseGroupStandingCell(standings: standings, indexPath: indexPath)
        case 1: return phaseGroupMatchCell(standings: standings, indexPath: indexPath)
        default: return UITableViewCell()
        }
    }
    
    private func phaseGroupStandingCell(standings: [(entrant: Entrant?, placement: Int?)], indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.value1Cell, for: indexPath) as? Value1Cell {
            cell.selectionStyle = .none
            
            var placementText = ""
            var progressedText: String?
            
            var teamNameStart: Int?
            var teamNameLength: Int?
            if let placement = standings[indexPath.row].placement {
                placementText = "\(placement): "
                teamNameStart = placementText.count
                if let progressionsOut = phaseGroup?.progressionsOut, progressionsOut.contains(placement) {
                    // TODO: If possible with the API, also display where the player has progressed to
                    progressedText = "Progressed"
                }
            }
            if let entrantName = standings[indexPath.row].entrant?.name {
                if let teamName = standings[indexPath.row].entrant?.teamName {
                    placementText += teamName + " "
                    teamNameLength = teamName.count
                }
                placementText += entrantName
            }
            
            let attributedText = NSMutableAttributedString(string: placementText)
            if let location = teamNameStart, let length = teamNameLength {
                attributedText.addAttribute(.foregroundColor, value: UIColor.systemGray, range: NSRange(location: location, length: length))
            }
            
            cell.updateLabels(attributedText: attributedText, detailText: progressedText)
            return cell
        }
        return UITableViewCell()
    }
    
    // TODO: Redesign this
    private func phaseGroupMatchCell(standings: [(entrant: Entrant?, placement: Int?)], indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.value1Cell, for: indexPath) as? Value1Cell {
            cell.selectionStyle = .none
            
            guard let set = phaseGroup?.matches?[safe: indexPath.row] else {
                return UITableViewCell()
            }
            
            cell.updateLabels(text: nil, detailText: set.state?.capitalized)
            cell.textLabel?.attributedText = phaseGroupMatchText(set, cell.textLabel?.font.pointSize ?? UIFont.labelFontSize)
            return cell
        }
        return UITableViewCell()
    }
    
    private func phaseGroupMatchText(_ set: PhaseGroupSet, _ size: CGFloat) -> NSAttributedString {
        var text = (set.fullRoundText ?? "") + " Match " + set.identifier
        
        var winningScoreLocation: Int?
        var boldTextLength: Int?
        var winnerPresent = false
        var entrant0Won = false
        
        if let entrants = set.entrants, !entrants.isEmpty {
            text += "\n"
            
            if entrants.count == 2, let name0 = entrants[0].entrant?.name,
                                    let score0 = entrants[0].score,
                                    let name1 = entrants[1].entrant?.name,
                                    let score1 = entrants[1].score {
                if let score0Num = Int(score0), let score1Num = Int(score1) {
                    winnerPresent = true
                    entrant0Won = score0Num > score1Num
                } else if let score0 = entrants[0].score, score0 == "W" {
                    winnerPresent = true
                    entrant0Won = true
                } else if let score1 = entrants[1].score, score1 == "W" {
                    winnerPresent = true
                }
                
                if winnerPresent, entrant0Won {
                    winningScoreLocation = text.count
                    boldTextLength = name0.count + 1 + score0.count
                }
                text += name0 + " "
                text += score0
                
                text += " - "
                if winnerPresent, !entrant0Won {
                    winningScoreLocation = text.count
                    boldTextLength = name1.count + 1 + score1.count
                }
                text += score1
                text += " "
                text += name1
            } else if entrants.count == 1, let name0 = entrants[0].entrant?.name {
                text += name0
            }
        }
        
        let attributedText = NSMutableAttributedString(string: text)
        if let location = winningScoreLocation, let length = boldTextLength {
            attributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: size), range: NSRange(location: location, length: length))
            let scoreLocation = entrant0Won ? location + length - 1 : location
            attributedText.addAttribute(.foregroundColor, value: UIColor.systemGreen, range: NSRange(location: scoreLocation, length: 1))
        }
        return attributedText
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return phaseGroupViewControl.selectedSegmentIndex == 0 ? UITableView.automaticDimension : 60
    }
}

// MARK: - Scroll View Delegate

extension PhaseGroupVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return bracketView
    }
}
