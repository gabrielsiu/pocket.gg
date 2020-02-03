//
//  Tournament.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-02.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import Foundation

struct Tournament {
    var name: String
    var imageUrl: String
    var date: String
    var id: Int
    var games: [Int]
    
    init(name: String, imageUrl: String, date: String, id: Int, games: [Int]) {
        self.name = name
        self.imageUrl = imageUrl
        self.date = date
        self.id = id
        self.games = games
    }
}
