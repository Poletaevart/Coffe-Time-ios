//
//  DrinkStore.swift
//  Coffee Time
//
//  Created by Assistant.
//

import Foundation
import Combine

// MARK: - Drink Model

struct Drink: Identifiable, Hashable, Codable {
    let id: UUID
    let date: Date
    let milliliters: Int
    let priceRub: Double
    let place: String
    let type: CoffeeType
    let customTypeName: String?

    init(
        id: UUID = UUID(),
        date: Date,
        milliliters: Int,
        priceRub: Double,
        place: String,
        type: CoffeeType,
        customTypeName: String? = nil
    ) {
        self.id = id
        self.date = date
        self.milliliters = milliliters
        self.priceRub = priceRub
        self.place = place
        self.type = type
        self.customTypeName = customTypeName
    }
}

// MARK: - Drink Store

@MainActor
final class DrinkStore: ObservableObject {
    @Published private(set) var drinks: [Drink] = []
    private var cancellables = Set<AnyCancellable>()
    private let saveURL: URL

    init() {
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        saveURL = folder.appendingPathComponent("drinks.json")

        load()

        // Автосохранение при изменениях
        $drinks
            .dropFirst()
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.save()
            }
            .store(in: &cancellables)
    }

    // MARK: - CRUD

    func addDrink(date: Date, milliliters: Int, priceRub: Double, place: String, type: CoffeeType, customTypeName: String? = nil) {
        let newDrink = Drink(date: date, milliliters: milliliters, priceRub: priceRub, place: place, type: type, customTypeName: customTypeName)
        drinks.append(newDrink)
    }

    func updateDrink(_ drink: Drink, date: Date, milliliters: Int, priceRub: Double, place: String, type: CoffeeType, customTypeName: String? = nil) {
        guard let idx = drinks.firstIndex(where: { $0.id == drink.id }) else { return }
        drinks[idx] = Drink(id: drink.id, date: date, milliliters: milliliters, priceRub: priceRub, place: place, type: type, customTypeName: customTypeName)
    }

    func deleteDrink(_ drink: Drink) {
        drinks.removeAll { $0.id == drink.id }
    }

    // MARK: - Persistence

    private func load() {
        guard let data = try? Data(contentsOf: saveURL) else { return }
        if let decoded = try? JSONDecoder().decode([Drink].self, from: data) {
            self.drinks = decoded
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(drinks) else { return }
        try? data.write(to: saveURL, options: [.atomic])
    }

    // MARK: - Monthly Aggregates

    func drinks(for monthDate: Date) -> [Drink] {
        guard let interval = Calendar.current.dateInterval(of: .month, for: monthDate) else { return [] }
        return drinks.filter { interval.contains($0.date) }.sorted { $0.date > $1.date }
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

    // MARK: - All-time stats

    var allTimeCupsCount: Int { drinks.count }
    var allTimeTotalMilliliters: Int { drinks.reduce(0) { $0 + $1.milliliters } }
    var allTimeTotalPriceRub: Double { drinks.reduce(0) { $0 + $1.priceRub } }
}
