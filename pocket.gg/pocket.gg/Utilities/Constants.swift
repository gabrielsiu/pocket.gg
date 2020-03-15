//
//  Constants.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-01-31.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

struct Constants {
    
    // MARK: - URLs
    
    struct API {
        static let endpoint = "https://api.smash.gg/gql/alpha"
        static let streams = [
            "TWITCH": "twitch.tv",
            "HITBOX": "smashcast.tv",
            "STREAMME": "stream.me",
            "MIXER": "mixer.com"
        ]
    }
    
    struct URL {
        static let apolloiOS = "https://www.apollographql.com/docs/ios/"
        static let smashGgAPI = "https://developer.smash.gg/docs/intro"
    }
    
    // MARK: - UI/Structure Constants
    
    struct Identifiers {
        static let tournamentCell = "tournamentCell"
        static let videoGameCell = "videoGameCell"
        static let eventCell = "eventCell"
        static let streamCell = "streamCell"
    }
    
    struct Colors {
        static let smashGgRed = UIColor(red: 189/255, green: 30/255, blue: 45/255, alpha: 1)
    }
    
    struct Sizes {
        static let logoSize: CGFloat = 100
        static let margin: CGFloat = 16
        static let mapHeight: CGFloat = 300
        
        static let eventImageRatio: CGFloat = 0.75
    }
    
    // MARK: - User Defaults
    
    struct UserDefaults {
        static let featuredTournaments = "featuredTournaments"
        static let upcomingTournaments = "upcomingTournaments"
        static let preferredVideoGames = "preferredVideoGames"
    }
    
    // MARK: - Error Messages
    
    struct Error {
        static let urlGeneration = "Error generating URL from provided string: "
        static let networkRequest = "Network request failed with error: "
        static let missingData = "ERROR: Missing data from network request."
        static let imageFromData = "ERROR: Could not create image from given data."

        static let endpointUrl = "ERROR: Could not make URL from endpoint."
        static let apolloFetch = "Error fetching GraphQL query: "
        static let tournamentNodes = "ERROR: Could not fetch tournament nodes."
        static let tournamentFromId = "ERROR: Could not create tournament from its ID."
    }
}

typealias k = Constants
