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
    
    @IBAction func onDone(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var gamescene: SKView!
    
    @IBAction func onAddLevel(_ sender: UIBarButtonItem) {
        scene.addFloor()
    }
    
    @IBAction func onDeleteLevel(_ sender: UIBarButtonItem) {
        
        guard let number = self.scene.floorManager.currentFloor?.number else {
            return
        }

        let alert = UIAlertController(title: "Remove Floor \(number)", message: "Are you sure?", preferredStyle: UIAlertController.Style.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Remove", style: UIAlertAction.Style.destructive, handler: {
            (alertAction) in
           self.scene.deleteFloor()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    // This Model is shared with GameBuilderScene's floorManager
    public var model: LevelModel!
    
    public let scene = GameBuilderScene()
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
    }
}

extension GameBuilderViewController {
    static let edit_segue = "edit"
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case GameBuilderViewController.edit_segue:
            guard let controller = segue.destination as? GameBuilderFloorEditorViewController else {
                fatalError("Edit Segue's destination is not \(GameBuilderFloorEditorViewController.self)")
            }
            
            guard let number = self.scene.floorManager.currentFloor?.number, let floorModel = scene.model.floorWith(number: number) else {
                return
            }
            
            controller.levelModel = scene.model
            controller.floorModel = floorModel
            
            return
        default:
            fatalError("Unhandled Segue \(segue.identifier as Any)")
        }
    }
}
