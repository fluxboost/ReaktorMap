//
//  TwitterModalViewController.swift
//  ReaktorMap
//
//  Created by Harry Liddell on 23/03/2019.
//  Copyright © 2019 harryliddell. All rights reserved.
//

import UIKit
import WebKit

class TwitterModalViewController: UIViewController {

	@IBOutlet weak var webView: WKWebView!
	
	var webAddress: String?
	
    override func viewDidLoad() {
        super.viewDidLoad()

		if let webAddress = webAddress {
			do {
				let urlRequest = try URLRequest(url: webAddress.asURL())
				webView.load(urlRequest)
			} catch {
				print("Error")
			}
		}
    }
}
