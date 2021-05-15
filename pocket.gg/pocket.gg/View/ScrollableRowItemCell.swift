//
//  ScrollableRowItemCell.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2021-05-01.
//  Copyright © 2021 Gabriel Siu. All rights reserved.
//

import UIKit

enum ScrollableRowItemCellType {
    case tournament
    case viewAll
}

final class ScrollableRowItemCell: UICollectionViewCell {
    var imageView: UIImageView
    var primaryLabel: UILabel
    var secondaryLabel: UILabel
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        imageView = UIImageView(image: UIImage(named: "placeholder"))
        primaryLabel = UILabel(frame: .zero)
        secondaryLabel = UILabel(frame: .zero)
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        imageView.setSquareAspectRatio(sideLength: k.Sizes.tournamentCellWidth)
        secondaryLabel.font = secondaryLabel.font.withSize(secondaryLabel.font.pointSize - 5)
        
        let spacerView = UIView(frame: .zero)
        spacerView.setContentHuggingPriority(UILayoutPriority(rawValue: 249), for: .vertical)
        
        let stackView = UIStackView()
        stackView.setup(subviews: [imageView, primaryLabel, secondaryLabel, spacerView], axis: .vertical, alignment: .fill, spacing: 5.0)
        
        contentView.addSubview(stackView)
        stackView.setEdgeConstraints(top: contentView.topAnchor,
                                     bottom: contentView.bottomAnchor,
                                     leading: contentView.leadingAnchor,
                                     trailing: contentView.trailingAnchor)
    }
    
    // MARK: - Public Methods
    
    func setImage(_ name: String, for type: ScrollableRowItemCellType) {
        switch type {
        case .tournament:
            imageView.image = UIImage(named: name)
        case .viewAll:
            let config = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 20))
            imageView.image = UIImage(systemName: name, withConfiguration: config)
            imageView.tintColor = .label
        }
    }
    
    func setCellStyle(for type: ScrollableRowItemCellType) {
        switch type {
        case .tournament:
            primaryLabel.font = UIFont.boldSystemFont(ofSize: primaryLabel.font.pointSize)
            primaryLabel.numberOfLines = 2
            secondaryLabel.numberOfLines = 3
        case .viewAll:
            primaryLabel.textAlignment = .center
            primaryLabel.font = UIFont.systemFont(ofSize: primaryLabel.font.pointSize)
        }
    }
    
    func updateView(text: String?, imageInfo: (url: String?, ratio: Double?)?, detailText: String?, newRatio: CGFloat? = nil) {
        primaryLabel.text = text
        secondaryLabel.text = detailText
        
        imageView.layer.cornerRadius = k.Sizes.cornerRadius
        imageView.layer.masksToBounds = true
        NetworkService.getImage(imageUrl: imageInfo?.url) { [weak self] (image) in
            guard let image = image else { return }
            var finalImage: UIImage?
            if let newRatio = newRatio, let prevRatio = imageInfo?.ratio {
                finalImage = image.cropToRatio(newRatio, from: CGFloat(prevRatio))
            } else {
                finalImage = image
            }
            DispatchQueue.main.async {
                self?.imageView.image = finalImage
            }
        }
    }
}
