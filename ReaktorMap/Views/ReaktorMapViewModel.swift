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
import Alamofire
import Moya

protocol ReaktorMapViewModelDelegate: class {
	func didAddTweets(updatedViewModel: ReaktorMapViewModel, newTweets: [Status])
}

class ReaktorMapViewModel {
	
	private var seconds = 0
	private var timer: Timer?
	
	var tweets: [Status] = []
	
	let provider = MoyaProvider<APIService>()
	
	weak var delegate: ReaktorMapViewModelDelegate?
	
	init(){}
	
	/**
	Called every second in order to update the view.
	*/
	func eachSecond() {
		seconds += 1
		//updateView()
	}
	
	/**
	Sends the updated view model to the view.
	*/
	func updateView(newTweets: [Status]) {
		delegate?.didAddTweets(updatedViewModel: self, newTweets: newTweets)
	}
	
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
	
	func fetchTweets(query: String, count: Int, resultType: String, location: CLLocation) {
		
		let latitude = String(format:"%f", location.coordinate.latitude)
		let longitude = String(format:"%f", location.coordinate.longitude)
		
		provider.request(.search(query: query, count: String(count), resultType: resultType, latitude: latitude, longitude: longitude)) { result in
			switch result {
				
			case let .success(moyaResponse):
				
				do {
					let filteredResponse = try moyaResponse.filterSuccessfulStatusCodes()
					let statuses = try filteredResponse.map(Statuses.self)
					self.tweets.append(contentsOf: statuses.statuses)
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
}
