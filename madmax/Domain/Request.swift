//
//  Request.swift
//  SwiftUISampleApp
//
//  Created by Woody Lee on 10/4/24.
//

import Foundation

// {"op": "subscribe", "args": [<SubscriptionTopic>]}

struct Request: Encodable {
    let op: String
    let args: [String]
}
