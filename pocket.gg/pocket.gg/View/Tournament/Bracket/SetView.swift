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
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = k.Sizes.cornerRadius
    }
    
    private func setupLabels() {
        // Set Identifier Label
        let setIdentifierLabel = UILabel()
        setIdentifierLabel.textAlignment = .center
        setIdentifierLabel.text = set.identifier
        addSubview(setIdentifierLabel)
        
        // Entrant Labels Container
        let labelsContainer = UIView()
        addSubview(labelsContainer)
        
        let teamLabel0 = UILabel()
        teamLabel0.text = set.entrants?[safe: 0]?.entrant?.teamName
        labelsContainer.addSubview(teamLabel0)
        
        let entrantLabel0 = UILabel()
        entrantLabel0.text = set.entrants?[safe: 0]?.entrant?.name
        labelsContainer.addSubview(entrantLabel0)
        
        let teamLabel1 = UILabel()
        teamLabel1.text = set.entrants?[safe: 1]?.entrant?.teamName
        labelsContainer.addSubview(teamLabel1)
        
        let entrantLabel1 = UILabel()
        entrantLabel1.text = set.entrants?[safe: 1]?.entrant?.name
        labelsContainer.addSubview(entrantLabel1)
        
        // Score Labels
        let scoreLabel0Container = UIView()
        addSubview(scoreLabel0Container)
        
        let scoreLabel1Container = UIView()
        addSubview(scoreLabel1Container)
        
        let scoreLabel0 = UILabel()
        scoreLabel0.text = set.entrants?[safe: 0]?.score
        scoreLabel0.textAlignment = .center
        scoreLabel0Container.addSubview(scoreLabel0)
        
        let scoreLabel1 = UILabel()
        scoreLabel1.text = set.entrants?[safe: 1]?.score
        scoreLabel1.textAlignment = .center
        scoreLabel1Container.addSubview(scoreLabel1)
        
        // Content Hugging & Compression Resistance Priorities
        setIdentifierLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        teamLabel0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        teamLabel1.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        teamLabel0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        teamLabel1.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        entrantLabel0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        entrantLabel1.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        scoreLabel0Container.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        scoreLabel1Container.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        scoreLabel0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        scoreLabel1.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        // Constraints
        setIdentifierLabel.widthAnchor.constraint(equalToConstant: setIdentifierLabel.intrinsicContentSize.width).isActive = true
        setIdentifierLabel.setEdgeConstraints(top: topAnchor,
                                              bottom: bottomAnchor,
                                              leading: leadingAnchor,
                                              trailing: labelsContainer.leadingAnchor,
                                              padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        labelsContainer.setEdgeConstraints(top: topAnchor,
                                           bottom: bottomAnchor,
                                           leading: setIdentifierLabel.trailingAnchor,
                                           padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        teamLabel0.widthAnchor.constraint(greaterThanOrEqualToConstant: k.Sizes.setWidth / 7).isActive = true
        teamLabel0.setEdgeConstraints(top: labelsContainer.topAnchor,
                                      leading: labelsContainer.leadingAnchor,
                                      trailing: entrantLabel0.leadingAnchor,
                                      padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        entrantLabel0.setEdgeConstraints(top: labelsContainer.topAnchor,
                                         leading: teamLabel0.trailingAnchor,
                                         trailing: labelsContainer.trailingAnchor,
                                         padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        teamLabel1.widthAnchor.constraint(greaterThanOrEqualToConstant: k.Sizes.setWidth / 7).isActive = true
        teamLabel1.setEdgeConstraints(bottom: labelsContainer.bottomAnchor,
                                      leading: labelsContainer.leadingAnchor,
                                      trailing: entrantLabel1.leadingAnchor,
                                      padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        entrantLabel1.setEdgeConstraints(bottom: labelsContainer.bottomAnchor,
                                         leading: teamLabel1.trailingAnchor,
                                         trailing: labelsContainer.trailingAnchor,
                                         padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        
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
    
    private func getAttributedText(text: String?, size: CGFloat, entrantNum: Int, teamNameLength: Int? = nil, addColor: Bool = false) -> NSMutableAttributedString {
        guard let text = text else { return NSMutableAttributedString(string: "") }
        guard let score0 = set.entrants?[safe: 0]?.score else { return NSMutableAttributedString(string: text) }
        guard let score1 = set.entrants?[safe: 1]?.score else { return NSMutableAttributedString(string: text) }
        
        var attributedText = NSMutableAttributedString(string: text)
        
        if let teamNameLength = teamNameLength {
            attributedText.addAttribute(.foregroundColor, value: UIColor.systemGray, range: NSRange(location: 0, length: teamNameLength))
        }
        
        if let score0Num = Int(score0), let score1Num = Int(score1) {
            if (entrantNum == 0 && score0Num > score1Num) || (entrantNum == 1 && score1Num > score0Num) {
                addAttributes(to: &attributedText, size: size, length: text.count, addColor: addColor)
            }
        } else if score0 == "W" || score1 == "W" {
            if (entrantNum == 0 && score0 == "W") || (entrantNum == 1 && score1 == "W") {
                addAttributes(to: &attributedText, size: size, length: text.count, addColor: addColor)
            }
        }
        
        return attributedText
    }
    
    private func addAttributes(to text: inout NSMutableAttributedString, size: CGFloat, length: Int, addColor: Bool = false) {
        text.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: size), range: NSRange(location: 0, length: length))
        if addColor {
            text.addAttribute(.foregroundColor, value: UIColor.systemGreen, range: NSRange(location: 0, length: length))
        }
    }
}
