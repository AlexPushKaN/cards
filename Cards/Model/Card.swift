import UIKit

enum CardType: String, CaseIterable, Codable {
    
    case circle
    case square
    case cross
    case emptyRect
    case emptyCircle
}

enum CardColor: String, CaseIterable, Codable {
    
    case blue
    case green
    case red
    case yellow
    case brown
    case orange
    case purple
    
    static func colorToEnumCase(color: UIColor) -> CardColor {
        
        var caseColor: CardColor = .blue
        if color == UIColor.blue { caseColor = CardColor.blue }
        else if color == UIColor.green { caseColor = CardColor.green }
        else if color == UIColor.red { caseColor = CardColor.red }
        else if color == UIColor.yellow { caseColor = CardColor.yellow }
        else if color == UIColor.brown { caseColor = CardColor.brown }
        else if color == UIColor.orange { caseColor = CardColor.orange }
        else if color == UIColor.purple { caseColor = CardColor.purple }

        return caseColor
    }
}

class Card: Codable {
    
    let type: CardType
    let color: CardColor
    var tag: Int
    var isFlipped: Bool
    var frame: CGRect
    
    init(type: CardType, color: CardColor, tag: Int, isFlipped: Bool, frame: CGRect) {
        self.type = type
        self.color = color
        self.tag = tag
        self.isFlipped = isFlipped
        self.frame = frame
    }
}
