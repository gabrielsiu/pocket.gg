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
    private var tournamentImage: UIImage?
    private var imageUrl = IMAGE_URL
    private var id = ""
    
    private var tournamentNames: [String] = []
    private var tournamentIDs: [Int] = []
    
    
    func getTournamentList(perPage: Int, pageNum: Int, videogameIds: [String], filters: [String: Bool], completion: @escaping CompletionHandler) {
        
        apollo.fetch(query: UpcomingTournamentsByVideogamesQuery(perPage: perPage, pageNum: pageNum, videogameIds: videogameIds, featured: filters["featured"], upcoming: filters["upcoming"])) { (result, error) in
            //Initial error check
            if error != nil {
                debugPrint("Error while fetching tournament data from smash.gg")
                debugPrint(error as Any)
                completion(false)
                return
            }

            //Get tournament nodes
            guard let nodes = result?.data?.tournaments?.nodes else {
                completion(false)
                debugPrint("Error while fetching tournament nodes")
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

                for (index, element) in gamesArray.enumerated() {
                    if index != (gamesArray.count - 1) {
                        self.gamesString.append("\(gamesDict[element] ?? "Invalid video game ID"), ")
                    } else {
                        self.gamesString.append("\(gamesDict[element] ?? "Invalid video game ID")")
                    }
                }
                
                //Tournament Dates
                let startDateDouble = Double(item?.startAt ?? "0")
                let endDateDouble = Double(item?.endAt ?? "0")
                
                let startDate = NSDate(timeIntervalSince1970: startDateDouble!).startFormattedISO8601
                let endDate = NSDate(timeIntervalSince1970: endDateDouble!).endFormattedISO8601
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
                        self.imageUrl = element?.url ?? IMAGE_URL
                    }
                }
                
                //Tournament ID
                self.id = (item?.id)!

                let tournament = Tournament(name: name, games: self.gamesString, date: self.dateString, imageName: self.imageUrl, id: self.id)
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
        tournamentImage = nil
        imageUrl = IMAGE_URL
        id = ""
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
