//
//  RoundRobinBracketView.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-12-07.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class RoundRobinBracketView: UIView, BracketView {
    let sets: [PhaseGroupSet]?
    var isValid = true
    
    let entrants: [Entrant]
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    // MARK: - Initialization
    
    init(sets: [PhaseGroupSet]?, entrants: [Entrant]?) {
        self.sets = sets
        
        guard let entrants = entrants else {
            self.entrants = []
            super.init(frame: .zero)
            isValid = false
            return
        }
        
        self.entrants = entrants
        super.init(frame: .zero)
        setupBracketView()
        
        let width = Int(k.Sizes.roundRobinSetWidth) * (entrants.count + 2) + ((entrants.count + 1) * Int(k.Sizes.roundRobinSetMargin))
        let height = Int(k.Sizes.roundRobinSetHeight) * (entrants.count + 1) + (entrants.count * Int(k.Sizes.roundRobinSetMargin))
        frame = CGRect(x: 0, y: 0, width: width, height: height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupBracketView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(RoundRobinSetCell.self, forCellWithReuseIdentifier: k.Identifiers.roundRobinSetCell)
        collectionView.backgroundColor = .systemBackground
        
        addSubview(collectionView)
        collectionView.setEdgeConstraints(top: topAnchor, bottom: bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor)
    }
}

// MARK: - Collection View Data Source & Delegate

extension RoundRobinBracketView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(pow(Double(entrants.count + 1), 2)) + entrants.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let numEntrants = entrants.count
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: k.Identifiers.roundRobinSetCell, for: indexPath) as? RoundRobinSetCell {
            
            if indexPath.row == 0 {
                cell.setupCell(type: .topCorner)
            } else if (1...numEntrants).contains(indexPath.row) {
                cell.setupCell(type: .entrantName)
                cell.showLabel(entrants[indexPath.row - 1].name ?? "")
            } else if indexPath.row == numEntrants + 1 {
                cell.setupCell(type: .topCorner)
            } else if indexPath.row % (numEntrants + 2) == 0 {
                cell.setupCell(type: .entrantName)
                let entrantIndex = indexPath.row / (numEntrants + 2) - 1
                cell.showLabel(entrants[entrantIndex].name ?? "")
            } else if (indexPath.row + 1) % (numEntrants + 2) == 0 {
                cell.setupCell(type: .overallEntrantScore)
            } else if indexPath.row % (numEntrants + 3) == 0 {
                cell.setupCell(type: .blank)
            } else {
                let offset = indexPath.row % (entrants.count + 2)
                let entrantIndex = (indexPath.row - offset) / (numEntrants + 2) - 1
                // TODO: Handle case of no entrant better
                guard let entrant0 = entrants[safe: entrantIndex] else { return cell }
                guard let entrant1 = entrants[safe: (indexPath.row % (entrants.count + 2)) - 1] else { return cell }
                // TODO: Make cleaner
                let set = sets?.first(where: { set -> Bool in
                    return set.entrants?.compactMap({ info -> Bool? in
                        guard let id = info.entrant?.id else { return nil }
                        if let id0 = entrant0.id, id0 == id {
                            return true
                        } else if let id1 = entrant1.id, id1 == id {
                            return true
                        }
                        return nil
                    }).count == 2
                })
                
                cell.setupCell(type: .setScore, set: set)
                cell.setupBorder(entrant: entrant0)
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: k.Sizes.roundRobinSetWidth, height: k.Sizes.roundRobinSetHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return k.Sizes.roundRobinSetMargin
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return k.Sizes.roundRobinSetMargin
    }
}
