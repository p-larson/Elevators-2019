//
//  FloorManager.swift
//  2.0
//  The Much Better Version
// 
//  Elevators
//
//  Created by Peter Larson on 7/7/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import SpriteKit

public final class FloorManager {
    
    let game: ElevatorsGameScene
    var generator: FloorGenerator {
        didSet {
            self.setupFloors()
        }
    }
    
    public private(set) var floors = [Floor]()
    public private(set) var renderedHolder = SKNode()
    
    public var elevatorSize: CGSize {
        return CGSize(width: floorSize.width / 9, height: floorSize.width / 6)
    }
    
    public var floorSize: CGSize {
        return CGSize(width: game.gameFrame.width, height: game.gameFrame.height / CGFloat(game.maxFloorsShown))
    }
    
    public private(set) var currentFloorNumber: Int = 0

    public init(game: ElevatorsGameScene, generator: FloorGenerator) {
        self.game = game
        self.generator = generator
    }
}
// Modeled Floor Generator Access
extension FloorManager {
    public func setModel(to model: LevelModel) {
        self.generator = ModeledLevelGenerator(model: model)
    }
}
// Zone Declarations
extension FloorManager {
    public var renderedZone: Range<Int> {
        return currentFloorNumber - game.maxElevatorRange ..< currentFloorNumber + game.maxFloorsShown
    }
    public var loadedZone: Range<Int> {
        return renderedZone.lowerBound ..< renderedZone.upperBound + game.maxElevatorRange
    }
}
// Prefixing and Suffixing #floors
fileprivate extension FloorManager {
    
    func floor(after floor: Int) -> Floor? {
        return floors.first(where: { (floor2) -> Bool in
            return floor2.number == floor + 1
        })
    }
    
    func floors(after floor: Int, max count: Int) -> [Floor] {
        return floors.filter({ (floor2) -> Bool in
            return floor < floor2.number && floor2.number <= floor + count
        })
    }
    
    func floor(before floor: Int) -> Floor? {
        return floors.first(where: { (floor2) -> Bool in
            return floor2.number == floor - 1
        })
    }
    
    func floors(before floor: Int, max count: Int) -> [Floor] {
        return floors.filter({ (floor2) -> Bool in
            return floor2.number < floor && floor - count <= floor2.number
        })
    }
}
// Calculating the Distance from One Floor to the Other
extension FloorManager {
    public func distance(from: Int, to: Int) -> CGFloat {
        return CGFloat(to - from) * floorSize.height
    }
}
// Getting Floor? from #floors by #Floor.number
extension FloorManager {
    public func floor(numbered: Int) -> Floor? {
        return floors.first(where: { (floor) -> Bool in
            return floor.number == numbered
        })
    }
}
// Update Floors
extension FloorManager {
    /// updateFloors:
    ///     Will Load and Render all Valid Floors and Dispose of any Invalid Floors.
    ///
    /// 1. Generate and Load any Floor that is in the Load Zone, else Render Zone if renderZone is true.
    /// 2. Quit Rendering any Floor that isn't in the Rendered Zone and Populate any Floor in the Render Zone that has not yet been Rendered.
    /// 3. Unload any Floor not in the Loaded Zone.
    /// 4. Update positions for all Rendered Floors.
    ///
    /// - Parameter onlyRenderZone: Only Generate and Load Floors in the Render Zone apposed to the Load Zone. This is for when you don't want any Floors generated outside the Render Zone, in situations like Setting up the Game where you don't want any Floors generated below the First Bottom Floor.
    public func updateFloors(onlyRenderZone: Bool = false) {
        // Generate and Load any Floor that is in the Load Zone, else Render Zone if renderZone is true
        (onlyRenderZone ? renderedZone : loadedZone).forEach { (number) in
            // Will return nil if there is not an avalible floor generated.
            if let floor = floor(numbered: number) ?? generator.generate(manager: self, number: number) {
                // Load if not already
                if self.floor(numbered: number) == nil {
                    floors.append(floor)
                }
                // Render if not already and is in the Render Zone
                if !floor.inParentHierarchy(renderedHolder)
                    && renderedZone.contains(floor.number) {
                    floor.removeFromParent()
                    renderedHolder.addChild(floor)
                }
            }
        }
        // 2.
        renderedHolder.children.compactMap ({ (child) -> Floor? in
            return child as? Floor
        }).forEach ({ (floor) in
            if !renderedZone.contains(floor.number) {
                floor.removeFromParent()
            } else if floor.baseElevators.count == 0 {
                generator.populate(floor: floor)
                floor.drawRopes()
            }
        })
        // 3.
        floors.removeAll { (floor) -> Bool in
            return !loadedZone.contains(floor.number)
        }
        // 4.
        renderedHolder.children.compactMap({ (node) -> Floor? in
            return node as? Floor
        }).forEach({ (floor) in
            floor.position.x = game.gameFrame.midX
            floor.position.y = game.gameFrame.minY + CGFloat(floor.number - currentFloorNumber) * floorSize.height
        })
    }
}
// Setting up the Floors
extension FloorManager {
    /// setupFloors:
    ///     Set up the Floor's Environment
    ///
    /// 1. Quit Rendering any currently Loaded Floor.
    /// 2. Dipose all Loaded Floors.
    /// 3. Reset Current Floor Number if shouldResetFloorNumber
    /// 4. Load only in the Render Zone.
    /// 5. Move FloorManager.renderedHolder to FloorManager.game to be Rendered.
    public func setupFloors(shouldResetFloorNumber: Bool = true) {
        // 1.
        floors.forEach { (floor) in
            floor.removeFromParent()
        }
        // 2.
        floors.removeAll()
        // 3.
        if shouldResetFloorNumber {
            currentFloorNumber = generator.firstFloorNumber
        }
        // 4.
        updateFloors(onlyRenderZone: true)
        // 5.
        if renderedHolder.inParentHierarchy(game) == false {
            renderedHolder.removeFromParent()
            game.addChild(renderedHolder)
        }
    }
}
// Jostling
extension FloorManager {
    /// jostle:
    ///     Jostling will move the Floors Up or Down and will Generate accordingly.
    ///     This method updates the floors at the end.
    ///     Do not call FloorManager#updateFloors after, will do nothing.
    ///
    /// - Parameter up: The Direction of the Jostle
    public func jostle(up: Bool = true) {
        currentFloorNumber += up ? 1 : -1
        updateFloors()
    }
}
// Passerbyes
extension FloorManager {
    func passerybyes(of floor: Floor) -> [Elevator] {
        return (floors(before: floor.number, max: game.maxElevatorRange) + floors(after: floor.number, max: game.maxElevatorRange)).map({ (floor) -> [Elevator] in
            return floor.baseElevators
        }).joined().filter { (elevator) -> Bool in
            return elevator.base < floor.number && elevator.destination >= floor.number
        }
    }
}
// Computed Current Floor?
extension FloorManager {
    public var currentFloor: Floor? {
        return floor(numbered: currentFloorNumber)
    }
}
// Protocol for Floor Generators
public protocol FloorGenerator {
    func generate(manager: FloorManager, number: Int) -> Floor?
    func populate(floor: Floor)
    var firstFloorNumber: Int { get }
}

