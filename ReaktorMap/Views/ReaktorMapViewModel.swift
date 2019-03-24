//
//  ReaktorMapViewModel.swift
//  ReaktorMap
//
//  Created by Harry Liddell on 21/03/2019.
//  Copyright © 2019 harryliddell. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import Moya

protocol ReaktorMapViewModelDelegate: class {
	func didAddTweets(updatedViewModel: ReaktorMapViewModel, newTweets: [Status])
	func refreshTweets()
}

class ReaktorMapViewModel {
	
	private var timer: Timer?
	
	var tweets: [Status] = []
	
	let provider = MoyaProvider<APIService>()
	
	weak var delegate: ReaktorMapViewModelDelegate?
	
	init(){}
	
	/**
	Sends the updated view model to the view.
	*/
	func updateView(newTweets: [Status]) {
		delegate?.didAddTweets(updatedViewModel: self, newTweets: newTweets)
	}
	
	/**
	Posts authorisation request to Twitter and returns a token to authenticate future requests.
	*/
	func authenticate() {
		
		provider.request(.authenticate) { result in
			switch result {
				
			case let .success(moyaResponse):
				
				do {
					let filteredResponse = try moyaResponse.filterSuccessfulStatusCodes()
					let token = try filteredResponse.map(Token.self)
					AuthManager.saveToken(token: token)
					print(token)
				} catch {
					if let error = error as? MoyaError {
						do {
							if let body = try error.response?.mapJSON() {
								print(body)
							}
						} catch {
							print(error)
						}
					}
				}
			case let .failure(error):
				print(error.localizedDescription)
			}
		}
	}
	
	/**
	Function that constructs a query with parameters to be sent as a GET request to the Twitter API
	*/
	func fetchTweets(query: String, count: Int, resultType: String, location: CLLocation) {
		
		let latitude = String(format:"%f", location.coordinate.latitude)
		let longitude = String(format:"%f", location.coordinate.longitude)
		
		timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(refreshSearch), userInfo: nil, repeats: false)
		
		let formattedQuery = FormatHelper.formatSearchInput(input: query)
		
		provider.request(.search(query: formattedQuery, count: String(count), resultType: resultType, latitude: latitude, longitude: longitude)) { result in
			switch result {
				
			case let .success(moyaResponse):
				
				do {
					let filteredResponse = try moyaResponse.filterSuccessfulStatusCodes()
					let statuses = try filteredResponse.map(Statuses.self)
					self.tweets = statuses.statuses
					self.updateView(newTweets: statuses.statuses)
					print(statuses)
				} catch {
					if let error = error as? MoyaError {
						do {
							if let body = try error.response?.mapJSON() {
								print(body)
							}
						} catch {
							print(error)
						}
					}
				}
			case let .failure(error):
				print(error.localizedDescription)
			}
		}
	}
	
	/**
	Selector function that prompts the view to fetch new tweets.
	*/
	@objc func refreshSearch() {
		delegate?.refreshTweets()
	}
	
	/**
	Pause refresh timer to avoid updating tweets in the background and affecting the indexes.
	*/
	func resumeRefreshTimer() {
		if timer == nil {
			timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(refreshSearch), userInfo: nil, repeats: false)
		}
	}
	
	/**
	Pause refresh timer to avoid updating tweets in the background and affecting the indexes.
	*/
	func stopRefreshTimer() {
		timer?.invalidate()
	}
	
	/**
	Clears all the current tweets from the view model and stops the refresh timer.
	*/
	func clearTweets() {
		tweets = []
		timer?.invalidate()
	}
}
