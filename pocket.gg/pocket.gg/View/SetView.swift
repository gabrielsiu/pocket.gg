//
//  SetView.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-11-07.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class SetView: UIView {
    
    let set: PhaseGroupSet
    
    // MARK: - Initialization
    
    init(set: PhaseGroupSet, xPos: CGFloat, yPos: CGFloat) {
        self.set = set
        super.init(frame: CGRect(x: xPos, y: yPos, width: k.Sizes.setWidth, height: k.Sizes.setHeight))
        
        setupAppearance()
        setupLabels()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentSetCard)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupAppearance() {
        backgroundColor = .systemGray
        layer.cornerRadius = k.Sizes.cornerRadius
    }
    
    private func setupLabels() {
        
        let totalStackView = UIStackView()
        let entrantsStackView = UIStackView()
        
        let name0Label = UILabel()
        let name1Label = UILabel()
        
        name0Label.text = set.entrants?[safe: 0]?.name
        name1Label.text = set.entrants?[safe: 1]?.name
        
        entrantsStackView.setup(subviews: [name0Label, name1Label], axis: .vertical, alignment: .leading)
        entrantsStackView.distribution = .fillEqually
        
        let setIdentifierLabel = UILabel()
        setIdentifierLabel.textAlignment = .center
        setIdentifierLabel.text = set.identifier
        
        totalStackView.setup(subviews: [setIdentifierLabel, entrantsStackView], axis: .horizontal, spacing: 10)
        
        addSubview(totalStackView)
        totalStackView.setEdgeConstraints(top: topAnchor,
                                          bottom: bottomAnchor,
                                          leading: leadingAnchor,
                                          trailing: trailingAnchor,
                                          padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
    }
    
    @objc private func presentSetCard() {
        // TODO: Present set card
    }
}
