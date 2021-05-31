//
//  NoEnabledGamesCell.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2021-05-30.
//  Copyright © 2021 Gabriel Siu. All rights reserved.
//

import UIKit

final class NoEnabledGamesCell: UITableViewCell {
    
    // MARK: - Initialization
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        backgroundColor = .secondarySystemBackground
        selectionStyle = .none
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        let imageView = UIImageView(image: UIImage(named: "placeholder"))
        
        let label = UILabel(frame: .zero)
        // TODO: Finalize wording
        label.text = "You haven't enabled any video games. Add your favorite video games to see tournaments that feature those games."
        label.textAlignment = .center
        label.numberOfLines = 0
        
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        imageView.setSquareAspectRatio(sideLength: k.Sizes.tournamentListCellHeight)
        imageView.setAxisConstraints(xAnchor: contentView.centerXAnchor)
        imageView.setEdgeConstraints(top: contentView.topAnchor,
                                     bottom: label.topAnchor,
                                     padding: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0))
        label.setEdgeConstraints(top: imageView.bottomAnchor,
                                 bottom: contentView.bottomAnchor,
                                 leading: contentView.leadingAnchor,
                                 trailing: contentView.trailingAnchor)
    }
}
