//
//  MapViewController.swift
//  BoloFence
//
//  Created by Luca D'Ambrosio on 10/05/2020.
//  Copyright © 2020 Luca D'Ambrosio. All rights reserved.
//

import UIKit
import MapKit
import Contacts

class MapViewController: UIViewController  {
    
    var numGeofence: String = ""
    var city: String = ""
    var address: String = ""
    var messageMap: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var arrayLocation: [GeofenceItem] = []
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.userLocation.title = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addGeofence()
    }
    
    func addGeofence() {
        for element in arrayLocation {
            numGeofence = element.numberGeofence
            city = element.address.locality!
            address = element.address.thoroughfare!
            latitude = Double(element.latitude)!
            longitude = Double(element.longitude)!
            
            if (element.message.starts(with: "http")){
                messageMap = ""
            } else {
                messageMap = element.message
            }
        }
        
        let coords = CLLocationCoordinate2DMake(latitude, longitude)
        let addressView = [CNPostalAddressStateKey: "Geofence " + numGeofence, CNPostalAddressPostalCodeKey: messageMap, CNPostalAddressCityKey: city, CNPostalAddressStreetKey: address] as [String : Any]
        let place = MKPlacemark(coordinate: coords, addressDictionary: addressView)
        self.mapView.showsUserLocation = false
        self.mapView.addAnnotation(place)

    }
}
