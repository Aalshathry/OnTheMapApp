//
//  ConfirmLocationViewController.swift
//
//  Created by Abdulrahman Al Shathry on 15/05/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import UIKit
import MapKit

class ConfirmLocationViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var location: StudentLocation?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMap()
    }
    
    @IBAction func finishTapped(_ sender: UIButton) {
        
        API.Parser.postLocation(self.location!) { err  in
            guard err == nil else {
                self.showAlert(title: "Error", message: err!)
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func setupMap() {
        guard let location = location else { return }
        
        let latitude = CLLocationDegrees(location.latitude!)
        let longitude = CLLocationDegrees(location.longitude!)
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = location.mapString

        mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
    }

}

extension ConfirmLocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let application = UIApplication.shared
            if let destination = view.annotation?.subtitle!,
                let url = URL(string: destination), application.canOpenURL(url) {
                application.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
