//
//  URLElement.swift
//  ReaktorMap
//
//  Created by Harry Liddell on 23/03/2019.
//  Copyright © 2019 harryliddell. All rights reserved.
//

import UIKit

class URLElement: Codable {
	
	let url: String
	
	enum CodingKeys: String, CodingKey {
		case url = "url"
	}
}
