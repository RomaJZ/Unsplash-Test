//
//  ViewController.swift
//  UranTest
//
//  Created by Roma Filipenko on 18.03.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import UIKit
import UranTestNetworkKit

class ViewController: UIViewController {

    //MARK: Outlets
    
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: Properties
    
    let photoDownloader = PhotoDownloader(client: UnsplashClient())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearchController()
        
        self.loadIndicator.startAnimating()
        
        //MARK: Photo downloader
        
        photoDownloader.showLoading = {
            
            if !self.photoDownloader.isLoading {
                self.loadIndicator.isHidden = true
                self.loadIndicator.stopAnimating()
            }
        }
        
        photoDownloader.showError = { error in
            
            print(error)
        }
        
        photoDownloader.reloadData = {
            
            self.collectionView.reloadData()
        }
        
        photoDownloader.startFetchingPhotos()
    }
    
    @IBAction func loadMore(_ sender: UIBarButtonItem) {
        photoDownloader.startFetchingPhotos()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        searchViewController.collectionView.delegate = self
    }
    
    // MARK: - Search
    
    var searchController: UISearchController!
    
    var searchViewController: SearchViewController!
    
    private func configureSearchController() {
        searchViewController = storyboard!.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController
        
        searchController = UISearchController(searchResultsController: searchViewController)
        
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.isActive = true
        searchController.searchBar.becomeFirstResponder()
        definesPresentationContext = true
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.placeholder = "Search photos"
        
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // MARK: - Context menu
    
    func makeContextMenu(for photo: Photo, at indexPath: IndexPath) -> UIMenu {
        
        let delete = UIAction(title: "Delete Photo", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
            
            self?.searchViewController.delete(photo, at: indexPath)
        }
        return UIMenu(title: "", children: [delete])
    }
    
    // MARK: - Navigation to photo
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case "showPhoto":
            let vc = segue.destination as? PhotoViewController
            vc?.photo = sender as? Photo
            
        default:
            break
        }
    }
}



//MARK: DataSource

extension ViewController: UICollectionViewDataSource {
     
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photoDownloader.cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath ) as! PhotoCell
            
            let image = photoDownloader.cellViewModels[indexPath.row].image
            
            cell.imageView.image = image
            
        return cell
    }
}

// MARK: - Delegate

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.collectionView {
            
            let photo = photoDownloader.cellViewModels[indexPath.row].photo
            performSegue(withIdentifier: "showPhoto", sender: photo)
            
        } else if collectionView == searchViewController.collectionView {
            
            let photo = searchViewController.searchPhotoDownloader.searchCellViewModels[indexPath.row].photo
            performSegue(withIdentifier: "showPhoto", sender: photo)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        guard collectionView == searchViewController.collectionView else {
            return nil
        }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { [weak self] _ in
            
            guard let photo = self?.searchViewController.searchPhotoDownloader.searchCellViewModels[indexPath.row].photo else { return nil }
            
            return self?.makeContextMenu(for: photo, at: indexPath)
        })
    }
}

// MARK: - Search results updating

extension ViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let text = searchController.searchBar.text else { return }
        let searchText = text.trimmingCharacters(in: .whitespaces)
        
        guard searchText.count >= 3 else {
            searchViewController.resetSearchResults()
            searchViewController.collectionView.reloadData()
            return
        }
        
        searchViewController.search(by: searchText)
    }
}

//MARK: Flow layout delegate

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var number: CGFloat = 0
        var collectionView = collectionView
         
        if collectionView == self.collectionView {
            collectionView = self.collectionView
            number = 3
        } else if collectionView == searchViewController.collectionView {
            collectionView = searchViewController.collectionView
            number = 1
        }
        
        let numberOfColumns: CGFloat  = number
        let width = collectionView.frame.width
        
        let xInsets: CGFloat = 10
        let cellSpacing: CGFloat = 5
        
        let size = CGSize(width: (width / numberOfColumns) - (xInsets + cellSpacing), height: (width / numberOfColumns) - (xInsets + cellSpacing))
        
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return size
    }
}

