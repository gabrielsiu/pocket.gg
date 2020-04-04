//
//  VideoGameDatabase.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-03-28.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import GRDB

enum VideoGameDatabaseError: Error {
    case appSupportDirURL
    case dbNotInAppBundle
}

struct VideoGameDatabase {
    static func openDatabase(atPath path: String) throws -> DatabaseQueue {
        return try DatabaseQueue(path: path)
    }
}
