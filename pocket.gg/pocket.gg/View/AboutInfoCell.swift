//
//  AboutInfoCell.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-26.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

class AboutInfoCell: UITableViewCell {
    
    let appNameLabel = UILabel()
    let authorLabel = UILabel()
    let labelStackView = UIStackView()
    
    var iconImageView: UIImageView?
    var aboutInfoStackView: UIStackView?
    var appIconVisible = true
    let appIcon = UIImage(named: "placeholder") // TODO: Replace with actual app icon
    
    // MARK: - Initialization

    init() {
        super.init(style: .default, reuseIdentifier: nil)
        selectionStyle = .none
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupViews() {
        appNameLabel.text = "pocket.gg"
        appNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        
        authorLabel.text = "Created by Gabriel Siu"
        
        labelStackView.addArrangedSubview(appNameLabel)
        labelStackView.addArrangedSubview(authorLabel)
        labelStackView.axis = .vertical
        labelStackView.spacing = 10
        
        if let appIcon = appIcon {
            labelStackView.alignment = .leading
            labelStackView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
            labelStackView.isLayoutMarginsRelativeArrangement = true
            
            iconImageView = UIImageView(image: appIcon)
            guard let iconImageView = iconImageView else { return }
            iconImageView.image = appIcon
            iconImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconImageViewTapped)))
            iconImageView.isUserInteractionEnabled = true
            
            aboutInfoStackView = UIStackView(arrangedSubviews: [iconImageView, labelStackView])
            guard let aboutInfoStackView = aboutInfoStackView else { return }
            aboutInfoStackView.axis = .horizontal
            aboutInfoStackView.alignment = .top
            aboutInfoStackView.spacing = 10
            
            contentView.addSubview(aboutInfoStackView)
            setupConstraints(aboutInfoStackView)
        } else {
            labelStackView.alignment = .center
            contentView.addSubview(labelStackView)
            setupConstraints(labelStackView)
        }
    }
    
    private func setupConstraints(_ stackView: UIStackView) {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    // MARK: - Actions
    
    @objc private func iconImageViewTapped() {
        guard appIconVisible else { return }
        guard let iconImageView = iconImageView else { return }
        guard let image = UIImage(named: "placeholder") else { return } // TODO: Replace with another icon of the same size
        appIconVisible = false
        
        UIView.transition(with: iconImageView, duration: 0.3, options: .transitionFlipFromRight, animations: { [weak self] in
            self?.iconImageView?.image = image
        }) { [weak self] (_) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                guard let iconImageView = self?.iconImageView else { return }
                
                UIView.transition(with: iconImageView, duration: 0.3, options: .transitionFlipFromLeft, animations: {
                    self?.iconImageView?.image = self?.appIcon
                }) { (_) in
                    self?.appIconVisible = true
                }
            }
        }
    }
}
