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
        
        var topStandings: [(name: String?, placement: Int?)]?
        var slug: String?
    }

    struct Stream {
        let name: String?
        let game: String?
        let logoUrl: String?
        let sourceUrl: String?
    }
}
