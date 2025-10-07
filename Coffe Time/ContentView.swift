//
//  ContentView.swift
//  Coffee Time
//
//  Created by Artem Poletaev on 03.10.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Главная", systemImage: "house.fill")
                }

            HistoryView()
                .tabItem {
                    Label("История", systemImage: "clock")
                }
        }
        .tint(.accentColor)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .toolbar(.visible, for: .tabBar)
    }
}

#Preview {
    ContentView()
}
