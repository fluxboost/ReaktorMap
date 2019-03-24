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
import NotificationBannerSwift

class ReaktorMapViewController: UIViewController {

	// MARK: - Outlets
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var mapView: MKMapView!
	
	// MARK: - Properties
	var userLocationManager = UserLocationManager.shared
	private var viewModel = ReaktorMapViewModel()
	private var selectedTweet: Status?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		viewModel.delegate = self
		userLocationManager.locationManager.delegate = self
		
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
	
	/**
	Get the user's current location as CLLocation
	*/
	private func fetchUserLocation() -> CLLocation {
		return mapView.userLocation.location!
	}

	/**
	Add tweets in specific directions and distances directly around the user so they're viewable.
	*/
	private func addNewTweetsToMap(newTweets: [Status]) {
		
		var count = 0
		
		for tweet in newTweets {
			if count == 0 {
				addTweetToMap(tweet: tweet, bearing: .north, count: count)
			} else if count == 1 {
				addTweetToMap(tweet: tweet, bearing: .east, count: count)
			} else if count == 2 {
				addTweetToMap(tweet: tweet, bearing: .west, count: count)
			} else if count == 3 {
				addTweetToMap(tweet: tweet, bearing: .south, count: count)
			} else if count == 4 {
				addTweetToMap(tweet: tweet, bearing: .northwest, count: count)
			}
			
			count += 1
		}
	}
	
	/**
	Add tweet to the map in certain areas around the user.
	*/
	private func addTweetToMap(tweet: Status, bearing: Bearing, count: Int) {
		
		let annotationLocation = LocationNearUser.locationWithBearing(bearing: bearing, distanceMeters: 200, origin: fetchUserLocation().coordinate)
		
		let tweetCoordinate = CLLocationCoordinate2D(latitude: annotationLocation.latitude,
												  longitude: annotationLocation.longitude);
		let annotation = MKPointAnnotation();
		annotation.coordinate = tweetCoordinate;
		annotation.title = tweet.user.screenName
		annotation.subtitle = String(count)
		
		mapView.addAnnotation(annotation);
	}
	
	/**
	Remove tweets from the view model, fade them out on the map, then remove them from the map view.
	*/
	private func removeCurrentTweets() {
		let allAnnotations = self.mapView.annotations
		
		for annotation in allAnnotations {
			let annotationView = mapView.view(for: annotation)
			
			// Prevent user location annotation from being removed from the view.
			if !annotation.isKind(of: MKUserLocation.self) {
				DispatchQueue.main.async {
					if let annotationView = annotationView {
						UIView.animate(withDuration: 2, delay: 0, options: .curveEaseOut, animations: {
							annotationView.alpha = 1.0
							annotationView.layoutIfNeeded()
						}) { completion in
							annotationView.alpha = 0.0
							annotationView.layoutIfNeeded()
							self.mapView.removeAnnotation(annotation)
						}
					}
				}
			}
		}
		
		self.mapView.removeAnnotations(allAnnotations)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "goToTwitterWebView" {
			let twitterModalViewController = segue.destination as! TwitterModalViewController
			if let selectedTweet = selectedTweet {
				twitterModalViewController.delegate = self
				twitterModalViewController.idStr = selectedTweet.idStr
				twitterModalViewController.handle = selectedTweet.user.screenName
			} else {
				print("Couldn't get web address")
			}
		}
	}	
}

extension ReaktorMapViewController: ReaktorMapViewModelDelegate {
	
	/**
	View model delegate function to update the view model and display the new tweets
	*/
	func didAddTweets(updatedViewModel: ReaktorMapViewModel, newTweets: [Status]) {
		viewModel = updatedViewModel
		
		if newTweets.count > 0  {
			removeCurrentTweets()
			addNewTweetsToMap(newTweets: newTweets)
		} else {
			let banner = StatusBarNotificationBanner(title: "No tweets found, will retry every 10 seconds.", style: .danger)
			banner.show()
		}
	}
	
	/**
	View model delegate to resend the current query to update the tweets.
	*/
	func refreshTweets() {
		viewModel.fetchTweets(query: searchBar.text!, count: 4, resultType: "recent", location: fetchUserLocation())
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
}

// MKMapView Delegate

extension ReaktorMapViewController: MKMapViewDelegate {
	
	/**
	Fade the new tweets in.
	*/
	func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
		DispatchQueue.main.async {
			UIView.animate(withDuration: 2, delay: 0, options: .curveEaseOut, animations: {
				for view in views {
					view.alpha = 0.0
					view.layoutIfNeeded()
				}
			}) { completion in
				for view in views {
					view.alpha = 1.0
					view.layoutIfNeeded()
				}
			}
		}
	}
	
	/**
	When the user selects an annotation it opens the tweet in a web view.
	*/
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		if let annotation = view.annotation {
			if let subtitle = annotation.subtitle! {
				let annotationCount = Int(subtitle)
				selectedTweet = viewModel.tweets[annotationCount!]
				viewModel.stopRefreshTimer()
				performSegue(withIdentifier: "goToTwitterWebView", sender: self)
			}
		} else {
			print("Error")
			let banner = StatusBarNotificationBanner(title: "An error occured retrieving the tweet, please refresh the query.", style: .danger)
			banner.show()
		}
	}
}

extension ReaktorMapViewController: UISearchBarDelegate {
	
	/**
	When search is cancelled, clear the search bar and reset the map.
	*/
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.text = ""
		searchBar.endEditing(true)
		removeCurrentTweets()
	}
	
	/**
	When the search button is pressed, the view model fetches tweets to show on the map.
	*/
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		mapView.setUserTrackingMode(.follow, animated: true)
		viewModel.fetchTweets(query: searchBar.text!, count: 5, resultType: "recent", location: fetchUserLocation())
		searchBar.endEditing(true)
	}
}

extension ReaktorMapViewController: TwitterModalViewControllerDelegate {
	
	func didReturnFromTwitterWebView() {
		viewModel.resumeRefreshTimer()
	}
}
