//
//  UserLocationManager.swift
//  ReaktorMap
//
//  Created by Harry Liddell on 20/03/2019.
//  Copyright © 2019 harryliddell. All rights reserved.
//

import CoreLocation

/**
UserLocationManager is a singleton used store location manager defaults and provide convenience functions.
*/
class UserLocationManager {
	
	static let shared = UserLocationManager()
	var locationManager = CLLocationManager()
	
	// Private init prevents reinitialisation of singleton.
	private init () {
		locationManager.activityType = .automotiveNavigation
		locationManager.distanceFilter = 5
		locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
	}
	
	/**
	Starts tracking the user's journey in the background.
	*/
	func startTracking() {
		locationManager.startUpdatingLocation()
		locationManager.allowsBackgroundLocationUpdates = true
		locationManager.pausesLocationUpdatesAutomatically = false
	}
	
	/**
	Stops tracking the users journey and stops working in the background.
	*/
	func stopTracking() {
		locationManager.stopUpdatingLocation()
		locationManager.allowsBackgroundLocationUpdates = false
		locationManager.pausesLocationUpdatesAutomatically = true
	}
	
	/**
	Requests user to enable location services.
	*/
	func requestAlwaysAuthorization() {
		locationManager.requestAlwaysAuthorization()
	}
	
	/**
	Checks if the user has made a decision on location services.
	
	- Returns: A bool containing 'true' if the user has already decided, and 'false' if not.
	*/
	func checkIfUserHasDecidedAuthorisation() -> Bool {
		if CLLocationManager.locationServicesEnabled() {
			switch CLLocationManager.authorizationStatus() {
				case .restricted, .denied, .authorizedAlways, .authorizedWhenInUse:
					print("Location services decided")
					return true
				case .notDetermined:
					return false
			}
		} else {
			print("Location services not decided")
			return false
		}
	}
	
	/**
	Checks if the user has enabled location services of 'always' or 'when in use'
	
	- Returns: A bool containing 'true' if the user has enabled, and 'false' if not.
	*/
	func checkIfAuthorised() -> Bool {
		if CLLocationManager.locationServicesEnabled() {
			switch CLLocationManager.authorizationStatus() {
				case .notDetermined:
					print("Location services not determined yet.")
					return false
				case .restricted, .denied:
					print("Location services are disabled")
					return false
				case .authorizedAlways, .authorizedWhenInUse:
					print("Location services enabled")
					return true
			}
		} else {
			print("Location services are not enabled")
			return false
		}
	}
}
