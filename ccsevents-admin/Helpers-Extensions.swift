//
//  Helpers-Extensions.swift
//  ccsevents-admin
//
//  Created by Amir Nazari on 10/21/16.
//  Copyright © 2016 Amir Nazari. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseDatabase
import MapleBacon

func deleteImageFromFirebaseStorage(title: String) {
    let storage = FIRStorage.storage()
    // Create a root reference
    let storageRef = storage.reference()
    // Create a reference to the file you want to upload
    let imageRef = storageRef.child("images/\(title)")
    imageRef.delete { (error) in
        if error != nil {
            print("Error deleting image: \(String(describing: error?.localizedDescription))")
        } else {
            print("Deleted image successfully")
        }
    }
}

func saveImageToFirebaseStorage(data : Data, title : String) {
    let storage = FIRStorage.storage()
    // Create a root reference
    let storageRef = storage.reference()
    // Create a reference to the file you want to upload
    let imageRef = storageRef.child("images/\(title)")
    
    let metadata = FIRStorageMetadata()
    metadata.contentType = "image/png"
    
    // Upload the file to the path
    let uploadTask = imageRef.put(data, metadata: metadata) { metadata, error in
        if error != nil {
            // Uh-oh, an error occurred!
            print("error")
        } else {
            // Metadata contains file metadata such as size, content-type, and download URL.
//            if let downloadURL = metadata!.downloadURL()?.absoluteString {
//                dbRef.setValue(downloadURL, forKey: "downloadURL")
//            }
        }
    }
    
    // Add a progress observer to an upload task
    _ = uploadTask.observe(.progress) { snapshot in
        
        // Upload reported progress
        if let progress = snapshot.progress {
            let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
            print("Percent Complete: \(percentComplete)%")
        }
    }
}

func getImageFromStorageRef(title: String, imageView: UIImageView, event: Event?) {
    
    imageView.image = #imageLiteral(resourceName: "calendar")
    
    if title == "" {
        return
    }
    
    let storage = FIRStorage.storage()
    let imageRef = storage.reference(withPath: "images/\(title)")
    
    imageRef.downloadURL { url, error in
        if let error = error {
            // Handle any errors
            print("error downloading image")
            print(error.localizedDescription)
            imageView.image = #imageLiteral(resourceName: "calendar")
            return
        } else {
            if let download = url {
                
                if let thisEvent = event {
                    thisEvent.downloadURL = download.absoluteString
                }
                
                DispatchQueue.main.async {
                    imageView.setImage(withUrl: download)
                }
            }
        }
    }
}

func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
    
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSize.init(width: newWidth, height: newHeight))
    image.draw(in: CGRect.init(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}

