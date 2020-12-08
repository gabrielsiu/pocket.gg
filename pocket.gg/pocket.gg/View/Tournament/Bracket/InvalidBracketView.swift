//
//  InvalidBracketView.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-12-06.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

class InvalidBracketView: UIView {
    
    // MARK: - Initialization
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setup() {
        // TODO: Finish design of this view
        let stackView = UIStackView()
        
        let imageView = UIImageView(image: UIImage(named: "placeholder"))
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel(frame: .zero)
        label.text = "Unable to generate a bracket view for this bracket"
        label.textAlignment = .center
        
        stackView.setup(subviews: [imageView, label], axis: .vertical, spacing: 20)
        
        addSubview(stackView)
        stackView.setAxisConstraints(xAnchor: centerXAnchor, yAnchor: centerYAnchor)
    }
}
