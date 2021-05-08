//
//  BingoData.swift
//  Bingo
//
//  Created by Solomon Abrahams on 08/05/2021.
//

import Foundation

class BingoData: ObservableObject {
    private static var documentsFolder: URL {
        do {
            return try FileManager.default.url(for: .documentDirectory,
                                               in: .userDomainMask,
                                               appropriateFor: nil,
                                               create: false)
        } catch {
            fatalError("Can't find documents directory.")
        }
    }
    private static var fileURL: URL {
        return documentsFolder.appendingPathComponent("cards.data")
    }
    @Published var cards: [BingoCard] = []
    
    func load() {
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let data = try? Data(contentsOf: Self.fileURL) else {
                    #if DEBUG
                    DispatchQueue.main.async {
                        self?.cards = BingoCard.data
                    }
                    #endif
                    return
                }
                guard let bingoCards = try? JSONDecoder().decode([BingoCard].self, from: data) else {
                    fatalError("Can't decode saved cards data.")
                }
                DispatchQueue.main.async {
                    self?.cards = bingoCards
                }
            }
    }
    
    func save() {
        print("save")
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let cards = self?.cards else { fatalError("Self out of scope") }
            guard let data = try? JSONEncoder().encode(cards) else { fatalError("Error encoding data") }
            do {
                let outfile = Self.fileURL
                try data.write(to: outfile)
            } catch {
                fatalError("Can't write to file")
            }
        }
    }
}
