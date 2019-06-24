//
//  Floor.swift
//  ElCore
//
//  Created by Peter Larson on 2/19/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import SpriteKit

/// A class to manage floors that intended on always be inside a SKScene
public class FloorManager: ElevatorsGameSceneDependent {
    public weak var model: LevelModel? = nil
    public let holder = SKNode()
    public let scene: ElevatorsGameScene
    public weak var currentFloor: Floor? = nil
    
    public var elevatorSize: CGSize {
        return CGSize(width: floorSize.width / 9, height: floorSize.width / 6)
    }
    
    public var floorSize: CGSize {
        return CGSize(width: scene.gameFrame.width, height: scene.gameFrame.height / CGFloat(scene.maxFloorsShown))
    }
    
    public func distance(from: Floor, to: Floor) -> CGFloat {
        return CGFloat(abs(from.number - to.number)) * floorSize.height
    }
    
    /// Count / Score
    public var currentFloorNumber: Int {
        return currentFloor?.number ?? 0
    }
    
    public var populatedFloorRange: Range<Int> {
        return currentFloorNumber ..< currentFloorNumber + scene.maxFloorsShown
    }
    
    public var validFloorRange: ClosedRange<Int> {
        return currentFloorNumber - scene.maxElevatorRange ... currentFloorNumber + scene.maxElevatorRange + scene.maxFloorsShown
    }
    
    /// Mutable public accessable floor list. Not all floors are children of self.holder
    public var floors = [Floor]()
    /// Offhand floors where jostled floors go
//    public var offhandFloors = [Floor]()
    /// Default Initializer, requires SKScene.
    ///
    /// - Parameters:
    ///   - scene: a scene that self will manage on.
    public init(scene: ElevatorsGameScene) {
        self.scene = scene
    }
    
}

public extension FloorManager {
    /// # of total baseElevators in all floors
    var baseElevatorCount: Int {
        return floors.reduce(0) { (x, y) -> Int in
            return x + y.baseElevators.count
        }
    }
    /// # of total connectedElevators in all floors
    var connectorElevatorCount: Int {
        return floors.reduce(0) { (x, y) -> Int in
            return x + y.connectedElevators.count
        }
    }
    
    private var bottomFloor: Floor? {
        return floors.first
    }
    
    private var topFloor: Floor? {
        return floors.last
    }
    
    private var topNumber: Int {
        return topFloor?.number ?? 0
    }
    
    func floor(number: Int) -> Floor? {
        return floors.first(where: { (floor) -> Bool in
            return floor.number == number
        })
    }
}

public extension FloorManager {
    func passovers(on: Floor) -> [Elevator] {
        return floors.map { (floor) -> [Elevator] in
            return floor.baseElevators
            }.joined().filter { (elevator) -> Bool in
                return elevator.base.number < on.number && elevator.destination.number > on.number
        }
    }
    
