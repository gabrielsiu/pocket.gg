//
//  EventsDataService.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2019-05-06.
//  Copyright © 2019 Gabriel Siu. All rights reserved.
//

import Foundation

class EventsDataService {
    
    static let instance = EventsDataService()
    
    //Variables
    private var events = [Event]()
    private var videogameImageUrl: String = ""
    
    func getEvents(id: String, completion: @escaping CompletionHandler) {
        events.removeAll()
        
        apollo.fetch(query: EventsByIdQuery(id: id)) { (result, error) in
            //Initial error check
            if error != nil {
                debugPrint("Error while fetching tournament events from smash.gg")
                debugPrint(error as Any)
                completion(false)
                return
            }
            
            //Get events
            guard let events = result?.data?.tournaments?.nodes?[0]?.events else {
                debugPrint("Error while fetching events")
                completion(false)
                return
            }
            
            for item in events {
                //Event Name
                let name = item?.name ?? ""
                
                //Event Start Day/Time
                let startAt = String(item?.startAt as! Int)
                
                //Event Videogame ID
                let videogame = item?.videogameId ?? -1
                
                //URL of Event Videogame Photo
                if item?.videogame?.images?.isEmpty ?? true {
                    self.videogameImageUrl = IMAGE_URL
                } else {
                    self.videogameImageUrl = item?.videogame?.images?[0]?.url ?? IMAGE_URL
                }
                
                let event = Event(name: name, date: startAt, game: videogame, imageUrl: self.videogameImageUrl)
                self.events.append(event)
            }
        }
    }
}
