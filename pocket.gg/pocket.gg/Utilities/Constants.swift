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
        static let twitch = "https://www.twitch.tv/"
    }
    
    // MARK: - UI/Structure Constants
    
    struct Identifiers {
        static let tournamentsRowCell = "tournamentsRowCell"
        static let tournamentCell = "tournamentCell"
        static let videoGameCell = "videoGameCell"
        static let eventCell = "eventCell"
        static let streamCell = "streamCell"
        static let value1Cell = "value1Cell"
        static let roundRobinSetCell = "roundRobinSetCell"
    }
    
    struct Sizes {
        static let tournamentCellWidth: CGFloat = 125
        static let tournamentCellHeight: CGFloat = 225
        
        static let logoSize: CGFloat = 100
        static let margin: CGFloat = 16
        static let mapHeight: CGFloat = 300
        
        static let eventImageRatio: CGFloat = 0.75
        
        static let cornerRadius: CGFloat = 5
        
        static let largeFont: CGFloat = UIFont.systemFontSize + 4.0
        
        static let bracketMargin: CGFloat = 50
        static let setWidth: CGFloat = 200
        static let setHeight: CGFloat = 50
        static let xSetSpacing: CGFloat = 50
        static let ySetSpacing: CGFloat = 50
        
        static let roundRobinSetWidth: CGFloat = 100
        static let roundRobinSetHeight: CGFloat = 50
        static let roundRobinSetMargin: CGFloat = 5
    }
    
    // MARK: - User Defaults
    
    struct UserDefaults {
        static let authToken = "authToken"
        
        static let featuredTournaments = "featuredTournaments"
        static let upcomingTournaments = "upcomingTournaments"
        static let preferredVideoGames = "preferredVideoGames"
    }
    
    // MARK: - Error Messages
    
    struct Error {
        static let genericTitle = "Error"
        
        static let invalidAuthToken = "Invalid auth token"
        
        static let emptyUrl = "ERROR: No URL provided."
        static let urlGeneration = "Error generating URL from provided string: "
        static let networkRequest = "Network request failed with error: "
        static let missingData = "ERROR: Missing data from network request."
        static let imageFromData = "ERROR: Could not create image from given data."

        static let endpointUrl = "ERROR: Could not make URL from endpoint."
        static let apolloFetch = "Error fetching GraphQL query: "
        static let tournamentNodes = "ERROR: Could not fetch tournament nodes."
        static let tournamentFromId = "ERROR: Could not create tournament from its ID."
        static let phases = "ERROR: Could not fetch event phases."
        static let standingsNodes = "ERROR: Could not fetch event standings nodes."
        static let phaseGroupsNodes = "ERROR: Could not fetch phase groups nodes."
        
        static let requestTitle = "Request error"
        static let getTournamentsMessage = "Unable to fetch tournaments from smash.gg"
        static let generateTournamentMessage = "Unable to load tournament details"
        static let generateEventMessage = "Unable to load event"
        static let getEventDetailsMessage = "Unable to fetch event details"
        static let generateBracketMessage = "Unable to load bracket"
        static let getBracketDetailsMessage = "Unable to fetch bracket details"
    }
}

typealias k = Constants
