//
//  ViewController.swift
//  SeeFood
//
//  Created by Loker, Steve on 5/8/18.
//  Copyright © 2018 Steven M. Loker. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var takePictureButton: UIButton!
    
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerController.delegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePickerController.dismiss(animated: true, completion: nil)
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = selectedImage
            takePictureButton.isHidden = true
            
            guard let ciImage = CIImage(image: selectedImage) else {
                fatalError("SNH: Unable to convert UIImage to CIImage")
            }
            
            detect(ciImage)
        }
    }
    
    func detect(_ ciImage: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Unable to load Inceptionv3 model")
        }

        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
            if let bestResult = results.max(by: { left, right in return left.confidence < right.confidence }) {
                self.checkForHotdog(in: bestResult)
            } else {
                self.notHotdog()
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        do {
            try handler.perform([request])
        } catch {
            print("Error performing request: \(error)")
        }
    }
    
    func checkForHotdog(in result: VNClassificationObservation?) {
        if result != nil && result!.identifier.contains("hotdog") {
            hotdog()
        } else {
            notHotdog()
        }
    }
    
    func hotdog() {
        title = "Hotdog!"
        navigationController?.navigationBar.barTintColor = UIColor.green
        navigationController?.navigationBar.tintColor = UIColor.black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
    }
    
    func notHotdog() {
        title = "Not Hotdog!"
        navigationController?.navigationBar.barTintColor = UIColor.red
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        displayPhotoOptions()
    }
    
    @IBAction func takePictureButtonTapped(_ sender: UIButton) {
        displayPhotoOptions()
        
    }
    
    func displayPhotoOptions() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default) { (action) in
            self.takePicture()
        })
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.showGallery()
        })
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet, animated: true, completion: nil)
    }
    
    func takePicture() {
        imagePickerController.sourceType = .camera
        imagePickerController.cameraDevice = .rear
        imagePickerController.allowsEditing = false
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func showGallery() {
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        present(imagePickerController, animated: true, completion: nil)
    }
    
}

