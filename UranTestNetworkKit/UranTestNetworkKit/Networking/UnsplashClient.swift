//
//  UnsplashClient.swift
//  UranTestNetworkKit
//
//  Created by Roma Filipenko on 20.03.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import Foundation

open class UnsplashClient: UnsplashAPI {
    
    static let baseUrl = "https://api.unsplash.com/"
    static let apiKey = "4c9fbfbbd92c17a2e95081cec370b4511659666240eb4db9416c40c641ee843b"
    
    func fetch(with endpoint: UnsplashEndpoint, for type: String, completion: @escaping (Result<Photos>) -> Void) {
        
        let request = endpoint.request
        get(with: request, for: type, completion: completion)
    }
    
    public init() {}
}
