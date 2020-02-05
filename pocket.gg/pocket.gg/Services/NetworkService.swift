//
//  NetworkService.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-02.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit
import Apollo
class NetworkService {
    
    func requestImage(imageUrl: String, complete: @escaping (_ success: Bool, _ image: UIImage?) -> Void) {
        guard let url = generateUrl(from: imageUrl) else {
            complete(false, nil)
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                debugPrint(networkRequestError, error as Any)
                complete(false, nil)
                return
            }
            guard let data = data else {
                debugPrint(missingDataError)
                complete(false, nil)
                return
            }
            guard let image = UIImage(data: data) else {
                debugPrint(imageFromDataError)
                complete(false, nil)
                return
            }
            complete(true, image)
        }.resume()
    }
    
    // MARK: - Private Helpers
    
    private func generateUrl(from urlString: String) -> URL? {
        guard let url = URL(string: urlString) else {
            debugPrint(urlGenerationError, urlString)
            return nil
        }
        return url
    }
}
