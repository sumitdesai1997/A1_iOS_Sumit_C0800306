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
    var city = ""
    var cityList = [String](repeating: "", count: 3)
    var countList = [Int](repeating: 0, count: 3)
    var drawPolygon = false
    
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
        
        // long press gesture for adding the cities
        let lpGesture = UILongPressGestureRecognizer(target: self, action: #selector(addMarker))
        mapView.addGestureRecognizer(lpGesture)
    }
    
    //MARK: - method for long press gesture
    @objc func addMarker(gesture: UIGestureRecognizer) {
        let touchPoint = gesture.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if(error != nil){
                print(error!)
            } else{
                if let placemark = placemarks?[0]{
                    
                    self.city = ""
                    
                    // adding markers only if the cities are from ontario
                    if placemark.administrativeArea != nil && placemark.administrativeArea == "ON" {
                        self.city = placemark.subAdministrativeArea!
                        
                        print(self.city)
                        print(placemark.administrativeArea!)
                        
                        // adding annotation for the coordinates
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        self.mapView.addAnnotation(annotation)
                        
                        // addiing title for the annotations
                        if(self.countList[0] == 0){
                            annotation.title = "A"
                            self.countList[0] = 1
                        } else if(self.countList[1] == 0){
                            annotation.title = "B"
                            self.countList[1] = 1
                        } else if(self.countList[2] == 0){
                            annotation.title = "C"
                            self.countList[2] = 1
                        }
                        
                        if(self.countList[0] != 0 && self.countList[1] != 0 && self.countList[2] != 0){
                            self.drawPolygon = true
                        }
        
                    }
                }
            }
        }
        

       }
    
    
    
    //MARK: - method didUpdateLocations from the CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0]
        
       // let latitude = userLocation.coordinate.latitude
       // let longitude = userLocation.coordinate.longitude
        
        displayLocation(latitude: 43.65, longitude: -79.38, title: "Your location", subtitle: "sample")
        
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

