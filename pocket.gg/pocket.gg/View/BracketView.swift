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
        let setDistribution = getDistribution(for: sets)
        
        /// The most number of sets per round out of all the rounds
        guard let max = setDistribution.max() else { return }
        /// The roundIndex corresponding to the round with the most number of sets
        guard let maxIndex = setDistribution.firstIndex(of: max) else { return }
        /// A bool value describing whether or not the first round has the most number of sets compared to the other rounds
        let firstRoundHasMostSets = max == setDistribution[0]
        /// The y positions and IDs of the sets in the round with the most number of sets. Only used when firstRoundHasMostSets is false
        var mostNumSetsRoundInfo = [(yPosition: CGFloat, id: Int?)]()
        
        /// Represents which round a particular set belongs to (Eg. If roundIndex == 0, the set belongs to the leftmost round)
        var roundIndex = 0
        /// The y positions and IDs of all of the sets from the previous round
        var prevRoundInfo = [(yPosition: CGFloat, id: Int?)]()
        /// The y positions and IDs of the sets in the current round. Only used when the current round has a different number of sets than the previous round
        var currRoundInfo = [(yPosition: CGFloat, id: Int?)]()
        
        // Iterate through all of the sets
        // If !firstRoundHasMostSets, ignore the sets before the round with the most number of sets
        for set in sets {
            // Preparation for if we reach a new round of sets
            if let prevRoundNum = prevRoundNum, prevRoundNum != set.roundNum {
                xPosition += (k.Sizes.setWidth + 50)
                roundIndex += 1
            }
            
            // Upon reaching the round with the most number of sets and if !firstRoundHasMostSets, clear all info about the previous sets
            if !firstRoundHasMostSets, roundIndex == maxIndex, set.roundNum != prevRoundNum {
                prevRoundNum = nil
                prevRoundInfo.removeAll()
            }
            
            // First Set
            if prevRoundNum == nil {
                addRoundLabel(at: CGPoint(x: xPosition, y: yOrigin), text: set.fullRoundText)
                yPosition = yOrigin + k.Sizes.setHeight
                prevRoundInfo.append((yPosition: yPosition, id: set.id))
            
            // Next Round of Sets
            } else if prevRoundNum != set.roundNum {
                if !firstRoundHasMostSets, mostNumSetsRoundInfo.isEmpty {
                    mostNumSetsRoundInfo = prevRoundInfo
                } else if !currRoundInfo.isEmpty {
                    prevRoundInfo = currRoundInfo
                    currRoundInfo.removeAll()
                }
                
                addRoundLabel(at: CGPoint(x: xPosition, y: yOrigin), text: set.fullRoundText)
                
            // Consecutive sets in the round with the most number of sets
            } else if (firstRoundHasMostSets && roundIndex == 0) || (!firstRoundHasMostSets && roundIndex == maxIndex) {
                yPosition += (k.Sizes.setHeight + 50)
                prevRoundInfo.append((yPosition: yPosition, id: set.id))
            }
            
            // Determine how to layout the sets for sets past the first round
            if (firstRoundHasMostSets && roundIndex > 0) || (!firstRoundHasMostSets && roundIndex > maxIndex) {
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
            if firstRoundHasMostSets || (!firstRoundHasMostSets && roundIndex >= maxIndex) {
                addSubview(SetView(set: set, xPos: xPosition, yPos: yPosition))
            }
            
            prevRoundNum = set.roundNum
        }
        
        if !mostNumSetsRoundInfo.isEmpty {
            // TODO
        }
    }
    
    // MARK: - Private Helpers
    
    private func getDistribution(for sets: [PhaseGroupSet]) -> [Int] {
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
