//
//  ContentView.swift
//  SwiftUIPullToRefreshScrollView
//
//  Created by 劉柏賢 on 2024/10/31.
//

import SwiftUI

/// 客製化 食 下拉更新 ScrollView
struct PullToRefreshScrollView<Content: View>: View {

    @State
    private var isShowPullToRefresh: Bool = false
    
    @State
    private var scrollViewYOffset: CGFloat = 0

    /// 出現的yOffset
    private let isShowPullToRefreshThreshold: CGFloat = 20

    /// Loading圖
    private let loadingImages: [UIImage]

    /// 可讓外部view
    private let content: Content

    /// 下拉更新
    let onRefresh: () async -> Void
    
    /// 坐標位置
    private let scrollViewOriginCoordinateSpace: String = "ScrollViewOrigin"
    
    init(
        loadingImages: [UIImage],
        @ViewBuilder content: @escaping () -> Content,
        onRefresh: @escaping () async -> Void
    ) {
        self.loadingImages = loadingImages
        self.content = content()
        self.onRefresh = onRefresh
    }

    var body: some View {
        ScrollView {
            GeometryReader { proxy in

                // 取得即時滑動位置
                Color.clear.preference(
                    key: OffsetPreferenceKey.self,
                    value: proxy.frame(in: .named(scrollViewOriginCoordinateSpace)).origin
                )
            }
            .frame(width: 0, height: 0)
            
            content
        }
        .coordinateSpace(name: scrollViewOriginCoordinateSpace)
        .onPreferenceChange(OffsetPreferenceKey.self) { (point: CGPoint) in

            // 取得即時滑動位置
            print("scrollView: \(point)")

            scrollViewYOffset = point.y
            
            if point.y < isShowPullToRefreshThreshold {
                isShowPullToRefresh = false
            } else {
                isShowPullToRefresh = true
            }
        }
        .background {
            if isShowPullToRefresh {
                PullToRefreshAnimation(yOffset: scrollViewYOffset, loadingImages: loadingImages, onRefresh: {
                    // 下拉更新
                    await onRefresh()
                })
            }
        }
    }
}

/// 取得ScrollView 即時滑動Offset
private struct OffsetPreferenceKey: PreferenceKey {
    
    static let defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) { }
}

#if DEBUG
#Preview {
    ContentView()
}
#endif
