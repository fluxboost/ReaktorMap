//
//  String+Base64.swift
//  ReaktorMap
//
//  Created by Harry Liddell on 21/03/2019.
//  Copyright © 2019 harryliddell. All rights reserved.
//

import Foundation

extension String {
	
	/**
	Takes a string of base64 encoding, decoded to a string
	
	- Returns: A string of the inputted base64 to a String
	*/
	func fromBase64() -> String? {
		guard let data = Data(base64Encoded: self) else {
			return nil
		}
		return String(data: data, encoding: .utf8)
	}
	
	/**
	Takes a string and base64 encodes it.
	
	- Returns: A string of the inputted string in base64
	*/
	func toBase64() -> String {
		return Data(self.utf8).base64EncodedString()
	}
}
