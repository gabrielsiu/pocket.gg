//
//  TournamentDataService.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2018-12-26.
//  Copyright © 2018 Gabriel Siu. All rights reserved.
//

import Foundation
import Apollo

class TournamentDataService {
    
    static let instance = TournamentDataService()
    
    //Variables
    private var tournaments = [Tournament]()
    private var unsortedArray: [Int] = []
    private var gamesString = ""
    private var dateString = ""
    private var tournamentImage = UIImage()
    private var imageUrl = "https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/Smash_Ball.png/200px-Smash_Ball.png"
    
    
    func getTournamentList(perPage: Int, pageNum: Int, videogameIds: [Int], filters: [String: Bool], completion: @escaping CompletionHandler) {
        
        apollo.fetch(query: UpcomingTournamentsByVideogamesQuery(perPage: perPage, pageNum: pageNum, videogameIds: videogameIds, featured: filters["featured"], upcoming: filters["upcoming"])) { (result, error) in
            //Initial error check
            if error != nil {
                debugPrint("Error while fetching tournament data from smash.gg")
                completion(false)
                return
            }
            
            //Get tournament nodes
            guard let nodes = result?.data?.tournaments?.nodes else {
                completion(false)
                print("Error while fetching tournament nodes")
                return
            }

            for item in nodes {
                //Tournament Name
                let name = item?.name ?? "Error tournament"
                
                //Tournament Games
                guard let events = item?.events else {
                    completion(false)
                    debugPrint("Error while fetching events from the tournament")
                    return
                }
                for element in events {
                    self.unsortedArray.append(element?.videogameId ?? 0)
                }
                let gamesArray = Array(Set(self.unsortedArray)).sorted()
                //Later, get the actual list of video games instead of just their IDs
                for (index, element) in gamesArray.enumerated() {
                    if index != (gamesArray.count - 1) {
                        self.gamesString.append("\(element), ")
                    } else {
                        self.gamesString.append("\(element)")
                    }
                }
                
                //Tournament Dates
                let startDate = NSDate(timeIntervalSince1970: Double(item?.startAt ?? 0)).startFormattedISO8601
                let endDate = NSDate(timeIntervalSince1970: Double(item?.endAt ?? 0)).endFormattedISO8601
                self.dateString = startDate + endDate
                
                //Tournament Logo URL
                guard let images = item?.images else {
                    completion(false)
                    debugPrint("Error while fetching images for the tournament")
                    return
                }
                
                var lowestRatio = 10.0
                for element in images {
                    let ratio = element?.ratio ?? 10.0
                    if ratio < lowestRatio {
                        lowestRatio = ratio
                        self.imageUrl = element?.url ?? "https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/Smash_Ball.png/200px-Smash_Ball.png"
                    }
                }

                let tournament = Tournament(name: name, games: self.gamesString, date: self.dateString, imageName: self.imageUrl)
                self.tournaments.append(tournament)
                self.resetTournamentInfo()
            }
            completion(true)
        }
    }
    
    func getTournaments() -> [Tournament] {
        return tournaments
    }

    func clearTournaments() {
        tournaments.removeAll()
    }
    
    func resetTournamentInfo() {
        unsortedArray.removeAll()
        gamesString = ""
        dateString = ""
        imageUrl = "https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/Smash_Ball.png/200px-Smash_Ball.png"
    }
 
}

//Date Formatter
extension NSDate {
    var startFormattedISO8601: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd-"
        return formatter.string(from: self as Date)
    }
    var endFormattedISO8601: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd, yyyy"
        return formatter.string(from: self as Date)
    }
}
