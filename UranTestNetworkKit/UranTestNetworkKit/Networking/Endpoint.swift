//
//  Requests.swift
//  UranTestNetworkKit
//
//  Created by Roma Filipenko on 20.03.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import Foundation

protocol Endpoint {
    
    var method: String { get }
    var baseUrl: String { get }
    var path: String { get }
    var urlParameters: [URLQueryItem] { get }
}

extension Endpoint {
    
    var urlComponent: URLComponents {
        var urlComponent = URLComponents(string: baseUrl)
        urlComponent?.path = path
        urlComponent?.queryItems = urlParameters

        return urlComponent!
    }

    var request: URLRequest {
        
        var request = URLRequest(url: urlComponent.url!)
        
        request.httpMethod = method
        
        request.setValue("v1", forHTTPHeaderField: "Accept-Version")
        request.setValue("Client-ID \(UnsplashClient.apiKey)", forHTTPHeaderField: "Authorization")
        return request
    }
}

enum Order: String {
    
    case popular, latest, oldest
}

enum UnsplashEndpoint: Endpoint {
    
    case photos(order: Order, page: Int)
    case search(order: Order, page: Int, query: String)
    
    var method: String {
        return "GET"
    }

    var baseUrl: String {
        return UnsplashClient.baseUrl
    }

    var path: String {
        switch self {
        case .photos:
            return "/photos"
        case .search:
            return "/search/photos"
        }
    }

    var urlParameters: [URLQueryItem] {
        switch self {
        case .photos(let order, let page):
            return [
                URLQueryItem(name: "order_by", value: order.rawValue),
                URLQueryItem(name: "per_page", value: "30"),
                URLQueryItem(name: "page", value: "\(page)")
                ]
        case .search(let order, let page, let query):
            return [
                URLQueryItem(name: "query", value: "\(query)"),
                URLQueryItem(name: "order_by", value: order.rawValue),
                URLQueryItem(name: "per_page", value: "30"),
                URLQueryItem(name: "page", value: "\(page)")
            ]
        }
    }
}
