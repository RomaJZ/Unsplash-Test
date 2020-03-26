//
//  Photo.swift
//  UranTestNetworkKit
//
//  Created by Roma Filipenko on 20.03.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import Foundation

public typealias Photos = [Photo]

public struct Photo: Codable {
    
    public let id: String
    public let urls: URLS
}

public struct URLS: Codable {
    
//    public let raw: URL
//    public let full: URL
    public let regular: URL
    public let small: URL
//    public let thumb: URL
}

extension Photo: Equatable {
    
    public static func == (lhs: Photo, rhs: Photo) -> Bool {
        
        guard lhs.id == rhs.id else { return false }
        return true
    }
}
