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
        apollo.fetch(query: AuthTokenTestQuery()) { result in
            switch result {
            case .failure: complete(false)
            case .success: complete(true)
            }
        }
    }
    
    static func getTournamentsByVideogames(pageNum: Int, complete: @escaping (_ tournaments: [Tournament]?) -> Void) {
        let videogameIDs = UserDefaults.standard.array(forKey: k.UserDefaults.preferredVideoGames) as? [Int] ?? [1]
        let featured = UserDefaults.standard.bool(forKey: k.UserDefaults.featuredTournaments)
        let upcoming = UserDefaults.standard.bool(forKey: k.UserDefaults.upcomingTournaments)
        
        apollo.fetch(query: TournamentsByVideogamesQuery(perPage: 10,
                                                         pageNum: 1,
                                                         videogameIds: videogameIDs.map { String($0) },
                                                         featured: featured,
                                                         upcoming: upcoming)) { result in
            switch result {
            case .failure(let error):
                debugPrint(k.Error.apolloFetch, error as Any)
                complete(nil)
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
                                          location: Location(address: tournament?.venueAddress),
                                          isOnline: tournament?.isOnline,
                                          headerImage: header)
                    })
                }
                
                complete(tournaments)
            }
        }
    }
    
    static func getTournamentDetailsById(id: Int, complete: @escaping (_ tournament: [String: Any?]?) -> Void) {
        apollo.fetch(query: TournamentDetailsByIdQuery(id: "\(id)")) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(k.Error.apolloFetch, error as Any)
                complete(nil)
                return
                
            case .success(let graphQLResult):
                guard let tournament = graphQLResult.data?.tournament else {
                    debugPrint(k.Error.tournamentFromId)
                    complete(nil)
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
                
                complete(["venueName": tournament.venueName,
                          "longitude": tournament.lng,
                          "latitude": tournament.lat,
                          "events": events,
                          "streams": streams,
                          "registration": (tournament.isRegistrationOpen, tournament.registrationClosesAt),
                          "contactInfo": tournament.primaryContact,
                          "slug": tournament.slug
                
                ])
            }
        }
    }
    
    static func getEventById(id: Int, complete: @escaping (_ event: [String: Any?]?) -> Void) {
        apollo.fetch(query: EventByIdQuery(id: "\(id)")) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(k.Error.apolloFetch, error as Any)
                complete(nil)
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
                
                complete(["phases": phases,
                          "topStandings": topStandings,
                          "slug": slug])
            }
        }
    }
    
    static func getPhaseGroupsById(id: Int, numPhaseGroups: Int, complete: @escaping (_ phaseGroups: [PhaseGroup]?) -> Void) {
        apollo.fetch(query: PhaseGroupsByIdQuery(id: "\(id)", perPage: numPhaseGroups)) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(k.Error.apolloFetch, error as Any)
                complete(nil)
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
                
                complete(phaseGroups)
            }
        }
    }
    
    static func getPhaseGroupStandingsById(id: Int, complete: @escaping (_ standings: [String: Any?]?) -> Void) {
        apollo.fetch(query: PhaseGroupStandingsByIdQuery(id: "\(id)")) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(k.Error.apolloFetch, error as Any)
                complete(nil)
                return
            
            case .success(let graphQLResult):
                var progressionsOut: [Int]?
                if let nodes = graphQLResult.data?.phaseGroup?.progressionsOut {
                    progressionsOut = nodes.compactMap { $0?.originPlacement }
                }
                
                var standings: [(name: String?, placement: Int?)]?
                if let nodes = graphQLResult.data?.phaseGroup?.standings?.nodes {
                    standings = nodes.map { (name: $0?.entrant?.name, placement: $0?.placement) }
                }
                
                var sets: [PhaseGroupSet]?
                if let nodes = graphQLResult.data?.phaseGroup?.sets?.nodes {
                    sets = nodes.map { PhaseGroupSet(state: ActivityState.allCases[($0?.state ?? 5) - 1].rawValue,
                                                     roundNum: $0?.round,
                                                     identifier: $0?.identifier,
                                                     fullRoundText: $0?.fullRoundText,
                                                     displayScore: $0?.displayScore,
                                                     entrant1: (name: $0?.slots?[safe: 0]??.entrant?.name, score: nil),
                                                     entrant2: (name: $0?.slots?[safe: 1]??.entrant?.name, score: nil))
                    }
                }
                
                complete(["progressionsOut": progressionsOut,
                          "standings": standings,
                          "sets": sets])
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
