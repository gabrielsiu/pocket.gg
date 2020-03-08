//
//  TournamentViewController.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-08.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class TournamentViewController: UITableViewController {
    
    var headerImageView: UIImageView?
    let generalInfoCell: TournamentGeneralInfoCell
    let locationCell: TournamentLocationCell
    
    var tournament: Tournament
    
    // MARK: - Initialization
    
    init(tournament: Tournament) {
        self.tournament = tournament
        generalInfoCell = TournamentGeneralInfoCell(tournament)
        locationCell = TournamentLocationCell()
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = tournament.name
        
        tableView.register(EventCell.self, forCellReuseIdentifier: k.Identifiers.eventCell)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
        setupHeaderImageView()
        loadTournamentDetails()
    }
    
    // MARK: - UI Setup
    
    private func setupHeaderImageView() {
        NetworkService.getImage(imageUrl: tournament.headerImage.url) { [weak self] (header) in
            guard let header = header else { return }
            
            DispatchQueue.main.async {
                guard let ratio = self?.tournament.headerImage.ratio else { return }
                guard let width = self?.tableView.frame.width else { return }
                
                // TODO: Using constraints, fix so that the header expands to fit the screen upon rotating the device
                self?.headerImageView = UIImageView.init(image: header)
                self?.headerImageView?.contentMode = .scaleAspectFit
                // TODO: Animate this frame change
                self?.headerImageView?.frame = CGRect(x: 0, y: 0, width: width, height: width / CGFloat(ratio))
                self?.tableView.tableHeaderView = self?.headerImageView
            }
        }
    }
    
    private func loadTournamentDetails() {
        NetworkService.getTournamentDetailsById(id: tournament.id) { [weak self] (details) in
            guard let details = details else {
                // TODO: Add failed request popup
                return
            }
            
            self?.tournament.location = details["location"] as? Tournament.Location
            self?.tournament.contactInfo = details["contact"] as? String
            self?.tournament.events = details["events"] as? [Tournament.Event]
            self?.tournament.streams = details["streams"] as? [Tournament.Stream]
            
            self?.generalInfoCell.updateView(location: self?.tournament.location?.address, {
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            })
            self?.locationCell.updateView(location: self?.tournament.location)
            self?.tableView.reloadSections([1], with: .automatic)
        }
    }
    
    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return tournament.events?.count ?? 0
        case 2: return 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: return generalInfoCell
        case 1:
            if let cell = tableView.dequeueReusableCell(withIdentifier: k.Identifiers.eventCell) as? EventCell {
                guard let event = tournament.events?[safe: indexPath.row] else {
                    return UITableViewCell()
                }
                cell.updateView(name: event.name, videogameImage: event.videogameImage, date: event.startDate)
                return cell
            }
            return UITableViewCell()
        case 2: return locationCell
        default: return UITableViewCell()
        }
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return "Events"
        case 2: return "Location"
        default: return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 2:
            return k.Sizes.mapHeight
        default:
            return UITableView.automaticDimension
        }
    }
}
