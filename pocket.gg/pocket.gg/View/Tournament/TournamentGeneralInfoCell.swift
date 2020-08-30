//
//  TournamentGeneralInfoCell.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-14.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class TournamentGeneralInfoCell: UITableViewCell {
    
    let tournament: Tournament
    
    let logoImageView = UIImageView(image: UIImage(named: "placeholder"))
    let dateIconView = UIImageView(image: UIImage(named: "calendar"))
    let locationIconView = UIImageView(image: UIImage(named: "location"))
    let nameLabel = UILabel()
    let dateLabel = UILabel()
    let locationLabel = UILabel()
    
    let dateStackView = UIStackView()
    let locationStackView = UIStackView()
    let labelStackView = UIStackView()
    let totalStackView = UIStackView()
    
    // MARK: - Initialization
    
    init(_ tournament: Tournament) {
        self.tournament = tournament
        super.init(style: .default, reuseIdentifier: nil)
        
        selectionStyle = .none
        setupViews()
        setupStackViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupViews() {
        logoImageView.layer.cornerRadius = k.Sizes.cornerRadius
        logoImageView.layer.masksToBounds = true
        NetworkService.getImage(imageUrl: tournament.logoUrl) { [weak self] (logo) in
            guard let logo = logo else { return }
            DispatchQueue.main.async {
                self?.logoImageView.image = logo
            }
        }
        
        nameLabel.text = tournament.name
        nameLabel.numberOfLines = 0
        nameLabel.font = UIFont.boldSystemFont(ofSize: k.Sizes.largeFont)
        
        dateLabel.text = tournament.date
        dateLabel.numberOfLines = 0
        
        guard !(tournament.isOnline ?? true) else {
            locationLabel.text = "Online"
            return
        }
        guard let address = tournament.location?.address else {
            locationLabel.text = "Location not available"
            return
        }
        locationLabel.text = address
        locationLabel.numberOfLines = 0
    }
    
    private func setupStackViews() {
        dateStackView.setup(subviews: [dateIconView, dateLabel], axis: .horizontal, alignment: .center, spacing: 5)
        locationStackView.setup(subviews: [locationIconView, locationLabel], axis: .horizontal, alignment: .center, spacing: 5)
        labelStackView.setup(subviews: [nameLabel, dateStackView, locationStackView], axis: .vertical, spacing: 5)
        totalStackView.setup(subviews: [logoImageView, labelStackView], axis: .horizontal, alignment: .top, spacing: 10)
        contentView.addSubview(totalStackView)
    }
    
    private func setConstraints() {
        dateIconView.setSquareAspectRatio(sideLength: dateLabel.font.pointSize)
        locationIconView.setSquareAspectRatio(sideLength: locationLabel.font.pointSize)
        
        logoImageView.setSquareAspectRatio(sideLength: k.Sizes.logoSize)
        totalStackView.setEdgeConstraints(top: contentView.topAnchor,
                                          bottom: contentView.bottomAnchor,
                                          leading: contentView.leadingAnchor,
                                          trailing: contentView.trailingAnchor,
                                          padding: UIEdgeInsets.init(top: k.Sizes.margin,
                                                                     left: k.Sizes.margin,
                                                                     bottom: k.Sizes.margin,
                                                                     right: k.Sizes.margin))
    }
}
