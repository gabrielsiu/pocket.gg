//
//  DefaultsService.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2018-12-30.
//  Copyright © 2018 Gabriel Siu. All rights reserved.
//

import Foundation

class DefaultsService {
    static let instance = DefaultsService()
    
    let defaults = UserDefaults.standard
    
    var tournamentsPerPage: Int {
        get {
            if defaults.integer(forKey: PER_PAGE_KEY) == 0 {
                return 30
            }
            return defaults.integer(forKey: PER_PAGE_KEY)
        }
        set {
            defaults.set(newValue, forKey: PER_PAGE_KEY)
        }
    }
    
    var preferredGames: [Int] {
        get {
            return defaults.array(forKey: GAMES_KEY) as? [Int] ?? [1]
        }
        set {
            defaults.set(newValue, forKey: GAMES_KEY)
        }
    }
    
    var filters: [String: Bool] {
        get {
            return defaults.dictionary(forKey: FILTERS_KEY) as? [String: Bool] ?? ["featured": true, "upcoming": true]
        }
        set {
            defaults.set(newValue, forKey: FILTERS_KEY)
        }
    }
    
}

//When asking for more content, increment page number (need to add page# variable to a query), but keep the existing tournament array. Append the new tournaments to the array, then update the views/refresh the table view
