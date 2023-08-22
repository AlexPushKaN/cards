import UIKit

class BoardGameController: UIViewController {

    var cardsPairsCounts = 8
    var cardViews = [UIView]()
    var numberOfCardsFlips = 0 {
        didSet {
            secondLabelView.text = String(numberOfCardsFlips)
        }
    }
    lazy var numberOfCards = 0 {
        didSet {
            if numberOfCards == 0 {
                let score = game.getScore(flips: numberOfCardsFlips)
                showCongratulationAlert(score: score)
            }
        }
    }
    lazy var game: Game = getNewGame()
    lazy var backButtonView = getBackButtonView()
    lazy var startButtonView = getStartButtonView()
    lazy var flipButtonView =  getFlipButtonView()
    lazy var firstLabelView = getFirstLabelView()
    lazy var secondLabelView = getSecondLabelView()
    lazy var boardGameView = getBoardGameView()
    private var cardSize: CGSize { CGSize(width: 80.0, height: 120.0) }
    private var cardMaxXCoordinate: Int { Int(boardGameView.frame.width - cardSize.width) }
    private var cardMaxYCoordinate: Int { Int(boardGameView.frame.height - cardSize.height) }
    private var flippedCards = [UIView]()
    private var isFrontSide: Bool?
    
    override func loadView() {
        
        super.loadView()
        view.backgroundColor = .systemBackground
        view.addSubview(backButtonView)
        view.addSubview(startButtonView)
        view.addSubview(flipButtonView)
        view.addSubview(firstLabelView)
        view.addSubview(secondLabelView)
        view.addSubview(boardGameView)
    }

    private func getNewGame() -> Game {

        if let game = Game(settingsGame: Settings.loadSettings()) {
            numberOfCardsFlips = 0
            game.generateCards()
            return game
        }
        
        let game = Game(cardsCount: cardsPairsCounts)
        numberOfCardsFlips = 0
        game.generateCards()
        return game
    }

    private func getCardsBy(modelData: [Card]) -> [UIView] {

        var cardViews = [UIView]()
        let cardViewFactory = CardViewFactory()

        for (index, modelCard) in modelData.enumerated() {
    
            let cardOne = cardViewFactory.get(modelCard.type, withSize: cardSize, withColor: modelCard.color, andBoardSize: boardGameView.bounds.size)
            cardOne.tag = index
            cardViews.append(cardOne)

            let cardTwo = cardViewFactory.get(modelCard.type, withSize: cardSize, withColor: modelCard.color, andBoardSize: boardGameView.bounds.size)
            cardTwo.tag = index
            cardViews.append(cardTwo)
        }
        
        numberOfCards = cardViews.count
        
        for card in cardViews {
            
            (card as! FlippableView).flipCompletionHandler = { [self] flippedCard in

                if flippedCard.isFlipped {
                    self.flippedCards.append(flippedCard)
                } else {
                    if let cardIndex = self.flippedCards.firstIndex(of: flippedCard) {
                        self.flippedCards.remove(at: cardIndex)
                    }
                }
                
                if self.flippedCards.count == 1  {
                    numberOfCardsFlips += 1
                } else if self.flippedCards.count == 2 {
                    let firstCard = game.cards[self.flippedCards.first!.tag]
                    let secondCard = game.cards[self.flippedCards.last!.tag]
                    if game.checkCards(firstCard, secondCard) {
                        UIView.animate(withDuration: 0.3, animations: {
                            self.flippedCards.first!.layer.opacity = 0
                            self.flippedCards.last!.layer.opacity = 0
                        }, completion: {_ in
                            self.flippedCards.first!.removeFromSuperview()
                            self.flippedCards.last!.removeFromSuperview()
                            self.flippedCards = []
                            self.numberOfCards -= 2
                        })
                    } else {
                        for card in self.flippedCards {
                            (card as! FlippableView).flip(all: false)
                        }
                    }
                }
            }
        }
        return cardViews
    }

    private func placeCardsOnBoard(_ cards: [UIView]) {

        for card in cardViews {
            card.removeFromSuperview()
        }
    
        cardViews = cards
        
        for card in cardViews {
            let randomXCoordinate = Int.random(in: 0...cardMaxXCoordinate)
            let randomYCoordinate = Int.random(in: 0...cardMaxYCoordinate)
            card.frame.origin = CGPoint(x: randomXCoordinate, y: randomYCoordinate)
            boardGameView.addSubview(card)
        }
    }

