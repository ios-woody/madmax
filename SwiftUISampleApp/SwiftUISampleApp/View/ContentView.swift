//
//  ContentView.swift
//  SwiftUISampleApp
//
//  Created by Woody Lee on 10/4/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedIndex: Int = 0
    private let scrollTopID = "scrollToTop"
    let data = OrderData.shared

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                Spacer().frame(height: 24)
                    .id(scrollTopID)
                Spacer().frame(height: 20)
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section {
                        contentView
                    } header: {
                        headerView(proxy: proxy)
                    }
                }
            }
            .clipped()
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if selectedIndex == 0 {
            OrderView()
                .environmentObject(data)
        } else {
            TradeView()
                .environmentObject(data)
        }
    }

    private func headerView(proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 0) {
            segmentView(proxy: proxy)
            headerViewOfSegmentView()
        }
    }

    private func segmentView(proxy: ScrollViewProxy) -> some View {
        HStack(spacing: 0) {
            segmentButton(index: 0, title: "Order Book", proxy: proxy)
            segmentButton(index: 1, title: "Recent Trades", proxy: proxy)
        }
        .padding(.horizontal, 20)
        .frame(height: 50)
        .background {
            Spacer()
        }
        .background(.white)
    }

    private func headerViewOfSegmentView() -> some View {
        HStack(alignment: .center) {
            Text(selectedIndex == 0 ? "QTY" : "Price(USD)")
            Spacer()
            Text(selectedIndex == 0 ? "Price(USD)" : "QTY")
            Spacer()
            Text(selectedIndex == 0 ? "QTY" : "Time")
        }
        .padding(10)
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background(selectedIndex == 0 ? .red : .green)
    }

    private func segmentButton(index: Int, title: String, proxy: ScrollViewProxy) -> some View {
        HStack(spacing: 0) {
            Button {
                withAnimation {
                    selectedIndex = index
                    proxy.scrollTo(scrollTopID)
                }
            } label: {
                Text(title)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    ContentView()
}
