//
//  Entities.swift
//  ReaktorMap
//
//  Created by Harry Liddell on 23/03/2019.
//  Copyright © 2019 harryliddell. All rights reserved.
//

import UIKit

struct Entities: Codable {
	
	let urls: [URLElement]
	
	enum CodingKeys: String, CodingKey {
		case urls = "urls"
	}
}
