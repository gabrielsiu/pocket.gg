//
//  TournamentListCell.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2021-05-29.
//  Copyright © 2021 Gabriel Siu. All rights reserved.
//

import UIKit

final class TournamentListCell: UITableViewCell {
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        imageView?.contentMode = .scaleAspectFill
        imageView?.setSquareAspectRatio(sideLength: k.Sizes.tournamentListCellHeight)
        imageView?.setEdgeConstraints(top: contentView.topAnchor,
                                      leading: contentView.leadingAnchor,
                                      trailing: textLabel?.leadingAnchor,
                                      padding: UIEdgeInsets(top: 11, left: 11, bottom: 0, right: 11))
        textLabel?.setEdgeConstraints(top: contentView.topAnchor,
                                      bottom: detailTextLabel?.topAnchor,
                                      leading: imageView?.trailingAnchor,
                                      trailing: contentView.trailingAnchor,
                                      padding: UIEdgeInsets(top: 11, left: 11, bottom: 0, right: 11))
        detailTextLabel?.setEdgeConstraints(top: textLabel?.bottomAnchor,
                                            leading: textLabel?.leadingAnchor,
                                            trailing: textLabel?.trailingAnchor)
        
        contentView.bottomAnchor.constraint(greaterThanOrEqualTo: imageView!.bottomAnchor, constant: 11).isActive = true
        contentView.bottomAnchor.constraint(greaterThanOrEqualTo: detailTextLabel!.bottomAnchor, constant: 11).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func updateView(text: String?, imageInfo: (url: String?, ratio: Double?)?, detailText: String?, newRatio: CGFloat? = nil) {
        textLabel?.text = text
        detailTextLabel?.text = detailText
        
        imageView?.layer.cornerRadius = k.Sizes.cornerRadius
        imageView?.layer.masksToBounds = true
        NetworkService.getImage(imageUrl: imageInfo?.url) { [weak self] (image) in
            guard let image = image else { return }
            var finalImage: UIImage?
            if let newRatio = newRatio, let prevRatio = imageInfo?.ratio {
                finalImage = image.cropToRatio(newRatio, from: CGFloat(prevRatio))
            } else {
                finalImage = image
            }
            DispatchQueue.main.async {
                self?.imageView?.image = finalImage
            }
        }
    }
}
