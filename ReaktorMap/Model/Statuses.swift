//
//  Tweet.swift
//  ReaktorMap
//
//  Created by Harry Liddell on 21/03/2019.
//  Copyright © 2019 harryliddell. All rights reserved.
//

import Foundation

struct Statuses: Codable {
	let statuses: [Status]
	
	enum CodingKeys: String, CodingKey {
		case statuses = "statuses"
	}
}
