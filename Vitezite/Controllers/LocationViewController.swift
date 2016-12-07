
//
//  LocationViewController.swift
//  Vitezite
//
//  Created by BHUVAN SHARMA on 19/07/16.
//  Copyright © 2016 Suresh Vijay. All rights reserved.
//

import UIKit
import MapKit

protocol UpdateLocationDelegate : class {
    func setAddressfromMap(location : String)
}

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class LocationViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblAddress: ExpandableFontLabel!
    weak var delegete : UpdateLocationDelegate?
    var resultSearchController:UISearchController? = nil
    @IBOutlet weak var searchController: UISearchBar!
    
    @IBOutlet weak var serachView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblAddress.hidden = true
        
        let appd = UIApplication.sharedApplication().delegate as! AppDelegate
        appd.findMyLocation()
        
        // Do any additional setup after loading the view, typically from a nib.
        let coordinate = CLLocationCoordinate2DMake(appd.userLat, appd.userLongi)
        let span = MKCoordinateSpanMake(0.003, 0.003)
        let region = MKCoordinateRegionMake(coordinate, span)
        mapView.setRegion(region, animated:true)
        mapView.showsUserLocation = true
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        //        annotation.title = "title"
        //        annotation.subtitle = "subtitle"
        self.mapView.addAnnotation(annotation)
        mapView.showsUserLocation = true
        
        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        //        searchController.sizeToFit()
        //        searchController.placeholder = "Search for places"
        //        searchController = resultSearchController?.searchBar
        self.navigationController?.navigationBarHidden = false;
        
        //do something like background color, title, etc you self
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionForBack(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: {
            
        })
        // self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func actionForDone(sender: AnyObject) {
        //setCurrentAnnotaionLocation(self.mapView.ann)
        
        //   mapView.showsUserLocation = true
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapView.region.center
        setCurrentAnnotaionLocation(annotation)
        delegete?.setAddressfromMap(lblAddress.text!)
        self.navigationController?.dismissViewControllerAnimated(true, completion: {
            
        })
    }
    
    func setCurrentAnnotaionLocation( annotation:MKAnnotation){
        let droppedAt = annotation.coordinate
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: droppedAt.latitude, longitude:droppedAt.longitude)
        geocoder.reverseGeocodeLocation(location) {
            (placemarks, error) -> Void in
            if error == nil && placemarks!.count > 0 {
                let placeMark = placemarks!.last! as CLPlacemark
                self.lblAddress.hidden = false
                self.lblAddress.text = "\(placeMark.thoroughfare != nil ? placeMark.thoroughfare! : "" ), \(placeMark.postalCode != nil ? placeMark.postalCode! : ""), \(placeMark.locality != nil ? placeMark.locality! : ""), \(placeMark.country != nil ? placeMark.country! : "")"
                //self.manager.stopUpdatingLocation()
            }
        }
        print(droppedAt)
    }
    
    // MARK: - MKMapView delegate
    
    // Called when the annotation was added
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
            pinView?.draggable = true
        }
        else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == MKAnnotationViewDragState.Ending {
            let droppedAt = view.annotation?.coordinate
            let geocoder = CLGeocoder()
            let location = CLLocation(latitude: droppedAt!.latitude, longitude:droppedAt!.longitude)
            geocoder.reverseGeocodeLocation(location) {
                (placemarks, error) -> Void in
                if error == nil && placemarks!.count > 0 {
                    let placeMark = placemarks!.last! as CLPlacemark
                    self.lblAddress.hidden = false
                    self.lblAddress.text = "\(placeMark.thoroughfare != nil ? "\(placeMark.thoroughfare!), " : "" )\(placeMark.postalCode != nil ? "\(placeMark.postalCode!), " : "")\(placeMark.locality != nil ? "\(placeMark.locality!), " : "")\(placeMark.country != nil ? placeMark.country! : "")"
                    //self.manager.stopUpdatingLocation()
                }
            }
            print(droppedAt)
        }
    }
    
    // MARK: - Navigation
    
    @IBAction func didReturnToMapViewController(segue: UIStoryboardSegue) {
        print(__FUNCTION__)
    }
}

extension LocationViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        // selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        
        mapView.setRegion(region, animated: true)
        
        setCurrentAnnotaionLocation(annotation)
    }
}
