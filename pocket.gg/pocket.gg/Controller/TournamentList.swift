//
//  TournamentList.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-01-31.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

class TournamentList: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TournamentCell.self, forCellReuseIdentifier: tournamentCellIdentifier)
        
        setupNavigationBar()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshTournamentList), for: .valueChanged)
        tableView.rowHeight = 75
    }

    // MARK: - UI Setup
    
    private func setupNavigationBar() {
        navigationItem.title = "Tournaments"
        navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .search, target: nil, action: nil), animated: false)
        navigationItem.setRightBarButton(UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: nil, action: nil), animated: false)
    }
    
    // MARK: - Actions
    
    @objc private func refreshTournamentList() {
        // TODO: Add GraphQL query
        refreshControl?.endRefreshing()
    }
    
    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: tournamentCellIdentifier, for: indexPath) as? TournamentCell {
            cell.updateView(name: "TestTitle", imageUrl: "https://www.bleepstatic.com/content/hl-images/2017/03/18/apple-swift.jpg", date: "testDate")
//            cell.layer.borderWidth = CGFloat(10)
//            cell.layer.borderColor = tableView.backgroundColor?.cgColor
            return cell
        }
        return UITableViewCell()
    }
}
