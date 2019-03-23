//
//  FormatHelper.swift
//  FloowJourney
//
//  Created by Harry Liddell on 25/02/2019.
//  Copyright © 2019 harryliddell. All rights reserved.
//

import UIKit

struct FormatHelper {
	
	/**
	Takes a query and formats it into a Twitter query string.
	
	- Returns: A string containing the modified query.
	*/
	static func formatSearchInput(input: String?) -> String {
		
		guard var modifiedInput = input else {
			return input!
		}
		
		if modifiedInput.contains("#") {
			modifiedInput = modifiedInput.replacingOccurrences(of: "#", with: "%23")
		}
		
		if modifiedInput.contains("@") {
			modifiedInput = modifiedInput.replacingOccurrences(of: "@", with: "%40")
		}
		
		return modifiedInput
	}
}
