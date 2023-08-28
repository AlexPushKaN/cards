import UIKit

protocol SnapshotProtocol {
    
    var continueGame: Snapshot? { get set }
}

class MainViewController: UIViewController, SnapshotProtocol {
    
    let margin: CGFloat = 10
    var continueGame: Snapshot?
    lazy var continueGameButtonView = UIButton(frame: CGRect(x: 0, y: 0, width: 200.0, height: 50.0))
    lazy var goToTheGameButtonView = UIButton(frame: CGRect(x: 0, y: 0, width: 200.0, height: 50.0))
    lazy var settingsButtonView = UIButton(frame: CGRect(x: 0, y: 0, width: 200.0, height: 50.0))
    lazy var exitButtonView = UIButton(frame: CGRect(x: 0, y: 0, width: 200.0, height: 50.0))
    lazy var sceneAnimation = SceneAnimation(cardCounts: 5, controller: self)
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        sceneAnimation.animatedCards()
        configureViewsOnScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.continueGame != nil {
            continueGameButtonView.isHidden = false
        } else {
            continueGameButtonView.isHidden = true
        }
    }
    
    private func configureViewsOnScene() {
        
        goToTheGameButtonView.setTitle("Играть", for: .normal)
        goToTheGameButtonView.center = view.center
        goToTheGameButtonView.setTitleColor(.black, for: .normal)
        goToTheGameButtonView.setTitleColor(.gray, for: .highlighted)
        goToTheGameButtonView.backgroundColor = .lightGray
        goToTheGameButtonView.layer.cornerRadius = 10.0
        goToTheGameButtonView.addAction(UIAction(handler: { action in

            let controller = BoardGameController()
            controller.delegate = self
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true)
        }), for: .touchUpInside)
        view.addSubview(goToTheGameButtonView)
        
        continueGameButtonView.setTitle("Продолжить", for: .normal)
        continueGameButtonView.center.x = goToTheGameButtonView.center.x
        continueGameButtonView.center.y = goToTheGameButtonView.center.y - goToTheGameButtonView.bounds.height - margin
        continueGameButtonView.setTitleColor(.black, for: .normal)
        continueGameButtonView.setTitleColor(.gray, for: .highlighted)
        continueGameButtonView.backgroundColor = .lightGray
        continueGameButtonView.layer.cornerRadius = 10.0
        continueGameButtonView.addAction(UIAction(handler: { action in
            
            let controller = BoardGameController()
            controller.delegate = self
            controller.snapshot = self.continueGame
            controller.game = controller.getNewGame()
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true)
        }), for: .touchUpInside)
        view.addSubview(continueGameButtonView)
        
        settingsButtonView.setTitle("Настройки", for: .normal)
        settingsButtonView.center.x = goToTheGameButtonView.center.x
        settingsButtonView.center.y = goToTheGameButtonView.center.y + goToTheGameButtonView.bounds.height + margin
        settingsButtonView.setTitleColor(.black, for: .normal)
        settingsButtonView.setTitleColor(.gray, for: .highlighted)
        settingsButtonView.backgroundColor = .lightGray
        settingsButtonView.layer.cornerRadius = 10.0
        settingsButtonView.addAction(UIAction(handler: { action in

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(identifier: "settingsTableViewController") as! SettingsTableViewController
            controller.settingsGame = Settings.loadSettings() ?? Settings()
            controller.modalTransitionStyle = .coverVertical
            controller.modalPresentationStyle = .automatic
            self.present(controller, animated: true)
        }), for: .touchUpInside)
        view.addSubview(settingsButtonView)
        
        exitButtonView.setTitle("Выход", for: .normal)
        exitButtonView.center.x = settingsButtonView.center.x
        exitButtonView.center.y = settingsButtonView.center.y + settingsButtonView.bounds.height + margin
        exitButtonView.setTitleColor(.black, for: .normal)
        exitButtonView.setTitleColor(.gray, for: .highlighted)
        exitButtonView.backgroundColor = .lightGray
        exitButtonView.layer.cornerRadius = 10.0
        exitButtonView.addAction(UIAction(handler: { action in
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        }), for: .touchUpInside)
        view.addSubview(exitButtonView)
    }
}
