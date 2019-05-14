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


//User Defaults
let PER_PAGE_KEY = "tournamentsPerPage"
let GAMES_KEY = "preferredGames"
let FILTERS_KEY = "preferredFilters"

let BEARER_HEADER = [
    "Authorization": "Bearer \(AUTH_TOKEN)"
]

let
IMAGE_URL = "https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/Smash_Ball.png/200px-Smash_Ball.png"
