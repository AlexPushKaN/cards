import Foundation

class Game {

    var cardsCount = 0
    var cards = [Card]()
    var cardTypes: [CardType]?
    var cardColors: [CardColor]?
    var cardBackSides: [String]?
    
    init(cardsCount: Int) {
        self.cardsCount = cardsCount
    }
    
    init?(settingsGame: Settings?) {
        
        guard let settingsGame = settingsGame else { return nil }
        
        cardTypes = []
        cardColors = []
        cardBackSides = []
        
        self.cardsCount = settingsGame.cardsPairsCounts
        cardTypes = settingsGame.cardTypes.compactMap { $0.value ? $0.key : nil }
        cardColors = settingsGame.cardColors.compactMap { $0.value ? $0.key : nil }
        cardBackSides = settingsGame.cardBackSides.compactMap { $0.value ? $0.key : nil }
    }
    
    func generateCards() {
        
        var cards = [Card]()
        for _ in 0..<cardsCount {
            let randomElement = Card(type: cardTypes?.randomElement()! ?? CardType.allCases.randomElement()!,
                                     color: cardColors?.randomElement()! ?? CardColor.allCases.randomElement()!)
            cards.append(randomElement)
        }
        self.cards = cards
    }

    func checkCards(_ firstCard: Card, _ secondCard: Card) -> Bool {
        return firstCard == secondCard
    }
    
    func getScore(flips: Int) -> Int {
        
        let totalScore = cardsCount * 100
        let deduction = flips * 10
        let score = totalScore > deduction ? totalScore - deduction : 0
        
        return score
    }
}
