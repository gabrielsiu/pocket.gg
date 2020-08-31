//
//  Tournament.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-02.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

/// A tournament that is registered on smash.gg
struct Tournament {
    
    // Info needed by TournamentListViewController
    // Query 0 - TournamentsByVideogames
    let id: Int?
    let name: String?
    let date: String?
    let logoUrl: String?
    
    // Preloaded data for TournamentViewController
    // Query 0 - TournamentsByVideogames
    var location: Location?
    let isOnline: Bool?
    let headerImage: (url: String?, ratio: Double?)?
    
    // On-demand data for TournamentViewController
    // Query 1 - TournamentDetailsById
    var events: [Event]?
    var streams: [Stream]?
    var registration: (isOpen: Bool?, closeDate: String?)?
    var contactInfo: String?
    var slug: String?
}
