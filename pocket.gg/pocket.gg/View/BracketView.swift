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
    
    var totalWidth: CGFloat = 0
    var totalHeight: CGFloat = 0
    
    // MARK: - Initialization
    
    init(sets: [PhaseGroupSet]?) {
        // First sort the sets by the number of characters in their identifier
        // Then sort the the sets by their identifier's alphabetical order
        self.sets = sets?.sorted {
            if $0.identifier.count != $1.identifier.count {
                return $0.identifier.count < $1.identifier.count
            } else {
                return $0.identifier < $1.identifier
            }
        }
        super.init(frame: .zero)
        setupBracketView()
        frame = CGRect(x: 0, y: 0, width: totalWidth, height: totalHeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupBracketView() {
        guard let sets = sets else { return }
        
        // Winners Bracket
        layoutSets(yOrigin: k.Sizes.bracketMargin, sets: sets.filter { $0.roundNum > 0 })
        // Losers Bracket
        layoutSets(yOrigin: totalHeight, sets: sets.filter { $0.roundNum < 0 })
        // Other
        layoutSets(yOrigin: totalHeight, sets: sets.filter { $0.roundNum == 0 })
    }
    
    private func layoutSets(yOrigin: CGFloat, sets: [PhaseGroupSet]) {
        guard !sets.isEmpty else { return }
        
        /// The x position of where the the SetView is going to be added in the BracketView
        var xPosition = k.Sizes.bracketMargin
        /// The y position of where the the SetView is going to be added in the BracketView
        var yPosition = yOrigin
        /// The round number of the previous set that was computed. Used for detecting if the current set belongs to a new round
        var prevRoundNum: Int?
        
        /// An array describing how many sets belong to each round
        let setDistribution = distribution(for: sets)
        
        /// Represents which round a particular set belongs to (Eg. If roundIndex == 0, the set belongs to the leftmost round)
        var roundIndex = 0
        /// The y positions and IDs of all of the sets from the previous round
        var prevRoundInfo = [(yPosition: CGFloat, id: Int?)]()
        /// The y positions and IDs of the sets in the current round. Only used when the current round has a different number of sets than the previous round
        var currRoundInfo = [(yPosition: CGFloat, id: Int?)]()
        
        for set in sets {
            // First Set
            if prevRoundNum == nil {
                addRoundLabel(at: CGPoint(x: k.Sizes.bracketMargin, y: yOrigin), text: set.fullRoundText)
                yPosition += k.Sizes.setHeight
                prevRoundInfo.append((yPosition: yPosition, id: set.id))
            
            // Next Round of Sets
            } else if let prevRoundNum = prevRoundNum, prevRoundNum != set.roundNum {
                xPosition += (k.Sizes.setWidth + 50)
                roundIndex += 1
                
                if !currRoundInfo.isEmpty {
                    prevRoundInfo = currRoundInfo
                    currRoundInfo.removeAll()
                }
                
                addRoundLabel(at: CGPoint(x: xPosition, y: yOrigin), text: set.fullRoundText)
                
            // Consecutive sets in the first round
            } else if roundIndex == 0 {
                yPosition += (k.Sizes.setHeight + 50)
                prevRoundInfo.append((yPosition: yPosition, id: set.id))
            }
            
            // Determine how to layout the sets for sets past the first round
            if roundIndex > 0 {
                // If the current round has a different number of sets than the previous round
                if setDistribution[roundIndex] != setDistribution[roundIndex - 1] {
                    guard let prevRoundIDs = set.prevRoundIDs else {
                        // TODO: Figure out a better way of handling this situation
                        continue
                    }
                        
                    // Get the y positions of the prerequisite sets for the current set
                    let prevYPositions = prevRoundInfo.filter { prevRoundIDs.contains($0.id ?? -1) }.map { $0.yPosition }
                    
                    // Calculate the y position for the current set based on those of the prerequisite set(s)
                    switch prevYPositions.count {
                    case 1:
                        yPosition = prevYPositions[0]
                    case 2:
                        yPosition = floor((prevYPositions[0] + prevYPositions[1]) / 2)
                    default:
                        continue
                    }
                    currRoundInfo.append((yPosition: yPosition, id: set.id))
                    
                // If the current round has the same number of sets as the previous round
                } else {
                    yPosition = prevRoundInfo.removeFirst().yPosition
                    prevRoundInfo.append((yPosition: yPosition, id: set.id))
                }
            }
            
            // Update the width and/or height of the entire BracketView if necessary
            updateBracketViewSize(xPosition: xPosition, yPosition: yPosition)
            
            // Add the set to the BracketView at the calculated position
            addSubview(SetView(set: set, xPos: xPosition, yPos: yPosition))
            
            prevRoundNum = set.roundNum
        }
    }
    
    // MARK: - Private Helpers
    
    private func distribution(for sets: [PhaseGroupSet]) -> [Int] {
        var setDistribution = [Int]()
        var prevRoundNum: Int?
        
        for set in sets {
            if prevRoundNum == nil {
                prevRoundNum = set.roundNum
                setDistribution = [1]
            } else if let prevRoundNum = prevRoundNum, set.roundNum == prevRoundNum {
                let endIndex = setDistribution.count - 1
                setDistribution[endIndex] += 1
            } else {
                prevRoundNum = set.roundNum
                setDistribution.append(1)
            }
        }
        return setDistribution
    }
    
    private func addRoundLabel(at point: CGPoint, text: String?) {
        let roundLabel = UILabel(frame: CGRect(x: point.x, y: point.y, width: k.Sizes.setWidth, height: k.Sizes.setHeight))
        roundLabel.textAlignment = .center
        roundLabel.text = text
        addSubview(roundLabel)
    }
    
    private func updateBracketViewSize(xPosition: CGFloat, yPosition: CGFloat) {
        if (xPosition + k.Sizes.setWidth + 50) > totalWidth {
            totalWidth = xPosition + k.Sizes.setWidth + 50
        }
        if (yPosition + k.Sizes.setHeight + 50) > totalHeight {
            totalHeight = yPosition + k.Sizes.setHeight + 50
        }
    }
}
