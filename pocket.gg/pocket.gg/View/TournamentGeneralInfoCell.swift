//
//  TournamentGeneralInfoCell.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-14.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

class TournamentGeneralInfoCell: UITableViewCell {

    let headerImageView = UIImageView()
    let logoImageView = UIImageView()
    let dateLabel = UILabel()
    let locationLabel = UILabel()
    
    init(tournament: Tournament) {
        super.init(style: .default, reuseIdentifier: nil)
        backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
    }
}
