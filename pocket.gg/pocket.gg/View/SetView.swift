//
//  SetView.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-11-07.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

class SetView: UIView {
    
    let set: PhaseGroupSet
    
    // MARK: - Initialization
    
    init(set: PhaseGroupSet, xPos: CGFloat, yPos: CGFloat) {
        self.set = set
        super.init(frame: CGRect(x: xPos, y: yPos, width: k.Sizes.setWidth, height: k.Sizes.setHeight))
        backgroundColor = .green
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        let name0Label = UILabel()
        let name1Label = UILabel()
        
        name0Label.text = set.entrants?[safe: 0]?.name
        name1Label.text = set.entrants?[safe: 1]?.name

        addSubview(name0Label)
        addSubview(name1Label)

        name0Label.setEdgeConstraints(top: topAnchor,
                                      bottom: name1Label.topAnchor,
                                      leading: leadingAnchor,
                                      trailing: trailingAnchor)
        name1Label.setEdgeConstraints(top: name0Label.bottomAnchor,
                                      bottom: bottomAnchor,
                                      leading: leadingAnchor,
                                      trailing: trailingAnchor)
    }
}
