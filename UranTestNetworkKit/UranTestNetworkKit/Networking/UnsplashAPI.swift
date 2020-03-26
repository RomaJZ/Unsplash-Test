//
//  UranTestNetworkKit.swift
//  UranTestNetworkKit
//
//  Created by Roma Filipenko on 18.03.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import Foundation

enum Result<T> {
    
    case succes(T)
    case error(Error)
}

enum APIError: Error {
    
    case unknown, badResponce, jsonDecoder, jsonSerialization, imageDownload, imageConvert
}

protocol UnsplashAPI {
    
    var session: URLSession { get }
    
    func get<T: Codable>(with request: URLRequest, for type: String, completion: @escaping (Result<[T]>) -> Void)
}

extension UnsplashAPI {
    
    var session: URLSession {
        return URLSession.shared
    }
    
    func get<T: Codable>(with request: URLRequest, for type: String, completion: @escaping (Result<[T]>) -> Void) {
        
        let task = session.dataTask(with: request) { (data, responce, error) in
            
            guard error == nil else {
                completion(.error(error!))
                return
            }
            
            guard let responce = responce as? HTTPURLResponse, 200..<300 ~= responce.statusCode else {
                completion(.error(APIError.badResponce))
                return
            }
            
            var result: [T] = []
            
            if type == "photos" {
                
                guard let photos = try? JSONDecoder().decode([T].self, from: data!) else {
                    completion(.error(APIError.jsonDecoder))
                    return
                }
                result = photos
                
            } else if type == "search" {

                let json = try? JSONSerialization.jsonObject(with: data!, options: [])

                if let resultsJson = json as? [String: Any], let results = resultsJson["results"] as? [Any] {

                    guard let data = try? JSONSerialization.data(withJSONObject: results, options: []) else {
                        completion(.error(APIError.jsonDecoder))
                        return
                    }

                    guard let photos = try? JSONDecoder().decode([T].self, from: data) else {
                        completion(.error(APIError.jsonDecoder))
                        return
                    }

                    result = photos

                } else {
                    result = []
                }
            }
            
            DispatchQueue.main.async {
                completion(.succes(result))
            }
        }
        task.resume()
    }
}
