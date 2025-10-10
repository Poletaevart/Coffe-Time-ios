//
//  GrainsView.swift
//  Coffe Time
//
//  Created by Artem Poletaev on 08.10.2025.
//


import SwiftUI
import Combine

struct Grain: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var weight: Double // в граммах
    var price: Double  // в рублях
    var date: Date
    
    init(id: UUID = UUID(), name: String, weight: Double, price: Double, date: Date = Date()) {
        self.id = id
        self.name = name
        self.weight = weight
        self.price = price
        self.date = date
    }
}

class GrainStore: ObservableObject {
    @Published var grains: [Grain] = [] {
        didSet {
            dataManager.save(grains)
        }
    }

    private let dataManager = GrainDataManager()
    
    init() {
        grains = dataManager.load()
    }
    
    var totalWeight: Double {
        grains.reduce(0) { $0 + $1.weight }
    }
    
    var totalPrice: Double {
        grains.reduce(0) { $0 + $1.price }
    }
    
    var averagePricePer100g: Double {
        guard totalWeight > 0 else { return 0 }
        return (totalPrice / totalWeight) * 100
    }
}

struct GrainsView: View {
    @State private var showAddSheet = false
    @EnvironmentObject var grainStore: GrainStore
    
    // MARK: - Период
    @State private var selectedMonth: Date = Date()
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var showAllTime = false
    @State private var showYearOnly = false
    
    // MARK: - Отфильтрованные зерна
    var filteredGrains: [Grain] {
        if showAllTime {
            return grainStore.grains
        } else if showYearOnly {
            return grainStore.grains.filter {
                Calendar.current.component(.year, from: $0.date) == selectedYear
            }
        } else {
            return grainStore.grains.filter {
                Calendar.current.isDate($0.date, equalTo: selectedMonth, toGranularity: .month)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Статистика
            HStack {
                StatCard(title: "Всего грамм", value: "\(Int(filteredGrains.reduce(0) { $0 + $1.weight })) г")
                StatCard(title: "Потрачено", value: "\(Int(filteredGrains.reduce(0) { $0 + $1.price })) ₽")
            }
            .padding(.horizontal)
            
            // MARK: - Фильтры
            HStack(spacing: 12) {
                // Кнопка выбора месяца
                Menu {
                    // Отображение месяцев текущего года
                    ForEach(1...12, id: \.self) { m in
                        Button("\(monthName(m)) \(String(selectedYear)) г.") {
                            selectedMonth = date(year: selectedYear, month: m)
                            showYearOnly = false
                            showAllTime = false
                        }
                    }
                    Divider()
                    // Секция выбора года
                    Text("Выбрать год")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    ForEach(yearsList, id: \.self) { year in
                        Button("\(String(year)) г.") {
                            selectedYear = year
                            showYearOnly = true
                            showAllTime = false
                            selectedMonth = date(year: year, month: 1) // сбрасываем выбранный месяц
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 16, weight: .medium))
                        Text(selectedMonthTitle)
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .clipShape(Capsule())
                    .shadow(color: Color.accentColor.opacity(0.4), radius: 8, x: 0, y: 4)
                }

                // Кнопка "Всё время"
                Button {
                    showAllTime = true
                    showYearOnly = false
                } label: {
                    HStack {
                        Image(systemName: "infinity")
                            .font(.system(size: 16, weight: .medium))
                        Text("Всё время")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .clipShape(Capsule())
                    .shadow(color: Color.accentColor.opacity(0.4), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.horizontal)

            // MARK: - История
            VStack(alignment: .leading, spacing: 0) {
                Text("История")
                    .font(.title2).bold()
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                
                if filteredGrains.isEmpty {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                            .padding(.horizontal)
                            .frame(height: 110)
                        VStack {
                            Text("Здесь будет история зерен")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        }
                    }
                    .padding(.bottom, 8)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(filteredGrains) { grain in
                                HistoryItemView(
                                    title: grain.name,
                                    subtitle: "\(Int(grain.weight)) г",
                                    amount: "\(Int(grain.price)) ₽",
                                    date: formattedDate(grain.date)
                                )
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
            
            Spacer()
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                showAddSheet = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 18, weight: .bold))
                    Text("Добавить зерно")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.accentColor)
                .clipShape(Capsule())
                .shadow(color: Color.accentColor.opacity(0.4), radius: 12, x: 0, y: 6)
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddGrainView(grainStore: grainStore)
        }
    }
    
    private var yearsList: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        let years = Set(grainStore.grains.map { Calendar.current.component(.year, from: $0.date) } + [currentYear, currentYear - 1])
        return Array(years).sorted(by: >)
    }
    
    private var selectedMonthTitle: String {
        let comps = Calendar.current.dateComponents([.year, .month], from: selectedMonth)
        let year = comps.year ?? Calendar.current.component(.year, from: Date())
        
        if showYearOnly {
            return "\(year) г."
        } else {
            let month = (comps.month ?? 1)
            return "\(monthName(month)) \(year) г."
        }
    }
    
    private func monthName(_ month: Int) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ru_RU")
        let name = fmt.monthSymbols[max(0, min(month - 1, 11))]
        return name.capitalized
    }
    
    private func date(year: Int, month: Int) -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = 1
        return Calendar.current.date(from: comps) ?? Date()
    }
}

private func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter.string(from: date)
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AddGrainView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var grainStore: GrainStore
    
    @State private var name = ""
    @State private var weight = ""
    @State private var price = ""
    @State private var date = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Название зерна", text: $name)
                TextField("Вес (г)", text: $weight)
                    .keyboardType(.decimalPad)
                TextField("Цена (₽)", text: $price)
                    .keyboardType(.decimalPad)
                DatePicker("Дата", selection: $date, displayedComponents: .date)
            }
            .navigationTitle("Добавить зерно")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        if let w = Double(weight), let p = Double(price) {
                            let newGrain = Grain(name: name, weight: w, price: p, date: date)
                            grainStore.grains.append(newGrain)
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    GrainsView()
        .environmentObject(GrainStore())
}
