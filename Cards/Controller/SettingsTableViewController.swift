import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var numberOfCardPairsPickerView: UIPickerView!
    @IBOutlet var collectionOfCardTypesSwitch: [UISwitch]!
    @IBOutlet var collectionOfCardColorsSwitch: [UISwitch]!
    @IBOutlet var collectionOfCardBackSidesSwitch: [UISwitch]!

    var settingsGame: Settings?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberOfCardPairsPickerView.dataSource = self
        numberOfCardPairsPickerView.delegate = self
        guard let settingsGame = self.settingsGame else { return }
        numberOfCardPairsPickerView.selectRow(settingsGame.cardsPairsCounts - 1, inComponent: 0, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let settingsGame = self.settingsGame {
            
            for section in 1...self.tableView.numberOfSections - 1 {
                for row in 0...self.tableView.numberOfRows(inSection: section) - 1 {
                    
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: section)) {
                        
                        let settingOptionName: String = (cell.viewWithTag(1) as! UILabel).text! as String
                        
                        if section == 1 {
                            settingsGame.cardTypes.forEach { [weak self] key, value in
                                if key == CardType(rawValue: settingOptionName) {
                                    self?.collectionOfCardTypesSwitch[row].isOn = value
                                }
                            }
                        } else if section == 2 {
                            settingsGame.cardColors.forEach { [weak self] key, value in
                                if key == CardColor(rawValue: settingOptionName) {
                                    self?.collectionOfCardColorsSwitch[row].isOn = value
                                }
                            }
                        } else if section == 3 {
                            settingsGame.cardBackSides.forEach { [weak self] key, value in
                                if key == settingOptionName {
                                    self?.collectionOfCardBackSidesSwitch[row].isOn = value
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        for section in 1...self.tableView.numberOfSections - 1 {
            for row in 0...self.tableView.numberOfRows(inSection: section) - 1 {
                
                if let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: section)) {
                    
                    let settingOptionName: String = (cell.viewWithTag(1) as! UILabel).text! as String
                    guard let settingsGame = self.settingsGame else { return }
                    
                    if section == 1 {
                        settingsGame.cardTypes[CardType(rawValue: settingOptionName)!] = collectionOfCardTypesSwitch[row].isOn
                    } else if section == 2 {
                        settingsGame.cardColors[CardColor(rawValue: settingOptionName)!] = collectionOfCardColorsSwitch[row].isOn
                    } else if section == 3 {
                        settingsGame.cardBackSides[settingOptionName] = collectionOfCardBackSidesSwitch[row].isOn
                    }
                }
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let settingsGame = self.settingsGame {
            Settings.save(settings: settingsGame)
        }
    }
}

//MARK: - UIPickerViewDataSource
extension SettingsTableViewController: UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 20
    }
}

//MARK: - UIPickerViewDelegate
extension SettingsTableViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17.0)
        label.textAlignment = .center
        label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        label.text = String(row + 1) + " пар(ы) карт"
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let settingsGame = self.settingsGame {
            settingsGame.cardsPairsCounts = row + 1
        }
    }
}
