//
//  SetCell.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2021-06-23.
//  Copyright © 2021 Gabriel Siu. All rights reserved.
//

import UIKit

final class SetCell: UITableViewCell {
    
    let entrantLabel0 = UILabel()
    let entrantLabel1 = UILabel()
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    let setStateLabel = UILabel()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupLabels()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLabels() {
        let vsLabel = UILabel()
        vsLabel.text = "vs."
        vsLabel.textAlignment = .center
        
        entrantLabel0.numberOfLines = 0
        entrantLabel1.numberOfLines = 0
        
        let labelsContainer = UIView()
        labelsContainer.addSubview(vsLabel)
        labelsContainer.addSubview(entrantLabel0)
        labelsContainer.addSubview(entrantLabel1)
        
        contentView.addSubview(labelsContainer)
        contentView.addSubview(scoreLabel)
        contentView.addSubview(setStateLabel)
        vsLabel.setAxisConstraints(xAnchor: labelsContainer.centerXAnchor)
        vsLabel.setEdgeConstraints(top: labelsContainer.topAnchor,
                                   bottom: labelsContainer.bottomAnchor,
                                   leading: entrantLabel0.trailingAnchor,
                                   trailing: entrantLabel1.leadingAnchor,
                                   padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5))
        entrantLabel0.setEdgeConstraints(top: labelsContainer.topAnchor,
                                         bottom: labelsContainer.bottomAnchor,
                                         leading: labelsContainer.leadingAnchor,
                                         trailing: vsLabel.leadingAnchor,
                                         padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5))
        entrantLabel1.setEdgeConstraints(top: labelsContainer.topAnchor,
                                         bottom: labelsContainer.bottomAnchor,
                                         leading: vsLabel.trailingAnchor,
                                         trailing: labelsContainer.trailingAnchor,
                                         padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0))
        labelsContainer.setEdgeConstraints(top: contentView.topAnchor,
                                           bottom: scoreLabel.topAnchor,
                                           leading: contentView.leadingAnchor,
                                           trailing: contentView.trailingAnchor,
                                           padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        scoreLabel.setEdgeConstraints(top: labelsContainer.bottomAnchor,
                                      bottom: setStateLabel.topAnchor,
                                      leading: contentView.leadingAnchor,
                                      trailing: contentView.trailingAnchor,
                                      padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        setStateLabel.setEdgeConstraints(top: scoreLabel.bottomAnchor,
                                         bottom: contentView.bottomAnchor,
                                         leading: contentView.leadingAnchor,
                                         trailing: contentView.trailingAnchor,
                                         padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
    
    func addSetInfo(_ set: PhaseGroupSet?) {
        guard let set = set else { return }
        let outcome = SetUtilities.getSetOutcome(set)
        
        setStateLabel.text = set.state?.capitalized
        setStateLabel.textAlignment = .right
        setStateLabel.textColor = .systemGray
        
        let entrant0Name = set.entrants?[safe: 0]?.entrant?.name
        let entrant0TeamName = set.entrants?[safe: 0]?.entrant?.teamName
        let entrant1Name = set.entrants?[safe: 1]?.entrant?.name
        let entrant1TeamName = set.entrants?[safe: 1]?.entrant?.teamName
        
        let entrantLabel0Text: String?
        if let entrant0TeamName = entrant0TeamName {
            entrantLabel0Text = entrant0TeamName + " " + (entrant0Name ?? "")
        } else {
            entrantLabel0Text = entrant0Name
        }
        
        entrantLabel0.textAlignment = .right
        entrantLabel0.attributedText = SetUtilities.getAttributedEntrantText(entrantLabel0Text,
                                                                             bold: outcome == .entrant0Won,
                                                                             size: entrantLabel0.font.pointSize,
                                                                             teamNameLength: entrant0TeamName?.count)
        
        let entrantLabel1Text: String?
        if let entrant1TeamName = entrant1TeamName {
            entrantLabel1Text = entrant1TeamName + " " + (entrant1Name ?? "")
        } else {
            entrantLabel1Text = entrant1Name
        }
        entrantLabel1.attributedText = SetUtilities.getAttributedEntrantText(entrantLabel1Text,
                                                                             bold: outcome == .entrant1Won,
                                                                             size: entrantLabel1.font.pointSize,
                                                                             teamNameLength: entrant1TeamName?.count)
        
        scoreLabel.attributedText = SetUtilities.getAttributedScoreText(entrant0Score: set.entrants?[safe: 0]?.score,
                                                                        entrant1Score: set.entrants?[safe: 1]?.score,
                                                                        outcome: outcome, size: scoreLabel.font.pointSize)
    }
}
