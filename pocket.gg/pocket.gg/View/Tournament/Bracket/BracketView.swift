//
//  BracketView.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-12-07.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

enum InvalidBracketViewCause {
    case noEntrants
    case bracketNotStarted
    case bracketLayoutError
    case unsupportedBracketType
}

protocol BracketView: UIView {
    var sets: [PhaseGroupSet]? { get }
    var isValid: Bool { get }
    var invalidationCause: InvalidBracketViewCause? { get }
}
