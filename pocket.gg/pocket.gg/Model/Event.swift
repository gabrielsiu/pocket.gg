//
//  Event.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2019-05-06.
//  Copyright © 2019 Gabriel Siu. All rights reserved.
//

import Foundation

struct Event {
    public private(set) var name: String!
    public private(set) var date: String!
    public private(set) var game: Int!
    public private(set) var imageUrl: String!
    
    init(name: String, date: String, game: Int, imageUrl: String) {
        self.name = name
        self.date = date
        self.game = game
        self.imageUrl = imageUrl
    }
}
