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
        HomeViewControllerRepresentable()
            .ignoresSafeArea()
    }
}

struct HomeViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> HomeViewController {
        return HomeViewController()
    }

    func updateUIViewController(_ uiViewController: HomeViewController, context: Context) {
    }
}

#Preview {
    ContentView()
}
