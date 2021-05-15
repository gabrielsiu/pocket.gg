//
//  ScrollableRowItemCell.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2021-05-01.
//  Copyright © 2021 Gabriel Siu. All rights reserved.
//

import UIKit

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
        
        primaryLabel.font = UIFont.boldSystemFont(ofSize: primaryLabel.font.pointSize)
        primaryLabel.numberOfLines = 2
        
        secondaryLabel.font = secondaryLabel.font.withSize(secondaryLabel.font.pointSize - 5)
        secondaryLabel.numberOfLines = 3
        
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
    
    func setPlaceholder(_ named: String) {
        imageView.image = UIImage(named: named)
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
