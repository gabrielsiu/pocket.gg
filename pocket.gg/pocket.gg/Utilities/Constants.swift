//
//  Constants.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-01-31.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

// MARK: smash.gg GraphQL API
let endpoint = "https://api.smash.gg/gql/alpha"

// MARK: UI/Structure Constants
let tournamentCellIdentifier = "tournamentCell"
let smashGgRed = UIColor(red: 189/255, green: 30/255, blue: 45/255, alpha: 1)

// MARK: Error Messages
let urlGenerationError = "Error generating URL from provided string: "
let networkRequestError = "Network request failed with error: "
let missingDataError = "ERROR: Missing data from network request."
let imageFromDataError = "ERROR: Could not create image from given data."

let endpointUrlError = "ERROR: Could not make URL from endpoint."
let apolloFetchError = "Error fetching GraphQL query: "
let nodesError = "ERROR: Could not fetch tournament nodes."

//
let Streams = [
    "TWITCH": "twitch.tv",
    "HITBOX": "smashcast.tv",
    "STREAMME": "stream.me",
    "MIXER": "mixer.com"
]
let tournamentFromId = "ERROR: Could not create tournament from its ID."
//sizes
let logoSize: CGFloat = 100
let mediumCellHeight: CGFloat = 150
let margin: CGFloat = 16
