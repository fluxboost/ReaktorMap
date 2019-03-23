//
//  APIManager.swift
//  ReaktorMap
//
//  Created by Harry Liddell on 20/03/2019.
//  Copyright © 2019 harryliddell. All rights reserved.
//

import Alamofire
import CoreLocation
import Moya

enum ApiError: Error {
	case forbidden              //Status code 403
	case notFound               //Status code 404
	case conflict               //Status code 409
	case internalServerError    //Status code 500
}

class AuthManager {
	
	static func isAuthenticated() -> Bool {
		if UserDefaults.standard.string(forKey: "accessToken") != nil {
			return true
		}
		
		return false
	}
	
	static func getTokenType() -> String? {
		return UserDefaults.standard.string(forKey: "tokenType")
	}
	
	static func getAccessToken() -> String? {
		return UserDefaults.standard.string(forKey: "accessToken")
	}
	
	static func saveToken(token: Token) {
		UserDefaults.standard.set(token.accessToken, forKey: "accessToken")
		UserDefaults.standard.set(token.tokenType, forKey: "tokenType")
	}
	
	static func deleteToken() {
		UserDefaults.standard.set(nil, forKey: "accessToken")
		UserDefaults.standard.set(nil, forKey: "tokenType")
	}
}
