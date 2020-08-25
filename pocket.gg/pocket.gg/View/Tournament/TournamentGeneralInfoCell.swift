//
//  TournamentGeneralInfoCell.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-14.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class TournamentGeneralInfoCell: UITableViewCell {
    
    let spinner = UIActivityIndicatorView(style: .large)
    
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
        super.init(style: .default, reuseIdentifier: nil)
        selectionStyle = .none
        
        setupViews(logoUrl: tournament.logoUrl, name: tournament.name, date: tournament.date)
        setupStackViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupViews(logoUrl: String, name: String, date: String) {
        spinner.startAnimating()
        contentView.addSubview(spinner)
        
        logoImageView.layer.cornerRadius = k.Sizes.cornerRadius
        logoImageView.layer.masksToBounds = true
        NetworkService.getImage(imageUrl: logoUrl) { [weak self] (logo) in
            guard let logo = logo else { return }
            DispatchQueue.main.async {
                self?.logoImageView.image = logo
            }
        }
        
        nameLabel.text = name
        nameLabel.numberOfLines = 0
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
        dateLabel.text = date
        dateLabel.numberOfLines = 0
        
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
        
        spinner.setAxisConstraints(xAnchor: contentView.centerXAnchor, yAnchor: contentView.centerYAnchor)
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
    
    // MARK: - Public Methods
    
    func updateView(isOnline: Bool?, location: String?, _ complete: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard !(isOnline ?? true) else {
                self?.spinner.stopAnimating()
                self?.locationLabel.text = "Online"
                complete()
                return
            }
            guard let location = location else {
                self?.spinner.stopAnimating()
                self?.locationLabel.text = "Location not available"
                complete()
                return
            }
            self?.spinner.stopAnimating()
            self?.locationLabel.text = location
            complete()
        }
    }
}
