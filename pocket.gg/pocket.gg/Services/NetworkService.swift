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
    
    public static func getTournamentsByVideogames(pageNum: Int, complete: @escaping (_ tournaments: [Tournament]?) -> Void) {
        // TODO: Modify function & query to read video game IDs and other parameters from UserDefaults
        apollo.fetch(query: TournamentsByVideogamesQuery(perPage: 10, pageNum: 1, videogameIds: ["1"], featured: true, upcoming: true)) { result in
            switch result {
            case .failure(let error):
                debugPrint(apolloFetchError, error as Any)
                complete(nil)
                return
            case .success(let graphQLResult):
                var tournaments = [Tournament]()
                
                guard let nodes = graphQLResult.data?.tournaments?.nodes else {
                    debugPrint(nodesError)
                    complete(nil)
                    return
                }
                
                for event in nodes {
                    let name = event?.name ?? ""
                    let id = Int(event?.id ?? "6") ?? 6
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    let start = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(event?.startAt ?? "0") ?? 0))
                    let end = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(event?.endAt ?? "3137983740") ?? 3137983740))
                    
                    let logo = event?.images?.reduce(("", 10), { (smallestImage, image) -> (String, Double) in
                        guard let url = image?.url else { return smallestImage }
                        guard let ratio = image?.ratio else { return smallestImage }
                        if ratio < smallestImage.1 {
                            return (url, ratio)
                        }
                        return smallestImage
                    })
                    
                    let header = event?.images?.reduce(("", 1), { (widestImage, image) -> (String, Double) in
                        guard let url = image?.url else { return widestImage }
                        guard let ratio = image?.ratio else { return widestImage }
                        if ratio > widestImage.1 {
                            return (url, ratio)
                        }
                        return widestImage
                    })
                    
                    tournaments.append(Tournament(name: name, logoUrl: logo?.0 ?? "", date: "\(start) - \(end)", id: id, headerImage: header ?? ("", 0)))
                }
                complete(tournaments)
            }
        }
    }
    
    public static func getTournamentDetailsById(id: Int, complete: @escaping (_ tournament: [String: Any?]?) -> Void) {
        apollo.fetch(query: TournamentDetailsByIdQuery(id: "\(id)")) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(apolloFetchError, error as Any)
                complete(nil)
                return
            case .success(let graphQLResult):
                guard let tournament = graphQLResult.data?.tournament else {
                    debugPrint(tournamentFromId)
                    complete(nil)
                    return
                }
                
                let events = tournament.events?.compactMap({ (event) -> Tournament.Event? in
                    guard let event = event else { return nil }
                    return Tournament.Event(name: event.name, videogameId: Int(event.videogame?.id ?? "6"))
                })
                let streams = tournament.streams?.compactMap({ (stream) -> Tournament.Stream? in
                    guard let stream = stream else { return nil }
                    return Tournament.Stream(name: stream.streamName, game: stream.streamGame, logoUrl: stream.streamLogo, sourceUrl: stream.streamSource?.rawValue)
                })
                
                complete(["venueName": tournament.venueName,
                          "location": Tournament.Location(address: tournament.venueAddress, longitude: tournament.lng, latitude: tournament.lat),
                          "contact": tournament.primaryContact,
                          "events": events,
                          "streams": streams
                ])
            }
        }
    }
    
    public static func getImage(imageUrl: String?, complete: @escaping (_ image: UIImage?) -> Void) {
        guard let imageUrl = imageUrl else {
            complete(nil)
            return
        }
        if let cachedImage = ImageCacheService.getCachedImage(with: imageUrl) {
            complete(cachedImage)
            return
        } else {
            guard let url = URL(string: imageUrl) else {
                debugPrint(urlGenerationError, imageUrl)
                complete(nil)
                return
            }
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard error == nil else {
                    debugPrint(networkRequestError, error as Any)
                    complete(nil)
                    return
                }
                guard let data = data else {
                    debugPrint(missingDataError)
                    complete(nil)
                    return
                }
                guard let image = UIImage(data: data) else {
                    debugPrint(imageFromDataError)
                    complete(nil)
                    return
                }
                ImageCacheService.saveImageToCache(image: image, with: imageUrl)
                complete(image)
            }.resume()
        }
    }
}
