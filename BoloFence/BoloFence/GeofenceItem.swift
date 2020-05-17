//
//  geofenceUser.swift
//  BoloFence
//
//  Created by Luca D'Ambrosio on 04/05/2020.
//  Copyright © 2020 Luca D'Ambrosio. All rights reserved.
//

import Foundation
import CoreLocation

struct GeofenceItem {
    var latitude: String
    var longitude: String
    var activity: String
    var dateTime: String
    var message: String
    var numberGeofence: String
    var address: CLPlacemark
}
