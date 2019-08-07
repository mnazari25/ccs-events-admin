//
//  GalleryItem.swift
//  ccsevents-admin
//
//  Created by Amir Nazari on 5/13/18.
//  Copyright © 2018 Amir Nazari. All rights reserved.
//

import Foundation

class GalleryItem: Comparable {
    
    var key: String
    var title: String
    var downloadURL: String
    
    init(key: String = "", title: String = "", downloadURL: String = "") {
        self.title = title
        self.downloadURL = downloadURL
        self.key = key
    }
    
    static func < (lhs: GalleryItem, rhs: GalleryItem) -> Bool {
        return lhs.key < rhs.key
    }
    
    static func == (lhs: GalleryItem, rhs: GalleryItem) -> Bool {
        return lhs.key == rhs.key
    }
}
