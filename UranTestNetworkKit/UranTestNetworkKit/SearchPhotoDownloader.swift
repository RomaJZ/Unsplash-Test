//
//  SearchPhotoDownloader.swift
//  UranTestNetworkKit
//
//  Created by Roma Filipenko on 24.03.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import UIKit

public struct SearchCellViewModel {
    
    public let image: UIImage
    public let photo: Photo
}

open class SearchPhotoDownloader {
    
    // MARK: Properties
    
    private let client: UnsplashClient
    private var newPhotos: Photos = [] {
        didSet {
            self.fetchPhoto()
        }
    }
    public var searchCellViewModels: [SearchCellViewModel] = [] {
        didSet (newElement) {
            print("SEARCH MODEL !!!!!!! \(self.searchCellViewModels.count)")
        }
    }
    
    public var isLoading: Bool = false {
        didSet {
            showLoading?()
        }
    }
    public var showLoading: (() -> Void)?
    public var reloadData: (() -> Void)?
    public var showError: ((Error) -> Void)?
    public var text: String?
    private var canFetchMore = true
    private var currentPage: Int = 1

    public init(client: UnsplashClient) {
        self.client = client
    }
    
    //MARK: Fetching photos
    
    public func startSearchingPhotos() {
        
        guard let text = text else { return }
        
        guard canFetchMore else { return }
        
        isLoading = true
        
        fetchPhotos(by: text, for: currentPage)
    }

    private func fetchPhotos(by text: String, for page: Int) {
        
        if let client = client as? UnsplashClient {
            
            let endpoint = UnsplashEndpoint.search(order: .latest, page: page, query: text)
            
            client.fetch(with: endpoint, for: "search") { [weak self] (result) in
                
                switch result {
                    
                case .succes(let newPhotos):

                    if newPhotos.isEmpty {
                        self?.canFetchMore = false
                    } else {
                        self?.newPhotos = newPhotos
                    }
                    
                    self?.currentPage += 1
                    if self!.currentPage > 10 {
                        self?.canFetchMore = false
                    }
                    
                case .error(let error):
                    self?.showError?(error)
                }
            }
        }
    }
    
    //MARK: Loading photos

    private func fetchPhoto() {
        
        let group = DispatchGroup()
        self.newPhotos.forEach { [weak self] (photo) in
            DispatchQueue.global(qos: .background).async(group: group) {
                group.enter()
                
                guard let image = self?.loadPhoto(url: photo.urls.small) else { return }
                
                self?.searchCellViewModels.append(SearchCellViewModel(image: image, photo: photo))
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.isLoading = false
            self.reloadData?()
        }
    }
    
    public func loadPhoto(url: URL) -> UIImage {
       
        var photo = UIImage()
        
        if let imageData = try? Data(contentsOf: url){
//            print(url)
            if let image = UIImage(data: imageData){
                
                photo = image
                
            } else {
                showError?(APIError.imageConvert)
            }
            
        } else {
            showError?(APIError.imageDownload)
        }
        return photo
    }
    
    //MARK: Reset search
    
    public func resetSearch() {
        
        canFetchMore = true
        
        currentPage = 1
        
        searchCellViewModels = []
    }
    
}
