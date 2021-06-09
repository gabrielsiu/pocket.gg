//
//  SetView.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-11-07.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

enum SetOutcome {
    case entrant0Won
    case entrant1Won
    case noWinner
}

final class SetView: UIView {
    
    let set: PhaseGroupSet
    let outcome: SetOutcome
    
    let size = UILabel().font.pointSize
    
    let labelsContainer = UIView()
    
    // MARK: - Initialization
    
    init(set: PhaseGroupSet, xPos: CGFloat, yPos: CGFloat) {
        self.set = set
        
        if let score0 = set.entrants?[safe: 0]?.score, let score1 = set.entrants?[safe: 1]?.score {
            if let score0Num = Int(score0), let score1Num = Int(score1) {
                if score0Num > score1Num {
                    outcome = .entrant0Won
                } else if score1Num > score0Num {
                    outcome = .entrant1Won
                } else {
                    outcome = .noWinner
                }
            } else if score0 == "W" {
                outcome = .entrant0Won
            } else if score1 == "W" {
                outcome = .entrant1Won
            } else {
                outcome = .noWinner
            }
        } else {
            outcome = .noWinner
        }
        super.init(frame: CGRect(x: xPos, y: yPos, width: k.Sizes.setWidth, height: k.Sizes.setHeight))
        
        setupAppearance()
        setupEntrantLabels()
        setupScoreLabels()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentSetCard)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupAppearance() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = k.Sizes.cornerRadius
        layer.masksToBounds = true
    }
    
    private func setupEntrantLabels() {
        addSubview(labelsContainer)
        
        let entrantLabel0 = UILabel()
        if outcome == .entrant0Won {
            entrantLabel0.attributedText = getAttributedText(text: set.entrants?[safe: 0]?.entrant?.name, size: size)
        } else {
            entrantLabel0.text = set.entrants?[safe: 0]?.entrant?.name
        }
        labelsContainer.addSubview(entrantLabel0)
        
        let entrantLabel1 = UILabel()
        if outcome == .entrant1Won {
            entrantLabel1.attributedText = getAttributedText(text: set.entrants?[safe: 1]?.entrant?.name, size: size)
        } else {
            entrantLabel1.text = set.entrants?[safe: 1]?.entrant?.name
        }
        labelsContainer.addSubview(entrantLabel1)
        
        entrantLabel0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        entrantLabel1.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        labelsContainer.setEdgeConstraints(top: topAnchor,
                                           bottom: bottomAnchor,
                                           leading: leadingAnchor,
                                           padding: UIEdgeInsets(top: 2, left: (k.Sizes.setHeight / 4) + 5, bottom: 2, right: 0))
        
        // Team for Entrant 0
        if set.entrants?[safe: 0]?.entrant?.teamName != nil {
            let teamLabel0 = UILabel()
            teamLabel0.attributedText = getAttributedText(text: set.entrants?[safe: 0]?.entrant?.teamName,
                                                          size: size, bold: outcome == .entrant0Won, color: .systemGray)
            labelsContainer.addSubview(teamLabel0)
            
            teamLabel0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            teamLabel0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            
            teamLabel0.widthAnchor.constraint(greaterThanOrEqualToConstant: k.Sizes.setWidth / 7).isActive = true
            
            teamLabel0.setEdgeConstraints(top: labelsContainer.topAnchor,
                                          leading: labelsContainer.leadingAnchor,
                                          trailing: entrantLabel0.leadingAnchor,
                                          padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5))
            entrantLabel0.setEdgeConstraints(top: labelsContainer.topAnchor,
                                             leading: teamLabel0.trailingAnchor,
                                             trailing: labelsContainer.trailingAnchor,
                                             padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 10))
        } else {
            entrantLabel0.setEdgeConstraints(top: labelsContainer.topAnchor,
                                             leading: labelsContainer.leadingAnchor,
                                             trailing: labelsContainer.trailingAnchor,
                                             padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        }
        
        // Team for Entrant 1
        if set.entrants?[safe: 1]?.entrant?.teamName != nil {
            let teamLabel1 = UILabel()
            teamLabel1.attributedText = getAttributedText(text: set.entrants?[safe: 1]?.entrant?.teamName,
                                                          size: size, bold: outcome == .entrant1Won, color: .systemGray)
            labelsContainer.addSubview(teamLabel1)
            
            teamLabel1.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            teamLabel1.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            
            teamLabel1.widthAnchor.constraint(greaterThanOrEqualToConstant: k.Sizes.setWidth / 7).isActive = true
            teamLabel1.setEdgeConstraints(bottom: labelsContainer.bottomAnchor,
                                          leading: labelsContainer.leadingAnchor,
                                          trailing: entrantLabel1.leadingAnchor,
                                          padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5))
            entrantLabel1.setEdgeConstraints(bottom: labelsContainer.bottomAnchor,
                                             leading: teamLabel1.trailingAnchor,
                                             trailing: labelsContainer.trailingAnchor,
                                             padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 10))
        } else {
            entrantLabel1.setEdgeConstraints(bottom: labelsContainer.bottomAnchor,
                                             leading: labelsContainer.leadingAnchor,
                                             trailing: labelsContainer.trailingAnchor,
                                             padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        }
    }
    
    private func setupScoreLabels() {
        let scoreLabel0Container = UIView()
        addSubview(scoreLabel0Container)
        
        let scoreLabel1Container = UIView()
        addSubview(scoreLabel1Container)
        
        let scoreLabel0 = UILabel()
        scoreLabel0.textAlignment = .center
        scoreLabel0Container.addSubview(scoreLabel0)
        
        let scoreLabel1 = UILabel()
        scoreLabel1.textAlignment = .center
        scoreLabel1Container.addSubview(scoreLabel1)
        
        if outcome == .entrant0Won {
            scoreLabel0.attributedText = getAttributedText(text: set.entrants?[safe: 0]?.score, size: size, color: .white)
            scoreLabel0Container.backgroundColor = .systemGreen
            scoreLabel1.attributedText = getAttributedText(text: set.entrants?[safe: 1]?.score, size: size, bold: false, color: .white)
            scoreLabel1Container.backgroundColor = .systemGray2
        } else if outcome == .entrant1Won {
            scoreLabel1.attributedText = getAttributedText(text: set.entrants?[safe: 1]?.score, size: size, color: .white)
            scoreLabel1Container.backgroundColor = .systemGreen
            scoreLabel0.attributedText = getAttributedText(text: set.entrants?[safe: 0]?.score, size: size, bold: false, color: .white)
            scoreLabel0Container.backgroundColor = .systemGray2
        }
        
        scoreLabel0Container.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        scoreLabel1Container.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        scoreLabel0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        scoreLabel1.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        scoreLabel0Container.setEdgeConstraints(top: topAnchor,
                                                bottom: centerYAnchor,
                                                leading: labelsContainer.trailingAnchor,
                                                trailing: trailingAnchor)
        scoreLabel1Container.setEdgeConstraints(top: centerYAnchor,
                                                bottom: bottomAnchor,
                                                leading: labelsContainer.trailingAnchor,
                                                trailing: trailingAnchor)
        scoreLabel0.setEdgeConstraints(top: scoreLabel0Container.topAnchor,
                                       bottom: scoreLabel0Container.bottomAnchor,
                                       leading: scoreLabel0Container.leadingAnchor,
                                       trailing: scoreLabel0Container.trailingAnchor,
                                       padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        scoreLabel1.setEdgeConstraints(top: scoreLabel1Container.topAnchor,
                                       bottom: scoreLabel1Container.bottomAnchor,
                                       leading: scoreLabel1Container.leadingAnchor,
                                       trailing: scoreLabel1Container.trailingAnchor,
                                       padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
    }
    
    // MARK: - Actions
    
    @objc private func presentSetCard() {
        // TODO: Present set card
//        NotificationCenter.default.post(name: Notification.Name("didTapSet"), object: set)
    }
    
    // MARK: - Private Helpers
    
    private func getAttributedText(text: String?, size: CGFloat, bold: Bool = true, color: UIColor? = nil) -> NSMutableAttributedString {
        guard let text = text else { return NSMutableAttributedString(string: "") }
        
        let attributedText = NSMutableAttributedString(string: text)
        if bold {
            attributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: size), range: NSRange(location: 0, length: text.count))
        }
        if let color = color {
            attributedText.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: text.count))
        }
        
        return attributedText
    }
}
