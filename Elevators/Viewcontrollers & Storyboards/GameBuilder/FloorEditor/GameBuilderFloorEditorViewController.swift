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
    public var floorModel: LevelModel.FloorModel!
    
    @IBOutlet weak var skview: SKView!
    @IBOutlet weak var positionerSlider: UISlider!
    
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var elevatorTypePicker: UIPickerView!
    @IBOutlet weak var toPicker: UIPickerView!
    
    @IBAction func onDelete(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func onCreate(_ sender: Any) {
        
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
    
}

extension GameBuilderFloorEditorViewController {
    public override func viewDidLoad() {
        [typePicker, elevatorTypePicker, toPicker].forEach { (picker) in
            picker?.delegate = self
            picker?.dataSource = self
        }
    }
}

extension GameBuilderFloorEditorViewController {
    public var nearbyFloors: [LevelModel.FloorModel] {
        var list = [LevelModel.FloorModel]()
        
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
        
        self.updatePickers()
    }
    
    public func updatePickers() {
        let type = TypePick.load(from: typePicker.selectedRow(inComponent: 0))
        
        let bool = type != TypePick.Coin
        
        self.enable(view: toPicker, value: bool)
        self.enable(view: elevatorTypePicker, value: bool)
        
        print(type)
    }
}


extension GameBuilderFloorEditorViewController: ControllerIdentifiable {
    static let id: String = "GameBuilderFloorEditorViewController"
}
