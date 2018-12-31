//
//  Tournament.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2018-12-30.
//  Copyright © 2018 Gabriel Siu. All rights reserved.
//

import Foundation

struct Tournament {
    public private(set) var name: String!
    public private(set) var games: String!
    public private(set) var date: String!
    //public private(set) var image: UIImage!
    public private(set) var imageName: String!
    
    init(name: String, games: String, date: String,/* image: UIImage,*/ imageName: String) {
        self.name = name
        self.games = games
        self.date = date
        //self.image = image
        self.imageName = imageName
    }
}
