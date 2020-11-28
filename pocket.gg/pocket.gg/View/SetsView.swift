//
//  SetsView.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-09-22.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class SetsView: UIView {
    
    let sets: [PhaseGroupSet]
    
    // MARK: - Initialization
    
    init(sets: [PhaseGroupSet]) {
        self.sets = sets
        super.init(frame: .zero)
        backgroundColor = .green
        
        setupSets()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSets() {
        for (index, set) in sets.enumerated() {
            let setView = UIView(frame: CGRect(x: 0, y: 0, width: k.Sizes.setWidth, height: k.Sizes.setHeight))

            let name0Label = UILabel()
            let name1Label = UILabel()

            name0Label.textAlignment = .center
            name1Label.textAlignment = .center
            
            name0Label.text = set.entrants?[safe: 0]?.name
            name1Label.text = set.entrants?[safe: 1]?.name

            setView.addSubview(name0Label)
            setView.addSubview(name1Label)

            name0Label.setEdgeConstraints(top: setView.topAnchor,
                                          bottom: name1Label.topAnchor,
                                          leading: setView.leadingAnchor,
                                          trailing: setView.trailingAnchor)
            name1Label.setEdgeConstraints(top: name0Label.bottomAnchor,
                                          bottom: setView.bottomAnchor,
                                          leading: setView.leadingAnchor,
                                          trailing: setView.trailingAnchor)
            
            addSubview(setView)
            setView.frame = CGRect(x: 0, y: CGFloat(index) * k.Sizes.setHeight, width: k.Sizes.setWidth, height: k.Sizes.setHeight)
            
        }
        
        frame = CGRect(x: 0, y: 0, width: k.Sizes.setWidth, height: CGFloat(sets.count) * k.Sizes.setHeight)
    }
}