    private func showCongratulationAlert(score: Int) {
        
        let alert = AlertManager.getCongratulationAlert(score: score,
            okCompletion: { [weak self] in
                
                guard let self = self else { return }
                self.flippedCards = []
                self.isFrontSide = false
                self.game = self.getNewGame()
                let cards = self.getCardsBy(modelData: self.game.cards)
                self.placeCardsOnBoard(cards)
            },
            cancelCompletion: { [weak self] in
                
                guard let self = self else { return }
                self.numberOfCardsFlips = 0
                self.dismiss(animated: true)
            }
        )
        present(alert, animated: true)
    }
}

//MARK: Configure views on scene
extension BoardGameController {
    
    private func getBackButtonView() -> UIButton {

        let button = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 50.0))
        let window = UIApplication.shared.windows[0]
        let topPadding = window.safeAreaInsets.top
        button.frame.origin.y = topPadding
        button.setTitle(" Меню ", for: .normal)
        button.sizeToFit()
        button.frame.origin.x = 20.0
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.backgroundColor = .systemGray4
        button.layer.cornerRadius = 10.0
        
        button.addAction(UIAction(handler: { action in
            
            self.dismiss(animated: true)
        }), for: .touchUpInside)
        
        return button
    }

    private func getStartButtonView() -> UIButton {

        let button = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 50.0))
        let window = UIApplication.shared.windows[0]
        let topPadding = window.safeAreaInsets.top
        button.frame.origin.y = topPadding
        button.setTitle(" Начать игру ", for: .normal)
        button.sizeToFit()
        button.frame.origin.x = backButtonView.frame.maxX + 10
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.backgroundColor = .systemGray4
        button.layer.cornerRadius = 10.0
        
        button.addAction(UIAction(handler: { action in
            
            self.flippedCards = []
            self.isFrontSide = false
            self.game = self.getNewGame()
            let cards = self.getCardsBy(modelData: self.game.cards)
            self.placeCardsOnBoard(cards)
        }), for: .touchUpInside)
        
        return button
    }
    
    private func getFlipButtonView() -> UIButton {

        let button = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 50.0))
        let window = UIApplication.shared.windows[0]
        let topPadding = window.safeAreaInsets.top
        button.frame.origin.y = topPadding
        button.setTitle(" Перевернуть все ", for: .normal)
        button.sizeToFit()
        button.frame.origin.x = startButtonView.frame.maxX + 10.0
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.backgroundColor = .systemGray4
        button.layer.cornerRadius = 10.0
        button.addAction(UIAction(handler: { action in
            
            self.flippedCards = []
            guard let isFrontSide = self.isFrontSide else { return }
            self.isFrontSide = !isFrontSide
            self.cardViews.forEach { cardViews in
                if (cardViews as! FlippableView).isFlipped == isFrontSide {
                    (cardViews as! FlippableView).flip(all: true)
                }
            }
        }), for: .touchUpInside)
        
        return button
    }
    
    private func getFirstLabelView() -> UILabel {

        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 50.0))
        label.frame.origin.y = backButtonView.frame.maxY + 25.0
        label.font = .boldSystemFont(ofSize: 17.0)
        label.textColor = .black
        label.text = "Количество переворотов карт:"
        label.sizeToFit()
        label.center.x = view.center.x - 20.0

        return label
    }
    
    private func getSecondLabelView() -> UILabel {

        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 20.0))
        label.frame.origin.y = backButtonView.frame.maxY + 25.0
        label.font = .boldSystemFont(ofSize: 25.0)
        label.textColor = .systemPink
        label.text = "0"
        label.frame.origin.x = firstLabelView.frame.maxX + 20.0

        return label
    }
    
    private func getBoardGameView() -> UIView {
        
        let margin: CGFloat = 10.0
        let marginTop: CGFloat = 60.0
        let boardView = UIView()
        
        let window = UIApplication.shared.windows[0]
        let topPadding = window.safeAreaInsets.top
        
        boardView.frame.origin.x = margin
        boardView.frame.origin.y = topPadding + startButtonView.frame.height + marginTop
        boardView.frame.size.width = UIScreen.main.bounds.width - margin * 2

        let bottomPadding = window.safeAreaInsets.bottom
        boardView.frame.size.height = UIScreen.main.bounds.height - boardView.frame.origin.y - margin - bottomPadding
        boardView.layer.cornerRadius = 5
        boardView.backgroundColor = UIColor(red: 0.1, green: 0.9, blue: 0.1, alpha: 0.3)
    
        return boardView
    }
}
