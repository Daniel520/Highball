//
//  ConversationsListDataManager.swift
//  Highball
//
//  Created by Ian Ynda-Hummel on 9/5/16.
//  Copyright © 2016 ianynda. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON

public protocol ConversationsListDataManagerDelegate: class {
	func listDataManagerDidReload(_ dataManager: ConversationsListDataManager)
}

open class ConversationsListDataManager {
	open weak var delegate: ConversationsListDataManagerDelegate?

	open fileprivate(set) var conversations: [Conversation] = []

	open func reloadData() {
		let headers = [
			"X-tumblr-form-key": "i7Wi4kwmh6ebC8jKpdV4xMUGcFA",
			"X-Requested-With": "XMLHttpRequest"
		]

		let participant = "thatseemsright.tumblr.com"
		let timestamp = Date().timeIntervalSince1970

		Alamofire.request(.GET, "https://www.tumblr.com/svc/conversations?participant=\(participant)&_=\(timestamp)", headers: headers)
			.response() { _, _, data, error in
				guard let data = data else {
					return
				}

				let json = JSON(data: data)

				guard let conversationsJSON = json["response"]["conversations"].array else {
					return
				}

				self.conversations = conversationsJSON.map { Conversation.from($0.dictionaryObject!) }.flatMap { $0 }

				self.delegate?.listDataManagerDidReload(self)
			}
	}
}