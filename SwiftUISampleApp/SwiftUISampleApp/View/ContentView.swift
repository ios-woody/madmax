//
//  ContentView.swift
//  SwiftUISampleApp
//
//  Created by Woody Lee on 10/4/24.
//

import SwiftUI

struct ContentView: View {
    let data = OrderData.shared

    var body: some View {
        OrderView()
            .environmentObject(data)
            .onAppear {
                Task {
                    do {
                        try await data.webSocketController.connect()
                    } catch {
                        print("Error")
                    }
                }
            }
    }
}

struct OrderView: View {
    @EnvironmentObject var orderData: OrderData

    var body: some View {
        VStack {
            Text(orderData.currentData.suffix(15).joined(separator: ", "))
        }
    }
}

#Preview {
    ContentView()
}
