import UIKit

class CardViewFactory {

    func get(_ shape: CardType, withSize size: CGSize, withColor color: CardColor, andBoardSize boardSize: CGSize) -> UIView {

        let frame = CGRect(origin: .zero, size: size)
        let viewColor = getViewColorBy(modelColor: color)

        switch shape {
        case .circle: return CardView<CircleShape>(frame: frame, color: viewColor, boardSize: boardSize)
        case .square: return CardView<SquareShape>(frame: frame, color: viewColor, boardSize: boardSize)
        case .cross: return CardView<CrossShape>(frame: frame, color: viewColor, boardSize: boardSize)
        case .emptyRect: return CardView<EmptyRectShape>(frame: frame, color: viewColor, boardSize: boardSize)
        case .emptyCircle: return CardView<EmptyCircleShape>(frame: frame, color: viewColor, boardSize: boardSize)
        }
    }

    private func getViewColorBy(modelColor: CardColor) -> UIColor {

        switch modelColor {
        case .blue: return .blue
        case .green: return .green
        case .red: return .red
        case .yellow: return .yellow
        case .brown: return .brown
        case .orange: return .orange
        case .purple: return .purple
        }
    }
}
