//
//  TradeView.swift
//  SwiftUISampleApp
//
//  Created by Woody Lee on 10/25/24.
//

import SwiftUI

struct TradeView: View {
    @EnvironmentObject var orderData: OrderData

    var body: some View {
        VStack {
            ForEach(orderData.items, id: \.self) { item in
                Text("Trade View")
                    .frame(height: 40)
            }
        }
    }
}
