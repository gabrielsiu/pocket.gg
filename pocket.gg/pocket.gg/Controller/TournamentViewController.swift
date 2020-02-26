//
//  TournamentViewController.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-08.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class TournamentViewController: UITableViewController {
    
    let generalInfoCell: TournamentGeneralInfoCell
    
    let tournament: Tournament
    
    // MARK: - Initialization
    
    init(tournament: Tournament) {
        self.tournament = tournament
        generalInfoCell = TournamentGeneralInfoCell(tournament: tournament)
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = tournament.name
        
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
