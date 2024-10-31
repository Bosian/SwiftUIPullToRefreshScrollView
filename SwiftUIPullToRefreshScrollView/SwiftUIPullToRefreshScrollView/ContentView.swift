//
//  ContentView.swift
//  SwiftUIPullToRefreshScrollView
//
//  Created by 劉柏賢 on 2024/10/31.
//

import SwiftUI

struct ContentView: View {

    @State
    private var count: Int = 0

    private let loadingImages: [UIImage] = {
        (1...4).compactMap { index in
            return UIImage(named: "loading_\(index)")
        }
    }()

    var body: some View {
        NavigationStack {
            PullToRefreshScrollView(loadingImages: loadingImages) {
                VStack {
                    ForEach(0..<50) { index in
                        Color.gray
                            .frame(width: .infinity, height: 120)
                    }
                }
                .padding()
            } onRefresh: {
                print("Refresh...")
                count += 1
            }
            .background(Color.green)
            .navigationTitle("Pull to refresh: \(count)")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
