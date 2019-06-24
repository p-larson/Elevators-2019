//
//  GameBuilderViewController.swift
//  Elevators
//
//  Created by Peter Larson on 5/14/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import ElCore
import SpriteKit

public class GameBuilderViewController: UIViewController, ControllerIdentifiable {
    
    static let id: String = "GameBuilderViewController"
    
    @IBOutlet weak var gamescene: SKView!
    @IBOutlet weak var levelNameLabel: UILabel!
    @IBOutlet weak var editLevelButton: UIButton!
    
    @IBAction func onEditLevel(_ sender: UIButton) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: GameBuilderFloorEditorViewController.id) as? GameBuilderFloorEditorViewController else {
            fatalError()
        }
        
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func onStepChanged(_ sender: UIStepper) {
        let value = Int(sender.value)
        
        print(value, model.floors.count)
        
        if value > model.floors.count {
            print("plus")
            let newFloor = LevelModel.FloorModel(number: model.floors.count + 1)
            model.floors.append(newFloor)
            scene.reloadScene()
        } else {
            print("minus")
        }
    }
    
    @IBAction func saveLevel(_ sender: UIButton) {
        
    }
    
    public func updateScene() {
        
    }
    
    // This Model is shared with GameBuilderScene's floorManager
    public var model: LevelModel!
    
    public let scene = GameBuilderScene()
}

extension GameBuilderViewController {
    func updatedSelectedFloor(to floor: Floor?) {
        self.editLevelButton.isEnabled = floor != nil
    }
}

extension GameBuilderViewController {
    public override func viewDidLoad() {
        self.setBackground(image: #imageLiteral(resourceName: "Backgrounds-1"))
        
        self.scene.scaleMode = .aspectFill
        self.scene.size = gamescene.frame.size
        self.scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.scene.backgroundColor = .clear
        self.scene.controller = self
        
        self.scene.floorManager.model = model
        
        self.gamescene.allowsTransparency = true
        
        self.gamescene.presentScene(scene)
        
        self.editLevelButton.isEnabled = false
    }
}
