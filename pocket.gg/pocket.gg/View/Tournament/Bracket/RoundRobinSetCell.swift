//
//  RoundRobinSetCell.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-12-15.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

enum RoundRobinSetCellType {
    case topCorner
    case blank
    case setScore
    case entrantName
    case overallEntrantScore
}

class RoundRobinSetCell: UICollectionViewCell {
    
    var set: PhaseGroupSet?
    let label = UILabel()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLabel() {
        label.textAlignment = .center
        
        contentView.addSubview(label)
        label.setEdgeConstraints(top: contentView.topAnchor,
                                 bottom: contentView.bottomAnchor,
                                 leading: contentView.leadingAnchor,
                                 trailing: contentView.trailingAnchor)
    }
    
    // MARK: - Public Methods
    
    func setupCell(type: RoundRobinSetCellType, set: PhaseGroupSet? = nil) {
        self.set = set
        
        switch type {
        case .topCorner, .entrantName, .overallEntrantScore:
            contentView.backgroundColor = .clear
        case .blank:
            contentView.backgroundColor = .secondarySystemBackground
        case .setScore:
            contentView.backgroundColor = .tertiarySystemBackground
        }
    }
    
    func setupBorder(entrant: Entrant) {
        guard let name = entrant.name else { return }
        guard let entrants = set?.entrants else { return }
        
        let color: UIColor
        if entrants.count == 2, let name0 = entrants[0].entrant?.name,
                                let score0 = entrants[0].score,
                                let name1 = entrants[1].entrant?.name,
                                let score1 = entrants[1].score {
            
            if name != name0 && name != name1 {
                // TODO: HANDLE ERROR CASE
                return
            }
            
            // TODO: MAKE THIS CLEANER
            var entrantWon = false
            var winnerPresent = false
            if let score0Num = Int(score0), let score1Num = Int(score1) {
                if name == name0, score0Num > score1Num {
                    entrantWon = true
                    winnerPresent = true
                } else if name == name0, score0Num < score1Num {
                    entrantWon = false
                    winnerPresent = true
                } else if name == name1, score0Num > score1Num {
                    entrantWon = false
                    winnerPresent = true
                } else if name == name1, score0Num < score1Num {
                    entrantWon = true
                    winnerPresent = true
                }
            } else if let score0 = entrants[0].score, score0 == "W" {
                entrantWon = name == name0
                winnerPresent = true
            } else if let score1 = entrants[1].score, score1 == "W" {
                entrantWon = name == name1
                winnerPresent = true
            }
            
            if winnerPresent {
                color = entrantWon ? .systemGreen : .systemRed
            } else {
                color = .systemGray
            }
        } else {
            color = .systemGray
        }
        
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = color.cgColor
    }
    
    func showLabel(_ num: String) {
        label.text = num
        label.textColor = .black
    }
}
