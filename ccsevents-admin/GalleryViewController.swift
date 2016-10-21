//
//  GalleryViewController.swift
//  ccsevents-admin
//
//  Created by Amir Nazari on 10/9/16.
//  Copyright © 2016 Amir Nazari. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController {

    @IBOutlet weak var galleryCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func toggleEditImages(_ sender: UIButton) {
        
    }
}

extension GalleryViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    //MARK: Required Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 25
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCollectionViewCell.galleryCellReuse, for: indexPath) as? GalleryCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.galleryImage.image = #imageLiteral(resourceName: "gallery")
        
        return cell
    }
    
    //MARK: Optional Methods
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? GalleryCollectionViewCell else {
            return
        }
        
        cell.toggleDeleteButton()
    }
}
