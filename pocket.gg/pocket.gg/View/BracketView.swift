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
        layoutSets()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutSets() {
        guard let sets = sets else { return }
        
        for set in sets where set.roundNum > 0 {
            print("\(set.identifier) - \(set.roundNum)")
        }
        
        // Winners Bracket
        var xPosition: CGFloat = 50
        var yPosition: CGFloat = 0
        var prevRoundNum: Int?
        
        var setDistribution = [Int]()
        for set in sets where set.roundNum > 0 {
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
        prevRoundNum = nil
        
        var roundIndex = 0 // Which column of sets we're on
        var prevRoundInfo = [(yPosition: CGFloat, id: Int?)]()
        var tempStorage = [(yPosition: CGFloat, id: Int?)]()
        
        for set in sets where set.roundNum > 0 {
            
            // First Set
            if prevRoundNum == nil {
                yPosition = 50
                prevRoundInfo.append((yPosition: yPosition, id: set.id))
            
            // Next Round of Sets
            } else if let prevRoundNum = prevRoundNum, prevRoundNum != set.roundNum {
                xPosition += (k.Sizes.setWidth + 50)
                roundIndex += 1
                
                if !tempStorage.isEmpty {
                    prevRoundInfo = tempStorage
                    tempStorage.removeAll()
                }
                
            // Another Set in the first Round
            } else if roundIndex == 0 {
                yPosition += (k.Sizes.setHeight + 50)
                prevRoundInfo.append((yPosition: yPosition, id: set.id))
                
            } else {
                
            }
            
            // Past 1st column, diff num of rounds
            if roundIndex > 0, setDistribution[roundIndex] != setDistribution[roundIndex - 1] {
                
                // Different num of sets in this round, and this is the first set
                if let prevRoundNum = prevRoundNum, prevRoundNum != set.roundNum {
                    tempStorage.removeAll()
                }
                // Calculate y position of current set
                
                guard let prevRoundIDs = set.prevRoundIDs else {
                    // TODO: Figure out what to do in this situation
                    fatalError()
                }
                    
                // Get the y positions of the preceding sets for the current set
                let prevYPositions = prevRoundInfo.filter { prevRoundIDs.contains($0.id ?? -1) }.map { $0.yPosition }
                
                switch prevYPositions.count {
                case 1:
                    yPosition = prevYPositions[0]
                case 2:
                    yPosition = floor((prevYPositions[0] + prevYPositions[1]) / 2)
                default:
                    fatalError()
                }
                
                // Store y position to the array
                tempStorage.append((yPosition: yPosition, id: set.id))
                
                
            // Same num of sets as prev round
            } else if roundIndex > 0 {
                yPosition = prevRoundInfo.removeFirst().yPosition
                prevRoundInfo.append((yPosition: yPosition, id: set.id))
            }
            
//            print("SET \(set.identifier): x: \(xPosition) y: \(yPosition)")
            addSubview(SetView(set: set, xPos: xPosition, yPos: yPosition))
            
            prevRoundNum = set.roundNum
        }
        
        // Losers Bracket
        xPosition = 50
        yPosition = 0
        for set in sets where set.roundNum < 0 {
            print("\(set.identifier) - \(set.roundNum)")
        }
    }
}
