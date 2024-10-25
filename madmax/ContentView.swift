//
//  ContentView.swift
//  madmax
//
//  Created by Taeheon Woo on 9/13/24.
//

import SwiftUI

struct ContentView: View {
    @SwiftUI.State private var selectedIndex: Int = 0

    let data = OrderData.shared

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                Section {
                    contentView
                } header: {
                    headerView
                }
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if selectedIndex == 0 {
            OrderView()
                .environmentObject(data)
        } else {
            // 화면 전환
        }
    }

    @ViewBuilder
    private var headerView: some View {
        HStack(spacing: 0) {
            segmentButton(index: 0, title: "Order Book")
            segmentButton(index: 1, title: "Recent Trades")
        }
        .padding(.horizontal, 20)
        .frame(height: 30)
        .background(.white)
    }
    private func segmentButton(index: Int, title: String) -> some View {
        HStack(spacing: 0) {
            Button {
                withAnimation {
                    selectedIndex = index
                }
            } label: {
                Text(title)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct OrderView: View {
    @EnvironmentObject var orderData: OrderData

    var body: some View {
        VStack {
            Text(orderData.currentData.suffix(15).joined(separator: ", "))
        }.onAppear {
            Task {
                do {
                    try await orderData.webSocketController.connect()
                } catch {
                    print("Error")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
