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
        if (error != nil) {
            // Uh-oh, an error occurred!
            print("error")
        } else {
            // Metadata contains file metadata such as size, content-type, and download URL.
            let downloadURL = metadata!.downloadURL
            print("\(downloadURL)")
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

func getImageFromStorageRef(title: String, imageView: UIImageView) {
    
    imageView.image = #imageLiteral(resourceName: "calendar")
    
    if title == "" {
        return
    }
    
    let storage = FIRStorage.storage()
    let imageRef = storage.reference(withPath: "images/\(title)")
    
    imageRef.data(withMaxSize: 1 * 1000 * 1000) { (data, error) -> Void in
        if (error != nil) {
            // Uh-oh, an error occurred!
            print("error downloading image")
            imageView.image = #imageLiteral(resourceName: "calendar")
        } else {
            let theImage: UIImage! = UIImage(data: data!)
            imageView.image = theImage
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

