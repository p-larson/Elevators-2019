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
    
    public var levelURLs: [URL] = {
        return LevelsLoader.shared.levelURLs()
    }()
    
    @IBAction func loadLevel(_ sender: UIButton) {
        let url = LevelsLoader.shared.levelURLs()[levelPickerView.selectedRow(inComponent: 0)]
        
        guard let model = LevelsLoader.shared.load(decodable: LevelModel.self, from: url) as? LevelModel else {
            return
        }
        print("loading", model.name)
        self.performSegue(withIdentifier: GameBuilderPickerViewController.load_segue, sender: model)
        
    }
    
    @IBAction func createLevel(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Create new Floor", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Name (You can edit this later)."
        }
        
        let saveAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { alert -> Void in
            // Nothing :)
        })
        
        let cancelAction = UIAlertAction(title: "Create", style: .default, handler: { (action: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: GameBuilderPickerViewController.create_segue, sender: alertController.textFields![0].text)
        })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var levelPickerView: UIPickerView!
}

extension GameBuilderPickerViewController {
    
    static let create_segue = "create"
    static let load_segue = "load"
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as? GameBuilderViewController
        
        switch segue.identifier {
        case GameBuilderPickerViewController.create_segue:
            let name = (sender as? String) ?? "Untitled"
            controller?.model = LevelModel(name: name)
            return
        case GameBuilderPickerViewController.load_segue:
            
            guard let model = sender as? LevelModel else {
                return
            }
            
            controller?.model = model
            
            
            return
        default:
            fatalError("Unhandled Segue \(segue.identifier as Any)")
        }
    }
}

extension GameBuilderPickerViewController {
    public override func viewDidLoad() {
        self.levelPickerView.delegate = self
        self.levelPickerView.dataSource = self
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

extension GameBuilderPickerViewController {
    public override func viewWillAppear(_ animated: Bool) {
        self.levelPickerView.reloadInputViews()
        print("will appear")
    }
}
