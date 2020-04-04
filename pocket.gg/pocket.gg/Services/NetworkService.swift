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
                guard let nodes = graphQLResult.data?.tournaments?.nodes else {
                    debugPrint(k.Error.tournamentNodes)
                    complete(nil)
                    return
                }
                
                var tournaments = [Tournament]()
                for event in nodes {
                    let name = event?.name ?? ""
                    let id = Int(event?.id ?? "6") ?? 6
                    let start = DateFormatter.shared.dateFromTimestamp(event?.startAt)
                    let end = DateFormatter.shared.dateFromTimestamp(event?.endAt)
                    let date = start == end ? start : "\(start) - \(end)"
                    
                    let logo = event?.images?.reduce(("", 10), { (smallestImage, image) -> (String, Double) in
                        guard let url = image?.url else { return smallestImage }
                        guard let ratio = image?.ratio else { return smallestImage }
                        if ratio < smallestImage.1 { return (url, ratio) }
                        return smallestImage
                    })
                    
                    let header = event?.images?.reduce(("", 1), { (widestImage, image) -> (String, Double) in
                        guard let url = image?.url else { return widestImage }
                        guard let ratio = image?.ratio else { return widestImage }
                        if ratio > widestImage.1 { return (url, ratio) }
                        return widestImage
                    })
                    
                    tournaments.append(Tournament(name: name,
                                                  logoUrl: logo?.0 ?? "",
                                                  date: date,
                                                  id: id, headerImage: header ?? ("", 0)))
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
                
                let events = tournament.events?.compactMap({ (event) -> Tournament.Event? in
                    guard let event = event else { return nil }
                    var id: Int?
                    if let unwrappedId = event.id { id = Int(unwrappedId) }
                    return Tournament.Event(name: event.name,
                                            startDate: event.startAt,
                                            id: id,
                                            videogameImage: event.videogame?.images?.compactMap { return ($0?.url, $0?.ratio) }.first)
                })
                let streams = tournament.streams?.compactMap({ (stream) -> Tournament.Stream? in
                    guard let stream = stream else { return nil }
                    return Tournament.Stream(name: stream.streamName,
                                             game: stream.streamGame,
                                             logoUrl: stream.streamLogo,
                                             sourceUrl: stream.streamSource?.rawValue)
                })
                
                complete(["location": Tournament.Location(venueName: tournament.venueName,
                                                          address: tournament.venueAddress,
                                                          longitude: tournament.lng,
                                                          latitude: tournament.lat),
                          "contact": tournament.primaryContact,
                          "events": events,
                          "streams": streams,
                          "registration": (tournament.isRegistrationOpen, tournament.registrationClosesAt),
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
                guard let nodes = graphQLResult.data?.event?.standings?.nodes else {
                    debugPrint(k.Error.standingsNodes)
                    complete(nil)
                    return
                }
                var topStandings = [(name: String?, placement: Int?)]()
                for standing in nodes {
                    topStandings.append((standing?.entrant?.name, standing?.placement))
                }
                // At the moment, the smash.gg API returns a slug with 'event' instead of 'events', leading to an incorrect URL
                let slug = graphQLResult.data?.event?.slug?.replacingOccurrences(of: "event", with: "events")
                complete(["topStandings": topStandings,
                          "slug": slug])
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
