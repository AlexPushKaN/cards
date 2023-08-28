import Foundation

class Snapshot: Codable {
    
    var numberOfCardsFlips: Int = 0
    var cardsPairsCounts: Int = 0
    var cards: [Card] = []
    var flippedCards: [Card] = []
}

//MARK: - UserDefaults Snapshot
extension Snapshot {

    static let snapshotDefaultsKey = "snapshotDefaultsKey"

    static func save(snapshot: Snapshot?) {
        let data = try? JSONEncoder().encode(snapshot)
        UserDefaults.standard.set(data, forKey: snapshotDefaultsKey)
    }

    static func loadSnapshot() -> Snapshot? {

        var snapshotGame: Snapshot?
        
        if let data = UserDefaults.standard.data(forKey: snapshotDefaultsKey) {
            snapshotGame = try? JSONDecoder().decode(Snapshot.self, from: data)
        }

        return snapshotGame
    }
}
