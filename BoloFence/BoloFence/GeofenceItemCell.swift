//
//  GeofenceTableViewCell.swift
//  BoloFence
//
//  Created by Luca D'Ambrosio on 04/05/2020.
//  Copyright © 2020 Luca D'Ambrosio. All rights reserved.
//

import UIKit

class GeofenceItemCell: UITableViewCell {

    @IBOutlet weak var numberGeofenceLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var geofenceItem: GeofenceItem? {
        didSet
        {
            numberGeofenceLabel.text = "Geofence " + geofenceItem!.numberGeofence
            latitudeLabel.text = "Latitude: " + geofenceItem!.latitude
            longitudeLabel.text = "Longitude: " + geofenceItem!.longitude
            activityLabel.text = "Activity: " + geofenceItem!.activity
            bodyLabel.text = "Message: " + geofenceItem!.message
            dateLabel.text = geofenceItem?.dateTime
        }
    }
    
}
