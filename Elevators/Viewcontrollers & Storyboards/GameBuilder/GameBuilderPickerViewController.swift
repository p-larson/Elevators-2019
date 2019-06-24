//
//  GameBuilderPickerViewController.swift
//  Elevators
//
//  Created by Peter Larson on 6/21/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import UIKit
import ElCore

public class GameBuilderPickerViewController: UIViewController, ControllerIdentifiable {
    
    static let id: String = "GameBuilderPickerViewController"
    
    public lazy var levelURLs: [URL] = {
        return LevelsLoader.shared.levelURLs()
    }()
    
    @IBAction func loadLevel(_ sender: UIButton) {
    
    }
    @IBAction func createLevel(_ sender: UIButton) {
        
        guard let levelName = levelNameTextField.text, (levelNameTextField.text?.count ?? 0) > 0 else {
            return
        }
        
        guard LevelsLoader.shared.containsLevel(named: levelName) == false else {
            
            // create the alert
            let alert = UIAlertController(title: "Cannot Create Level", message: "Level Name \"\(levelName)\" is already a Level!", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        // Load GameBuilderViewController
        
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "GameBuilderViewController") as? GameBuilderViewController else {
            return
        }
        
        controller.model = LevelModel(number: -1, name: levelName, state: .build)
        
        self.present(controller, animated: true, completion: nil)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        levelNameTextField.endEditing(true)
    }
    
    
    @IBOutlet weak var levelNameTextField: UITextField!
    @IBOutlet weak var levelPickerView: UIPickerView!
}

extension GameBuilderPickerViewController {
    public override func viewDidLoad() {
        self.levelPickerView.delegate = self
        self.levelPickerView.dataSource = self
        self.levelNameTextField.delegate = self
    }
}

extension GameBuilderPickerViewController: UIPickerViewDataSource {
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.levelURLs.count == 0 ? 1 : self.levelURLs.count
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}

extension GameBuilderPickerViewController: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return levelURLs.count == 0 ? "No Levels Saved" : levelURLs[row].lastPathComponent
    }
}

extension GameBuilderPickerViewController: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
