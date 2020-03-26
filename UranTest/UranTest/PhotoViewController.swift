//
//  PhotoViewController.swift
//  UranTest
//
//  Created by Roma Filipenko on 22.03.2020.
//  Copyright © 2020 Roma&Co. All rights reserved.
//

import UIKit
import UranTestNetworkKit

class PhotoViewController: UIViewController {
    
    //MARK: Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    
    //MARK: Properties
    
    var photo: Photo?
    let photoDownloader = PhotoDownloader(client: UnsplashClient())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPhoto()
    }
    
    //MARK: Loading regular photo
    
    func loadPhoto() {
        loadIndicator.startAnimating()
        
        if let photo = photo {
            let url = photo.urls.regular

            let image = photoDownloader.loadPhoto(url: url)

            loadIndicator.stopAnimating()
            imageView.image = image
        } else {

            loadIndicator.stopAnimating()
            imageView.image = nil
        }
    }
}
