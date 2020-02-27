//
//  AboutInfoCell.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-26.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

class AboutInfoCell: UITableViewCell {
    
    var iconImageView = UIImageView()
    var appNameLabel = UILabel()
    var authorLabel = UILabel()
    var appIconVisible = true

    init() {
        super.init(style: .default, reuseIdentifier: nil)
        setupUI()
        
        selectionStyle = .none
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(appNameLabel)
        contentView.addSubview(authorLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        let totalWidth = iconImageView.intrinsicContentSize.width + max(appNameLabel.intrinsicContentSize.width, authorLabel.intrinsicContentSize.width) + 10
        let hSpacing = floor((contentView.frame.width - totalWidth)/2)
        
        iconImageView.frame = CGRect(x: hSpacing, y: 0, width: iconImageView.intrinsicContentSize.width, height: iconImageView.intrinsicContentSize.height)
        appNameLabel.frame = CGRect(x: iconImageView.frame.maxX + 10, y: iconImageView.frame.minY + 10, width: appNameLabel.intrinsicContentSize.width, height: appNameLabel.intrinsicContentSize.height)
        authorLabel.frame = CGRect(x: appNameLabel.frame.minX, y: appNameLabel.frame.maxY + 10, width: authorLabel.intrinsicContentSize.width, height: authorLabel.intrinsicContentSize.height)
    }
    
    private func setupUI() {
        iconImageView.image = UIImage(named: "placeholder") // TODO: Replace with actual app icon
        iconImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(iconImageViewTapped)))
        iconImageView.isUserInteractionEnabled = true
        
        appNameLabel.text = "pocket.gg"
        appNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        
        authorLabel.text = "Created by Gabriel Siu"
    }
    
    @objc private func iconImageViewTapped() {
        guard appIconVisible else { return }
        appIconVisible = false
        
        UIView.transition(with: iconImageView, duration: 0.3, options: .transitionFlipFromLeft, animations: { [weak self] in
            self?.iconImageView.image = UIImage(named: "settings") // TODO: Replace with another icon
        }, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let imageView = self?.iconImageView else { return }
            UIView.transition(with: imageView, duration: 0.3, options: .transitionFlipFromRight, animations: {
                imageView.image = UIImage(named: "placeholder")
            }, completion: { (_) in
                self?.appIconVisible = true
            })
        }
    }
}
