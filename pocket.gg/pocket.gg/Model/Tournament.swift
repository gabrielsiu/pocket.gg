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
    
    /// Where the tournament is located
    ///
    /// The address for each tournament pre-fetched as part of the TournamentsByVideogames query, and the rest is fetched as a part of the TournamentDetailsById query
    struct Location {
        let address: String?
        var venueName: String?
        var longitude: Double?
        var latitude: Double?
    }
    
    /// An external service where the tournament is streamed, and can be viewed online
    struct Stream {
        let name: String?
        let game: String?
        let logoUrl: String?
        let sourceUrl: String?
    }
    
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
        
        /// A round of the event
        ///
        /// Eg: R1 Pools, R2 Pools, Top 64, Top 8, etc.
        struct Phase {
            
            // Info needed by EventViewController
            // Query 2 - EventById
            let id: Int?
            let name: String?
            let state: String?
            
            // Preloaded data for PhaseGroupListViewController
            // Query 2 - EventById
            let numPhaseGroups: Int?
            let numEntrants: Int?
            let bracketType: String?
            
            // On-demand data for PhaseGroupListViewController
            // Query 3 - PhaseGroupsById
            var phaseGroups: [PhaseGroup]?
            
            /// A pool within a certain phase
            ///
            /// Eg: R1 Pools can have many phase groups, whereas Top 8 only has 1
            struct PhaseGroup {
                
                // Info needed by PhaseGroupListViewController
                // Query 3 - PhaseGroupsById
                let id: Int?
                let name: String?
                let state: String?
                
                // On-demand data for PhaseGroupViewController
                // Query 4 - PhaseGroupStandingsById
                var progressionsOut: [Int]?
                var standings: [(name: String?, placement: Int?)]?
            }
        }
    }
}
