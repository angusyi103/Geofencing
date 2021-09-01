//
//  ViewController.swift
//  GeofencingTest
//
//  Created by Angus Yi on 2020/11/12.
//

import UIKit
import MapKit
import CoreLocation

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class ViewController: UIViewController {
    
    @IBOutlet weak var mkMapView: MKMapView!
    @IBOutlet weak var addPinBtn: UIButton!
    
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    
    let locationManager = CLLocationManager()
    
    private var currentCoordinate: CLLocationCoordinate2D?
    private var annotationCalloutView: AnnotationCalloutView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setUpUI()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = (locationSearchTable as UISearchResultsUpdating)
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mkMapView
        locationSearchTable.handleMapSearchDelegate = self
        
    }
    
    private func setUpUI() {
        mkMapView.delegate = self
        addPinBtn.backgroundColor = .blue
        addPinBtn.layer.cornerRadius = addPinBtn.frame.height/2
    }
    
    @IBAction func addPinPressed(_ sender: Any) {
        if CLLocationManager.locationServicesEnabled() {
            mkMapView.removeAnnotations(mkMapView.annotations)
            let annotation = MKPointAnnotation()
            let location = CLLocation.init(latitude: currentCoordinate!.latitude, longitude: currentCoordinate!.longitude)
            let address = CLGeocoder.init()
            address.reverseGeocodeLocation(location, completionHandler: { (placeMarks, error) in
                if error == nil && placeMarks!.count > 0 {
                    var placeMark: CLPlacemark!
                    placeMark = placeMarks?[0]
                    // Location name
                    if let locationName = placeMark.location {
                        print(locationName)
                    }
                    // Street address
                    if let street = placeMark.thoroughfare {
                        print(street)
                    }
                    // City
                    if let city = placeMark.locality {
                        print(city)
                    }
                    // State
                    if let state = placeMark.administrativeArea {
                        print(state)
                    }
                    // Zip code
                    if let zipCode = placeMark.postalCode {
                        print(zipCode)
                    }
                    // Country
                    if let country = placeMark.country {
                        print(country)
                    }
                }
            })
            annotation.coordinate = currentCoordinate!
            mkMapView.addAnnotation(annotation)
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: currentCoordinate!, span: span)
            mkMapView.setRegion(region, animated: true)
        }
    }
    
    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
        mkMapView.removeAnnotations(mkMapView.annotations)
        let viewLocation = sender.location(in: self.mkMapView)
        let locCoord = self.mkMapView.convert(viewLocation, toCoordinateFrom: self.mkMapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locCoord
        annotation.title = "customPoint"
        annotation.subtitle = "setPoint"
        let location = CLLocation.init(latitude: locCoord.latitude, longitude: locCoord.longitude)
        let address = CLGeocoder.init()
        address.reverseGeocodeLocation(location, completionHandler: { (placeMarks, error) in
            if error == nil && placeMarks!.count > 0 {
                var placeMark: CLPlacemark!
                placeMark = placeMarks?[0]
                // Location name
                if let subThoroughfare = placeMark.subThoroughfare {
                    print(subThoroughfare)
                }
                // Street address
                if let street = placeMark.thoroughfare {
                    print(street)
                }
                // City
                if let city = placeMark.locality {
                    print(city)
                }
                // State
                if let state = placeMark.administrativeArea {
                    print(state)
                }
                // Zip code
                if let zipCode = placeMark.postalCode {
                    print(zipCode)
                }
                // Country
                if let country = placeMark.country {
                    print(country)
                }
            }
        })
        mkMapView.addAnnotation(annotation)
    }
}

//MARK: AnnotationCalloutViewDelegate
extension ViewController: AnnotationCalloutViewDelegate {
    func saveBtnPressed() {
//        annotationCalloutView.
    }
}

//MARK: CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locationValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("location = \(locationValue.latitude), \(locationValue.longitude)")
        currentCoordinate = CLLocationCoordinate2D(latitude: locationValue.latitude, longitude: locationValue.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: currentCoordinate!, span: span)
        mkMapView.setRegion(region, animated: true)
    }
}

//MARK: MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var annView = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annView == nil {
            annView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
//            annView?.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
//            let base = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
//            base.isUserInteractionEnabled = true
//            base.layer.cornerRadius = 3.0
//            base.clipsToBounds = true
//            base.backgroundColor = UIColor.white
//
//            annView?.addSubview(base)
//            annView?.annotation = annotation
//        } else {
//            annView?.annotation = annotation
        }
        
        annView?.canShowCallout = false
        
        return annView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        let view = Bundle.main.loadNibNamed("AnnotationCalloutView", owner: nil, options: nil)
//        let calloutView = view?[0] as! AnnotationCalloutView
        annotationCalloutView = AnnotationCalloutView.instanceFromNib() as? AnnotationCalloutView
        annotationCalloutView?.initUI()
        view.addSubview(annotationCalloutView!)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension ViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mkMapView.removeAnnotations(mkMapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality, let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mkMapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mkMapView.setRegion(region, animated: true)
    }
}
