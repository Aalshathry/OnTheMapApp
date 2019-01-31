//
//  MapViewController.swift
//
//  Created by Abdulrahman Al Shathry on 15/05/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: ContainerViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override var locationsData: LocationsData? {
        didSet {
            updatePins()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func updatePins() {
        guard let locations = locationsData?.studentLocations else { return }
        
        var annotations = [MKPointAnnotation]()
        
        for location in locations {
            guard let latitude = location.latitude, let longitude = location.longitude else { continue }
            
            let latitud = CLLocationDegrees(latitude)
            let longitud = CLLocationDegrees(longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
            
            let first = location.firstName
            let last = location.lastName
            let mediaURL = location.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first ?? "") \(last ?? "")"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
    }
    
    
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