    func updatePositions() {
        // Set up debug
        larsonenter(#function)
        // Prepare for deinit of function.
        defer {
            larsonexit()
        }
        
        larsondebug("Current Floor \(currentFloor?.number ?? -1)")
        
        larsondebug("Filtering Valid Floors")
        
        let invalidFloors = floors.filter({ (floor) -> Bool in
            return self.validFloorRange.contains(floor.number) == false
        })
        
        invalidFloors.forEach { (floor) in
            larsondebug("Invalidating floor \(floor.number) [\(validFloorRange)]")
            floor.removeFromParent()
        }
        
        floors.removeAll { (floor) -> Bool in
            return invalidFloors.contains(floor)
        }
        
        floors.enumerated().forEach { (index, floor) in
            position(floor: floor, for: index, offhand: false)
            larsondebug("calculating position for floor \(floor.number) of index \(index), \(floor.position.y)")
        }
    }
    func position(floor: Floor, for index: Int, offhand: Bool) {
        
        guard let currentFloor = self.currentFloor else {
            larsondebug("Current floor not set!")
            return
        }
        
        let offset = CGFloat(floor.number - currentFloor.number)
        
        larsondebug("positioning floor \(floor.number)")
        
        floor.position = CGPoint(x: scene.gameFrame.midX, y: scene.gameFrame.minY + offset * scene.floorManager.floorSize.height)
        
        floor.move(toParent: holder)
    }
    
}

public extension FloorManager {
    func setupGame(preCurrentFloorNumber: Int? = nil) {
        // Set up debug
        larsonenter(#function)
        // Prepare for deinit of function.
        defer {
            larsonexit()
        }
        // Empty holder
        holder.removeFromParent()
        // Add holder to scene
        scene.addChild(holder)
        larsondebug("set scene's background color")
        // Empty current Floors loaded in.
        larsondebug("clearing floors")
        floors.forEach { floor in
            floor.removeFromParent()
        }
        floors = []
        larsonenter("generating floors...")
        // Generate the Max Loaded Floors.
        var modelDone = false
        repeat {
            // Generate next floor
            guard let floor = self.next() else {
                // No Next Floor to Generate.
                modelDone = true
                break
            }
            // Set as Current Level
            if self.currentFloor == nil {
                self.currentFloor = floor
            }
            // Add to array
            self.floors.append(floor)
            // Add to holder
            holder.addChild(floor)
            larsondebug("generated floor \(floor.number)")
        } while floors.count < scene.maxFloorsLoaded && modelDone == false
        // Update current floor based on context
        if let preCurrentFloorNumber = preCurrentFloorNumber, let preCurrentFloor = floor(number: preCurrentFloorNumber) {
            larsondebug("has preCurrentFloorNumber", preCurrentFloor, "has preCurrentFloor", preCurrentFloor)
            self.currentFloor = preCurrentFloor
        }
        larsondebug("current floor: \(currentFloor?.number)")
        larsondebug("updating floors.")
        // Update floors
        self.update()
        // Open first floor
        self.bottomFloor?.openElevators()
        
        larsondebug("finished generating floors.")
        
        larsonexit()
    }
}

public extension FloorManager {
    func update() {
        // Set up debug
        larsonenter(#function)
        // Prepare for deinit of function.
        defer {
            larsonexit()
        }
        // Populate Elevators
        self.populateElevators()
        // Update floor positions
        self.updatePositions()
    }
    
    /// Debug Print
    func debugPrint(_ floors: [Floor]? = nil) {
        let f = floors ?? self.floors
        f.reversed().forEach { level in
            Swift.print(level.description)
        }
    }
    /// Get the last count elements from the offset
    ///
    /// - Parameters:
    ///   - count: max number of elements
    ///   - offset: index offset to start at
    /// - Returns: last <= count elements from the offset
    private func getLast(count: Int, offset: Int = 0) -> ArraySlice<Floor> {
        return floors[floors.startIndex + offset ..< floors.endIndex].suffix(count)
    }
    /// Get the first count elements from the offset
    ///
    /// - Parameters:
    ///   - count: max number of elements
    ///   - offset: index offset to start at
    /// - Returns: last <= count elements from the offset
    private func getFirst(count: Int, offset: Int = 0) -> ArraySlice<Floor> {
        return floors[floors.startIndex + offset ..< floors.endIndex].prefix(count)
    }
    /// Generate the next Floor Classification based on the current sequence.
    ///
    /// hasAvailableNormalFloor
    ///    true if the last maxElevatorsRange contains a floor that has a normal type in it.
    ///
    /// - Returns:
    ///         normal if
    ///             the last element does not exist (sequence is empty),
    ///             the last element was not normal and random bool is true and the last maxElevatorRange elements does not contain a normal level
    ///         trap_1 if
    ///             the last element was normal and
    private func generateNextType() -> Floor.Classification {
        // Set up debug
        larsonenter(#function)
        // Prepare for deinit of function.
        defer {
            larsonexit()
        }
        
        guard let last = floors.last else {
            return .normal
        }
        
        let hasAvailableNormalFloor = self.getLast(count: scene.maxElevatorRange).filter { $0.type == .normal && $0 != last }.count > 0
        
        if last.type == .normal && !hasAvailableNormalFloor {
            return .normal
        }
        
        switch last.type {
        case .normal:
            
            if !hasAvailableNormalFloor {
                return .normal
            }
            
            return Bool.random() && self.getLast(count: scene.maxElevatorRange).filter { $0.type == .normal && $0 != last }.count != 0 ? .trap_1 : .normal
        case .trap_1:
            return Bool.random() ? .trap_2 : .normal
        case .trap_2:
            return .normal
        case .level:
            return .normal
        }
    }
    
    func jostle(count: Int) {
        // Set up debug
        larsonenter(#function)
        // Prepare for deinit of function.
        defer {
            larsonexit()
        }
        
        
        // Set the current floor
        guard let targetNumber = currentFloor?.number.advanced(by: count) else {
            larsondebug("No Valid Target Number.")
            return
        }
        
        larsondebug("jostling from floor \(currentFloor?.number ?? -1)")
        
        self.currentFloor = floor(number: targetNumber)
        
        larsondebug("set current floor to \(currentFloor?.number ?? -1)")
        
        for _ in 0 ..< count {

            // Add next
            
            guard let next = self.next() else {
                continue
            }
            
            self.floors.append(next)
            holder.addChild(next)
            
            larsondebug("Added", next)
        }
        // Update Floors
        self.update()
    }
    
    @discardableResult
    /// Generate the Next floor based on the current sequence.
    ///
    /// - Returns: generates a new floor based on the current sequence if there is a model, it
    private func next() -> Floor? {
        
        // Set up debug
        larsonenter(#function)
        // Prepare for deinit of function.
        defer {
            larsonexit()
        }
        
        let number = topNumber.advanced(by: 1)
        
        larsondebug("Generating Floor \(number)")
        
        guard let model = model else {
            let floor = Floor(number: number, type: generateNextType(), elevatorSize: elevatorSize, floorSize: floorSize, manager: self)
            
            return floor
        }
        
        larsondebug("Level has Model.")
        
        // Check if Model has Next Floor
        guard let floorModel = model.floorWith(number: number) else {
            larsondebug("Model does not have a next Floor.")
            return nil
        }
        
        larsondebug("Loaded Floor from Model \(floorModel.number)", floorSize)
        
        return Floor(floorModel, elevatorSize: elevatorSize, floorSize: floorSize, manager: self)
    }
    
    /// Populate the scene of all the current floors
    private func populateElevators() {
        // Set up debug
        larsonenter(#function)
        // Prepare for deinit of function.
        defer {
            larsonexit()
        }
        
        // Populating Elevators from Model
        
        if model != nil {
            larsondebug("Has Model. Reloading Elevators")
            
            larsondebug("Clearing floor.")
            floors.forEach { (floor) in
                floor.baseElevators.forEach({ (elevator) in
                    elevator.removeFromParent()
                })
            }
            
            larsondebug("Loading Elevators from Models...")
            floors.enumerated().forEach { (index, floor) in
                // Skip if floor isn't maxElevatorsRagne away from end so it doesn't try to connect to floors that don't exist yet.
                guard self.validFloorRange.contains(floor.number), let floorModel = model?.floorWith(number: floor.number) else {
                    larsondebug("", index < floors.endIndex - scene.maxElevatorRange, model?.floorWith(number: floor.number) == nil)
                    return
                }
                
                larsondebug("Loading ElevatorModels from FloorModel \(floorModel.number)")
                floorModel.baseElevators.forEach({ (elevatorModel) in

                    // Base Floor
                    guard let base = self.floor(number: elevatorModel.base) else {
                        larsondebug("Could not find ElevatorModel's base \(elevatorModel.base)")
                        return
                    }
                    
                    // Destination Floor
                    guard let destination = self.floor(number: elevatorModel.destination) else {
                        larsondebug("Could not find ElevatorModel's destination \(elevatorModel.destination)")
                        return
                    }
                    
                    floor.loadElevator(from: elevatorModel, base: base, destination: destination)
                    
                    larsondebug("Loaded Elevator")
                })
                
            }
            
            self.populateRopes()
            
            return
        }
        
        // Populating Elevatos from Generator
        
        floors.enumerated().forEach { index, floor in
            // Cannot Populate Floor if it's base elevators are already Populated or
            // is not the maxElevatorRange or more away from the end.
            guard floor.baseElevators.count == 0, index < floors.endIndex - scene.maxElevatorRange else {
                larsondebug("1.", floor.baseElevators.count == 0, index < floors.endIndex - scene.maxElevatorRange)
                return
            }
            
            var nearbyFloors = Array(self.getFirst(count: scene.maxElevatorRange, offset: index + 1))
            
            
            larsondebug("nearby floors:")
            larsonperform {
                self.debugPrint(nearbyFloors)
            }
            
            let elevatorCount = floor.type == .normal ? Int.random(in: 1 ... scene.maxElevatorsPerFloor) : Int.random(in: 1 ... scene.maxElevatorsPerTrapFloor)
            
            larsondebug("adding \(elevatorCount) to floor \(floor.number)")
            // Create scene based on the floor type
            switch floor.type {
            case .normal:
                // Priority 1
                // Normal to Normal
                larsonenter("normal floor")
                larsondebug("finding definite nearby normal")
                let target = nearbyFloors.first {
                    level in level.type == .normal && level != floor
                    }!
                larsondebug("connecting to \(target.number)")
                // Add elevator to targeted normal floor and connected to target
                floor.addConnector(to: target)
                
                // Remove floor as an option for any other elevators
                nearbyFloors = Array(nearbyFloors.filter { level in level.number != target.number })
                repeat {
                    larsondebug("adding more elevators to fill elevatorCount need")
                    larsondebug("updated nearby floors \(nearbyFloors)")
                    // 50/50 chance to create another normal elevator
                    if Bool.random() {
                        // Next normal if there is no elevator to it yet from the current floor.
                        if let nextNormalTarget = nearbyFloors.first(where: { (floor2) -> Bool in
                            return floor2.type == .normal && floor.baseElevators.contains(where: { (elevator2) -> Bool in
                                return elevator2.destination != floor2
                            })
                        }) {
                            larsondebug("connecting to \(nextNormalTarget.number)")
                            // Add Elevator to nextNormalTarget
                            floor.addConnector(to: nextNormalTarget)
                        } else {
                            larsondebug("adding broken due to no nextNormalTarget")
                            // Broken Elevator
                            floor.addBroken()
                        }
                        
                    } else {
                        // Next trap if there is no elevator to it yet from the current floor
                        if let nextTrapTarget = nearbyFloors.first(where: { (floor2) -> Bool in
                            return floor2.type != .normal && floor.baseElevators.contains(where: { (elevator2) -> Bool in
                                return elevator2.destination != floor2
                            })
                        }) {
                            larsondebug("trap to \(nextTrapTarget.number)")
                            // Add Elevator to nextNormalTarget
                            floor.addTrap(to: nextTrapTarget)
                        } else {
                            larsondebug("adding broken due to no nextNormalTarget")
                            // Broken Elevator
                            floor.addBroken()
                        }
                    }
                } while floor.baseElevators.count < elevatorCount
                
                larsonexit()
                
                break
            case .trap_1:
                
                larsonenter("trap 1")
                
                // Priority 1
                // Trap to Trap 2
                if let nextFloor = nearbyFloors.first {
                    if nextFloor.type == .trap_2 {
                        floor.addTrap(to: nextFloor)
                        larsondebug("adding prioritized trap elevator to trap 2 floor \(nextFloor.number)")
                    }
                }
                
                // Fill with Broken
                repeat {
                    // Broken Elevator
                    floor.addBroken()
                    larsondebug("filling with broken")
                } while floor.baseElevators.count < elevatorCount
                
                larsonexit()
                
                break
            case .trap_2:
                
                larsonenter("trap 2")
                // Fill with Broken
                repeat {
                    // Broken Elevator
                    floor.addBroken()
                    larsondebug("filling with broken")
                } while floor.baseElevators.count < elevatorCount
                
                larsonexit()
                
                break
            case .level:
                break
            }
            larsonexit()
            
            floor.updateElevatorPositions()
        }
        
        self.populateRopes()
    }
    
    private func populateRopes() {
        floors.flatMap({$0.baseElevators}).forEach {
            elevator in
            
            guard elevator.hasRope == false else {
                return
            }
            
            elevator.drawRope()
        }
    }
}
