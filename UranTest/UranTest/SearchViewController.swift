//
//  SearchViewController.swift
//  UranTest
//
//  Created by Roma Filipenko on 22.03.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import UIKit
import UranTestNetworkKit

class SearchViewController: UIViewController {
    
    //MARK: Outlets
    
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: Properties
    
    let searchPhotoDownloader = SearchPhotoDownloader(client: UnsplashClient())
    let viewController = ViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Search
    
    func search(by text: String) {
        
        self.loadIndicator.startAnimating()
            
        searchPhotoDownloader.resetSearch()
        
        searchPhotoDownloader.text = text
        
        searchPhotoDownloader.startSearchingPhotos()
        
        searchPhotoDownloader.showLoading = {
            
            if !self.searchPhotoDownloader.isLoading {
                self.loadIndicator.isHidden = true
                self.loadIndicator.stopAnimating()
            }
        }
        
        searchPhotoDownloader.showError = { error in
            
            print(error)
        }
        
        searchPhotoDownloader.reloadData = {
            
            self.collectionView.reloadData()
        }
    }
    
    func resetSearchResults() {
        
        searchPhotoDownloader.resetSearch()
    }
    
    // MARK: - Delete
    
    func delete(_ photo: Photo, at indexPath: IndexPath) {
            
        searchPhotoDownloader.searchCellViewModels.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
    }
    
}

//MARK: DataSource

extension SearchViewController: UICollectionViewDataSource {
     
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchPhotoDownloader.searchCellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchPhotoCell", for: indexPath ) as! PhotoCell
        
        let image = searchPhotoDownloader.searchCellViewModels[indexPath.row].image
        
        cell.imageView.image = image
        
        return cell
    }
}
