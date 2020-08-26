//
//  Tournament.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-02.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

struct Tournament {
    let name: String
    let logoUrl: String
    let date: String
    let id: Int
    var headerImage: (url: String, ratio: Double)
    
    var contactInfo: String?
    var location: Location?
    var events: [Event]?
    var streams: [Stream]?
    var registration: (isOpen: Bool?, closeDate: String?)?
    var slug: String?
    
    var isOnline = true
    struct Location {
        let venueName: String?
        let address: String?
        let longitude: Double?
        let latitude: Double?
    }
    
    struct Event {
        let name: String?
        let startDate: String?
        let id: Int?
        let videogameImage: (url: String?, ratio: Double?)?
        
        var phases: [Phase]?
        var topStandings: [(name: String?, placement: Int?)]?
        var slug: String?
    }

    struct Stream {
        let name: String?
        let game: String?
        let logoUrl: String?
        let sourceUrl: String?
    }
    
    // Phase: A round of the tournament
    // Eg: R1 Pools, R2 Pools, Top 64, Top 8, etc.
    struct Phase {
        let name: String?
        let id: Int?
        let state: String?
        let numPhaseGroups: Int?
        
        var numEntrants: Int?
        var bracketType: String?
        var phaseGroups: [PhaseGroup]?
    }
    
    // Phase Group: A pool within a certain phase
    // Eg: R1 Pools can have many phase groups, whereas Top 8 only has 1
    struct PhaseGroup {
        let name: String?
        let id: Int?
        let state: String?
    }
}
