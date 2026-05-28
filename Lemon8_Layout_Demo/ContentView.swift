//
//  ContentView.swift
//  Lemon8_Layout_Demo
//
//  Created by changshuang on 2025/12/28.
//

import SwiftUI
import UIKit

struct ContentView: View {
    var body: some View {
        FeedViewControllerRepresentable()
            .ignoresSafeArea()
    }
}

struct FeedViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> FeedViewController {
        return FeedViewController(tabName: "推荐")
    }

    func updateUIViewController(_ uiViewController: FeedViewController, context: Context) {
    }
}

#Preview {
    ContentView()
}
