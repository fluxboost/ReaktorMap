
//
//  APIService.swift
//  ReaktorMap
//
//  Created by Harry Liddell on 22/03/2019.
//  Copyright © 2019 harryliddell. All rights reserved.
//

import Foundation
import Moya

enum APIService {
	case authenticate
	case search(query: String, count: String, resultType: String, latitude: String, longitude: String)
}

// MARK: - TargetType Protocol Implementation

extension APIService: TargetType {
	
	var baseURL: URL { return URL(string: Constants.baseURL)! }
	
	var path: String {
		switch self {
		case .authenticate: return "/oauth2/token"
		case .search: return "/1.1/search/tweets.json"
		}
	}
	
	var method: Moya.Method {
		switch self {
		case .authenticate:
			return .post
		case .search:
			return .get
		}
	}
	
	var task: Task {
		switch self {
		case .authenticate: // Send no parameters
			return .requestParameters(parameters: ["grant_type": "client_credentials"], encoding: URLEncoding.queryString)
		case let .search(input, count, resultType, latitude, longitude):  // Always sends parameters in URL, regardless of which HTTP method is used
			return .requestParameters(parameters: ["q": input, "count": count, "result_type" : resultType, "geocode" : "\(latitude),\(longitude),20mi"], encoding: URLEncoding.queryString)
		}
	}
	
	var sampleData: Data {
		switch self {
		case .authenticate:
			return "Half measures are as bad as nothing at all.".utf8Encoded
		case .search(let query, let count, let resultType, let latitude, let longitude):
			return "{\"q\": \(query), \"count\": \"\(count)\", \"result_type\": \"\(resultType)\", \"latitude\": \"\(latitude)\", \"longitude\": \"\(longitude)\"}".utf8Encoded
		}
	}
	
	var headers: [String: String]? {
		if AuthManager.isAuthenticated() {
			let tokenType = AuthManager.getTokenType()!
			let accessToken = AuthManager.getAccessToken()!
			return ["Content-type": "application/json", "Authorization" : "\(tokenType) \(accessToken)"]
		} else {
			let base64String = "\(Constants.twitterAPIKey):\(Constants.twitterAPISecret)".toBase64()
			return ["Content-type": "application/json", "Authorization" : "Basic \(base64String)"]
		}
	}
}

// MARK: - Helpers

private extension String {
	var urlEscaped: String {
		return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
	}
	
	var utf8Encoded: Data {
		return data(using: .utf8)!
	}
}
