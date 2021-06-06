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
        // Entrants Stack View
        let entrantsStackView = UIStackView()
        let name0Label = UILabel()
        let name1Label = UILabel()
        let size = name0Label.font.pointSize
        
        let fullName0: String?
        var teamName0Length: Int?
        if let teamName = set.entrants?[safe: 0]?.entrant?.teamName, let entrantName = set.entrants?[safe: 0]?.entrant?.name {
            fullName0 = teamName + " " + entrantName
            teamName0Length = teamName.count
        } else {
            fullName0 = set.entrants?[safe: 0]?.entrant?.name
        }
        let fullName1: String?
        var teamName1Length: Int?
        if let teamName = set.entrants?[safe: 1]?.entrant?.teamName, let entrantName = set.entrants?[safe: 1]?.entrant?.name {
            fullName1 = teamName + " " + entrantName
            teamName1Length = teamName.count
        } else {
            fullName1 = set.entrants?[safe: 1]?.entrant?.name
        }
        name0Label.attributedText = getAttributedText(text: fullName0, size: size, entrantNum: 0, teamNameLength: teamName0Length)
        name1Label.attributedText = getAttributedText(text: fullName1, size: size, entrantNum: 1, teamNameLength: teamName1Length)
        
        entrantsStackView.setup(subviews: [name0Label, name1Label], axis: .vertical, alignment: .leading)
        entrantsStackView.distribution = .fillEqually
        
        // Score Stack View
        let scoreStackView = UIStackView()
        let score0Label = UILabel()
        let score1Label = UILabel()
        
        score0Label.attributedText = getAttributedText(text: set.entrants?[safe: 0]?.score, size: size, entrantNum: 0, addColor: true)
        score1Label.attributedText = getAttributedText(text: set.entrants?[safe: 1]?.score, size: size, entrantNum: 1, addColor: true)
        
        scoreStackView.setup(subviews: [score0Label, score1Label], axis: .vertical, alignment: .trailing)
        scoreStackView.distribution = .fillEqually
        
        // Total Stack View
        let totalStackView = UIStackView()
        let setIdentifierLabel = UILabel()
        
        setIdentifierLabel.textAlignment = .center
        setIdentifierLabel.text = set.identifier
        
        totalStackView.setup(subviews: [setIdentifierLabel, entrantsStackView, scoreStackView], axis: .horizontal, spacing: 10)
        
        addSubview(totalStackView)
        totalStackView.setEdgeConstraints(top: topAnchor,
                                          bottom: bottomAnchor,
                                          leading: leadingAnchor,
                                          trailing: trailingAnchor,
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
