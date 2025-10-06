//
//  ContentView.swift
//  Coffe Time
//
//  Created by Artem Poletaev on 03.10.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = DrinkStore()
    var body: some View {
        TabView {
            HomeView()
                .environmentObject(store)
                .tabItem { Label("Главная", systemImage: "house.fill") }

            HistoryView()
                .environmentObject(store)
                .tabItem { Label("История", systemImage: "clock") }
        }
        .tint(.accentColor)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .toolbar(.visible, for: .tabBar)
    }
}

#Preview {
    ContentView()
}

