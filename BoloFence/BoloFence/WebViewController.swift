//
//  WebViewController.swift
//  BoloFence
//
//  Created by Luca D'Ambrosio on 09/05/2020.
//  Copyright © 2020 Luca D'Ambrosio. All rights reserved.
//

import UIKit
import WebKit
import Contacts
import MapKit
import CoreLocation

class WebViewController: UIViewController {
    
    var url: String = ""
    var lat: String = ""
    var lon: String = ""
    var address: CLPlacemark? = nil
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("WebView: ", url)
        if url.starts(with: "http"){
            labelMessage.removeFromSuperview()
            mapView.removeFromSuperview()
            let topConst = NSLayoutConstraint(item: self.webView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
            let botConst = NSLayoutConstraint(item: self.webView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
            let leftConst = NSLayoutConstraint(item: self.webView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
            let rigthConst = NSLayoutConstraint(item: self.webView, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
            
            NSLayoutConstraint.activate([topConst,botConst,leftConst,rigthConst])
            
            self.webView.translatesAutoresizingMaskIntoConstraints = false
            load(url)
            
            
        } else {
            print("Notification: ", url)
            
            webView.removeFromSuperview()
            labelMessage.text = url

            let latitude = Double(lat)
            let longitude = Double(lon)
            let coords = CLLocationCoordinate2DMake(latitude!, longitude!)

            let addressView = [CNPostalAddressStreetKey: address?.thoroughfare, CNPostalAddressCityKey: address?.locality, CNPostalAddressPostalCodeKey: address?.postalCode, CNPostalAddressISOCountryCodeKey:  address?.isoCountryCode] as [String : Any]
            let place = MKPlacemark(coordinate: coords, addressDictionary: addressView)
            
            self.mapView.addAnnotation(place)
        }
    }
    
    func load(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
    }
}
