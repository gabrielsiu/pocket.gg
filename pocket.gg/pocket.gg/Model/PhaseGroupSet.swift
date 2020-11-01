//
//  PhaseGroupSet.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-09-10.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

struct PhaseGroupSet {
    let state: String?
    let roundNum: Int?
    let identifier: String?
    let fullRoundText: String?
    var entrants: [(name: String?, score: String?)]?
}
