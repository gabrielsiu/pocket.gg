//
//  Constants.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2018-12-26.
//  Copyright © 2018 Gabriel Siu. All rights reserved.
//

import Foundation

typealias CompletionHandler = (_ Success: Bool) -> ()

let ENDPOINT = "https://api.smash.gg/gql/alpha"


//Look up faster way of looking up game IDs (hash table maybe?)
let allGames = [
    1: "Melee",
    2: "PM",
    3: "Super Smash Bros. for Wii U",
    4: "Super Smash Bros.",
    5: "Brawl",
    6: "Other"
]

let BEARER_HEADER = [
    "Authorization": "Bearer \(AUTH_TOKEN)"
]
