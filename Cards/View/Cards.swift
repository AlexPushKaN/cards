import UIKit

protocol FlippableView: UIView {
    var isFlipped: Bool { get set }
    var boardSize: CGSize { get set }
    var flipCompletionHandler: ((FlippableView) -> Void)? { get set }
    func flip(all: Bool)
}

class CardView<ShapeType: ShapeLayerProtocol>: UIView, FlippableView {
    
    var isFlipped: Bool = false {
        
        didSet {
            self.setNeedsDisplay()
        }
    }
    var flipCompletionHandler: ((FlippableView) -> Void)?
    var color: UIColor
    var cornerRadius = 20.0
    var boardSize: CGSize
    lazy var frontSideView: UIView = self.getFrontSideView()
    lazy var backSideView: UIView = self.getBackSideView()
    private let margin: Int = 10
    private var customAnchorPoint: CGPoint = CGPoint(x: 0.0, y: 0.0)
    private var startTouchPoint: CGPoint!

    init(frame: CGRect, color: UIColor, boardSize: CGSize) {
        
        self.color = color
        self.boardSize = boardSize
        super.init(frame: frame)
        
        setupBorders()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func flip(all: Bool) {
        let fromView = isFlipped ? frontSideView : backSideView
        let toView = isFlipped ? backSideView : frontSideView
        if all {
            UIView.transition(from: fromView, to: toView, duration: 0.5, options: [.transitionFlipFromTop], completion: nil)
        } else {
            UIView.transition(from: fromView, to: toView, duration: 0.5, options: [.transitionFlipFromTop], completion: { _ in
                self.flipCompletionHandler?(self)
            })
        }
        
        isFlipped.toggle()
    }
    
    override func draw(_ rect: CGRect) {

        backSideView.removeFromSuperview()
        frontSideView.removeFromSuperview()

        if isFlipped {
            self.addSubview(backSideView)
            self.addSubview(frontSideView)
        } else {
            self.addSubview(frontSideView)
            self.addSubview(backSideView)
        }
    }
    
    private func getFrontSideView() -> UIView {
        let view = UIView(frame: self.bounds)
        view.backgroundColor = .white
        let shapeView = UIView(frame: CGRect(x: margin,
                                             y: margin,
                                             width: Int(self.bounds.width) - margin * 2,
                                             height: Int(self.bounds.height) - margin * 2))
        view.addSubview(shapeView)
        let shapeLayer = ShapeType(size: shapeView.frame.size, fillColor: color.cgColor)
        shapeView.layer.addSublayer(shapeLayer)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = CGFloat(cornerRadius)
        return view
    }
    
    private func getBackSideView() -> UIView {
        let view = UIView(frame: self.bounds)
        view.backgroundColor = .white
        switch ["circle", "line"].randomElement()! {
        case "circle":
            let layer = BackSideCircle(size: self.bounds.size, fillColor: UIColor.black.cgColor)
            view.layer.addSublayer(layer)
        case "line":
            let layer = BackSideLine(size: self.bounds.size, fillColor: UIColor.black.cgColor)
            view.layer.addSublayer(layer) default:
            break
        }
        
        view.layer.masksToBounds = true
        view.layer.cornerRadius = CGFloat(cornerRadius)
    return view
    }
    
    private func setupBorders() {
        self.clipsToBounds = true
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.black.cgColor
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        customAnchorPoint.x = touches.first!.location(in: window).x - frame.minX
        customAnchorPoint.y = touches.first!.location(in: window).y - frame.minY
        startTouchPoint = frame.origin
        self.superview?.bringSubviewToFront(self)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.frame.origin.x = touches.first!.location(in: window).x - customAnchorPoint.x
        self.frame.origin.y = touches.first!.location(in: window).y - customAnchorPoint.y
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        var moveOffTheBoard: Bool = false

        if self.frame.origin.x < 0 {
            self.frame.origin.x = 0
            moveOffTheBoard = true
        }
        if self.frame.origin.x > boardSize.width - self.bounds.width {
            self.frame.origin.x = boardSize.width - self.bounds.width
            moveOffTheBoard = true
        }
        if self.frame.origin.y < 0 {
            self.frame.origin.y = 0
            moveOffTheBoard = true
        }
        if self.frame.origin.y > boardSize.height - self.bounds.height {
            self.frame.origin.y = boardSize.height - self.bounds.height
            moveOffTheBoard = true
        }
        
        if self.frame.origin == startTouchPoint && moveOffTheBoard == false {
            flip(all: false)
        }
    }
}

