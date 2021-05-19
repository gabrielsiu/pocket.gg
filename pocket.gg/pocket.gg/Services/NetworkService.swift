//
//  NetworkService.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-02.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit
import Apollo

final class NetworkService {
    static func isAuthTokenValid(complete: @escaping (_ valid: Bool) -> Void) {
        ApolloService.shared.client.fetch(query: AuthTokenTestQuery(), queue: .global(qos: .utility)) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure: complete(false)
                case .success: complete(true)
                }
            }
        }
    }
    
    static func getTournamentsByVideogames(perPage: Int, pageNum: Int, featured: Bool = true, upcoming: Bool = true, gameIDs: [Int], complete: @escaping (_ tournaments: [Tournament]?) -> Void) {
        ApolloService.shared.client.fetch(query: TournamentsByVideogamesQuery(perPage: perPage,
                                                                              pageNum: pageNum,
                                                                              videogameIds: gameIDs.map { String($0) },
                                                                              featured: featured,
                                                                              upcoming: upcoming),
                                          queue: .global(qos: .utility)) { result in
            switch result {
            case .failure(let error):
                debugPrint(k.Error.apolloFetch, error as Any)
                DispatchQueue.main.async { complete(nil) }
                return
                
            case .success(let graphQLResult):
                var tournaments: [Tournament]?
                if let nodes = graphQLResult.data?.tournaments?.nodes {
                    tournaments = nodes.map({ (tournament) -> Tournament in
                        let start = DateFormatter.shared.dateFromTimestamp(tournament?.startAt)
                        let end = DateFormatter.shared.dateFromTimestamp(tournament?.endAt)
                        let date = start == end ? start : "\(start) - \(end)"
                        
                        let logo = tournament?.images?.reduce(("", 10), { (smallestImage, image) -> (String, Double) in
                            guard let url = image?.url else { return smallestImage }
                            guard let ratio = image?.ratio else { return smallestImage }
                            if ratio < smallestImage.1 { return (url, ratio) }
                            return smallestImage
                        })
                        
                        let header = tournament?.images?.reduce(("", 1), { (widestImage, image) -> (String, Double) in
                            guard let url = image?.url else { return widestImage }
                            guard let ratio = image?.ratio else { return widestImage }
                            if ratio > widestImage.1 { return (url, ratio) }
                            return widestImage
                        })
                        
                        return Tournament(id: Int(tournament?.id ?? "-1"),
                                          name: tournament?.name,
                                          date: date,
                                          logoUrl: logo?.0,
                                          isOnline: tournament?.isOnline,
                                          location: Location(address: tournament?.venueAddress),
                                          headerImage: header)
                    })
                }
                
                DispatchQueue.main.async { complete(tournaments) }
            }
        }
    }
    
    static func getTournamentDetailsById(id: Int, complete: @escaping (_ tournament: [String: Any?]?) -> Void) {
        ApolloService.shared.client.fetch(query: TournamentDetailsByIdQuery(id: "\(id)"), queue: .global(qos: .utility)) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(k.Error.apolloFetch, error as Any)
                DispatchQueue.main.async { complete(nil) }
                return
                
            case .success(let graphQLResult):
                guard let tournament = graphQLResult.data?.tournament else {
                    debugPrint(k.Error.tournamentFromId)
                    DispatchQueue.main.async { complete(nil) }
                    return
                }
                
                let events = tournament.events?.map({ (event) -> Event in
                    return Event(id: Int(event?.id ?? "-1"),
                                 name: event?.name,
                                 state: event?.state?.rawValue,
                                 winner: event?.standings?.nodes?[safe: 0]??.entrant?.name,
                                 startDate: event?.startAt,
                                 eventType: event?.type,
                                 videogameName: event?.videogame?.name,
                                 videogameImage: event?.videogame?.images?.compactMap { return ($0?.url, $0?.ratio) }.first)
                })
                
                let streams = tournament.streams?.map({ (stream) -> Stream in
                    return Stream(name: stream?.streamName,
                                  game: stream?.streamGame,
                                  logoUrl: stream?.streamLogo,
                                  sourceUrl: stream?.streamSource?.rawValue)
                })
                
                DispatchQueue.main.async {
                    complete(["venueName": tournament.venueName,
                              "longitude": tournament.lng,
                              "latitude": tournament.lat,
                              "events": events,
                              "streams": streams,
                              "registration": (tournament.isRegistrationOpen, tournament.registrationClosesAt),
                              "contact": (tournament.primaryContact, tournament.primaryContactType),
                              "slug": tournament.slug
                    
                    ])
                }
            }
        }
    }
    
    static func getEventById(id: Int, complete: @escaping (_ event: [String: Any?]?) -> Void) {
        ApolloService.shared.client.fetch(query: EventByIdQuery(id: "\(id)"), queue: .global(qos: .utility)) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(k.Error.apolloFetch, error as Any)
                DispatchQueue.main.async { complete(nil) }
                return
                
            case .success(let graphQLResult):
                var phases: [Phase]?
                if let eventPhases = graphQLResult.data?.event?.phases {
                    phases = eventPhases.map({ (phase) -> Phase in
                        return Phase(id: Int(phase?.id ?? "-1"),
                                     name: phase?.name,
                                     state: phase?.state?.rawValue,
                                     numPhaseGroups: phase?.groupCount,
                                     numEntrants: phase?.numSeeds,
                                     bracketType: phase?.bracketType?.rawValue)
                    })
                }
                
                var topStandings: [(name: String?, placement: Int?)]?
                if let nodes = graphQLResult.data?.event?.standings?.nodes {
                    topStandings = nodes.map { ($0?.entrant?.name, $0?.placement) }
                }
                
                let slug = graphQLResult.data?.event?.slug
                
                DispatchQueue.main.async {
                    complete(["phases": phases,
                              "topStandings": topStandings,
                              "slug": slug])
                }
            }
        }
    }
    
    static func getPhaseGroupsById(id: Int, numPhaseGroups: Int, complete: @escaping (_ phaseGroups: [PhaseGroup]?) -> Void) {
        ApolloService.shared.client.fetch(query: PhaseGroupsByIdQuery(id: "\(id)", perPage: numPhaseGroups),
                                          queue: .global(qos: .utility)) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(k.Error.apolloFetch, error as Any)
                DispatchQueue.main.async { complete(nil) }
                return
            
            case .success(let graphQLResult):
                var phaseGroups: [PhaseGroup]?
                if let nodes = graphQLResult.data?.phase?.phaseGroups?.nodes {
                    phaseGroups = nodes.map({ (phaseGroup) -> PhaseGroup in
                        return PhaseGroup(id: Int(phaseGroup?.id ?? "-1"),
                                          name: phaseGroup?.displayIdentifier,
                                          state: ActivityState.allCases[(phaseGroup?.state ?? 5) - 1].rawValue)
                    })
                }
                
                DispatchQueue.main.async { complete(phaseGroups) }
            }
        }
    }
    
    static func getPhaseGroupStandingsById(id: Int, complete: @escaping (_ standings: [String: Any?]?) -> Void) {
        ApolloService.shared.client.fetch(query: PhaseGroupStandingsByIdQuery(id: "\(id)"), queue: .global(qos: .utility)) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(k.Error.apolloFetch, error as Any)
                DispatchQueue.main.async { complete(nil) }
                return
            
            case .success(let graphQLResult):
                var progressionsOut: [Int]?
                if let nodes = graphQLResult.data?.phaseGroup?.progressionsOut {
                    progressionsOut = nodes.compactMap { $0?.originPlacement }
                }
                
                var standings: [(entrant: Entrant?, placement: Int?)]?
                if let nodes = graphQLResult.data?.phaseGroup?.standings?.nodes {
                    standings = nodes.map { (entrant: Entrant(id: Int($0?.entrant?.id ?? "-1"), name: $0?.entrant?.name), placement: $0?.placement) }
                }
                
                var sets: [PhaseGroupSet]?
                if let nodes = graphQLResult.data?.phaseGroup?.sets?.nodes {
                    sets = nodes.map({ (set) -> PhaseGroupSet in
                        var phaseGroupSet = PhaseGroupSet(id: Int(set?.id ?? "-1"),
                                                          state: ActivityState.allCases[(set?.state ?? 5) - 1].rawValue,
                                                          roundNum: set?.round ?? 0,
                                                          identifier: set?.identifier ?? "",
                                                          fullRoundText: set?.fullRoundText,
                                                          prevRoundIDs: set?.slots?.compactMap({ (slot) -> Int? in
                                                            guard let prevRoundID = slot?.prereqId else { return nil }
                                                            return Int(prevRoundID)
                                                          }),
                                                          entrants: nil)
                        
                        if let displayScore = set?.displayScore, let slots = set?.slots {
                            let entrantStrings = displayScore.components(separatedBy: " - ")
                            let entrants = slots.compactMap { slot -> (name: String, id: String)? in
                                guard let name = slot?.entrant?.name else { return nil }
                                guard let id = slot?.entrant?.id else { return nil }
                                return (name: name, id: id)
                            }
                            
                            phaseGroupSet.entrants = entrants.map {
                                for entrantString in entrantStrings where entrantString.contains($0.name) {
                                    guard let index = entrantString.lastIndex(of: " ") else {
                                        return (entrant: Entrant(id: Int($0.id), name: $0.name), score: nil)
                                    }
                                    return (entrant: Entrant(id: Int($0.id), name: $0.name),
                                            score: String(entrantString[index...]).trimmingCharacters(in: .whitespacesAndNewlines))
                                }
                                return (entrant: Entrant(id: Int($0.id), name: $0.name), score: nil)
                            }
                            
                        } else {
                            phaseGroupSet.entrants = set?.slots?.compactMap {
                                return (entrant: Entrant(id: Int($0?.entrant?.id ?? "-1"), name: $0?.entrant?.name), score: nil)
                            }
                        }
                        
                        return phaseGroupSet
                    })
                }
                
                DispatchQueue.main.async {
                    complete(["bracketType": graphQLResult.data?.phaseGroup?.bracketType?.rawValue,
                              "progressionsOut": progressionsOut,
                              "standings": standings,
                              "sets": sets])
                }
            }
        }
    }
    
    static func getPhaseGroupSets(id: Int, page: Int, complete: @escaping (_ sets: [PhaseGroupSet]?) -> Void) {
        ApolloService.shared.client.fetch(query: PhaseGroupSetsPageQuery(id: "\(id)", page: page), queue: .global(qos: .utility)) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(k.Error.apolloFetch, error as Any)
                DispatchQueue.main.async { complete(nil) }
                return
            
            case .success(let graphQLResult):
                var sets: [PhaseGroupSet]?
                if let nodes = graphQLResult.data?.phaseGroup?.sets?.nodes {
                    sets = nodes.map({ (set) -> PhaseGroupSet in
                        var phaseGroupSet = PhaseGroupSet(id: Int(set?.id ?? "-1"),
                                                          state: ActivityState.allCases[(set?.state ?? 5) - 1].rawValue,
                                                          roundNum: set?.round ?? 0,
                                                          identifier: set?.identifier ?? "",
                                                          fullRoundText: set?.fullRoundText,
                                                          prevRoundIDs: set?.slots?.compactMap({ (slot) -> Int? in
                                                            guard let prevRoundID = slot?.prereqId else { return nil }
                                                            return Int(prevRoundID)
                                                          }),
                                                          entrants: nil)
                        
                        if let displayScore = set?.displayScore, let slots = set?.slots {
                            let entrantStrings = displayScore.components(separatedBy: " - ")
                            let entrants = slots.compactMap { slot -> (name: String, id: String)? in
                                guard let name = slot?.entrant?.name else { return nil }
                                guard let id = slot?.entrant?.id else { return nil }
                                return (name: name, id: id)
                            }
                            
                            phaseGroupSet.entrants = entrants.map {
                                for entrantString in entrantStrings where entrantString.contains($0.name) {
                                    guard let index = entrantString.lastIndex(of: " ") else {
                                        return (entrant: Entrant(id: Int($0.id), name: $0.name), score: nil)
                                    }
                                    return (entrant: Entrant(id: Int($0.id), name: $0.name),
                                            score: String(entrantString[index...]).trimmingCharacters(in: .whitespacesAndNewlines))
                                }
                                return (entrant: Entrant(id: Int($0.id), name: $0.name), score: nil)
                            }
                            
                        } else {
                            phaseGroupSet.entrants = set?.slots?.compactMap {
                                return (entrant: Entrant(id: Int($0?.entrant?.id ?? "-1"), name: $0?.entrant?.name), score: nil)
                            }
                        }
                        
                        return phaseGroupSet
                    })
                }
                
                DispatchQueue.main.async { complete(sets) }
            }
        }
    }
    
    static func getImage(imageUrl: String?, complete: @escaping (_ image: UIImage?) -> Void) {
        guard let imageUrl = imageUrl else {
            complete(nil)
            return
        }
        if let cachedImage = ImageCacheService.getCachedImage(with: imageUrl) {
            complete(cachedImage)
            return
        } else {
            guard !imageUrl.isEmpty else {
                debugPrint(k.Error.emptyUrl)
                complete(nil)
                return
            }
            guard let url = URL(string: imageUrl) else {
                debugPrint(k.Error.urlGeneration, imageUrl)
                complete(nil)
                return
            }
            URLSession.shared.dataTask(with: url) { (data, _, error) in
                guard error == nil else {
                    debugPrint(k.Error.networkRequest, error as Any)
                    complete(nil)
                    return
                }
                guard let data = data else {
                    debugPrint(k.Error.missingData)
                    complete(nil)
                    return
                }
                guard let image = UIImage(data: data) else {
                    debugPrint(k.Error.imageFromData)
                    complete(nil)
                    return
                }
                ImageCacheService.saveImageToCache(image: image, with: imageUrl)
                complete(image)
            }.resume()
        }
    }
}
