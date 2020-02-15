//
//  Constants.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-01-31.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

public struct Constants {
    
    // MARK: - smash.gg GraphQL API
    
    struct API {
        static let endpoint = "https://api.smash.gg/gql/alpha"
    }
    
    // MARK: - UI/Structure Constants
    
    struct Identifiers {
        static let tournamentCellIdentifier = "tournamentCell"
        static let videoGameCellIdentifier = "videoGameCell"
    }
    
    struct Colors {
        static let smashGgRed = UIColor(red: 189/255, green: 30/255, blue: 45/255, alpha: 1)
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
    }
}

typealias k = Constants
