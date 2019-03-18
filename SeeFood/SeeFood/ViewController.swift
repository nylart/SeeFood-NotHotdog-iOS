//
//  ViewController.swift
//  NotHotdog
//
//  Created by Tralyn Le on 3/17/19.
//  Copyright © 2019 Tralyn Le. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var fullScreenImageView: UIImageView!
    
    @IBOutlet weak var responseImageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    let startImage = UIImage(named: "StartScreen.png")
    let hotdogImage = UIImage(named: "Hotdog.png")
    let notHotdogImage = UIImage(named: "NotHotdog.png")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "SeeFood"
        
        // Hide the imageView and responseImageView
        imageView.isHidden = true
        responseImageView.isHidden = true
        
        // Set image picker properties
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
    }
    
    // When the user takes/selects a photo, try to convert it to a CIImage and then run detection on it
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Show imageview again
        imageView.isHidden = false
        
        // Set the image view's image to the user picked image
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image = userPickedImage
            
            // Convert the passed image to a CIImage
            guard let ciimage = CIImage(image: userPickedImage) else{
                fatalError("Could not convert UIImage to CIImage")
            }
            
            // Run detection on the image
            detect(image: ciimage)
        }
        // Dismiss the image picker
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    // Runs detection on the passed image using the Core ML model
    func detect(image: CIImage) {
        
        // Load the model that will be used to classify our image
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed")
        }
        
        // Create a request that tries to classify the data
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else{
                fatalError("Model failed to process image")
            }
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog"){
                    self.responseImageView.image = self.hotdogImage
                    self.responseImageView.isHidden = false
                }
                else {
                    self.responseImageView.image = self.notHotdogImage
                    self.responseImageView.isHidden = false
                }
            }
        }
        
        // Define the data with a handler
        let handler = VNImageRequestHandler(ciImage: image)
        
        // Use the handler to perform the task of classifying the image
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
    // When the camera button is tapped, present the image picker.
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
        fullScreenImageView.isHidden = true
        responseImageView.isHidden = true
    }
    
}

