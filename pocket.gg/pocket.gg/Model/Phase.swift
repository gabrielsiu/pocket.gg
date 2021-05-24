//
//  Phase.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-08-31.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

/// A round of the event
///
/// Eg: R1 Pools, R2 Pools, Top 64, Top 8, etc.
struct Phase {
    
    // Info needed by EventVC
    // Query 2 - EventById
    let id: Int?
    let name: String?
    let state: String?
    
    // Preloaded data for PhaseGroupListVC
    // Query 2 - EventById
    let numPhaseGroups: Int?
    let numEntrants: Int?
    let bracketType: String?
    
    // On-demand data for PhaseGroupListVC
    // Query 3 - PhaseGroupsById
    var phaseGroups: [PhaseGroup]?
}
