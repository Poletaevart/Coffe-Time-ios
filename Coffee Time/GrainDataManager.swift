//
//  GrainDataManager.swift
//  Coffe Time
//
//  Created by Artem Poletaev on 08.10.2025.
//

import Foundation

struct GrainDataManager {
    private let saveKey = "SavedGrains"

    // Сохранение данных
    func save(_ grains: [Grain]) {
        do {
            let encoded = try JSONEncoder().encode(grains)
            UserDefaults.standard.set(encoded, forKey: saveKey)
        } catch {
            print("❌ Ошибка сохранения зерен:", error)
        }
    }

    // Загрузка данных
    func load() -> [Grain] {
        guard let savedData = UserDefaults.standard.data(forKey: saveKey) else { return [] }
        do {
            let decoded = try JSONDecoder().decode([Grain].self, from: savedData)
            return decoded
        } catch {
            print("⚠️ Ошибка загрузки зерен:", error)
            return []
        }
    }

    // Очистка (если понадобится)
    func clear() {
        UserDefaults.standard.removeObject(forKey: saveKey)
    }
}
