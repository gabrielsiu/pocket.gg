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
        static let smashggAPI = "https://developer.smash.gg/docs/intro"
        static let twitch = "https://www.twitch.tv/"
        
        static let twitter = "https://twitter.com/gabrielsiu_dev"
    }
    
    // MARK: - UI/Structure Constants
    
    struct Identifiers {
        static let tournamentsRowCell = "tournamentsRowCell"
        static let tournamentCell = "tournamentCell"
        static let tournamentListCell = "tournamentListCell"
        static let tournamentSetCell = "tournamentSetCell"
        static let tournamentSetGameCell = "tournamentSetGameCell"
        static let videoGameCell = "videoGameCell"
        static let eventCell = "eventCell"
        static let streamCell = "streamCell"
        static let value1Cell = "value1Cell"
        static let roundRobinSetCell = "roundRobinSetCell"
    }
    
    struct Sizes {
        static let tournamentCellWidth: CGFloat = 125
        static let tournamentCellHeight: CGFloat = 225
        
        static let tournamentListCellHeight: CGFloat = 75
        
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
        static let authTokenDate = "authTokenDate"
        
        static let pinnedTournaments = "pinnedTournaments"
        static let showPinnedTournaments = "showPinnedTournaments"
        static let featuredTournaments = "featuredTournaments"
        static let upcomingTournaments = "upcomingTournaments"
        static let preferredVideoGames = "preferredVideoGames"
        
        static let onlySearchFeatured = "onlySearchFeatured"
        static let showOlderTournamentsFirst = "showOlderTournamentsFirst"
        static let searchUsingEnabledGames = "searchUsingEnabledGames"
        static let recentSearches = "recentSearches"
        
        static let alternateAppIconUsed = "alternateAppIconUsed"
    }
    
    // MARK: - Notification Center
    
    struct Notification {
        static let tournamentPinToggled = "tournamentPinToggled"
        static let settingsChanged = "settingsChanged"
        static let didTapSet = "didTapSet"
    }
    
    // MARK: - Errors
    
    struct Error {
        static let title = "Error"
        
        static let invalidAuthToken = "Invalid auth token"
        
        static let emptyUrl = "ERROR: No URL provided."
        static let urlGeneration = "Error generating URL from provided string: "
        static let networkRequest = "Network request failed with error: "
        static let missingData = "ERROR: Missing data from network request."
        static let imageFromData = "ERROR: Could not create image from given data."
        
        static let apolloFetch = "Error fetching GraphQL query: "
        
        // TODO: Finalize wording
        static let pinnedTournamentLimit = "You can only have up to 10 pinned tournaments"
    }
    
    // MARK: - Messages
    
    struct Message {
        // MARK: MainVC
        static let errorLoadingTournaments = "Unable to load tournaments"
        static let noTournaments = "No tournaments found for this category"
        static let noPinnedTournaments = "You don't have any pinned tournaments"
        static let noPreferredGames = "You haven't enabled any video games. Add your favorite video games to see tournaments that feature those games."
        
        // MARK: TournamentVC
        static let errorLoadingEvents = "Unable to load events"
        static let noEvents = "No events found"
        static let errorLoadingStreams = "Unable to load streams"
        static let noStreams = "No streams found"
        static let errorLoadingLocation = "Unable to load location"
        static let noLocation = "No location found"
        static let errorLoadingContactInfo = "Unable to load contact info"
        static let noContactInfo = "No contact info found"
        static let errorLoadingRegistrationInfo = "Unable to load registration info"
        
        // MARK: EventVC
        static let errorLoadingBrackets = "Unable to load brackets"
        static let noBrackets = "No brackets found"
        static let errorLoadingStandings = "Unable to load standings"
        static let noStandings = "No standings found"
        
        // MARK: PhaseGroupListVC
        static let errorLoadingPhaseGroups = "Unable to load pools"
        static let noPhaseGroups = "No pools found"
        
        // MARK: PhaseGroupVC
        static let errorLoadingPhaseGroupStandings = "Unable to load standings"
        static let noPhaseGroupStandings = "No standings found"
        static let errorLoadingSets = "Unable to load matches"
        static let noSets = "No matches found"
        
        // MARK: SetVC
        static let errorLoadingGames = "Unable to load games"
        static let noGames = "No games reported"
    }
}

typealias k = Constants
