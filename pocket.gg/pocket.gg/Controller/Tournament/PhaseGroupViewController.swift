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
            
            // TODO: Possibly slow, maybe replace with closure that returns frame size after it's done
            let bracketView = BracketView(sets: result["sets"] as? [PhaseGroupSet])
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
    }
}

// MARK: - Table View Data Source & Delegate

extension PhaseGroupViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phaseGroup.standings?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
}
