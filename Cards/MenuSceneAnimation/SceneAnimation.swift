import UIKit

class SceneAnimation {

    var cardViewFactory = CardViewFactory()
    var board: UIView
    var cardViews: [UIView] = []
    private var animator: UIDynamicAnimator
    private var collisionBehavior: UICollisionBehavior
    private var dynamicItemBehavior: UIDynamicItemBehavior
    private var pushBehavior: UIPushBehavior
    
    init(view: UIView) {

        self.board = view
        
        collisionBehavior = UICollisionBehavior(items: [])
        dynamicItemBehavior = UIDynamicItemBehavior(items: [])
        pushBehavior = UIPushBehavior(items: [], mode: .instantaneous)

        animator = UIDynamicAnimator(referenceView: board)
        animator.addBehavior(dynamicItemBehavior)
        animator.addBehavior(collisionBehavior)
        animator.addBehavior(pushBehavior)
    }

    func getCardsOnScene(forAnimation count: Int) {
        
        for _ in 0..<count {
            
            let randomSize = CGFloat.random(in: 80.0...120.0)
            let cardSize = CGSize(width: randomSize * 2 / 3, height: randomSize)
            let cardView = cardViewFactory.get(CardType.allCases.randomElement()!,
                                                withSize: cardSize,
                                                withColor: CardColor.allCases.randomElement()!,
                                               andBoardSize: board.bounds.size)
            
            let widthScene = board.bounds.width - cardView.bounds.width
            let heightScene = board.bounds.height - cardView.bounds.height
            
            cardView.frame.origin.x = CGFloat.random(in: 0.0...widthScene)
            cardView.frame.origin.y = CGFloat.random(in: 0.0...heightScene)
            
            cardViews.append(cardView)
        }
    }
    
    func animatedCards() {
        
        for cardView in cardViews {
            
            cardView.isUserInteractionEnabled = false
            let x = CGFloat.random(in: 0.0...board.frame.width - cardView.frame.width)
            let y =  CGFloat.random(in: 0.0...board.frame.height - cardView.frame.height)
            
            board.addSubview(cardView)
            
            UIView.animate(withDuration: 2.0, delay: 0.0, usingSpringWithDamping: 5.0, initialSpringVelocity: 5.0) {

                cardView.frame.origin.x = x
                cardView.frame.origin.y = y
                (cardView as! FlippableView).flip(all: true)

            } completion: { _ in
                
                cardView.frame.origin.x = x
                cardView.frame.origin.y = y
                (cardView as! FlippableView).flip(all: true)
                
                self.collisionBehavior.setTranslatesReferenceBoundsIntoBoundary( with: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1))
                self.dynamicItemBehavior.addLinearVelocity(CGPoint(x: CGFloat.random(in: -50...50), y: CGFloat.random(in: -50...50)), for: cardView)
                self.dynamicItemBehavior.elasticity = 1.0
                self.pushBehavior.magnitude = 1.0
                self.pushBehavior.angle = CGFloat.random(in: 0...(2 * .pi))
                
                self.collisionBehavior.addItem(cardView)
                self.dynamicItemBehavior.addItem(cardView)
                self.pushBehavior.addItem(cardView)
            }
        }
    }
}
