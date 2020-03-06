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
    
    let tournament: Tournament
    
    // MARK: - Initialization
    
    init(tournament: Tournament) {
        self.tournament = tournament
        generalInfoCell = TournamentGeneralInfoCell(tournament)
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
            if let location = details?["location"] as? Tournament.Location, let address = location.address {
                self?.generalInfoCell.updateView(location: address, {
                    self?.tableView.beginUpdates()
                    self?.tableView.endUpdates()
                })
            }
        }
    }
    
    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // TODO: Add other sections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
            // TODO: Add rows for other sections
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: return generalInfoCell
        default: return UITableViewCell()
        }
    }
}
