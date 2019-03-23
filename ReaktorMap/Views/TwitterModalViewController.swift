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
	
	var handle: String?
	var idStr: String?
	
    override func viewDidLoad() {
        super.viewDidLoad()

		if let tweetId = idStr {
			if let handle = handle {
				do {
					let urlRequest = try URLRequest(url: "https://twitter.com/\(handle)/status/\(tweetId)".asURL())
					webView.load(urlRequest)
				} catch {
					print("Error")
				}
			} else {
				dismiss(animated: true, completion: nil)
			}
		} else {
			dismiss(animated: true, completion: nil)
		}
    }
}
