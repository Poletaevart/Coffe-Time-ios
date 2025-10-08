import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: DrinkStore
    @State private var isAddDrinkPresented: Bool = false
    @State private var selectedType: CoffeeType = .espresso
    @State private var otherName: String = ""
    @State private var inputMilliliters: String = ""
    @State private var inputPriceRub: String = ""
    @State private var inputPlace: String = ""
    @State private var inputDate: Date = Date()
    @State private var isEditingDrink: Drink? = nil

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        StatTile(title: "Чашек", value: "\(store.cupsCount(for: Date()))")
                        StatTile(title: "мл", value: "\(store.totalMilliliters(for: Date()))")
                        StatTile(title: "₽", value: String(format: "%.0f", store.totalPriceRub(for: Date())))
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("История за \(AppFormatting.monthTitle(for: Date()))")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Spacer()
                        if !store.drinks(for: Date()).isEmpty {
                            Text("\(store.drinks(for: Date()).count)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.thinMaterial, in: Capsule())
                        }
                    }

                    if store.drinks(for: Date()).isEmpty {
                        HStack(spacing: 10) {
                            Image(systemName: "tray")
                                .foregroundStyle(.secondary)
                            Text("Пока пусто. Добавьте первый кофе")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(store.drinks(for: Date())) { drink in
                                    DrinkRow(drink: drink, onEdit: { item in
                                        inputMilliliters = String(item.milliliters)
                                        inputPriceRub = String(Int(item.priceRub))
                                        inputPlace = item.place
                                        inputDate = item.date
                                        selectedType = item.type
                                        otherName = (item.type == .other) ? (item.customTypeName ?? "") : ""
                                        // Present edit sheet
                                        isEditingDrink = item
                                    }, onDelete: { item in
                                        store.deleteDrink(item)
                                    })
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 8)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: { isAddDrinkPresented = true }) {
                HStack(spacing: 10) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 18, weight: .bold))
                    Text("Добавить кофе")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.accentColor, in: Capsule())
                .overlay(
                    Capsule().strokeBorder(.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.accentColor.opacity(0.35), radius: 14, x: 0, y: 8)
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        // Форма добавления напитка
        .sheet(isPresented: $isAddDrinkPresented) {
            NavigationStack {
                Form {
                    DatePicker("Дата", selection: $inputDate, displayedComponents: [.date, .hourAndMinute])

                    Picker("Тип", selection: $selectedType) {
                        ForEach(CoffeeType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }

                    if selectedType == .other {
                        TextField("Название напитка", text: $otherName)
                    }

                    TextField("Миллилитры", text: $inputMilliliters)
                        .keyboardType(.numberPad)
                    TextField("Цена (₽)", text: $inputPriceRub)
                        .keyboardType(.decimalPad)
                    TextField("Где пил", text: $inputPlace)
                }
                .navigationTitle("Добавить кофе")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Отмена") { isAddDrinkPresented = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Сохранить") {
                            let ml = Int(inputMilliliters.filter { $0.isNumber }) ?? 0
                            let price = Double(inputPriceRub.replacingOccurrences(of: ",", with: ".")) ?? 0
                            store.addDrink(
                                date: inputDate,
                                milliliters: ml,
                                priceRub: price,
                                place: inputPlace,
                                type: selectedType,
                                customTypeName: selectedType == .other ? otherName : nil
                            )
                            clearInput()
                            isAddDrinkPresented = false
                        }
                        .disabled(!isAddValid)
                    }
                }
            }
        }
        // Форма редактирования напитка
        .sheet(item: $isEditingDrink) { editing in
            NavigationStack {
                Form {
                    DatePicker("Дата", selection: $inputDate, displayedComponents: [.date, .hourAndMinute])

                    Picker("Тип", selection: $selectedType) {
                        ForEach(CoffeeType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }

                    if selectedType == .other {
                        TextField("Название напитка", text: $otherName)
                    }

                    TextField("Миллилитры", text: $inputMilliliters)
                        .keyboardType(.numberPad)
                    TextField("Цена (₽)", text: $inputPriceRub)
                        .keyboardType(.decimalPad)
                    TextField("Где пил", text: $inputPlace)
                }
                .navigationTitle("Редактировать кофе")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Отмена") { isEditingDrink = nil }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Сохранить") {
                            let ml = Int(inputMilliliters.filter { $0.isNumber }) ?? 0
                            let price = Double(inputPriceRub.replacingOccurrences(of: ",", with: ".")) ?? 0
                            store.updateDrink(
                                editing,
                                date: inputDate,
                                milliliters: ml,
                                priceRub: price,
                                place: inputPlace,
                                type: selectedType,
                                customTypeName: selectedType == .other ? otherName : nil
                            )
                            clearInput()
                            isEditingDrink = nil
                        }
                        .disabled(!isAddValid)
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button(role: .destructive) {
                            store.deleteDrink(editing)
                            clearInput()
                            isEditingDrink = nil
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
        }
    }

    private var isAddValid: Bool {
        let hasML = Int(inputMilliliters) ?? 0 > 0
        let hasType = (selectedType != .other) || !otherName.trimmingCharacters(in: .whitespaces).isEmpty
        return hasML && hasType
    }

    private func clearInput() {
        inputMilliliters = ""
        inputPriceRub = ""
        inputPlace = ""
        inputDate = Date()
        selectedType = .espresso
        otherName = ""
    }
}

extension HomeView {
    struct DrinkRow: View {
        let drink: Drink
        let onEdit: (Drink) -> Void
        let onDelete: (Drink) -> Void

        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(drink.place)
                        .font(.headline)
                    Text(drink.customTypeName ?? drink.type.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(AppFormatting.shortDate(drink.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(drink.milliliters) мл")
                        .font(.subheadline)
                    Text(String(format: "%.0f ₽", drink.priceRub))
                        .font(.subheadline)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .contentShape(Rectangle())
            .onTapGesture {
                onEdit(drink)
            }
        }
    }
}
