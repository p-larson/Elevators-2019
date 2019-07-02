//
//  GameBuilderFloorEditorViewController.swift
//  Elevators
//
//  Created by Peter Larson on 6/23/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import UIKit
import ElCore
import SpriteKit

public final class GameBuilderFloorEditorViewController: UIViewController {

    // Never will have a scenario where these aren't loaded.
    public var levelModel: LevelModel!
    public var floorModel: FloorModel!
    
    public var scene: GameBuilderFloorEditorScene!
    
    @IBOutlet weak var skview: SKView!
    @IBOutlet weak var positionerSlider: UISlider!
    
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var elevatorTypePicker: UIPickerView!
    @IBOutlet weak var toPicker: UIPickerView!
    
    @IBAction func onDelete(_ sender: UIBarButtonItem) {
        self.scene.remove()
    }
    
    @IBAction func onCreate(_ sender: Any) {
        self.scene.add()
    }
    
    public enum TypePick: String, CaseIterable {
        case Elevator, Coin
        
        public static func load(from: Int) -> TypePick {
            if allCases.indices.contains(from) {
                return allCases[from]
            }
            
            return TypePick.Elevator
        }
    }
    
    @IBAction func onValueChange(_ sender: Any) {
        
    }
    
}

extension GameBuilderFloorEditorViewController {
    public override func viewDidLoad() {
        self.setBackground(image: #imageLiteral(resourceName: "Backgrounds-1"))
        
        [typePicker, elevatorTypePicker, toPicker].forEach { (picker) in
            picker?.delegate = self
            picker?.dataSource = self
        }
        
        scene = GameBuilderFloorEditorScene()
        
        scene.model = floorModel
        scene.scaleMode = .aspectFill
        scene.size = skview.frame.size
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.backgroundColor = UIColor.clear
        scene.controller = self
        
        skview.presentScene(scene)
        skview.allowsTransparency = true
        
        scene.load(from: floorModel)
        
        self.updateViews()
    }
}

extension GameBuilderFloorEditorViewController {
    public var nearbyFloors: [FloorModel] {
        var list = [FloorModel]()
        
        let whitelist = floorModel.number - levelModel.maxElevatorRange ... floorModel.number + levelModel.maxElevatorRange
        
        levelModel.floors.filter { (floor) -> Bool in
            return whitelist.contains(floor.number)
        }.forEach { (floor) in
            list.append(floor)
        }
        
        return list
    }
}

extension GameBuilderFloorEditorViewController: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case self.typePicker:
            return TypePick.load(from: row).rawValue
        case self.elevatorTypePicker:
            return Elevator.Kind.load(from: row).rawValue
        case self.toPicker:
            return String(self.nearbyFloors[row].number)
        default:
            fatalError("PickerView not Handled in \(#function)")
        }
    }
}

extension GameBuilderFloorEditorViewController: UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // For All
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case self.typePicker:
            return 2
        case self.elevatorTypePicker:
            return 3
        case self.toPicker:
            return self.nearbyFloors.count
        default:
            fatalError("PickerView not Handled in \(#function)")
        }
    }
    
    
}

extension GameBuilderFloorEditorViewController {
    public func enable(view: UIPickerView, value: Bool) {
        UIView.animate(withDuration: 0.125) {
            view.alpha = value ? 1.0 : 0.25
        }
        
        view.isUserInteractionEnabled = value
    }
}

extension GameBuilderFloorEditorViewController {
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.updateViews()
    }
    
    public func updateViews() {
        
        let pickers = [typePicker, elevatorTypePicker, toPicker]
        
        if let positionable = scene.selected {
            if let elevator = positionable as? Elevator {
                // Enable all pickers
                self.enable(view: typePicker, value: true)
                self.enable(view: elevatorTypePicker, value: true)
                self.enable(view: toPicker, value: true)
                // Set type picker to elevator
                typePicker.selectRow(0, inComponent: 0, animated: true)
                // Select the elvator type
                if let row = Elevator.Kind.allCases.firstIndex(where: { (kind) -> Bool in
                    return elevator.type == kind
                }) {
                    elevatorTypePicker.selectRow(row, inComponent: 0, animated: true)
                }
                
                let value = Float(scene.floor.percent(from: elevator))
                
                positionerSlider.setValue(value, animated: true)
            }
            
            positionerSlider.isEnabled = true
            
        } else {
            pickers.forEach { (picker) in
                self.enable(view: picker!, value: false)
            }
        }
    }
}


extension GameBuilderFloorEditorViewController: ControllerIdentifiable {
    static let id: String = "GameBuilderFloorEditorViewController"
}
