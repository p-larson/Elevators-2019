//
//  FloorManager.swift
//  ElCore
//
//  Created by Peter Larson on 2/19/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import Foundation
import SpriteKit

/// A class to manage floors that intended on always be inside a SKScene
public class FloorManager: ElevatorsGameSceneDependent {
    
    public let holder = SKNode()
    public let scene: ElevatorsGameScene
    
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
        return bottomFloor?.number ?? 0
    }
    
    /// Mutable public accessable floor list
    public var floors = [Floor]()
    /// Offhand floors where jostled floors go
    public var offhandFloors = [Floor]()
    /// Default Initializer, requires SKScene.
    ///
    /// - Parameters:
    ///   - scene: a scene that self will manage on.
    public init(scene: ElevatorsGameScene) {
        self.scene = scene
    }
    
    public func updatePositions() {
        // Set up debug
        larsonenter(#function)
        // Prepare for deinit of function.
        defer {
            larsonexit()
        }
        floors.enumerated().forEach { (index, floor) in
            position(floor: floor, for: index, offhand: false)
            larsondebug("calculating position for floor \(floor.number) of index \(index), \(floor.position.y)")
        }
        offhandFloors.enumerated().forEach { (index, floor) in
            position(floor: floor, for: index, offhand: true)
            larsondebug("calculating offhand position for floor \(floor.number) of index \(index), \(floor.position.y)")
        }
    }
    private func position(floor: Floor, for index: Int, offhand: Bool) {
        floor.position = offhand ? offhandPosition(for: index) : position(for: index)
    }
    
    public func position(for index: Int) -> CGPoint {
        let h = CGFloat(index) * scene.floorManager.floorSize.height
        return CGPoint(x: scene.gameFrame.midX, y: scene.gameFrame.minY + h)
    }
    
    public func offhandPosition(for index: Int) -> CGPoint {
        let h = CGFloat(index) * scene.floorManager.floorSize.height
        return self.position(for: -offhandFloors.count).add(0, h)
    }
    
    public func setupGame() {
        // Set up debug
        larsonenter(#function)
        // Prepare for deinit of function.
        defer {
            larsonexit()
        }
        // Add holder to scene
        scene.addChild(holder)
        larsondebug("set scene's background color")
        // Empty current Floors loaded in.
        larsondebug("clearing floors")
        floors.forEach { floor in
            floor.removeFromParent()
        }
        offhandFloors.forEach { floor in
            floor.removeFromParent()
        }
        floors = []
        offhandFloors = []
        larsonenter("generating floors...")
        // Generate the Max Loaded Floors.
        repeat {
            // Generate next floor
            let floor = self.next()
            // Add to array
            self.floors.append(floor)
            // Add to holder
            holder.addChild(floor)
            larsondebug("generated floor \(floor.number)")
        } while floors.count < scene.maxFloorsLoaded
        larsondebug("updating floors.")
        // Update floors
        self.update()
        
        larsondebug("finished generating floors.")
        
        larsonexit()
    }
    
    public func update() {
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
    public func debugPrint(_ floors: [Floor]? = nil) {
        let f = floors ?? self.floors
        f.reversed().forEach { level in
            Swift.print(level.description)
        }
    }
    /// # of total baseElevators in all floors
    public var baseElevatorCount: Int {
        return floors.reduce(0) { (x, y) -> Int in
            return x + y.baseElevators.count
        }
    }
    /// # of total connectedElevators in all floors
    public var connectorElevatorCount: Int {
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
    /// Number of the last Floor
    public var lastNumber: Int {
        return floors.last?.number ?? 0
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
        }
    }
    
    public func jostle(count: Int) {
        // Set up debug
        larsonenter(#function)
        // Prepare for deinit of function.
        defer {
            larsonexit()
        }
        for _ in 0 ..< count {
            // Remove from array and from parent.
            let removed = self.floors.remove(at: floors.startIndex)
            // Add to offhand floors
            offhandFloors.append(removed)
            // Remove any surplus floors in offhand floors.
            if offhandFloors.count > scene.maxOffhandFloors {
                let last = offhandFloors.removeFirst()
                last.removeFromParent()
            }
            larsondebug("Removed", removed)
            
            // Add next
            let next = self.next()
            self.floors.append(next)
            holder.addChild(next)
            larsondebug("Added", next)
        }
        // Update floors
        self.update()
    }
    
    @discardableResult
    /// Generate the Next floor based on the current sequence.
    ///
    /// - Returns: generates a new floor based on the current sequence
    private func next() -> Floor {
        
        let floor = Floor(number: lastNumber.advanced(by: 1), type: generateNextType(), elevatorSize: scene.floorManager.elevatorSize, floorSize: scene.floorManager.floorSize)
        
        floor.manager = self
        
        return floor
    }
    
    /// Populate the scene of all the current floors
    private func populateElevators() {
        // Set up debug
        larsonenter(#function)
        // Prepare for deinit of function.
        defer {
            larsonexit()
        }
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
