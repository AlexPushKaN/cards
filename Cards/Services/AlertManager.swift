import UIKit

class AlertManager {
    
    static func getCongratulationAlert(score: Int,
                                       okCompletion: @escaping () -> Void,
                                       cancelCompletion: @escaping () -> Void) -> UIAlertController {
        
        let congratulations = UIAlertController(title: "Победа!!!",
                                                message: "Вы победили! Счет: \(score). Желаете ли Вы победить в следующей игре?",
                                                preferredStyle: .alert)
        
        let actionOK = UIAlertAction(title: "Да, продолжим играть!",
                                     style: .default) { _ in
            okCompletion()
        }
        
        let actionCancel = UIAlertAction(title: "Нет, в другой раз",
                                         style: .cancel) { _ in
            cancelCompletion()
        }
        
        congratulations.addAction(actionOK)
        congratulations.addAction(actionCancel)
        
        return congratulations
    }
}
