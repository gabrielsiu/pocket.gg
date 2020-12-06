//
//  SetPathView.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-12-05.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

class SetPathView: UIView {
    let numPrecedingSets: Int
    
    // MARK: - Initialization
    
    init(numPrecedingSets: Int) {
        self.numPrecedingSets = numPrecedingSets
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        
        if numPrecedingSets == 1 {
            linePath.move(to: CGPoint(x: rect.minX, y: rect.minY + floor(k.Sizes.setHeight / 2)))
            linePath.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + floor(k.Sizes.setHeight / 2)))
        } else if numPrecedingSets == 2 {
            // 1
            linePath.move(to: CGPoint(x: rect.minX, y: rect.minY + floor(k.Sizes.setHeight / 2)))
            linePath.addLine(to: CGPoint(x: rect.minX + floor(rect.width / 2), y: rect.minY + floor(k.Sizes.setHeight / 2)))

            // 2
            linePath.move(to: CGPoint(x: rect.minX, y: rect.maxY - floor(k.Sizes.setHeight / 2)))
            linePath.addLine(to: CGPoint(x: rect.minX + floor(rect.width / 2), y: rect.maxY - floor(k.Sizes.setHeight / 2)))
            
            // 3
            linePath.move(to: CGPoint(x: rect.minX + floor(rect.width / 2), y: rect.minY + floor(k.Sizes.setHeight / 2)))
            linePath.addLine(to: CGPoint(x: rect.minX + floor(rect.width / 2), y: rect.maxY - floor(k.Sizes.setHeight / 2)))
            
            // 4
            linePath.move(to: CGPoint(x: rect.minX + floor(rect.width / 2), y: rect.minY + floor(rect.height / 2)))
            linePath.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + floor(rect.height / 2)))
        }
        
        line.path = linePath.cgPath
        line.strokeColor = UIColor.black.cgColor
        line.lineWidth = 3
        line.lineCap = .round
        layer.addSublayer(line)
    }
}
