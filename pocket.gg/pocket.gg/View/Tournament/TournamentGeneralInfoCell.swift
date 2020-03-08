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
    
    // MARK: - Initialization
    
    init(_ tournament: Tournament) {
        super.init(style: .default, reuseIdentifier: nil)
        selectionStyle = .none
        setupViews(logoUrl: tournament.logoUrl, name: tournament.name, date: tournament.date)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
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
        
        nameLabel.numberOfLines = 0
        dateLabel.numberOfLines = 0
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
        
        spinner.setAxisConstraints(xAnchor: contentView.centerXAnchor, yAnchor: contentView.centerYAnchor)
        logoImageView.setSquareAspectRatio(sideLength: k.Sizes.logoSize)
        totalStackView.setEdgeConstraints(top: contentView.topAnchor, bottom: contentView.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets.init(top: k.Sizes.margin, left: k.Sizes.margin, bottom: k.Sizes.margin, right: k.Sizes.margin))
    }
    
    // MARK: - Public Methods
    
    func updateView(location: String?, _ complete: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let location = location else {
                complete()
                return
            }
            self?.spinner.stopAnimating()
            self?.locationLabel.text = "📍 \(location)"
            complete()
        }
    }
}
