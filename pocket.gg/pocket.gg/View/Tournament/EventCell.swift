//
//  EventCell.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-03-07.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: k.Identifiers.eventCell)
        
        contentView.clipsToBounds = true
        imageView?.contentMode = .scaleAspectFill
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func updateView(name: String?, videogameImage: (url: String?, ratio: Double?)?, date: String?) {
        textLabel?.text = name
        NetworkService.getImage(imageUrl: videogameImage?.url) { [weak self] (image) in
            DispatchQueue.main.async {
                // TODO: Figure out solution to set all table view imageViews to be the same size, so the video game pictures can all appear the same size
                self?.imageView?.image = image?.cropToRatio(k.Sizes.eventImageRatio, from: CGFloat(videogameImage?.ratio ?? 1))
            }
        }
        detailTextLabel?.text = DateFormatter.shared.dateFromTimestamp(date)
    }
}
