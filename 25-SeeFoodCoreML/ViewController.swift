//
//  ViewController.swift
//  25-SeeFoodCoreML
//
//  Created by administrator on 07/07/2024.
//

import UIKit
import CoreML
import Vision


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedimage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedimage
            
            guard let ciImange = CIImage(image: userPickedimage) else {
                fatalError("Could not convert to CIImange")
            }
            
            detect(image: ciImange)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    func detect(image: CIImage){
        guard let model = try? VNCoreMLModel(for: MLModel(contentsOf: Inceptionv3.urlOfModelInThisBundle)) else {
            fatalError("unable to load coreML")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, Error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("model faild to proccess image")
            }
            
            //print(results)
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("keyboard") {
                    self.navigationItem.title = "Keybaord!"
                }else {
                    self.navigationItem.title = firstResult.identifier
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }catch {
            print(error)
        }
    }

    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
            
    }
    
    
    
}

