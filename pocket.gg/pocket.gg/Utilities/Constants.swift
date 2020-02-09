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
let missingDataError = "Missing data from network request."
let imageFromDataError = "Error creating image from given data."

let apolloFetchError = "Error fetching GraphQL query: "
let nodesError = "Error while fetching tournamet nodes."
