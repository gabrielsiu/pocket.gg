//
//  TournamentGeneralInfoCell.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-14.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class TournamentGeneralInfoCell: UITableViewCell {
    
    // TODO: Move property initialization to proper function (for all classes)
    let spinner = UIActivityIndicatorView(style: .large)
    
    let logoImageView = UIImageView(image: UIImage(named: "placeholder"))
    let nameLabel = UILabel()
    let dateLabel = UILabel()
    let locationLabel = UILabel()
    
    let labelStackView = UIStackView()
    let totalStackView = UIStackView()
    
    init(_ tournament: Tournament) {
        super.init(style: .default, reuseIdentifier: nil)
        
        setupViews(logoUrl: tournament.logoUrl, name: tournament.name, date: tournament.date)
        setupConstraints()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(logoUrl: String, name: String, date: String) {
        spinner.startAnimating()
        contentView.addSubview(spinner)
        
        NetworkService.getImage(imageUrl: logoUrl) { [weak self] (logo) in
            DispatchQueue.main.async {
                self?.logoImageView.image = logo
            }
        }
        
        nameLabel.text = name
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        dateLabel.text = "📅 \(date)"
        locationLabel.text = "📍 "
        
        nameLabel.numberOfLines = 0
        locationLabel.numberOfLines = 0
        
        labelStackView.addArrangedSubview(nameLabel)
        labelStackView.addArrangedSubview(dateLabel)
        labelStackView.addArrangedSubview(locationLabel)
        labelStackView.axis = .vertical
        labelStackView.alignment = .leading
        labelStackView.spacing = 5
        
        totalStackView.addArrangedSubview(logoImageView)
        totalStackView.addArrangedSubview(labelStackView)
        totalStackView.axis = .horizontal
        totalStackView.alignment = .top
        totalStackView.spacing = 10
        
        contentView.addSubview(totalStackView)
    }
    
    private func setupConstraints() {
        // TODO: If this sort of setup a lot, make constriants extension file
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.widthAnchor.constraint(equalToConstant: k.Sizes.logoSize).isActive = true
        logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor).isActive = true
        
        totalStackView.translatesAutoresizingMaskIntoConstraints = false
        totalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: k.Sizes.margin).isActive = true
        totalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -k.Sizes.margin).isActive = true
        totalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: k.Sizes.margin).isActive = true
        totalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -k.Sizes.margin).isActive = true
    }
    
    func updateView(location: String, _ complete: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            self?.spinner.stopAnimating()
            self?.locationLabel.text?.append(location)
            complete()
        }
    }
}
