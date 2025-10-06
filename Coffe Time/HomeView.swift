import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: DrinkStore
    @State private var isAddDrinkPresented: Bool = false
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
                        StatTile(title: "Чашек", value: "\(store.currentMonthCupsCount)")
                        StatTile(title: "мл", value: "\(store.currentMonthTotalMilliliters)")
                        StatTile(title: "₽", value: String(format: "%.0f", store.currentMonthTotalPriceRub))
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
                        if !store.currentMonthDrinks.isEmpty {
                            Text("\(store.currentMonthDrinks.count)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.thinMaterial, in: Capsule())
                        }
                    }

                    if store.currentMonthDrinks.isEmpty {
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
                                ForEach(store.currentMonthDrinks) { drink in
                                    DrinkRow(drink: drink, onEdit: { item in
                                        inputMilliliters = String(item.milliliters)
                                        inputPriceRub = String(Int(item.priceRub))
                                        inputPlace = item.place
                                        inputDate = item.date
                                        // Present edit sheet
                                        isEditingDrink = item
                                    }, onDelete: { item in
                                        store.deleteDrink(item)
                                    })
                                }
                            }
                            .padding(.vertical, 2)
                        }
                        .frame(maxHeight: 260)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity)
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
        .sheet(isPresented: $isAddDrinkPresented) {
            AddDrinkSheet(
                milliliters: $inputMilliliters,
                priceRub: $inputPriceRub,
                place: $inputPlace,
                date: $inputDate
            ) {
                let ml = Int(inputMilliliters.filter { $0.isNumber }) ?? 0
                let price = Double(inputPriceRub.replacingOccurrences(of: ",", with: ".")) ?? 0
                store.addDrink(date: inputDate, milliliters: ml, priceRub: price, place: inputPlace)
                inputMilliliters = ""
                inputPriceRub = ""
                inputPlace = ""
                inputDate = Date()
            }
        }
        // Edit sheet
        .sheet(item: $isEditingDrink) { editing in
            AddDrinkSheet(
                milliliters: $inputMilliliters,
                priceRub: $inputPriceRub,
                place: $inputPlace,
                date: $inputDate,
                onSave: {
                let ml = Int(inputMilliliters.filter { $0.isNumber }) ?? 0
                let price = Double(inputPriceRub.replacingOccurrences(of: ",", with: ".")) ?? 0
                store.updateDrink(editing, date: inputDate, milliliters: ml, priceRub: price, place: inputPlace)
                inputMilliliters = ""
                inputPriceRub = ""
                inputPlace = ""
                inputDate = Date()
            },
                onDelete: {
                store.deleteDrink(editing)
                inputMilliliters = ""
                inputPriceRub = ""
                inputPlace = ""
                inputDate = Date()
            },
                isEditing: true
            )
        }
    }
}


