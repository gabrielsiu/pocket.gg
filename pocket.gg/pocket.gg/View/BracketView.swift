//
//  BracketView.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-09-10.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class BracketView: UIView {
    
    let sets: [PhaseGroupSet]?
    
    // MARK: - Initialization
    
    init(sets: [PhaseGroupSet]?) {
        self.sets = sets
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
