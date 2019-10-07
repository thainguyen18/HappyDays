//
//  MemoriesViewController.swift
//  HappyDays
//
//  Created by Thai Nguyen on 10/6/19.
//  Copyright © 2019 Thai Nguyen. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import Speech

class MemoriesViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDelegateFlowLayout {
    
    var memories = [URL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        loadMemories()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }
    
    
    @objc func addTapped() {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.modalPresentationStyle = .formSheet
        navigationController?.present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true)
        
        if let possibleImage = info[.originalImage] as? UIImage {
            saveMemory(image: possibleImage)
            loadMemories()
        }
    }
    
    
    private func saveMemory(image: UIImage) {
        let memoryName = "memory-\(Date().timeIntervalSince1970)"
        
        let imageName = memoryName + ".jpg"
        let thumbnailName = memoryName + ".thumb"
        
        do {
            // Full size image
            let imagePath = getDocumentDirectory().appendingPathComponent(imageName)
            
            if let jpegData = image.jpegData(compressionQuality: 0.8) {
                try jpegData.write(to: imagePath, options: [.atomicWrite])
            }
            
            // Thumbnail image
            if let thumbnail = resize(image: image, to: 200) {
                let thumbnailImagePath = getDocumentDirectory().appendingPathComponent(thumbnailName)
                
                if let jpegData = thumbnail.jpegData(compressionQuality: 0.8) {
                    try jpegData.write(to: thumbnailImagePath, options: [.atomicWrite])
                }
            }
            
        } catch {
            print("Fail to save to disk")
        }
    }
    
    func resize(image: UIImage, to width: CGFloat) -> UIImage? {
        let scale = width / image.size.width
        
        let height = image.size.height * scale
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0) 
        
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    func checkPermissions() {
        let photoAuth = PHPhotoLibrary.authorizationStatus() == .authorized
        let recordAuth = AVAudioSession.sharedInstance().recordPermission == .granted
        let transcribeAuth = SFSpeechRecognizer.authorizationStatus() == .authorized
        
        let authorized = photoAuth && recordAuth && transcribeAuth
        
        if !authorized {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "FirstRun") {
                navigationController?.present(vc, animated: true)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkPermissions()
    }
    
    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    func loadMemories() {
        memories.removeAll()
        
        guard let files = try? FileManager.default.contentsOfDirectory(at: getDocumentDirectory(), includingPropertiesForKeys: nil, options: []) else { return }
        
        for file in files {
            let fileName = file.lastPathComponent
            
            if fileName.hasSuffix(".thumb") {
                let noExtension = fileName.replacingOccurrences(of: ".thumb", with: "")
                
                let memoryPath = getDocumentDirectory().appendingPathComponent(noExtension)
                
                memories.append(memoryPath)
            }
        }
        
        // Load collection views
        collectionView.reloadSections(IndexSet(integer: 1))
    }
    
    // CollectionView DataSource Delegate
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else {
            return memories.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Memory", for: indexPath) as! MemoryCell
        
        let memory = memories[indexPath.row]
        
        let imageName = thumbnailURL(for: memory).path
        
        let image = UIImage(contentsOfFile: imageName)
        
        cell.imageView.image = image
        
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 1 {
            return CGSize.zero
        } else {
            return CGSize(width: 0, height: 50)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 200)
    }
    
    
    func imageURL(for memory: URL) -> URL {
        return memory.appendingPathExtension("jpg")
    }
    
    func thumbnailURL(for memory: URL) -> URL {
        return memory.appendingPathExtension("thumb")
    }
    
    func audioURL(for memory: URL) -> URL {
        return memory.appendingPathExtension("m4a")
    }
    
    func transcriptionURL(for memory: URL) -> URL {
        return memory.appendingPathExtension("txt")
    }
    
}
