//
//  PhotoInfoViewController.swift
//  Photorama
//
//  Created by Pierce Gallego on 11/24/23.
//

import UIKit

class PhotoInfoViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var isFavorite: UIBarButtonItem!
    
    var photo: Photo! {
        didSet {
            print("[\(photo.photoID!)] View count: \(photo.viewCount)")
            navigationItem.title = photo.title
        }
    }
    var store: PhotoStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        store.fetchImage(for: photo) { (result) -> Void in
            switch result {
            case let .success(image):
                self.imageView.image = image
            case let .failure(error):
                print("Error fetching image for photo: \(error)")
            }
        }
        photo.viewCount += 1
        isFavorite.image = photo.isFavorite == false ? UIImage(systemName: "star") : UIImage(systemName: "star.fill")
        store.saveContextIfNeeded()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showTags":
            let navController = segue.destination as! UINavigationController
            let tagController = navController.topViewController as! TagsViewController
            
            tagController.store = store
            tagController.photo = photo
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
}


extension PhotoInfoViewController {
    @IBAction func setFavorite(_ sender: UIBarButtonItem) {
        photo.isFavorite.toggle()
        store.saveContextIfNeeded()
        isFavorite.image = photo.isFavorite == false ? UIImage(systemName: "star") : UIImage(systemName: "star.fill")
    }
}
