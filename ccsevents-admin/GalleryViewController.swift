//
//  GalleryViewController.swift
//  ccsevents-admin
//
//  Created by Amir Nazari on 10/9/16.
//  Copyright © 2016 Amir Nazari. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import MapleBacon

class GalleryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var ref: FIRDatabaseReference!
    var imageRef: FIRStorageReference!
    
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    
    var galleryImageObjects: [GalleryItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let storage = FIRStorage.storage()
        // Create a root reference
        imageRef = storage.reference()
        
        ref = FIRDatabase.database().reference(withPath: "ccs/gallery")
        ref.child("Images").observe(FIRDataEventType.value, with: { (snapshot) in
            var tempGallery: [GalleryItem] = []
            
            for child in snapshot.children {
                
                let galleryObject = GalleryItem()
                
                guard let snap = child as? FIRDataSnapshot else {
                    return
                }
                
                galleryObject.key = snap.key
                
                if snap.hasChild("title") {
                    if let title = snap.childSnapshot(forPath: "title").value as? String {
                        galleryObject.title = title
                    }
                }
                
                if snap.hasChild("downloadURL") {
                    if let downloadURL = snap.childSnapshot(forPath: "downloadURL").value as? String {
                        galleryObject.downloadURL = downloadURL
                    }
                }
                
                tempGallery.append(galleryObject)
            }
            
            if tempGallery.containsSameElements(as: self.galleryImageObjects) {
                // no changes
                return
            } else {
                self.galleryImageObjects = tempGallery
            }
            
            DispatchQueue.main.async {
                self.galleryCollectionView.reloadData()
            }
        })
    }
    
    @IBAction func toggleEditImages(_ sender: UIButton) {
//        // Handle select profile image view
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Canceled picker image")
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        var selectedImageFromPicker: UIImage?

        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }

        if let selectedImage = selectedImageFromPicker {
            let resizedImage = resizeImage(image: selectedImage, newWidth: 400)

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddhhmmss"
            let imageTitle = dateFormatter.string(from: Date())

            guard let data = UIImagePNGRepresentation(resizedImage) else {
                return
            }
            self.saveGalleryImageToFirebaseStorage(data: data, title: imageTitle)
        }

        dismiss(animated: true, completion: nil)
    }
    
    func saveGalleryImageToFirebaseStorage(data : Data, title : String) {
        
        // Create a reference to the file you want to upload
        let imageReference = imageRef.child("gallery/\(title)")
        
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/png"
        
        // Upload the file to the path
        let uploadTask = imageReference.put(data, metadata: metadata) { metadata, error in
            if error != nil {
                // Uh-oh, an error occurred!
                print("error")
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                if let downloadURL = metadata!.downloadURL()?.absoluteString {
                    let galleryItem = ["title" : title, "downloadURL" : downloadURL]
                    self.ref.child("Images").childByAutoId().setValue(galleryItem)
                }
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
}

extension GalleryViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    //MARK: Required Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return galleryImageObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCollectionViewCell.galleryCellReuse, for: indexPath) as? GalleryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(GalleryViewController.deleteImage(_:)), for: .touchUpInside)

        let galleryItem = galleryImageObjects[indexPath.row]
        cell.hideDeleteButton()
        cell.galleryImage.image = #imageLiteral(resourceName: "gallery")
        
        if let url = URL(string: galleryItem.downloadURL) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error?.localizedDescription)
                    return
                }
                
                if let imageData = data {
                    DispatchQueue.main.async {
                        cell.galleryImage.image = UIImage(data: imageData)
                    }
                }
            }).resume()
        }
        
        return cell
    }
    
    //MARK: Optional Methods
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? GalleryCollectionViewCell else {
            return
        }
        cell.toggleDeleteButton()
    }
    
    @objc func deleteImage(_ sender : UIButton) {
        
        let tag = sender.tag
        if galleryImageObjects.count <= tag { return }
        let item = galleryImageObjects[tag]
        ref.child("Images/\(item.key)").removeValue()
        imageRef.child("gallery/\(item.title)").delete { (error) in
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            }
            
            print("Image deleted successfully!")
        }
    }
}
