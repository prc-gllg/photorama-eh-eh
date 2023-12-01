//
//  ViewController.swift
//  Photorama
//
//  Created by Pierce Gallego on 11/24/23.
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegate, UITabBarDelegate {

    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet weak var tabbar: UITabBar!
    var selectedTab = Int()
    var store: PhotoStore!
    let photoDataSource = PhotoDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
        collectionView.reloadData()
        store.fetchInterestingPhotos { (photosResult) -> Void in
            self.updateDataSource()
        }
        
        tabbar.delegate = self
        tabbar.selectedItem = self.tabbar.items![selectedTab] as UITabBarItem
        navigationItem.title = self.tabbar.items![selectedTab].title
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPhoto":
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
                let photo = photoDataSource.photos[selectedIndexPath.row]
                let destinationVC = segue.destination as! PhotoInfoViewController
                destinationVC.photo = photo
                destinationVC.store = store
            }
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
}

//private functions
extension PhotosViewController {
    //method to update data source
    private func updateDataSource(selectedTab: Int = 0) {
        fetchPhotos(selectedTab: selectedTab) { (fetchResult) in
            switch fetchResult {
            case let .success(photos):
                self.photoDataSource.photos = photos
            case .failure(_):
                self.photoDataSource.photos.removeAll()
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    private func fetchPhotos(selectedTab: Int, completion: @escaping (Result<[Photo], Error>) -> Void) {
        switch selectedTab {
        case 0:
            store.fetchAllPhotos { completion($0) }
        case 1:
            store.fetchFavorites { completion($0) }
        default:
            print("Unexpected tab item tag.")
        }
    }
}

//UITabBarDelegate Methods
extension PhotosViewController {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        navigationItem.title = item.title
        //fetch photos based on tabbar item
        updateDataSource(selectedTab: item.tag)
    }
}

//UICollectionViewDelegate Methods
extension PhotosViewController {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = photoDataSource.photos[indexPath.row]
        
        store.fetchImage(for: photo) { (result) -> Void in
            guard let photoIndex = self.photoDataSource.photos.firstIndex(of: photo), case let .success(image) = result else {
                return
            }
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            
            if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                cell.update(displaying: image)
            }
        }
    }
}
