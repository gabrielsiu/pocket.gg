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
                var tournaments = [Tournament]()
                if let nodes = graphQLResult.data?.tournaments?.nodes {
                    tournaments = nodes.map {
                        let start = DateFormatter.shared.dateFromTimestamp($0?.startAt)
                        let end = DateFormatter.shared.dateFromTimestamp($0?.endAt)
                        let date = start == end ? start : "\(start) - \(end)"
                        
                        let logo = $0?.images?.reduce(("", 10), { (smallestImage, image) -> (String, Double) in
                            guard let url = image?.url else { return smallestImage }
                            guard let ratio = image?.ratio else { return smallestImage }
                            if ratio < smallestImage.1 { return (url, ratio) }
                            return smallestImage
                        })
                        
                        let header = $0?.images?.reduce(("", 1), { (widestImage, image) -> (String, Double) in
                            guard let url = image?.url else { return widestImage }
                            guard let ratio = image?.ratio else { return widestImage }
                            if ratio > widestImage.1 { return (url, ratio) }
                            return widestImage
                        })
                        
                        return Tournament(id: Int($0?.id ?? "-1"),
                                          name: $0?.name,
                                          date: date,
                                          logoUrl: logo?.0,
                                          isOnline: $0?.isOnline,
                                          location: Location(address: $0?.venueAddress),
                                          headerImage: header)
                    }
                }
                DispatchQueue.main.async { complete(tournaments) }
            }
        }
    }
    
    static func searchForTournaments(_ search: String?, gameIDs: [Int], featured: Bool, sortBy: String, perPage: Int, page: Int, complete: @escaping (_ tournaments: [Tournament]?) -> Void) {
        ApolloService.shared.client.fetch(query: SearchForTournamentsQuery(search: search,
                                                                           videogameIds: gameIDs.map { String($0) },
                                                                           featured: featured,
                                                                           sortBy: sortBy,
                                                                           perPage: perPage,
                                                                           page: page),
                                          queue: .global(qos: .utility)) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(k.Error.apolloFetch, error as Any)
                DispatchQueue.main.async { complete(nil) }
                return
                
            case .success(let graphQLResult):
                var tournaments = [Tournament]()
                if let nodes = graphQLResult.data?.tournaments?.nodes {
                    tournaments = nodes.map {
                        let start = DateFormatter.shared.dateFromTimestamp($0?.startAt)
                        let end = DateFormatter.shared.dateFromTimestamp($0?.endAt)
                        let date = start == end ? start : "\(start) - \(end)"
                        
                        let logo = $0?.images?.reduce(("", 10), { (smallestImage, image) -> (String, Double) in
                            guard let url = image?.url else { return smallestImage }
                            guard let ratio = image?.ratio else { return smallestImage }
                            if ratio < smallestImage.1 { return (url, ratio) }
                            return smallestImage
                        })
                        
                        let header = $0?.images?.reduce(("", 1), { (widestImage, image) -> (String, Double) in
                            guard let url = image?.url else { return widestImage }
                            guard let ratio = image?.ratio else { return widestImage }
                            if ratio > widestImage.1 { return (url, ratio) }
                            return widestImage
                        })
                        
                        return Tournament(id: Int($0?.id ?? "-1"),
                                          name: $0?.name,
                                          date: date,
                                          logoUrl: logo?.0,
                                          isOnline: $0?.isOnline,
                                          location: Location(address: $0?.venueAddress),
                                          headerImage: header)
                    }
                }
                DispatchQueue.main.async { complete(tournaments) }
            }
        }
    }
    
    static func getTournamentDetails(_ id: Int, complete: @escaping (_ tournament: [String: Any?]?) -> Void) {
        ApolloService.shared.client.fetch(query: TournamentDetailsQuery(id: "\(id)"), queue: .global(qos: .utility)) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(k.Error.apolloFetch, error as Any)
                DispatchQueue.main.async { complete(nil) }
                return
                
            case .success(let graphQLResult):
                guard let tournament = graphQLResult.data?.tournament else {
                    DispatchQueue.main.async { complete(nil) }
                    return
                }
                
                var events = [Event]()
                if let tournamentEvents = tournament.events {
                    events = tournamentEvents.map {
                        Event(id: Int($0?.id ?? "-1"),
                                     name: $0?.name,
                                     state: $0?.state?.rawValue,
                                     winner: EntrantService.getEventWinner($0),
                                     startDate: $0?.startAt,
                                     eventType: $0?.type,
                                     videogameName: $0?.videogame?.name,
                                     videogameImage: $0?.videogame?.images?.compactMap { return ($0?.url, $0?.ratio) }.first)
                    }
                }
                
                var streams = [Stream]()
                if let tournamentStreams = tournament.streams {
                    streams = tournamentStreams.map {
                        Stream(name: $0?.streamName,
                               logoUrl: $0?.streamLogo,
                               sourceUrl: $0?.streamSource?.rawValue)
                    }
                }
                
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
    
    static func getEvent(_ id: Int, complete: @escaping (_ event: [String: Any?]?) -> Void) {
        ApolloService.shared.client.fetch(query: EventQuery(id: "\(id)"), queue: .global(qos: .utility)) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(k.Error.apolloFetch, error as Any)
                DispatchQueue.main.async { complete(nil) }
                return
                
            case .success(let graphQLResult):
                var phases = [Phase]()
                if let eventPhases = graphQLResult.data?.event?.phases {
                    phases = eventPhases.map {
                        return Phase(id: Int($0?.id ?? "-1"),
                                     name: $0?.name,
                                     state: $0?.state?.rawValue,
                                     numPhaseGroups: $0?.groupCount,
                                     numEntrants: $0?.numSeeds,
                                     bracketType: $0?.bracketType?.rawValue)
                    }
                }
                
                var topStandings = [(entrant: Entrant?, placement: Int?)]()
                if let nodes = graphQLResult.data?.event?.standings?.nodes {
                    topStandings = nodes.compactMap { EntrantService.getEntrantAndStanding($0) }
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
    
    static func getPhaseGroups(_ id: Int, numPhaseGroups: Int, complete: @escaping (_ phaseGroups: [PhaseGroup]?) -> Void) {
        ApolloService.shared.client.fetch(query: PhaseGroupsQuery(id: "\(id)", perPage: numPhaseGroups),
                                          queue: .global(qos: .utility)) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(k.Error.apolloFetch, error as Any)
                DispatchQueue.main.async { complete(nil) }
                return
            
            case .success(let graphQLResult):
                var phaseGroups = [PhaseGroup]()
                if let nodes = graphQLResult.data?.phase?.phaseGroups?.nodes {
                    phaseGroups = nodes.map {
                        return PhaseGroup(id: Int($0?.id ?? "-1"),
                                          name: $0?.displayIdentifier,
                                          state: ActivityState.allCases[($0?.state ?? 5) - 1].rawValue)
                    }
                }
                DispatchQueue.main.async { complete(phaseGroups) }
            }
        }
    }
    
    static func getPhaseGroup(_ id: Int, complete: @escaping (_ phaseGroup: [String: Any?]?) -> Void) {
        ApolloService.shared.client.fetch(query: PhaseGroupQuery(id: "\(id)"), queue: .global(qos: .utility)) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(k.Error.apolloFetch, error as Any)
                DispatchQueue.main.async { complete(nil) }
                return
            
            case .success(let graphQLResult):
                var progressionsOut = [Int]()
                if let nodes = graphQLResult.data?.phaseGroup?.progressionsOut {
                    progressionsOut = nodes.compactMap { $0?.originPlacement }
                }
                
                var standings = [(entrant: Entrant?, placement: Int?)]()
                if let nodes = graphQLResult.data?.phaseGroup?.standings?.nodes {
                    standings = nodes.compactMap { EntrantService.getEntrantAndStanding2($0) }
                }
                
                var sets = [PhaseGroupSet]()
                if let nodes = graphQLResult.data?.phaseGroup?.sets?.nodes {
                    sets = nodes.map {
                        var phaseGroupSet = PhaseGroupSet(id: Int($0?.id ?? "-1"),
                                                          state: ActivityState.allCases[($0?.state ?? 5) - 1].rawValue,
                                                          roundNum: $0?.round ?? 0,
                                                          identifier: $0?.identifier ?? "",
                                                          fullRoundText: $0?.fullRoundText,
                                                          prevRoundIDs: $0?.slots?.compactMap {
                                                            guard let prevRoundID = $0?.prereqId else { return nil }
                                                            return Int(prevRoundID)
                                                          },
                                                          entrants: nil)
                        phaseGroupSet.entrants = EntrantService.getEntrantsForSet(displayScore: $0?.displayScore,
                                                                                  winnerID: $0?.winnerId,
                                                                                  slots: $0?.slots)
                        return phaseGroupSet
                    }
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
    
    static func getPhaseGroupSetGames(_ id: Int, complete: @escaping (_ games: [PhaseGroupSetGame]?) -> Void) {
        ApolloService.shared.client.fetch(query: PhaseGroupSetGamesQuery(id: "\(id)"), queue: .global(qos: .utility)) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(k.Error.apolloFetch, error as Any)
                DispatchQueue.main.async { complete(nil) }
                return
            
            case .success(let graphQLResult):
                var games = [PhaseGroupSetGame]()
                if let nodes = graphQLResult.data?.set?.games {
                    games = nodes.map { PhaseGroupSetGame(winnerID: $0?.winnerId, stageName: $0?.stage?.name) }
                }
                DispatchQueue.main.async { complete(games) }
            }
        }
    }
    
    // MARK: - Remaining Standings & Sets
    
    static func getPhaseGroupStandings(_ id: Int, page: Int, complete: @escaping (_ standings: [(entrant: Entrant?, placement: Int?)]?) -> Void) {
        ApolloService.shared.client.fetch(query: PhaseGroupStandingsPageQuery(id: "\(id)", page: page), queue: .global(qos: .utility)) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(k.Error.apolloFetch, error as Any)
                DispatchQueue.main.async { complete(nil) }
                return
                
            case .success(let graphQLResult):
                var standings = [(entrant: Entrant?, placement: Int?)]()
                if let nodes = graphQLResult.data?.phaseGroup?.standings?.nodes {
                    standings = nodes.compactMap { EntrantService.getEntrantAndStanding3($0) }
                }
                DispatchQueue.main.async { complete(standings) }
            }
        }
    }
    
    static func getPhaseGroupSets(_ id: Int, page: Int, complete: @escaping (_ sets: [PhaseGroupSet]?) -> Void) {
        ApolloService.shared.client.fetch(query: PhaseGroupSetsPageQuery(id: "\(id)", page: page), queue: .global(qos: .utility)) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(k.Error.apolloFetch, error as Any)
                DispatchQueue.main.async { complete(nil) }
                return
            
            case .success(let graphQLResult):
                var sets = [PhaseGroupSet]()
                if let nodes = graphQLResult.data?.phaseGroup?.sets?.nodes {
                    sets = nodes.map {
                        var phaseGroupSet = PhaseGroupSet(id: Int($0?.id ?? "-1"),
                                                          state: ActivityState.allCases[($0?.state ?? 5) - 1].rawValue,
                                                          roundNum: $0?.round ?? 0,
                                                          identifier: $0?.identifier ?? "",
                                                          fullRoundText: $0?.fullRoundText,
                                                          prevRoundIDs: $0?.slots?.compactMap({ (slot) -> Int? in
                                                            guard let prevRoundID = slot?.prereqId else { return nil }
                                                            return Int(prevRoundID)
                                                          }),
                                                          entrants: nil)
                        phaseGroupSet.entrants = EntrantService.getEntrantsForSet2(displayScore: $0?.displayScore,
                                                                                   winnerID: $0?.winnerId,
                                                                                   slots: $0?.slots)
                        return phaseGroupSet
                    }
                }
                DispatchQueue.main.async { complete(sets) }
            }
        }
    }
    
    // MARK: - Image Fetching
    
    static func getImage(imageUrl: String?, cache: Cache = .regular, newSize: CGSize? = nil, complete: @escaping (_ image: UIImage?) -> Void) {
        guard let imageUrl = imageUrl else {
            complete(nil)
            return
        }
        if let cachedImage = ImageCacheService.getCachedImage(with: imageUrl, cache: cache) {
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
                
                let finalImage: UIImage
                if let newSize = newSize {
                    if newSize.width.isZero && newSize.height.isZero {
                        finalImage = image
                    } else if newSize.width.isZero {
                        finalImage = image.resize(toHeight: newSize.height)
                    } else if newSize.height.isZero {
                        finalImage = image.resize(toWidth: newSize.width)
                    } else {
                        finalImage = image.resize(toSize: newSize)
                    }
                } else {
                    finalImage = image
                }
                ImageCacheService.saveImageToCache(image: finalImage, with: imageUrl, cache: cache)
                complete(finalImage)
            }.resume()
        }
    }
}
