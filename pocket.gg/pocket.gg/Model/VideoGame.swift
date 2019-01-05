//
//  VideoGame.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2019-01-04.
//  Copyright © 2019 Gabriel Siu. All rights reserved.
//

import Foundation

struct VideoGame {
    public private(set) var name: String!
    public private(set) var enabled: Bool!
    
    init(name: String, enabled: Bool) {
        self.name = name
        self.enabled = enabled
    }
}
