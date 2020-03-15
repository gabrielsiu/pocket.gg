//
//  StreamCell.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-03-14.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class StreamCell: SubtitleCell {

    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: k.Identifiers.streamCell)
        
        contentView.clipsToBounds = true
        imageView?.contentMode = .scaleAspectFill
        imageView?.image = UIImage(named: "placeholder")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
