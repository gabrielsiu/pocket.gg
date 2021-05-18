//
//  InvalidBracketView.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-12-06.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class InvalidBracketView: UIView {
    
    let cause: InvalidBracketViewCause
    var unsupportedBracketType: String?
    var labelText: String {
        switch cause {
        case .bracketLayoutError: return "Unable to generate a bracket view for this bracket"
        case .bracketNotStarted: return "This bracket has not started yet. Check back again when the bracket starts"
        case .noEntrants: return "This entrant currently has no entrants."
        case .unsupportedBracketType:
            let bracketType = unsupportedBracketType != nil ? " (\(unsupportedBracketType ?? ""))" : ""
            return "This type of bracket is currently not supported." + bracketType
        }
    }
    
    // MARK: - Initialization
    
    init(cause: InvalidBracketViewCause, bracketType: String? = nil) {
        self.cause = cause
        self.unsupportedBracketType = bracketType
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setup() {
        // TODO: Finish design of this view, fix constraints
        let stackView = UIStackView()
        
        let imageView = UIImageView(image: UIImage(named: "placeholder"))
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel(frame: .zero)
        label.text = labelText
        label.textAlignment = .center
        
        stackView.setup(subviews: [imageView, label], axis: .vertical, spacing: 20)
        
        addSubview(stackView)
        stackView.setAxisConstraints(xAnchor: centerXAnchor, yAnchor: centerYAnchor)
    }
}
