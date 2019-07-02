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
    
    public var maxElevatorRange: Int {
        return model?.maxElevatorRange ?? scene.maxElevatorRange
    }
    
    public var populatedFloorRange: Range<Int> {
        return currentFloorNumber ..< currentFloorNumber + scene.maxFloorsShown
    }
    
    public var validFloorRange: ClosedRange<Int> {
        return currentFloorNumber - maxElevatorRange ... currentFloorNumber + maxElevatorRange + scene.maxFloorsShown
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
    
    var bottomFloor: Floor? {
        return floors.first
    }
    
    var topFloor: Floor? {
        return floors.last
    }
    
    var topNumber: Int {
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
        
        let invalidFloors = floors.filter({ (floor) -> Bool in
            return self.validFloorRange.contains(floor.number) == false
        })
        
        invalidFloors.forEach { (floor) in
            floor.removeFromParent()
        }
        
        floors.removeAll { (floor) -> Bool in
            return invalidFloors.contains(floor)
        }
        
        floors.enumerated().forEach { (index, floor) in
            position(floor: floor, for: index, offhand: false)
        }
    }
    func position(floor: Floor, for index: Int, offhand: Bool) {
        
        guard let currentFloor = self.currentFloor else {
            return
        }
        
        let offset = CGFloat(floor.number - currentFloor.number)
        
        floor.position = CGPoint(x: scene.gameFrame.midX, y: scene.gameFrame.minY + offset * scene.floorManager.floorSize.height)
        
        floor.move(toParent: holder)
    }
    
}

public extension FloorManager {
    func setupGame(preCurrentFloorNumber: Int? = nil) {
        // Empty holder
        holder.removeFromParent()
        // Add holder to scene
        scene.addChild(holder)
        // Empty current Floors loaded in.
        floors.forEach { floor in
            floor.removeFromParent()
        }
        floors = []
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
        } while floors.count < scene.maxFloorsLoaded && modelDone == false
        // Update current floor based on context
        if let preCurrentFloorNumber = preCurrentFloorNumber, let preCurrentFloor = floor(number: preCurrentFloorNumber) {
            self.currentFloor = preCurrentFloor
        }
        // Update floors
        self.update()
        // Open first floor
        self.bottomFloor?.openElevators()
    }
}

public extension FloorManager {
    func update() {
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
    /// Generate the next Floor Kind based on the current sequence.
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
    private func generateNextType() -> Floor.Kind {
        guard let last = floors.last else {
            return .Normal
        }
        
        let hasAvailableNormalFloor = self.getLast(count: scene.maxElevatorRange).filter { $0.type == .Normal && $0 != last }.count > 0
        
        if last.type == .Normal && !hasAvailableNormalFloor {
            return .Normal
        }
        
        switch last.type {
        case .Normal:
            
            if !hasAvailableNormalFloor {
                return .Normal
            }
            
            return Bool.random() && self.getLast(count: scene.maxElevatorRange).filter { $0.type == .Normal && $0 != last }.count != 0 ? .Trap : .Normal
        case .Trap:
            return Bool.random() ? .TrapEnd : .Normal
        case .TrapEnd:
            return .Normal
        case .Level:
            return .Normal
        }
    }
    
    func jostle(count: Int) {
        // Set the current floor
        guard let targetNumber = currentFloor?.number.advanced(by: count) else {
            return
        }
        
        self.currentFloor = floor(number: targetNumber)
        
        for _ in 0 ..< count {

            // Add next
            
            guard let next = self.next() else {
                continue
            }
            
            self.floors.append(next)
            holder.addChild(next)
        }
        // Update Floors
        self.update()
    }
    
    @discardableResult
    /// Generate the Next floor based on the current sequence.
    ///
    /// - Returns: generates a new floor based on the current sequence if there is a model, it
    private func next() -> Floor? {
        let number = topNumber.advanced(by: 1)
        
        guard let model = model else {
            let floor = Floor(number: number, type: generateNextType(), elevatorSize: elevatorSize, floorSize: floorSize, manager: self)
            
            return floor
        }
        
        // Check if Model has Next Floor
        guard let floorModel = model.floorWith(number: number) else {
            return nil
        }
        
        return Floor(floorModel, elevatorSize: elevatorSize, floorSize: floorSize, manager: self)
    }
    
    /// Populate the scene of all the current floors
    private func populateElevators() {
        // Populating Elevators from Model
        
        if model != nil {
            
            floors.forEach { (floor) in
                floor.baseElevators.forEach({ (elevator) in
                    elevator.removeFromParent()
                })
            }
            
            floors.enumerated().forEach { (index, floor) in
                // Skip if floor isn't maxElevatorsRagne away from end so it doesn't try to connect to floors that don't exist yet.
                guard self.validFloorRange.contains(floor.number), let floorModel = model?.floorWith(number: floor.number) else {
                    return
                }
                
                floorModel.baseElevators.forEach({ (elevatorModel) in

                    // Base Floor
                    guard let base = self.floor(number: elevatorModel.base) else {
                        return
                    }
                    
                    // Destination Floor
                    guard let destination = self.floor(number: elevatorModel.destination) else {
                        return
                    }
                    
                    floor.loadElevator(from: elevatorModel, base: base, destination: destination)
                    
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
                return
            }
            
            var nearbyFloors = Array(self.getFirst(count: scene.maxElevatorRange, offset: index + 1))
            
            let elevatorCount = floor.type == .Normal ? Int.random(in: 1 ... scene.maxElevatorsPerFloor) : Int.random(in: 1 ... scene.maxElevatorsPerTrapFloor)
            
            // Create scene based on the floor type
            switch floor.type {
            case .Normal:
                // Priority 1
                // Normal to Normal
                let target = nearbyFloors.first {
                    level in level.type == .Normal && level != floor
                    }!
                // Add elevator to targeted normal floor and connected to target
                floor.addConnector(to: target)
                
                // Remove floor as an option for any other elevators
                nearbyFloors = Array(nearbyFloors.filter { level in level.number != target.number })
                repeat {
                    // 50/50 chance to create another normal elevator
                    if Bool.random() {
                        // Next normal if there is no elevator to it yet from the current floor.
                        if let nextNormalTarget = nearbyFloors.first(where: { (floor2) -> Bool in
                            return floor2.type == .Normal && floor.baseElevators.contains(where: { (elevator2) -> Bool in
                                return elevator2.destination != floor2
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
                                return elevator2.destination != floor2
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
                break
            }
            
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
