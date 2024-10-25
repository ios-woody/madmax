//
//  OrderData.swift
//  SwiftUISampleApp
//
//  Created by Woody Lee on 10/4/24.
//

import Foundation

actor OrderData: ObservableObject {
    static let shared = OrderData()

    @MainActor
    @Published private(set) var items: [OrderBookBuySellItemModel] = []

    private var buyItems: [Int64: OrderBookItemModel] = [:]
    private var sellItems: [Int64: OrderBookItemModel] = [:]
    private var pendingUpdate = false

    public lazy var webSocketController = WebSocketController(orderData: self)

    private init() {
        Task {
            await self.startPeriodicUpdate()
        }
    }

    func storeData(orderBookItems: [OrderBookItem]) {
        orderBookItems.forEach { addItem($0) }
        pendingUpdate = true
    }

    private func startPeriodicUpdate() async {
        while true {
            try? await Task.sleep(nanoseconds: 1_000_000_000)

            if pendingUpdate {
                await updateItemsIfNeeded()
            }
        }
    }

    private func updateItemsIfNeeded() async {
        pendingUpdate = false

        let buyItemsSorted = buyItems.sorted(by: { $0.value.price < $1.value.price }).map { $0.value }
        let sellItemsSorted = sellItems.sorted(by: { $0.value.price > $1.value.price }).map { $0.value }

        var pairItems: [OrderBookBuySellItemModel] = []
        for (index, buyItem) in buyItemsSorted.enumerated() where index < sellItems.count {
            pairItems.append(
                OrderBookBuySellItemModel(
                    buyItem: buyItem,
                    sellItem: sellItemsSorted[index]
                )
            )
            if pairItems.count >= 100 { break }
        }

        await MainActor.run { [pairItems] in
            self.items = pairItems
        }
    }


    private func addItem(_ item: OrderBookItem) {
        guard let size = item.size else { return }

        switch item.side {
        case .buy:
            let totalBuySize = buyItems.reduce(0) { partialResult, item in
                return partialResult + item.value.size
            }
           let item = OrderBookItemModel(
                id: item.id,
                side: item.side,
                size: size,
                price: item.price,
                sizePercent: size / Double(totalBuySize)
            )
            print(size / Double(totalBuySize))
            buyItems[item.id] = item
        case .sell:
            let totalSellSize = sellItems.reduce(0) { partialResult, item in
                return partialResult + item.value.size
            }
            let item = OrderBookItemModel(
                id: item.id,
                side: item.side,
                size: size,
                price: item.price,
                sizePercent: size / Double(totalSellSize)
            )

            sellItems[item.id] = item
        }
    }
}
struct OrderBookBuySellItemModel: Hashable {
    let buyItem: OrderBookItemModel
    let sellItem: OrderBookItemModel
}

struct OrderBookItemModel: Hashable {
    let id: Int64
    let side: Side
    let size: Double
    let price: Double
    let sizePercent: Double

    var sizeString: String {
        numberFormatter.string(from: size as NSNumber) ?? ""
    }

    var priceString: String {
        numberFormatter.string(from: price as NSNumber) ?? ""
    }

//    var sizePercentFloat: CGFloat {
//        return CGFloat(exactly: sizePercent)
//    }
}

private let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter
}()
