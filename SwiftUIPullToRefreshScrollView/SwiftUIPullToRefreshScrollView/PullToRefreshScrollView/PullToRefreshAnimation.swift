//
//  ContentView.swift
//  SwiftUIPullToRefreshScrollView
//
//  Created by 劉柏賢 on 2024/10/31.
//

import SwiftUI

/// 客製下拉更新圖片
struct PullToRefreshAnimation: View {

    /// ScrollView y offset
    private let yOffset: CGFloat

    /// 下拉到最大值 (trigger refresh) 50
    private let yOffsetMax: CGFloat
    
    /// 圖片高度 50
    private let loadingImageHeight: CGFloat
    
    /// 動畫圖
    private let loadingImages: [UIImage]
    
    /// 下拉更新
    private let onRefresh: () async -> Void
    
    @State
    private var timerIndex: Int = 0
    
    @State
    private var task: Task<Void, Never>?
    
    @State
    var isUpdate: Bool = false
    
    private let interval: Int = 1
    
    /// - Parameters:
    ///   - yOffset: ScrollView yOffset
    ///   - loadingImages: 圖片
    ///   - yOffsetMax: 啟動動畫時的yOffset
    ///   - loadingImageHeight: 圖片高度
    ///   - onRefresh: 下拉更新
    init(yOffset: CGFloat, loadingImages: [UIImage], yOffsetMax: CGFloat = 50, loadingImageHeight: CGFloat = 50, onRefresh: @escaping () async -> Void) {
        self.yOffset = yOffset
        self.yOffsetMax = yOffsetMax
        self.loadingImageHeight = loadingImageHeight
        self.loadingImages = loadingImages
        self.onRefresh = onRefresh
    }

    var body: some View {
        VStack(spacing: 0) {
            Image(uiImage: loadingImages[timerIndex])
                .resizable()
                .frame(width: loadingImageHeight, height: loadingImageHeight)
                .offset(y: min(0, yOffset - loadingImageHeight)) // 圖片下拉時的位置
            
            Spacer()
        }
        .onChange(of: yOffset) { oldValue, newValue in

            // 如已啟動動畫則不依滑動yOffset
            guard task == nil else { return }

            let yOffset = newValue
            let loadingImageMaxCount: Int = loadingImages.count

            let ratio: CGFloat = yOffset / yOffsetMax
            let index = Int(ratio * CGFloat(loadingImageMaxCount)) % loadingImageMaxCount
            print("\(type(of: self)): index = \(index), ratio = \(ratio), yOffset = \(yOffset), yOffsetMax = \(yOffsetMax), loadingImageMaxCount = \(loadingImageMaxCount), loadingImageMaxCount \(loadingImageMaxCount)")
            self.timerIndex = index
            
            switch yOffset {
                case let y where y <= 0:
                    cancel() // 停止動畫
                    
                case let y where y > yOffsetMax:
                    next() // 啟動動畫
                    
                    if !isUpdate {
                        isUpdate = true
                        
                        Task { @MainActor in

                            print("\(type(of: self)): 下拉更新")

                            // 下拉更新
                            await onRefresh()
                            isUpdate = false
                        }
                    }

                default:
                    break
            }
        }
        .onDisappear {
            print("\(type(of: self)): \(#function)")
            cancel()
        }
    }

    @MainActor
    private func next() {
        print("\(type(of: self)): Timer \(#function)")

        cancel()

        task = Task {
            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000 / loadingImages.count))
            if let task, !task.isCancelled {
                timerIndex = (timerIndex + 1) % loadingImages.count
                print("\(type(of: self)): Timer, timerIndex = \(timerIndex), yOffset = \(yOffset), yOffsetMax = \(yOffsetMax)")

                next()
            }
        }
    }
    
    private func cancel() {
        print("\(type(of: self)): Timer \(#function)")
        task?.cancel()
    }
}

#if DEBUG
#Preview {
    ContentView()
}
#endif
