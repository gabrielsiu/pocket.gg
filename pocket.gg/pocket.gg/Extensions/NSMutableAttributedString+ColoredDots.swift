//
//  NSMutableAttributedString+ColoredDots.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-08-26.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    static func addColoredDotToText(_ string: String, dotColor: UIColor) -> NSMutableAttributedString {
        let stringWithDot = "● " + string
        let coloredDot = NSMutableAttributedString(string: stringWithDot, attributes: nil)
        coloredDot.addAttribute(.foregroundColor, value: dotColor, range: NSRange(location: 0, length: 1))
        return coloredDot
    }
}
