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
    
    var type: RoundRobinSetCellType?
    var set: PhaseGroupSet?
    var color: UIColor?
    let label = UILabel()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupLabel()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentSetCard)))
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
    
    // MARK: - Actions
    
    @objc private func presentSetCard() {
        guard let type = type, type == .setScore else { return }
        NotificationCenter.default.post(name: Notification.Name(k.Notification.didTapSet), object: set)
    }
    
    // MARK: - Public Methods
    
    func setupCell(type: RoundRobinSetCellType, set: PhaseGroupSet? = nil) {
        self.type = type
        self.set = set
        
        switch type {
        case .topCorner, .entrantName:
            contentView.backgroundColor = .clear
        case .blank:
            contentView.backgroundColor = .secondarySystemBackground
        case .setScore:
            contentView.backgroundColor = .systemBackground
        case .overallEntrantScore:
            contentView.backgroundColor = .clear
            label.numberOfLines = 2
        }
    }
    
    func getColor(entrant: Entrant?) {
        guard let name = entrant?.name, let entrants = set?.entrants else {
            color = .systemGray
            return
        }
        
        if entrants.count == 2, let name0 = entrants[0].entrant?.name,
                                let score0 = entrants[0].score,
                                let name1 = entrants[1].entrant?.name,
                                let score1 = entrants[1].score {
            
            if name != name0 && name != name1 {
                color = .systemGray
                return
            }
            
            var entrantWon: Bool?
            if let score0Num = Int(score0), let score1Num = Int(score1) {
                if name == name0 {
                    entrantWon = score0Num > score1Num
                } else if name == name1 {
                    entrantWon = score0Num < score1Num
                }
            } else if let score0 = entrants[0].score, score0 == "W" {
                entrantWon = name == name0
            } else if let score1 = entrants[1].score, score1 == "W" {
                entrantWon = name == name1
            }
            
            if let entrantWon = entrantWon {
                color = entrantWon ? .systemGreen : .systemRed
            } else {
                color = .systemGray
            }
        } else {
            color = .systemGray
        }
    }
    
    func showBorderAndScore() {
        guard let color = color else { return }
        
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = color.cgColor
        
        guard let entrants = set?.entrants else { return }
        guard entrants.count == 2, let score0 = entrants[0].score, let score1 = entrants[1].score else { return }
        
        if let score0Num = Int(score0), let score1Num = Int(score1) {
            if score0Num > score1Num {
                label.attributedText = getAttributedText("\(color == UIColor.systemRed ? score1 : score0) - \(color == UIColor.systemRed ? score0 : score1)")
            } else {
                label.attributedText = getAttributedText("\(color == UIColor.systemRed ? score0 : score1) - \(color == UIColor.systemRed ? score1 : score0)")
            }
        } else {
            switch color {
            case .systemRed:
                label.attributedText = getAttributedText("L")
            case .systemGreen:
                label.attributedText = getAttributedText("W")
            default:
                label.attributedText = getAttributedText("-")
            }
        }
        label.textColor = color
    }
    
    func showText(_ text: String?) {
        label.attributedText = getAttributedText(text)
    }
    
    // MARK: - Private Helpers
    
    private func getAttributedText(_ text: String?) -> NSAttributedString {
        guard let type = type else { return NSMutableAttributedString() }
        guard let text = text else { return NSMutableAttributedString() }
        
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(.font,
                                    value: UIFont.boldSystemFont(ofSize: label.font.pointSize),
                                    range: NSRange(location: 0, length: text.count))
        
        switch type {
        case .entrantName:
            if let range = text.range(of: " | ") {
                let sponsorLength = text[..<range.lowerBound].count
                attributedText.addAttribute(.foregroundColor,
                                            value: UIColor.systemGray,
                                            range: NSRange(location: 0, length: sponsorLength))
                attributedText.deleteCharacters(in: NSRange(location: sponsorLength, length: 2))
            }
            return attributedText
            
        case .overallEntrantScore:
            if let range = text.range(of: "\n") {
                let gameScoreIndex = text[..<range.lowerBound].count
                let gameScoreLength = text[range.upperBound...].count + 1
                attributedText.addAttribute(.foregroundColor,
                                            value: UIColor.systemGray,
                                            range: NSRange(location: gameScoreIndex, length: gameScoreLength))
            }
            return attributedText
            
        default:
            return attributedText
        }
    }
}
