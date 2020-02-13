//
//  TournamentViewController.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-08.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class TournamentViewController: UIViewController {
    
    let tournament: Tournament
    let headerImageView = UIImageView()
    let logoImageView = UIImageView()
    let dateLabel = UILabel()
    let locationLabel = UILabel()
    
    
    // MARK: - Initialization
    
    init(tournament: Tournament) {
        self.tournament = tournament
        super.init(nibName: nil, bundle: nil)
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
    
    // MARK: - UI Setup
    
    private func setupUI() {
        
    }
}
