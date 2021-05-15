//
//  ViewController.swift
//  A1_iOS_Sumit_C0800306
//
//  Created by Sumit Desai on 15/05/21.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnDirection: UIButton!
    
    // creating an object of location manager
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        btnDirection.isHidden = true
        
        // assign the delegate of locationManager to this class
        locationManager.delegate = self
        
        // assign the best accuracy of the location
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // requesting the user for the location access
        locationManager.requestWhenInUseAuthorization()
        
        // updating the location of the user as per movement
        locationManager.startUpdatingLocation()
    }
    
    //MARK: - method didUpdateLocations from the CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        displayLocation(latitude: latitude, longitude: longitude, title: "Your location", subtitle: "sample")
        
    }
    
    //MARK: - method to display the location on the map
    func displayLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String, subtitle: String){
       
        // 1.1 define span
        let latDelta : CLLocationDegrees = 0.1
        let longDelta : CLLocationDegrees = 0.1
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        
        // 1.2 define location
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // 1.3 define region
        let region = MKCoordinateRegion(center: location, span: span)
        
        // 1.4 set the region on the map
        mapView.setRegion(region, animated: true)
        
        // 1.5 define annotation
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
        	
    }


}

