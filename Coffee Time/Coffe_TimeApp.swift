//
//  Coffe_TimeApp.swift
//  Coffe Time
//
//  Created by Artem Poletaev on 03.10.2025.
//

import SwiftUI

@main
struct Coffe_TimeApp: App {
    @StateObject private var store = DrinkStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
