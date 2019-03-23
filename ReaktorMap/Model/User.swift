//
//  User.swift
//  ReaktorMap
//
//  Created by Harry Liddell on 21/03/2019.
//  Copyright © 2019 harryliddell. All rights reserved.
//

import UIKit

struct User: Codable {
	
	let screenName: String
	
	enum CodingKeys: String, CodingKey {
		case screenName = "screen_name"
	}
}
