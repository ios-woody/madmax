//
//  OrderData.swift
//  SwiftUISampleApp
//
//  Created by Woody Lee on 10/4/24.
//

import Foundation

@MainActor
class OrderData: ObservableObject {
    static let shared = OrderData()

    @Published private(set) var currentData: [String] = []

    public lazy var webSocketController = WebSocketController(orderData: self)

    private init() {}

    func storeData(string: String) {
        self.currentData.append(string)
    }

}