public final class ModeledLevelGenerator: FloorGenerator {
    
    public init(model: LevelModel) {
        self.model = model
    }
    
    public func generate(manager: FloorManager, number: Int) -> Floor? {
        if let floorModel = model.floorWith(number: number) {
            return Floor(floorModel, manager: manager)
        } else if number == firstFloorNumber {
            print("Level Model is missing Floor Data for it's First Floor (\(firstFloorNumber))!")
        }
        
        return nil
    }
    
    public var firstFloorNumber: Int {
        return model.firstFloor
    }
    
    public var model: LevelModel = .empty
    
    /// populate:
    ///     Load elevators from model.
    ///
    ///     1. From the Floor's Model, Floor#loadElevator every ElevatorModel in Floor.baseElevator
    ///
    /// - Parameters:
    ///   - floor: The Floor to be Populated
    public func populate(floor: Floor) {
        
        // 1.
        floor.model?.baseElevators.forEach({ (elevatorModel) in
            floor.loadElevator(from: elevatorModel)
        })
    }
}

public final class EndlessGenerator: FloorGenerator {
    
    public static let shared = EndlessGenerator()
    
    public var firstFloorNumber: Int {
        return 1
    }
    
    public func generate(manager: FloorManager, number: Int) -> Floor? {
        let kind: Floor.Kind = {
            
            let previousFloors = manager.floors(before: number, max: manager.game.maxElevatorRange)
            
            let hasNormalInRange = previousFloors.contains(where: { (floor) -> Bool in
                return floor.type == .Normal
            })
            
            guard let last = previousFloors.sorted(by: { return $0.number < $1.number }).last else {
                return .Normal
            }
            
            switch last.type {
                
            case .Normal:
                return hasNormalInRange && Bool.random() ? .Trap : .Normal
            case .Trap:
                return Bool.random() ? .Normal : .TrapEnd
            case .TrapEnd:
                return .Normal
            case .Level:
                fatalError("Level Type Floors are Illegal from EndlessGenerators.")
            }
        }()
        
        return .init(number: number, type: kind, manager: manager)
    }
    
