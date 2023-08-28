import UIKit

class SceneAnimation {
    
    var cardCounts: Int
    var cardViewFactory = CardViewFactory()
    weak var controller: UIViewController?
    lazy var cardViews = getCardsOnScene(forAnimation: cardCounts)
    private var animator: UIDynamicAnimator
    private var collisionBehavior: UICollisionBehavior
    
    init(cardCounts: Int, controller: UIViewController) {
        
        self.cardCounts = cardCounts
        self.controller = controller
        animator = UIDynamicAnimator(referenceView: controller.view)
        collisionBehavior = UICollisionBehavior(items: [])
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(collisionBehavior)
    }

    private func getCardsOnScene(forAnimation count: Int) -> [UIView] {
        var cardViews: [UIView] = []
        
        for _ in 0..<count {
            
            let randomSize = CGFloat.random(in: 80.0...120.0)
            let cardSize = CGSize(width: randomSize * 2 / 3, height: randomSize)
            let cardView = cardViewFactory.get(CardType.allCases.randomElement()!,
                                                withSize: cardSize,
                                                withColor: CardColor.allCases.randomElement()!,
                                                andBoardSize: controller?.view.bounds.size ?? CGSize.zero)
            
            let widthScene = controller?.view.bounds.width ?? 0 - cardView.bounds.width
            let heightScene = controller?.view.bounds.height ?? 0 - cardView.bounds.height
            
            cardView.frame.origin.x = CGFloat.random(in: 0.0...widthScene)
            cardView.frame.origin.y = CGFloat.random(in: 0.0...heightScene)
            
            cardViews.append(cardView)
        }
        return cardViews
    }
    
    func animatedCards() {
        
        guard let referenceView = animator.referenceView else {
            return
        }
        
        for cardView in cardViews {
            
            cardView.isUserInteractionEnabled = false
            let x = CGFloat.random(in: 0.0...controller!.view.frame.width - cardView.frame.width)
            let y =  CGFloat.random(in: 0.0...controller!.view.frame.height - cardView.frame.height)
            
            if !referenceView.subviews.contains(cardView) {
                referenceView.addSubview(cardView)
            }
            
            collisionBehavior.addItem(cardView)
            
            UIView.animate(withDuration: 2.0, delay: 0.0, usingSpringWithDamping: 5.0, initialSpringVelocity: 5.0) {
                
                cardView.frame.origin.x = x
                cardView.frame.origin.y = y
                (cardView as! FlippableView).flip(all: true)
                
            } completion: { _ in
                
                (cardView as! FlippableView).flip(all: true)
                
                let dynamicItemBehavior = UIDynamicItemBehavior(items: [cardView])
                dynamicItemBehavior.addLinearVelocity(CGPoint(x: CGFloat.random(in: -50...50), y: CGFloat.random(in: -50...50)), for: cardView)
                dynamicItemBehavior.elasticity = 1.0
                self.animator.addBehavior(dynamicItemBehavior)

                let pushBehavior = UIPushBehavior(items: [cardView], mode: .instantaneous)
                pushBehavior.magnitude = 0.7
                pushBehavior.angle = CGFloat.random(in: 0...(2 * .pi))
                self.animator.addBehavior(pushBehavior)
            }
        }
    }
}
