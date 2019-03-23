//
//  Token.swift
//  ReaktorMap
//
//  Created by Harry Liddell on 21/03/2019.
//  Copyright © 2019 harryliddell. All rights reserved.
//

import UIKit

struct Token: Codable {
	
	let tokenType: String
	let accessToken: String
	
	enum CodingKeys: String, CodingKey {
		case tokenType = "token_type"
		case accessToken = "access_token"
	}
}
