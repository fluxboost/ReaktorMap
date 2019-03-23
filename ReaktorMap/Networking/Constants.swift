//
//  Constants.swift
//  ReaktorMap
//
//  Created by Harry Liddell on 21/03/2019.
//  Copyright © 2019 harryliddell. All rights reserved.
//

import UIKit

struct Constants {
	
	// Twitter Keys
	static let twitterAPIKey = "kIOMV7Wp7v9FNuP9RibCvmRCw"
	static let twitterAPISecret = "sNfTvwSR0zRJpUoybh4qsojxoeCrMwzMWrx33xNYHaZujr4yK1"
	
	// Twitter Base URL
	static let baseURL = "https://api.twitter.com"
	
	// Parameters
	struct Parameters {
		static let query = "q"
		static let resultType = "result_type"
		static let grantType = "grant_type"
	}
	
	// Header fields
	enum HttpHeaderField: String {
		case authorization = "Authorization"
		case contentType = "Content-Type"
		case acceptType = "Accept"
		case acceptEncoding = "Accept-Encoding"
	}
	
	// The content type (JSON)
	enum ContentType: String {
		case json = "application/json"
		case auth = "application/x-www-form-urlencoded;charset=UTF-8."
	}
}
