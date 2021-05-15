//
//  ScrollableRowCell.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2021-04-30.
//  Copyright © 2021 Gabriel Siu. All rights reserved.
//

import UIKit

final class ScrollableRowCell: UITableViewCell {
    
    var collectionView: UICollectionView

    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .secondarySystemBackground // TODO: Get the right color for dark mode (.systemBackground)
        collectionView.register(ScrollableRowItemCell.self, forCellWithReuseIdentifier: k.Identifiers.tournamentCell)
        
        contentView.addSubview(collectionView)
        collectionView.setEdgeConstraints(top: contentView.topAnchor,
                                          bottom: contentView.bottomAnchor,
                                          leading: contentView.leadingAnchor,
                                          trailing: trailingAnchor)
    }
    
    // MARK: - Public Methods
    
    func setCollectionViewProperties(_ dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forSection section: Int) {
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = section
        collectionView.reloadData()
    }

}
