//
//  ViewController.swift
//  BoloFence
//
//  Created by Luca D'Ambrosio on 16/05/2020.
//  Copyright © 2020 Luca D'Ambrosio. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreMotion
import Alamofire

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //Variable
    var user : String? = ""
    var latitude: Double? = 0.0
    var longitude: Double? = 0.0
    var latitude0: Double? = 0.0
    var longitude0: Double? = 0.0
    var timerActivity: Double = 5.0
    var activity: String = ""
    var activity0: String? = ""
    var distanceActivity: Double = 0
    var distance: Double = 0
    var timer0: Double = 5.0
    var messageResponse : String = ""
    var selectedRow : Int = 0
    var firstLocation: CLPlacemark? = nil
    
    //Class object
    private  let motionManager = CMMotionActivityManager()
    private  let locationManager = CLLocationManager()
    private var notificationPublisher = NotificationPublisher()
    private var viewModel = GeofenceItemModel()
    private let geoCoder = CLGeocoder()
    private var cellTable = GeofenceItemCell()
    
    //UI
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startActivityUpdates()
        self.getUserLocation()
        Timer.scheduledTimer(timeInterval: self.timer0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    @objc func fireTimer( timer: Timer) {
        if((self.activity != "stationary") && (self.activity != "unknown")) {
            self.activity0 = self.activity
            self.getUserLocation()
            
            let coordinate0 = CLLocation(latitude: self.latitude0!, longitude: self.longitude0!)
            print(coordinate0)
            
            let coordinate1 = CLLocation(latitude: self.latitude!, longitude: self.longitude!)
            print(coordinate1)
            
            let distanceInMeters = coordinate0.distance(from: coordinate1)// result is in meters
            print(String(format: "The real distance in meters is %.01fm", distanceInMeters))
            
            self.latitude0 = self.latitude
            self.longitude0 = self.longitude
            print(String(format: "The distance activity is %.01fm",self.distanceActivity))
            
            if(self.activity0 == self.activity && self.distanceActivity > distanceInMeters){
                print(self.distanceActivity)
                if(self.activity0 == "walk"){
                    self.distanceActivity -= 2
                } else if(self.activity0 == "running"){
                    self.distanceActivity -= 5
                } else if(self.activity0 == "car"){
                    self.distanceActivity -= 15
                } else if(self.activity0 == "bike"){
                    self.distanceActivity -= 10
                }
            } else {
                if (self.activity == "running"){
                    self.activity = "walk"
                }
                self.sendPosition(user: self.user!, latitude: String(self.latitude!), longitude: String(self.longitude!), activity: self.activity)
                self.timer0 = self.timerActivity
                timer.fireDate = timer.fireDate.addingTimeInterval(timer0)
            }
        } else {
            self.timer0 = self.timerActivity
            timer.fireDate = timer.fireDate.addingTimeInterval(timer0)
        }
    }
    
    // Recupero della posizione utente
    func getUserLocation() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.pausesLocationUpdatesAutomatically = true
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        self.latitude = userLocation.coordinate.latitude
        self.longitude = userLocation.coordinate.longitude
        print("Location manager: " , latitude as Any, " ", longitude as Any)
        geoCoder.reverseGeocodeLocation(userLocation, completionHandler: { (placemarks, error) in
            if error == nil {
                self.firstLocation = placemarks?[0]
            }
            else {
                print(error as Any)
            }
        })
        
        manager.stopUpdatingLocation()
        manager.allowsBackgroundLocationUpdates = false
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
    
    //Funzione che permette la comunicazione delle coordinate al server tramite richiesta HTTP GET
    func sendPosition(user: String, latitude: String, longitude: String, activity: String) {
        let timestamp = self.generateDate()
        let parameters: [String: Any?] = [
            "type": "Feature",
            "geometry":
                [
                    "type": "Point",
                    "coordinates":
                        [
                            latitude,
                            longitude
                    ]
            ], "properties":
                [
                    "user": user,
                    "activity": activity
            ]
        ]
        
        AF.request("http://192.168.1.67:3600/geofencecheck", method: .get, parameters: parameters as Parameters).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let JSON = value as? [String: Any] {
                    let status = JSON["status"] as! Bool
                    print(status)
                    if status == true {
                        let message = JSON["message"] as! String
                        self.messageResponse = message
                        print(message)
                        print(timestamp)
                        
                        
                        self.viewModel.geofenceItems.append(GeofenceItem(latitude: String(self.latitude!), longitude: String(self.longitude!), activity: self.activity, dateTime: timestamp, message: message, numberGeofence: String(self.viewModel.geofenceItems.count), address: self.firstLocation!))
                        self.notificationPublisher.sendNotification(title: "Sei entrato in un nuovo geofence", body: message, badge: 5, delayInterval: 1)
                        self.tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .bottom)
                        let secondTab = self.tabBarController
                        let nav = secondTab!.viewControllers?[1] as! UINavigationController
                        let svc = nav.topViewController as! MapViewController
                        svc.arrayLocation = self.viewModel.geofenceItems
                        self.tableView.reloadData()
                    }
                    
                }
            case .failure( _):
                print("Error in server!")
            }
        }
    }
    
    
    func startActivityUpdates() {
        
        if CMMotionActivityManager.isActivityAvailable() {
            motionManager.startActivityUpdates(to: OperationQueue.main) { (activity) in
                guard let activity = activity else {
                    return
                }
                
                if (activity.confidence == CMMotionActivityConfidence.high) {
                    print("Confidence activity: ", activity.confidence.rawValue)
                    if activity.stationary {
                        self.activity = "stationary"
                        self.timerActivity = 10.0
                        self.distanceActivity = 0.0
                        print("Activity: stationary")
                    }
                    
                    if activity.walking {
                        self.activity = "walk"
                        self.timerActivity = 5.0
                        self.distanceActivity = 10.0
                        print("Activity: walk")
                    }
                    
                    if activity.running {
                        self.activity = "running"
                        self.timerActivity = 10.0
                        self.distanceActivity = 75.0
                        print("Activity: running")
                    }
                    
                    if activity.cycling {
                        self.activity = "bike"
                        self.timerActivity = 10.0
                        self.distanceActivity = 80.0
                        print("Activity: bike")
                        
                    }
                    
                    if activity.automotive {
                        self.activity = "car"
                        self.timerActivity = 15.0
                        self.distanceActivity = 120.0
                        print("Activity: car")
                        
                    }
                    
                    if activity.unknown {
                        self.timerActivity = 1.0
                        self.distanceActivity = 0.0
                        self.activity = "unknown"
                        print("Activity: unknown")
                        
                    }
                }
            }
        }
    }
    
    func generateDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return (formatter.string(from: Date()) as NSString) as String
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "segueWeb", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
        if let indexPath = tableView.indexPathForSelectedRow {
            let selectedRow = indexPath.row
            print(selectedRow)
            let messageToView = viewModel.geofenceItems[selectedRow].message
            let addressToView = viewModel.geofenceItems[selectedRow].address
            let latitudeToView = viewModel.geofenceItems[selectedRow].latitude
            let longitudeToView = viewModel.geofenceItems[selectedRow].longitude
            
            let destinationVCWeb = segue.destination as? WebViewController
            print("Web: ", messageToView)
            destinationVCWeb!.url = messageToView
            destinationVCWeb!.address = addressToView
            destinationVCWeb!.lat = latitudeToView
            destinationVCWeb!.lon = longitudeToView
            
            
        }
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.geofenceItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "geo") as? GeofenceItemCell else {
            return UITableViewCell()
        }
        cell.geofenceItem = viewModel.geofenceItems[indexPath.row]
        return cell
    }
}
