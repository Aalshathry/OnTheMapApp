//
//  AddLocationViewController.swift
//
//  Created by Abdulrahman Al Shathry on 15/05/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import UIKit
import CoreLocation

class AddLocationViewController: UIViewController {
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mediaLinkTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToNotificationsObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromNotificationsObserver()
    }
    
    @IBAction func findLocationTapped(_ sender: UIButton) {
        guard let location = locationTextField.text,
              let mediaLink = mediaLinkTextField.text,
              location != "", mediaLink != "" else {
            self.showAlert(title: "Missing Information", message: "You need to fill both fields in order to find your location!")
            return
        }
        
        let studentLocation = StudentLocation(mapString: location, mediaURL: mediaLink)
        geocodeCoordinates(studentLocation)
    }
    
    private func geocodeCoordinates(_ studentLocation: StudentLocation) {
        let AI = self.startAnActivityIndicator()

        CLGeocoder().geocodeAddressString(studentLocation.mapString!) { (placeMarks, err) in
            guard err == nil else {
                self.showAlert(title: "Error", message: "There was an error in generating the mapString")
                return
            }

            AI.stopAnimating()
            
            guard let firstLocation = placeMarks?.first?.location else { return }

            var location = studentLocation
            location.latitude = firstLocation.coordinate.latitude
            location.longitude = firstLocation.coordinate.longitude

            self.performSegue(withIdentifier: "mapSegue", sender: location)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapSegue", let VC = segue.destination as? ConfirmLocationViewController {
            VC.location = (sender as! StudentLocation)
        }
    }
    
    private func setupUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(self.cancelTapped(_:)))
        locationTextField.delegate = self
        mediaLinkTextField.delegate = self
    }
    
    @objc private func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}


