//
//  ReaktorMapViewController.swift
//  ReaktorMap
//
//  Created by Harry Liddell on 20/03/2019.
//  Copyright © 2019 harryliddell. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Alamofire

class ReaktorMapViewController: UIViewController {

	// MARK: - Outlets
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var mapView: MKMapView!
	
	// MARK: - Properties
	var userLocationManager = UserLocationManager.shared
	private var viewModel = ReaktorMapViewModel()
	private var selectedUrl: String?
	
	// MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		viewModel.delegate = self
		
		if userLocationManager.checkIfAuthorised() {
			setupLocationManager()
		} else {
			userLocationManager.requestAlwaysAuthorization()
		}
		
		viewModel.authenticate()
    }
	
	/**
	Sets the location manager delegate and begins tracking the user.
	*/
	private func setupLocationManager() {
		userLocationManager.locationManager.delegate = self
		mapView.setUserTrackingMode(.follow, animated: true)
		applyUserRegionToMap()
	}
	
	/**
	Sets the map's centre and zoom to the user's location
	*/
	private func applyUserRegionToMap() {
		let userLocation = mapView.userLocation
		let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
		mapView.setRegion(region, animated: false)
	}
	
	private func fetchUserLocation() -> CLLocation {
		return mapView.userLocation.location!
	}
	
	private func fadeOutOldTweets() {
		
	}
	
	private func addNewTweetsToMap(newTweets: [Status]) {
		
		var count = 0
		
		for tweet in newTweets {
			if count == 0 {
				addTweetToMap(tweet: tweet, bearing: .north)
			} else if count == 1 {
				addTweetToMap(tweet: tweet, bearing: .east)
			} else if count == 2 {
				addTweetToMap(tweet: tweet, bearing: .west)
			}
			
			count += 1
		}
	}
	
	private func addTweetToMap(tweet: Status, bearing: Bearing) {
		
		let annotationLocation = LocationNearUser.locationWithBearing(bearing: bearing, distanceMeters: 200, origin: fetchUserLocation().coordinate)
		
		let tweetCoordinate = CLLocationCoordinate2D(latitude: annotationLocation.latitude,
												  longitude: annotationLocation.longitude);
		let annotation = MKPointAnnotation();
		annotation.coordinate = tweetCoordinate;
		annotation.title = tweet.user.screenName
		
		if let urlElement = tweet.entities.urls.first {
			annotation.subtitle = urlElement.url
		}
		
		mapView.addAnnotation(annotation);
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "goToTwitterWebView" {
			let twitterModalViewController = segue.destination as! TwitterModalViewController
			if let selectedUrl = selectedUrl {
				twitterModalViewController.webAddress = selectedUrl
			} else {
				print("Couldn't get web address")
			}
		}
	}
}

extension ReaktorMapViewController: ReaktorMapViewModelDelegate {
	
	func didAddTweets(updatedViewModel: ReaktorMapViewModel, newTweets: [Status]) {
		viewModel = updatedViewModel
		
		if newTweets.count > 0  {
			fadeOutOldTweets()
			addNewTweetsToMap(newTweets: newTweets)
		}
	}
}

// CLLocationManager Delegate

extension ReaktorMapViewController: CLLocationManagerDelegate {
	
	/**
	When user enables location services, setup map.
	*/
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status != .denied && status != .notDetermined {
			setupLocationManager()
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
	}
}

// MKMapView Delegate

extension ReaktorMapViewController: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
		
		UIView.animate(withDuration: 1.5, animations: {
			for view in views {
				view.alpha = 0.0
			}
		}) { (Bool) in
			for view in views {
				view.alpha = 1.0
			}
		}
	}
	
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		if let annotation = view.annotation {
			selectedUrl = annotation.subtitle!
			performSegue(withIdentifier: "goToTwitterWebView", sender: self)
		} else {
			print("Error")
		}
	}
}

extension ReaktorMapViewController: UISearchBarDelegate {
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.text = ""
		searchBar.endEditing(true)
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		viewModel.fetchTweets(query: searchBar.text!, count: 3, resultType: "recent", location: fetchUserLocation())
	}
}
