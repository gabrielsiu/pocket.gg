//
//  VideoGameCell.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2019-01-03.
//  Copyright © 2019 Gabriel Siu. All rights reserved.
//

import UIKit

class VideoGameCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var videoGameName: UILabel!
    @IBOutlet weak var videoGameSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let maxWidth = UIScreen.main.bounds.size.width - 30 - videoGameSwitch.frame.width
        videoGameName.preferredMaxLayoutWidth = maxWidth
        // Initialization code
    }
    
    func updateView(videoGame: VideoGame) {
        self.videoGameName.text = videoGame.name
        self.videoGameSwitch.isOn = videoGame.enabled
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
