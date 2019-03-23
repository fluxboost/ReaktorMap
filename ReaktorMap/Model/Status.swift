//
//  Status.swift
//  ReaktorMap
//
//  Created by Harry Liddell on 21/03/2019.
//  Copyright © 2019 harryliddell. All rights reserved.
//

import UIKit

struct Status: Codable {
	
	let createdAt: String
	let user: User
	let entities: Entities
	let idStr: String
	
	enum CodingKeys: String, CodingKey {
		case createdAt = "created_at"
		case user = "user"
		case entities = "entities"
		case idStr = "id_str"
	}
}
