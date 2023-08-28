import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        let controller = MainViewController()
        if let continueGame = Snapshot.loadSnapshot() {
            print("Данные загрузились")
            controller.continueGame = continueGame
        }
        window.rootViewController = controller
        window.makeKeyAndVisible()
        self.window = window
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
        
        if let controller = window?.rootViewController as? MainViewController {
            if let continueGameSnapshot = controller.continueGame {
                print("Данные сохранились")
                Snapshot.save(snapshot: continueGameSnapshot)
            }
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}

