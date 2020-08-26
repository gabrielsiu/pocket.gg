//
//  LoadingCell.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-03-28.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class LoadingCell: UITableViewCell {
    
    let spinner = UIActivityIndicatorView(style: .large)
    
    // MARK: - Initialization
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        selectionStyle = .none
        setupSpinner()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupSpinner() {
        spinner.startAnimating()
        contentView.addSubview(spinner)
        spinner.setAxisConstraints(xAnchor: contentView.centerXAnchor, yAnchor: contentView.centerYAnchor)
    }
}
