//
//  PreferredGamesService.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2021-05-08.
//  Copyright © 2021 Gabriel Siu. All rights reserved.
//

import UIKit

final class PreferredGamesService {
    static func getEnabledGames() -> [VideoGame] {
        var videoGames = [VideoGame]()
        if let data = UserDefaults.standard.data(forKey: k.UserDefaults.preferredVideoGames) {
            do {
                videoGames = try PropertyListDecoder().decode([VideoGame].self, from: data)
            } catch {
                print(error.localizedDescription)
                return []
            }
        }
        return videoGames
    }
    
    static func updateEnabledGames(_ games: [VideoGame]) {
        do {
            UserDefaults.standard.set(try PropertyListEncoder().encode(games), forKey: k.UserDefaults.preferredVideoGames)
        } catch {
            print(error.localizedDescription)
        }
    }
}
