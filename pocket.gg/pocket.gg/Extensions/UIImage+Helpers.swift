//
//  UIImage+Helpers.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-03-07.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

extension UIImage {
    func resize(to newHeight: CGFloat) -> UIImage {
        guard newHeight < size.height else { return self }
        
        let newWidth = newHeight * (size.width / size.height)
        return UIGraphicsImageRenderer(size: CGSize(width: newWidth, height: newHeight)).image { _ in
            self.draw(in: CGRect(origin: .zero, size: CGSize(width: newWidth, height: newHeight)))
        }
    }
    
    func cropToRatio(_ newRatio: CGFloat, from oldRatio: CGFloat) -> UIImage {
        // If original image is more wide, then cropped version should retain the existing height
        // If original image is more tall, then cropped version should retain the existing width
        let newWidth  = newRatio > oldRatio ?                        size.width : size.width * newRatio / oldRatio
        let newHeight = newRatio > oldRatio ? size.height * newRatio / oldRatio : size.height
        let newX      = newRatio > oldRatio ?                                 0 : (size.width - newWidth) / 2
        let newY      = newRatio > oldRatio ?    -(size.height - newHeight) / 2 : 0
        
        guard let cropped = cgImage?.cropping(to: CGRect(x: newX, y: newY, width: newWidth, height: newHeight)) else { return self }
        return UIImage(cgImage: cropped)
    }
}
