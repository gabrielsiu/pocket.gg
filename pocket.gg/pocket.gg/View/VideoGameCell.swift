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

    @IBAction func videoGameToggled(_ sender: Any) {
        var preferredArray: [Int] = DefaultsService.instance.preferredGames
        
        //Get the key associated with the video game name selected
        let key = VideoGameService.instance.getKey(for: self.videoGameName.text ?? "Error video game")
        if key == -1 {
            return
        }
        
        if preferredArray.contains(key) {
            //Untoggling a game: if the game is already in the preferred games array & the switch is toggled
            var gameIndex: Int = 0
            //Get the index of the key already in the preferred games array
            for element in preferredArray {
                if element == key {
                    break
                }
                gameIndex = gameIndex + 1
            }
            //Remove the game from the preferred games array
            preferredArray.remove(at: gameIndex)
        } else {
            //Toggling a game: if the game isn't already in the preferred games array & the switch is toggled
            if preferredArray.isEmpty {
                preferredArray.append(key)
            } else {
                var gameIndex: Int = 0
                //Loop through the preferred games array, inserting the new key if it belongs somewhere in the array
                for element in preferredArray {
                    if key < element {
                        preferredArray.insert(key, at: gameIndex)
                        break
                    }
                    gameIndex = gameIndex + 1
                }
                //If the new key belongs at the end of the array, just append it
                if gameIndex == preferredArray.count {
                    preferredArray.append(key)
                }
            }
        }
        //Save the new preferred games array to the user defaults
        DefaultsService.instance.preferredGames = preferredArray
        preferredArray.removeAll()
        print("now default array is \(DefaultsService.instance.preferredGames)")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
