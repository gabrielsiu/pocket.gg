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
    
    // MARK: - Public Methods
    
    public static func getUpcomingTournamentsByVideogames(pageNum: Int, complete: @escaping (_ success: Bool, _ tournaments: [Tournament]?) -> Void) {
        apollo.fetch(query: UpcomingTournamentsByVideogamesQuery(perPage: 10, pageNum: 1, videogameIds: ["1"], featured: true, upcoming: true)) { result in
            switch result {
            case .failure(let error):
                debugPrint(k.Error.apolloFetch, error as Any)
                complete(false, nil)
            case .success(let graphQLResult):
                var tournaments = [Tournament]()
                
                guard let nodes = graphQLResult.data?.tournaments?.nodes else {
                    debugPrint(k.Error.tournamentNodes)
                    complete(false, nil)
                    return
                }
                
                for event in nodes {
                    let name = event?.name ?? ""
                    let id = Int(event?.id ?? "6") ?? 6
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    let start = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(event?.startAt ?? "0") ?? 0))
                    let end = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(event?.endAt ?? "3137983740") ?? 3137983740))
                    
                    // TODO: Rework logic of getting best image URL to be more concise if possible
                    var lowestRatio = 10.0
                    var imageUrl = ""
                    if let images = event?.images {
                        for image in images {
                            let ratio = image?.ratio ?? 10.0
                            if ratio < lowestRatio {
                                lowestRatio = ratio
                                imageUrl = image?.url ?? ""
                            }
                        }
                    }
                    tournaments.append(Tournament(name: name, imageUrl: imageUrl, date: "\(start) - \(end)", id: id))
                }
                complete(true, tournaments)
            }
        }
    }
    
    public static func requestImage(imageUrl: String, complete: @escaping (_ success: Bool, _ image: UIImage?) -> Void) {
        guard let url = URL(string: imageUrl) else {
            debugPrint(k.Error.urlGeneration, imageUrl)
            complete(false, nil)
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                debugPrint(k.Error.networkRequest, error as Any)
                complete(false, nil)
                return
            }
            guard let data = data else {
                debugPrint(k.Error.missingData)
                complete(false, nil)
                return
            }
            guard let image = UIImage(data: data) else {
                debugPrint(k.Error.imageFromData)
                complete(false, nil)
                return
            }
            complete(true, image)
        }.resume()
    }
}
