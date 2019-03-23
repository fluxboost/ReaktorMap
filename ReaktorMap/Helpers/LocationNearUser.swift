//
//  CLLocation+Move.swift
//  ReaktorMap
//
//  Created by Harry Liddell on 23/03/2019.
//  Copyright © 2019 harryliddell. All rights reserved.
//

import Foundation
import CoreLocation

enum Bearing: Double {
	case north = 0
	case northeast = 45
	case east = 90
	case southeast = 125
	case south = 180
	case southwest = 225
	case west = 270
	case northwest = 315
}

class LocationNearUser {
	
	static func locationWithBearing(bearing: Bearing, distanceMeters: Double, origin: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
		let distRadians = distanceMeters / (6372797.6) // earth radius in meters
		
		let lat1 = origin.latitude * .pi / 180
		let lon1 = origin.longitude * .pi / 180
		
		let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearing.rawValue))
		let lon2 = lon1 + atan2(sin(bearing.rawValue) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))
		
		return CLLocationCoordinate2D(latitude: lat2 * 180 / .pi, longitude: lon2 * 180 / .pi)
	}
	
	static func getRandomBearing() {
		
	}
}
