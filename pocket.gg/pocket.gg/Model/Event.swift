//
//  Event.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-08-31.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

/// An event for a particular video game
///
/// Eg. Melee Singles
struct Event {

    // Info needed by TournamentViewController
    // Query 1 - TournamentDetailsById
    let id: Int?
    let name: String?
    let state: String?
    let winner: String?
    
    // Preloaded data for EventViewController
    // Query 1 - TournamentDetailsById
    let startDate: String?
    let eventType: Int?
    let videogameName: String?
    let videogameImage: (url: String?, ratio: Double?)?
    
    // On-demand data for EventViewController
    // Query 2 - EventById
    var phases: [Phase]?
    var topStandings: [(name: String?, placement: Int?)]?
    var slug: String?
}
