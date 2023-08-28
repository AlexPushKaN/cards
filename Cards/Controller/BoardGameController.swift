import UIKit

class BoardGameController: UIViewController {

    var cardPairsCount = 4
    var cardViews = [UIView]()
    var cardViewsForSnapshot = [UIView]()
    var settingsGame: Settings? = Settings.loadSettings()
    var snapshot: Snapshot?
    var delegate: SnapshotProtocol?
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
        
        view.backgroundColor = .white
        view.addSubview(backButtonView)
        view.addSubview(startButtonView)
        view.addSubview(flipButtonView)
        view.addSubview(firstLabelView)
        view.addSubview(secondLabelView)
        view.addSubview(boardGameView)
        
        self.numberOfCardsFlips = snapshot?.numberOfCardsFlips ?? 0
    }
    
    func getNewGame() -> Game {
        
        flippedCards = []
        isFrontSide = false
        
        let game = Game()
        game.cardsCount = cardPairsCount
        game.setForGame(settings: settingsGame)
        
        if let snapshot = snapshot {
            
            game.cards = snapshot.cards
            let cardViews = self.getCardsBy(stepIn: 2, modelData: snapshot.cards, continueGame: true)
            placeCardsOnBoard(cardViews)
        } else {

            game.generateCards()
            let cardViews = self.getCardsBy(stepIn: 1, modelData: game.cards, continueGame: false)
            placeCardsOnBoard(cardViews)
            takeSnapshotBoard(cardViews: cardViewsForSnapshot)
        }
        return game
    }

    private func getCardsBy(stepIn: Int, modelData: [Card], continueGame: Bool) -> [UIView] {
        
        var cardViews = [UIView]()
        let cardViewFactory = CardViewFactory()

        for indexModelCard in stride(from: 0, to: modelData.count, by: stepIn) {

            let cardOne = cardViewFactory.get(modelData[indexModelCard].type,
                                              withSize: cardSize,
                                              withColor: modelData[indexModelCard].color,
                                              andBoardSize: boardGameView.bounds.size)
            cardOne.tag = indexModelCard
            cardViews.append(cardOne)
                
            let cardTwo = cardViewFactory.get(modelData[indexModelCard].type,
                                                  withSize: cardSize,
                                                  withColor: modelData[indexModelCard].color,
                                                  andBoardSize: boardGameView.bounds.size)
            cardTwo.tag = indexModelCard
            cardViews.append(cardTwo)
        }
        
        if continueGame {
            
            for (index, card) in cardViews.enumerated() {
                
                card.frame = modelData[index].frame
                (card as! FlippableView).isFlipped = modelData[index].isFlipped
                if (card as! FlippableView).isFlipped {
                    self.flippedCards.append(card)
                }
            }
        }
            
        cardViewsForSnapshot = cardViews
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
                    
                    self.numberOfCardsFlips += 1
                } else if self.flippedCards.count == 2 {
                    
                    let firstCard = game.cards[self.flippedCards.first!.tag]
                    let secondCard = game.cards[self.flippedCards.last!.tag]
                    if game.checkCards(firstCard, secondCard) {
                        for flippedCard in self.flippedCards {
                            guard let index = cardViewsForSnapshot.firstIndex(of: flippedCard) else { return }
                            cardViewsForSnapshot.remove(at: index)
                        }
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
                takeSnapshotBoard(cardViews: cardViewsForSnapshot)
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
            
            let randomXCoordinate = card.frame.origin.x > 0.0 ? Int(card.frame.origin.x) : Int.random(in: 0...cardMaxXCoordinate)
            let randomYCoordinate = card.frame.origin.y > 0.0 ? Int(card.frame.origin.y) : Int.random(in: 0...cardMaxYCoordinate)
            card.frame.origin = CGPoint(x: randomXCoordinate, y: randomYCoordinate)
            boardGameView.addSubview(card)
        }
    }

    private func takeSnapshotBoard(cardViews: [UIView]) {
        
        self.snapshot = Snapshot()
        self.snapshot?.numberOfCardsFlips = self.numberOfCardsFlips
        self.snapshot?.cardsPairsCounts = self.cardPairsCount
        
        guard let snapshot = self.snapshot else { return }

        snapshot.cards.removeAll()
        
        for cardView in cardViews {

            if let cardView = cardView as? CardView<CircleShape> {
                
                let card = Card(type: .circle,
                                color: CardColor.colorToEnumCase(color: cardView.color),
                                tag: cardView.tag,
                                isFlipped: cardView.isFlipped,
                                frame: cardView.frame)
                snapshot.cards.append(card)
                cardView.isFlipped ? snapshot.flippedCards.append(card) : nil
            } else if let cardView = cardView as? CardView<SquareShape> {
                
                let card = Card(type: .square,
                                color: CardColor.colorToEnumCase(color: cardView.color),
                                tag: cardView.tag,
                                isFlipped: cardView.isFlipped,
                                frame: cardView.frame)
                snapshot.cards.append(card)
                cardView.isFlipped ? snapshot.flippedCards.append(card) : nil
            } else if let cardView = cardView as? CardView<CrossShape> {
                
                let card = Card(type: .cross,
                                color: CardColor.colorToEnumCase(color: cardView.color),
                                tag: cardView.tag,
                                isFlipped: cardView.isFlipped,
                                frame: cardView.frame)
                snapshot.cards.append(card)
                cardView.isFlipped ? snapshot.flippedCards.append(card) : nil
            } else if let cardView = cardView as? CardView<EmptyRectShape> {
                
                let card = Card(type: .emptyRect,
                                color: CardColor.colorToEnumCase(color: cardView.color),
                                tag: cardView.tag,
                                isFlipped: cardView.isFlipped,
                                frame: cardView.frame)
                snapshot.cards.append(card)
                cardView.isFlipped ? snapshot.flippedCards.append(card) : nil
            }
        }
        self.delegate!.continueGame = self.snapshot
    }
    
    private func showCongratulationAlert(score: Int) {
        
        let alert = AlertManager.getCongratulationAlert(score: score,
            okCompletion: { [weak self] in
                
                guard let self = self else { return }
                self.flippedCards = []
                self.isFrontSide = false
                self.numberOfCardsFlips = 0
                snapshot = nil
                self.game = self.getNewGame()
                delegate!.continueGame = nil
                Snapshot.save(snapshot: nil)
            },
            cancelCompletion: { [weak self] in
                
                guard let self = self else { return }
                self.numberOfCardsFlips = 0
                delegate!.continueGame = nil
                Snapshot.save(snapshot: nil)
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
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 10.0
        
        button.addAction(UIAction(handler: { action in
            
            if self.cardViewsForSnapshot.count > 0 {
                self.takeSnapshotBoard(cardViews: self.cardViewsForSnapshot)
            }
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
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 10.0
        
        button.addAction(UIAction(handler: { action in

            self.game = self.getNewGame()
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
        button.backgroundColor = .lightGray
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
