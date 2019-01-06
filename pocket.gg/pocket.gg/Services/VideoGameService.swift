//
//  VideoGameService.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2019-01-06.
//  Copyright © 2019 Gabriel Siu. All rights reserved.
//

import Foundation

class VideoGameService {
    static let instance = VideoGameService()
    
    func getKey(for value: String) -> Int {
        //Find the corresponding key for a game name from gamesDict. An array is returned, though each video game name should only have 1 key mapped to it
        let gameKeyArray = (gamesDict as NSDictionary).allKeys(for: value) as! [Int]
        if gameKeyArray.isEmpty {
            debugPrint("Error with video game names")
            return -1
        }
        if gameKeyArray.count != 1 {
            debugPrint("Error with video game names")
            return -1
        }
        var gameKey: Int = 0
        for element in gameKeyArray {
            gameKey += element
        }
        return gameKey
    }
}
