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
    
    // variable for user location
    var userLocation = CLLocation()
    
    // variables to store the details on the user actions
    var city = ""
    var cityList = [String](repeating: "", count: 3)
    var countList = [Int](repeating: 0, count: 3)
    var cityCoordinateList = [CLLocationCoordinate2D](repeating: CLLocationCoordinate2D(latitude: 0, longitude: 0), count:3)
    var annotationList = [MKPointAnnotation](repeating: MKPointAnnotation(), count:3)
    var drawPolygon = false
    var markerCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // hiding the button at the time of view did load
        btnDirection.isHidden = true
        
        // assign the delegate of CLLocationManagerDelegate to this class
        locationManager.delegate = self
        
        // assign the delegate of MKMapViewDelegate to this class
        mapView.delegate = self
        
        // assign the best accuracy of the location
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // requesting the user for the location access
        locationManager.requestWhenInUseAuthorization()
        
        // updating the location of the user as per movement
        locationManager.startUpdatingLocation()
        
        // double tap gesture for adding the markers
        let lpGesture = UITapGestureRecognizer(target: self, action: #selector(addMarker))
        lpGesture.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(lpGesture)
    }
    
    //MARK: - method for long press gesture
    @objc func addMarker(gesture: UIGestureRecognizer) {
        let touchPoint = gesture.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        // method to find the province of location
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if(error != nil){
                print(error!)
            } else{
                if let placemark = placemarks?[0]{
                    
                    self.city = ""
                    
                    // adding markers only if cities are from ontario
                    if placemark.administrativeArea != nil && placemark.administrativeArea == "ON" {
                        
                        self.city = placemark.locality!
                        
                        let distanceThreshold = 1000.0 // meters
                        for i in 0..<self.annotationList.count {
                            let distance = location.distance(from: CLLocation.init(latitude: self.annotationList[i].coordinate.latitude,
                                                                                   longitude: self.annotationList[i].coordinate.longitude))
                            // if user tap on the marker or near by marker then remove that particular marker
                            if  distance < distanceThreshold
                            {
                                print("removing the annotation as distance is \(distance)")
                                self.mapView.removeAnnotation(self.annotationList[i])
                                self.mapView.removeOverlays(self.mapView.overlays)
                                for v in self.view.subviews {
                                    if v is UILabel {
                                       v.removeFromSuperview()
                                   }
                                }
                                
                                self.countList[i] = 0
                                self.cityList[i] = ""
                                self.cityCoordinateList[i] = CLLocationCoordinate2D(latitude: 0, longitude: 0)
                                self.markerCount -= 1
                                self.annotationList[i] = MKPointAnnotation()
                                
                                self.btnDirection.isHidden = true
                                
                                print("Marker for \(self.markerCount)")
                                print("Province: \(placemark.administrativeArea!)")
                                print("City list: \(self.cityList)")
                                print("Count list: \(self.countList)")
                                print("drawPolygon : \(self.drawPolygon)")
                                
                                return
                            }
                        }
                        
                        // adding markers if number of marker is less than 4 else remove all 3 and adding new one
                        if(self.markerCount < 3){
                            
                            // if the same city is selected again then don't add the marker
                            for i in 0..<self.cityList.count{
                                if(self.cityList[i] == self.city){
                                    print("City \(self.city) already there")
                                    return
                                }
                            }
                            
                            // adding annotation for the coordinates
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = coordinate
                                                      
                            // updating arrays and giving annotation title as per the selection of marker
                            if(self.countList[0] == 0){
                                self.countList[0] = 1
                                self.cityList[0] = self.city
                                self.cityCoordinateList[0] = coordinate
                                annotation.title = "A"
                                self.annotationList[0] = annotation
                            } else if(self.countList[1] == 0){
                                self.countList[1] = 1
                                self.cityList[1] = self.city
                                self.cityCoordinateList[1] = coordinate
                                annotation.title = "B"
                                self.annotationList[1] = annotation
                            } else if(self.countList[2] == 0){
                                self.countList[2] = 1
                                self.cityList[2] = self.city
                                self.cityCoordinateList[2] = coordinate
                                annotation.title = "C"
                                self.annotationList[2] = annotation
                            }
                            self.mapView.addAnnotation(annotation)
                            self.markerCount += 1
                            
                        } else {
                            // if user tap is not near the exiting markers and also there's already three markers then remove them and add new marker
                            self.markerCount = 1
                            self.mapView.removeAnnotations(self.mapView.annotations)
                            self.mapView.removeOverlays(self.mapView.overlays)
                            for v in self.view.subviews {
                                if v is UILabel {
                                   v.removeFromSuperview()
                               }
                            }
                            self.displayLocation(latitude: 43.65, longitude: -79.38, title: "Your location", subtitle: "you are here")
                            
                            self.countList = [1,0,0]
                            self.cityList = [self.city, "", ""]
                            self.cityCoordinateList = [coordinate, CLLocationCoordinate2D(latitude: 0, longitude: 0),CLLocationCoordinate2D(latitude: 0, longitude: 0)]
        
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = coordinate
                            annotation.title = "A"
                            self.annotationList = [annotation, MKPointAnnotation(), MKPointAnnotation()]
                            self.mapView.addAnnotation(annotation)
                            
                        }
                        
                        // setting draw polygon flag true if three markers are there
                        self.drawPolygon = false
                        self.btnDirection.isHidden = true
                        if(self.countList[0] != 0 && self.countList[1] != 0 && self.countList[2] != 0){
                            self.mapView.removeOverlays(self.mapView.overlays)
                            for v in self.view.subviews {
                                if v is UILabel {
                                   v.removeFromSuperview()
                               }
                            }
                            self.drawPolygon = true
                            self.btnDirection.isHidden = false
                        }
                        
                        print("Marker for \(self.markerCount)")
                        print("Province: \(placemark.administrativeArea!)")
                        print("City list: \(self.cityList)")
                        print("Count list: \(self.countList)")
                        print("drawPolygon : \(self.drawPolygon)")
                        
                        // draw polygon if the drawPolygon flag is trye
                        if(self.drawPolygon){
                           self.drawingPolygon()
                        }
        
                    }
                }
            }
        }
    }
    
    //MARK: - method to draw polygon
    func drawingPolygon(){
        print("drawing the Polygon")
        let polygon = MKPolygon(coordinates: cityCoordinateList, count: cityCoordinateList.count)
        mapView.addOverlay(polygon)
        
        // method call to display the distance between markers
        findTheDistnceBetweenMarkers()
    }
    
    //MARK: - method to find the distance between markers
    func findTheDistnceBetweenMarkers(){
        
        // createing location object for all three markers
        let marker0 = CLLocation(latitude: cityCoordinateList[0].latitude, longitude: cityCoordinateList[0].longitude)
        let marker1 = CLLocation(latitude: cityCoordinateList[1].latitude, longitude: cityCoordinateList[1].longitude)
        let marker2 = CLLocation(latitude: cityCoordinateList[2].latitude, longitude: cityCoordinateList[2].longitude)
        
        // stroing the value of distance between 2 markers
        let distanceInKm0 = "AB= " + String(format: "%.2f", (marker0.distance(from: marker1))/1000)
        let distanceInKm1 = "BC= " + String(format: "%.2f", (marker1.distance(from: marker2))/1000)
        let distanceInKm2 = "AC= " + String(format: "%.2f", (marker2.distance(from: marker0))/1000)
        
        // creating CLLocationCoordinate2D for all three markers that will be used to find the midpoint of polygon line
        let marker02d = CLLocationCoordinate2D(latitude: cityCoordinateList[0].latitude, longitude: cityCoordinateList[0].longitude)
        let marker12d = CLLocationCoordinate2D(latitude: cityCoordinateList[1].latitude, longitude: cityCoordinateList[1].longitude)
        let marker22d = CLLocationCoordinate2D(latitude: cityCoordinateList[2].latitude, longitude: cityCoordinateList[2].longitude)

        
        // showing the label for distance
        showLabelForDistance(source: marker02d, destination: marker12d, distance: distanceInKm0, tag: 0)
        showLabelForDistance(source: marker12d, destination: marker22d, distance: distanceInKm1, tag: 1)
        showLabelForDistance(source: marker22d, destination: marker02d, distance: distanceInKm2, tag: 2)
        
        print("distance0: \(distanceInKm0)")
        print("distance1: \(distanceInKm1)")
        print("distance2: \(distanceInKm2)")
        
    }
    
    // MARK: - method to show the label near polygon line
    func showLabelForDistance(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, distance: String, tag: Int){
        // finding the mid point of polyline
        let latDiff =  source.latitude - destination.latitude
        let longDiff =  source.longitude - destination.longitude
        let latMulti = latDiff/2
        let longMulti = longDiff/2
        let lat = source.latitude - latMulti
        let long = source.longitude - longMulti
        //let middle = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        // creating the label object to display the distance
        let label = UILabel()
        let coordinate = mapView.convert(CLLocationCoordinate2D(latitude: lat, longitude: long), toPointTo: label)
        label.frame = CGRect(x: coordinate.x-100, y: coordinate.y-25, width: 200, height: 50)
        label.text = "\(distance) Km"
        label.textColor = .black
        label.textAlignment = .center
        label.tag = tag
        view.addSubview(label)
        
       // displayLocation(latitude: lat, longitude: long, title: "\(distance) Km", subtitle: "")
        
    }

    //MARK: - method to draw the route between three markers
    @IBAction func clickDirection(_ sender: UIButton) {
        
        self.mapView.removeOverlays(self.mapView.overlays)
        for v in self.view.subviews {
            if v is UILabel {
               v.removeFromSuperview()
           }
        }
        
        let marker0 = MKPlacemark(coordinate: cityCoordinateList[0])
        let marker1 = MKPlacemark(coordinate: cityCoordinateList[1])
        let marker2 = MKPlacemark(coordinate: cityCoordinateList[2])
        
        // calling the function that will calculate the direction between these markers
        calculateDirection(source: marker0, destination: marker1)
        calculateDirection(source: marker1, destination: marker2)
        calculateDirection(source: marker2, destination: marker0)
        
    }
    
    // MARK: -  calculating the direction between 2 points on the map
    func calculateDirection(source: MKPlacemark, destination: MKPlacemark) {
        // requesting for the direction
        let directionRequest = MKDirections.Request()
        
        // assigning the source and destination
        directionRequest.source = MKMapItem(placemark: source)
        directionRequest.destination = MKMapItem(placemark: destination)
        
        // assiging the transport type
        directionRequest.transportType = .automobile
        
        // calculating the direction
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
           guard let directionResponse = response else {return}
           
           let route = directionResponse.routes[0]
           self.mapView.addOverlay(route.polyline, level: .aboveRoads)
           
           // defining the bounding map rectangle and then setting the visibility
           let rect = route.polyline.boundingMapRect
           self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
           
          // removing this line helps to set the region for all three markers
          // self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
       }
    }
    
    //MARK: - method to draw polyline
    func drawingPolyline(){
        print("drawing the Polyline")
        let polyline = MKPolyline(coordinates: cityCoordinateList, count: cityCoordinateList.count)
        mapView.addOverlay(polyline)
    }
    
    
    //MARK: - method didUpdateLocations from the CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      // current location of the user
      userLocation = locations[0]
        
       let latitude = userLocation.coordinate.latitude
       let longitude = userLocation.coordinate.longitude
        
       displayLocation(latitude: latitude, longitude: longitude, title: "Your location", subtitle: "you are here")
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

// providing extention of ViewController class
extension ViewController: MKMapViewDelegate{
    
    //MARK: - method to renderer for overlay
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon{
            let renderer = MKPolygonRenderer(overlay: overlay)
            renderer.fillColor = UIColor.red.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.green
            renderer.lineWidth = 3
            return renderer
        } else if overlay is MKPolyline {
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.strokeColor = UIColor.blue
            rendrer.lineWidth = 3
            return rendrer
        }
        return MKOverlayRenderer()
    }
    
    //MARK: - method for viewFor annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        } else if (annotation.title != "Your location") {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom") ?? MKPinAnnotationView()
            annotationView.image = UIImage(named: "ic_place_2x")
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return annotationView
        }
        return nil
    }
    
    //MARK: - method for callout accessory control tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let coordinate0 = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let coordinate1 = CLLocation(latitude: view.annotation!.coordinate.latitude, longitude: view.annotation!.coordinate.longitude)
        let distanceInKm = (coordinate1.distance(from: coordinate0))/1000
        
        let alertController = UIAlertController(title: "Distance", message: "Distance from your location is \(String(format:"%.2f",distanceInKm)) Km.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

