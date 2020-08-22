//
//  VideoGame.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-26.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import Foundation
import GRDB

struct VideoGame: Codable, FetchableRecord, MutablePersistableRecord {
    let id: Int
    let name: String
}
