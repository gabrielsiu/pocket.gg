//
//  SubtitleCell.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-03-14.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

class SubtitleCell: UITableViewCell {
    
    var imageViewFrame: CGRect? = nil
    var textLabelFrame: CGRect? = nil
    var detailTextLabelFrame: CGRect? = nil
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let imageViewFrame = imageViewFrame {
            imageView?.frame = imageViewFrame
        } else {
            imageViewFrame = imageView?.frame
        }
        if let textLabelFrame = textLabelFrame {
            textLabel?.updateWidth(oldFrame: textLabelFrame, newFrame: textLabel?.frame)
        } else {
            textLabelFrame = textLabel?.frame
        }
        if let detailTextLabelFrame = detailTextLabelFrame {
            detailTextLabel?.updateWidth(oldFrame: detailTextLabelFrame, newFrame: detailTextLabel?.frame)
        } else {
            detailTextLabelFrame = detailTextLabel?.frame
        }
    }
    
    func updateView(text: String?, imageInfo: (url: String?, ratio: Double?)?, detailText: String?, placeholderName: String, newRatio: CGFloat? = nil) {
        textLabel?.text = text
        detailTextLabel?.text = detailText
        NetworkService.getImage(imageUrl: imageInfo?.url) { [weak self] (image) in
            
            guard let image = image else {
                DispatchQueue.main.async {
                    // TODO: Currently observing that when a cell gets dequeued and the image is nil, the imageView of the cell takes on an image from another cell. If it's possible to fix this behaviour, then we don't need to explicitly set the image to the placeholder again.
                    self?.imageView?.image = UIImage(named: placeholderName)
                }
                return
            }
            // TODO: If possible, find a way to crop the image to the exact same size as the placeholder (currently, some of the text labels' frames are being slightly shifting upon the cell being tapped)
            var finalImage: UIImage?
            if let newRatio = newRatio, let prevRatio = imageInfo?.ratio {
                finalImage = image.cropToRatio(newRatio, from: CGFloat(prevRatio))
            } else {
                finalImage = image
            }
            DispatchQueue.main.async {
                self?.imageView?.image = finalImage
            }
        }
    }
}

private extension UILabel {
    func updateWidth(oldFrame: CGRect, newFrame: CGRect?) {
        if let newWidth = newFrame?.width, newWidth > oldFrame.width {
            frame = CGRect(x: frame.minX, y: frame.minY, width: newWidth, height: frame.height)
        } else {
            frame = oldFrame
        }
    }
}
