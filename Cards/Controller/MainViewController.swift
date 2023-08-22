import UIKit

class MainViewController: UIViewController {
    
    override func loadView() {
        
        super.loadView()
        configureViewsOnScene()
    }
    
    private func configureViewsOnScene() {
        
        let goToTheGameButtonView = UIButton(frame: CGRect(x: 0, y: 0, width: 200.0, height: 50.0))
        goToTheGameButtonView.setTitle("Играть", for: .normal)
        goToTheGameButtonView.center = view.center
        goToTheGameButtonView.setTitleColor(.black, for: .normal)
        goToTheGameButtonView.setTitleColor(.gray, for: .highlighted)
        goToTheGameButtonView.backgroundColor = .systemGray4
        goToTheGameButtonView.layer.cornerRadius = 10.0
        goToTheGameButtonView.addAction(UIAction(handler: { action in
            
            let controller = BoardGameController()
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true)
        }), for: .touchUpInside)
        view.addSubview(goToTheGameButtonView)
        
        let margin: CGFloat = 10
        let settingsButtonView = UIButton(frame: CGRect(x: 0, y: 0, width: 200.0, height: 50.0))
        settingsButtonView.setTitle("Настройки", for: .normal)
        settingsButtonView.center.x = goToTheGameButtonView.center.x
        settingsButtonView.center.y = goToTheGameButtonView.center.y + goToTheGameButtonView.bounds.height + margin
        settingsButtonView.setTitleColor(.black, for: .normal)
        settingsButtonView.setTitleColor(.gray, for: .highlighted)
        settingsButtonView.backgroundColor = .systemGray4
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
    }
}
