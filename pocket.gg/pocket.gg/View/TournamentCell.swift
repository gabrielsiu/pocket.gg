//
//  TournamentCell.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-01-31.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class TournamentCell: UITableViewCell {
    
    var imageViewFrame:       CGRect? = nil
    var textLabelFrame:       CGRect? = nil
    var detailTextLabelFrame: CGRect? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: tournamentCellIdentifier)
        
        imageView?.image = UIImage(named: "placeholder")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let imageViewFrame = imageViewFrame {
            imageView?.frame = imageViewFrame
        } else {
            imageViewFrame = imageView?.frame
        }
        if let textLabelFrame = textLabelFrame {
            textLabel?.frame = textLabelFrame
        } else {
            textLabelFrame = textLabel?.frame
        }
        if let detailTextLabelFrame = detailTextLabelFrame {
            detailTextLabel?.frame = detailTextLabelFrame
        } else {
            detailTextLabelFrame = detailTextLabel?.frame
        }
    }
    
    public func updateView(name: String, imageUrl: String, date: String) {
        textLabel?.text = name
        NetworkService.requestImage(imageUrl: imageUrl) { [weak self] (complete, image) in
            DispatchQueue.main.async {
                self?.imageView?.image = image ?? UIImage(named: "placeholder")
            }
        }
        detailTextLabel?.text = date
    }
}
