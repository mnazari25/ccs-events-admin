//
//  GalleryCollectionViewCell.swift
//  ccsevents-admin
//
//  Created by Amir Nazari on 10/9/16.
//  Copyright © 2016 Amir Nazari. All rights reserved.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {
    static let galleryCellReuse = "galleryCellReuse"
    
    //Outlets
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var galleryImage: UIImageView!
    @IBOutlet weak var deleteBottomConstraint: NSLayoutConstraint!
    
    public func toggleDeleteButton() {
        if deleteBottomConstraint.constant >= 0 {
            deleteBottomConstraint.constant = -deleteButton.frame.height
            UIView.animate(withDuration: 0.5) {
                self.contentView.layoutIfNeeded()
            }
        } else {
            deleteBottomConstraint.constant = 0
            UIView.animate(withDuration: 0.5) {
                self.contentView.layoutIfNeeded()
            }
        }
    }
}
