import Foundation

class Settings: Codable {
    
    var cardsPairsCounts: Int = 0
    var cardTypes: [CardType : Bool] = [:]
    var cardColors: [CardColor : Bool] = [:]
    var cardBackSides: [String : Bool] = [:]
}

//MARK: - UserDefaults Settings
extension Settings {

    static let settingsDefaultsKey = "settingsDefaultsKey"

    static func save(settings: Settings) {
        let data = try? JSONEncoder().encode(settings)
        UserDefaults.standard.set(data, forKey: settingsDefaultsKey)
    }

    static func loadSettings() -> Settings? {

        var settingsGame: Settings?
        
        if let data = UserDefaults.standard.data(forKey: settingsDefaultsKey) {
            settingsGame = try? JSONDecoder().decode(Settings.self, from: data)
        }

        return settingsGame
    }
}
