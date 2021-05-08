//
//  ContentView.swift
//  Bingo
//
//  Created by Solomon Abrahams on 08/05/2021.
//

import SwiftUI

struct BingoItem: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var completed: Bool
    
    init(id: UUID = UUID(), title: String, completed: Bool) {
        self.id = id
        self.title = title
        self.completed = completed
    }
}

struct BingoCard: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var items: [BingoItem]

    init(id: UUID = UUID(), title: String, items: [BingoItem]) {
        self.id = id
        self.title = title
        self.items = items
    }
}

extension BingoCard {
    static var data: [BingoCard] {
        [
            BingoCard(title: "Card1", items: [BingoItem(title: "Item1", completed: false), BingoItem(title: "Item2", completed: false), BingoItem(title: "Item3", completed: false)]),
            BingoCard(title: "Card2", items: [BingoItem(title: "Item0", completed: false)]),
        ]
    }
}

extension BingoCard {
    struct Data {
        var title: String = ""
        var items: [BingoItem] = []
    }

    var data: Data {
        return Data(title: title, items: items)
    }

    mutating func update(from data: Data) {
        title = data.title
        items = data.items
    }
}

struct BingoEditor: View {
    @Binding var card: BingoCard
    
    var body: some View {
        ForEach(card.items, id: \.self) { item in
            TextField("test", text: binding(for: item).title)
        }
    }
    
    private func binding(for item: BingoItem) -> Binding<BingoItem> {
        guard let itemIndex = card.items.firstIndex(where: { $0.id == item.id }) else {
            fatalError("Can't find item in array")
        }
        return $card.items[itemIndex]
    }
}

struct BingoCreator: View, Equatable {
    static func == (lhs: BingoCreator, rhs: BingoCreator) -> Bool {
        return lhs.cards.count == rhs.cards.count && lhs.cards.count > 0
    }
    
    @Binding var cards: [BingoCard]
    let saveAction: () -> Void
    @State private var data = BingoCard.Data()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        VStack {
            Button("New") {
                let newCard = BingoCard(title: "NewCard", items: [BingoItem(title: "Item1", completed: false),
                    BingoItem(title: "Item2", completed: false),
                    BingoItem(title: "Item3", completed: false),
                    BingoItem(title: "Item4", completed: false),
                    BingoItem(title: "Item5", completed: false),
                    BingoItem(title: "Item6", completed: false),
                    BingoItem(title: "Item7", completed: false),
                    BingoItem(title: "Item8", completed: false),
                    BingoItem(title: "Item9", completed: false)]
                )
                cards.append(newCard)

            }
            NavigationView {
                List(cards) { card in
                    NavigationLink(destination: BingoEditor(card: binding(for: card))) {
                        Text(card.title)
                    }
                }
                .onChange(of: scenePhase) { phase in
                    if phase == .inactive { saveAction() }
                    saveAction()
                }
            }
        }
    }
    
    private func binding(for card: BingoCard) -> Binding<BingoCard> {
        guard let cardIndex = cards.firstIndex(where: { $0.id == card.id }) else {
            fatalError("Can't find card in array")
        }
        return $cards[cardIndex]
    }
}

struct BingoGrid: View {
    let data = (1...9).map { "Item \($0)" }
    @Binding var cards: [BingoCard]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(cards[0].items, id: \.self) {
                item in Text(item.title).frame(minHeight:100)
            }
        }
    }
}

struct ContentView: View {
    @ObservedObject private var data = BingoData()
    
    var body: some View {
        TabView {
            BingoCreator(cards: $data.cards) {
                data.save()
            }.equatable()
            .onAppear {
                data.load()
            }
            .tabItem {
                Text("Tab 1")
            }
            BingoGrid(cards: $data.cards).tabItem {
                Text("Tab 2")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
