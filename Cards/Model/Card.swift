import UIKit

enum CardType: String, CaseIterable, Codable {
    
    case circle
    case square
    case cross
    case emptyRect
}

enum CardColor: String, CaseIterable, Codable {
    
    case blue
    case green
    case red
    case yellow
    case brown
    case orange
    case purple
}

typealias Card = (type: CardType, color: CardColor)
