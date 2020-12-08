//
//  RoundRobinBracketView.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-12-07.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class RoundRobinBracketView: UIView, BracketView {
    let sets: [PhaseGroupSet]?
    var totalSize: CGSize = .zero
    var isValid = true
    
    // MARK: - Initialization
    
    init(sets: [PhaseGroupSet]?) {
        self.sets = sets
        super.init(frame: .zero)
        setupBracketView()
        frame = CGRect(x: 0, y: 0, width: totalSize.width, height: totalSize.height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupBracketView() {
        
    }
}
