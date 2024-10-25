//
//  OrderBookView.swift
//  SwiftUISampleApp
//
//  Created by Woody Lee on 10/25/24.
//

import SwiftUI

struct OrderView: View {
    @EnvironmentObject var orderData: OrderData

    var body: some View {
        VStack(spacing: 0) {
            ForEach(orderData.items, id: \.self) { item in
                orderBookItemView(orderItem: item)
            }
        }
        .onAppear {
            Task {
                do {
                    try await orderData.webSocketController.connect()
                } catch {
                    print("Error")
                }
            }
        }
    }

    private func orderBookItemView(orderItem: OrderBookBuySellItemModel) -> some View {
        HStack(spacing: 0) {
            orderBookBuyItemView(orderItem: orderItem.buyItem)
            orderBookSellItemView(orderItem: orderItem.sellItem)
        }
        .frame(height: 40)
    }

    private func orderBookBuyItemView(orderItem: OrderBookItemModel) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                HStack {
                    Text("\(orderItem.sizeString)")
                    Spacer()
                    Text("\(orderItem.priceString)")
                        .foregroundStyle(.green)
                }
                Spacer()
                    .background(.green.opacity(0.3))
                    .frame(width: (geometry.size.width) * orderItem.sizePercent)
            }
        }
    }

    private func orderBookSellItemView(orderItem: OrderBookItemModel) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Spacer()
                    .background(.red.opacity(0.3))
                    .frame(width: (geometry.size.width) * orderItem.sizePercent)
                HStack {
                    Text("\(orderItem.priceString)")
                        .foregroundStyle(.red)
                    Spacer()
                    Text("\(orderItem.sizeString)")
                }
            }
        }
    }

}

#Preview {
//    OrderView()
}
