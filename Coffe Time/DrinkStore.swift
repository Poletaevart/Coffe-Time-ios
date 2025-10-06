//
//  DrinkStore.swift
//  Coffe Time
//
//  Created by Assistant.
//

import Foundation
import Combine

struct Drink: Identifiable, Hashable {
    let id: UUID
    let date: Date
    let milliliters: Int
    let priceRub: Double
    let place: String
    let type: CoffeeType

    init(id: UUID = UUID(), date: Date, milliliters: Int, priceRub: Double, place: String, type: CoffeeType) {
        self.id = id
        self.date = date
        self.milliliters = milliliters
        self.priceRub = priceRub
        self.place = place
        self.type = type
    }
}

final class DrinkStore: ObservableObject {
    @Published private(set) var drinks: [Drink] = []

    func addDrink(date: Date, milliliters: Int, priceRub: Double, place: String, type: CoffeeType) {
        let newDrink = Drink(date: date, milliliters: milliliters, priceRub: priceRub, place: place, type: type)
        drinks.append(newDrink)
    }

    func updateDrink(_ drink: Drink, date: Date, milliliters: Int, priceRub: Double, place: String, type: CoffeeType) {
        guard let idx = drinks.firstIndex(where: { $0.id == drink.id }) else { return }
        drinks[idx] = Drink(id: drink.id, date: date, milliliters: milliliters, priceRub: priceRub, place: place, type: type)
    }

    func deleteDrink(_ drink: Drink) {
        drinks.removeAll { $0.id == drink.id }
    }

    // MARK: - Monthly Aggregates

    var currentMonthDrinks: [Drink] {
        let calendar = Calendar.current
        let now = Date()
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else { return [] }
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) ?? now
        return drinks.filter { $0.date >= startOfMonth && $0.date <= endOfMonth }
    }

    var currentMonthCupsCount: Int {
        currentMonthDrinks.count
    }

    var currentMonthTotalMilliliters: Int {
        currentMonthDrinks.reduce(0) { $0 + $1.milliliters }
    }

    var currentMonthTotalPriceRub: Double {
        currentMonthDrinks.reduce(0) { $0 + $1.priceRub }
    }
}

// MARK: - Month filtering helpers
extension DrinkStore {
    func drinks(for monthDate: Date) -> [Drink] {
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate)) else { return [] }
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) ?? monthDate
        return drinks.filter { $0.date >= startOfMonth && $0.date <= endOfMonth }
    }

    func cupsCount(for monthDate: Date) -> Int {
        drinks(for: monthDate).count
    }

    func totalMilliliters(for monthDate: Date) -> Int {
        drinks(for: monthDate).reduce(0) { $0 + $1.milliliters }
    }

    func totalPriceRub(for monthDate: Date) -> Double {
        drinks(for: monthDate).reduce(0) { $0 + $1.priceRub }
    }

    // All-time aggregates
    var allTimeCupsCount: Int { drinks.count }
    var allTimeTotalMilliliters: Int { drinks.reduce(0) { $0 + $1.milliliters } }
    var allTimeTotalPriceRub: Double { drinks.reduce(0) { $0 + $1.priceRub } }
}