    public func populate(floor: Floor) {
        let manager = floor.manager!
        let game = manager.game
        
        var nearbyFloors = manager.floors(after: floor.number, max: game.maxElevatorRange)
        let elevatorCount = floor.type == .Normal ? Int.random(in: 1 ... game.maxElevatorsPerFloor) : Int.random(in: 1 ... game.maxElevatorsPerTrapFloor)
        
        // Create scene based on the floor type
        switch floor.type {
        case .Normal:
            // Priority 1
            // Normal to Normal
            let target = nearbyFloors.first {
                level in level.type == .Normal
            }!
            // Add elevator to targeted normal floor and connected to target
            floor.addConnector(to: target)
            // Remove floor as an option for any other elevators
            nearbyFloors = Array(nearbyFloors.filter { level in level.number != target.number }
            )
            repeat {
                // 50/50 chance to create another normal elevator
                if Bool.random() {
                    // Next normal if there is no elevator to it yet from the current floor.
                    if let nextNormalTarget = nearbyFloors.first(where: { (floor2) -> Bool in
                        return floor2.type == .Normal && floor.baseElevators.contains(where: { (elevator2) -> Bool in
                            return elevator2.destination != floor2.number
                        })
                    }) {
                        // Add Elevator to nextNormalTarget
                        floor.addConnector(to: nextNormalTarget)
                    } else {
                        // Broken Elevator
                        floor.addBroken()
                    }
                } else {
                    // Next trap if there is no elevator to it yet from the current floor
                    if let nextTrapTarget = nearbyFloors.first(where: { (floor2) -> Bool in
                        return floor2.type != .Normal && floor.baseElevators.contains(where: { (elevator2) -> Bool in
                            return elevator2.destination != floor2.number
                        })
                    }) {
                        // Add Elevator to nextNormalTarget
                        floor.addTrap(to: nextTrapTarget)
                    } else {
                        // Broken Elevator
                        floor.addBroken()
                    }
                }
            } while floor.baseElevators.count < elevatorCount
            break
        case .Trap:
            // Priority 1
            // Trap to Trap 2
            if let nextFloor = nearbyFloors.first {
                if nextFloor.type == .TrapEnd {
                    floor.addTrap(to: nextFloor)
                }
            }
            // Fill with Broken
            repeat {
                // Broken Elevator
                floor.addBroken()
            } while floor.baseElevators.count < elevatorCount
            break
        case .TrapEnd:
            // Fill with Broken
            repeat {
                // Broken Elevator
                floor.addBroken()
            } while floor.baseElevators.count < elevatorCount
            break
        case .Level:
            fatalError("Illegal Floor Type in EndlessGenerator! Cannot have a Floor with Floor.type == .Level!")
        }
    }
}
