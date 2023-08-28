import Foundation

class Game {

    var cardsCount = 0
    var cards = [Card]()
    var cardTypes: [CardType] = []
    var cardColors: [CardColor] = []
    var cardBackSides: [String] = []
    
    func setForGame(settings: Settings?) {
        
        cardTypes = []
        cardColors = []
        cardBackSides = []
        
        if let settings = settings {
            
            self.cardsCount = settings.cardsPairsCounts
            cardTypes = settings.cardTypes.compactMap { $0.value ? $0.key : nil }
            cardColors = settings.cardColors.compactMap { $0.value ? $0.key : nil }
            cardBackSides = settings.cardBackSides.compactMap { $0.value ? $0.key : nil }
        }
    }
    
    func generateCards() {
        
        var cards = [Card]()
        for tag in 0..<cardsCount {
            let randomElement = Card(type: cardTypes.count > 0 ? cardTypes.randomElement()! : CardType.allCases.randomElement()!,
                                     color: cardColors.count > 0 ? cardColors.randomElement()! : CardColor.allCases.randomElement()!,
                                     tag: tag,
                                     isFlipped: false,
                                     frame: .zero)
            
            cards.append(randomElement)
        }
        self.cards = cards
    }

    func checkCards(_ firstCard: Card, _ secondCard: Card) -> Bool {
        return firstCard.type == secondCard.type && firstCard.color == secondCard.color
    }
    
    func getScore(flips: Int) -> Int {
        
        let totalScore = cardsCount * 100
        let deduction = flips * 10
        let score = totalScore > deduction ? totalScore - deduction : 0
        
        return score
    }
}
