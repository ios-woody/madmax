//
//  Response.swift
//  SwiftUISampleApp
//
//  Created by Woody Lee on 10/4/24.
//

import Foundation

struct Response: Decodable {
    let table: Table
    let action: Action
    let data: [ResponseItem]

    private enum CodingKeys : String, CodingKey {
        case table
        case action
        case data
    }

    init(from decoder : Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        table = try container.decode(Table.self, forKey: .table)
        action = try container.decode(Action.self, forKey: .action)

        var dataContainer = try container.nestedUnkeyedContainer(forKey: .data)
        var responseData: [ResponseItem] = []

        while !dataContainer.isAtEnd {
            switch table {
            case .trade:
                responseData.append(.trade(try dataContainer.decode(TradeItem.self)))
            case .orderBookL2_25:
                responseData.append(.orderBook(try dataContainer.decode(OrderBookItem.self)))
            }
        }
        data = responseData
    }
}

enum Table: String, Decodable {
    case orderBookL2_25
    case trade
}

enum Action: String, Decodable {
    case partial
    case insert
    case update
    case delete
}

enum ResponseItem: Decodable {
    case trade(TradeItem)
    case orderBook(OrderBookItem)
}

struct TradeItem: Decodable, Equatable {
    let timestamp: Date
    let side: Side
    let size: Int64
    let price: Decimal
    let trdMatchID: String
}

struct OrderBookItem: Decodable, Hashable {
    let id: Int64
    let side: Side
    let size: Decimal?
    let price: Decimal
}

enum Side: String, Decodable {
    case buy = "Buy"
    case sell = "Sell"
}
