//
//  Floor.swift
//  Elevators
//
//  Created by Peter Larson on 2/2/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import CoreGraphics
import SpriteKit

public class Floor: SKNode {
    public let elevatorSize: CGSize
    public let number: Int
    public let type: Classification
    public let floorSize: CGSize
    public weak var manager: FloorManager!
    public var connectedElevators = [Elevator]()
    private var isPositioned: Bool = false
    public static let baseZPosition: CGFloat = 4.0
    private lazy var label: SKLabelNode = _label()
    private lazy var base: SKSpriteNode = _base()
    
    public init(number: Int, type: Classification, elevatorSize: CGSize, floorSize: CGSize, manager: FloorManager) {
        self.number = number
        self.type = type
        self.elevatorSize = elevatorSize
        self.floorSize = floorSize
        self.manager = manager
        super.init()
        self.setup()
    }
    
    
    public init(_ model: LevelModel.FloorModel, elevatorSize: CGSize, floorSize: CGSize, manager: FloorManager) {
        self.number = model.number
        self.type = .level
        self.elevatorSize = elevatorSize
        self.floorSize = floorSize
        self.manager = manager
        super.init()
        self.setup()
        
        print("init from model", elevatorSize, floorSize)
    }
    
    private func setup() {
        self.addChild(base)
        
        if Larson.debugging {
            self.addChild(label)
        }
        
        print("setup \(base)")
    }

    
    public required init?(coder aDecoder: NSCoder) {
        return nil
    }
}

public extension Floor {
    static func == (lhs: Floor, rhs: Floor) -> Bool {
        return lhs.number == rhs.number
    }
}

fileprivate extension Floor {
    func _label() -> SKLabelNode {
        let node = SKLabelNode()
        node.verticalAlignmentMode = .center
        node.fontSize = 16
        node.zPosition = 10000
        node.position.y = baseSize.height + node.fontSize
        node.text = "\(number) \(type) \(baseElevators.count) \(connectedElevators.count)"
        node.fontColor = GameColors.floor
        return node
    }
    
    func _base() -> SKSpriteNode {
        let texture = Graphics.texture(of: baseSize, block: { (context: CGContext) in
            let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: self.baseSize), cornerRadius: self.baseSize.height / CGFloat(2))
            context.addPath(path.cgPath)
            GameColors.floor.setFill()
            context.fillPath()
        })
        let node = SKSpriteNode(texture: texture, color: .clear, size: baseSize)
        node.colorBlendFactor = 1
        node.color = GameColors.floor
        node.zPosition = Floor.baseZPosition
        
        return node
    }
}

public extension Floor {
    
    var baseSize: CGSize {
        return CGSize(width: floorSize.width, height: floorSize.height / 24)
    }
    
    var baseElevators: [Elevator] {
        return children.compactMap { child in return
            child as? Elevator
        }
    }
    
    var elevatorY: CGFloat {
        return elevatorSize.height / 2 + baseSize.height / 2
    }
}

extension Floor {
    public enum Classification {
        case normal
        case trap_1
        case trap_2
        case level
    }
}


public extension Floor {
    func open(elevator: Elevator) {
        elevator.open()
    }
    
    func openElevators() {
        baseElevators.forEach { (elevator) in
            open(elevator: elevator)
        }
    }
    
    func close(elevator: Elevator) {
        elevator.close()
    }
    
    func closeElevators() {
        baseElevators.forEach { (elevator) in
            close(elevator: elevator)
        }
    }
    
}

public extension Floor {
    func addTrap(to: Floor) {
        let elevator = Elevator(type: .trap, base: self, destination: to, size: elevatorSize, skin: manager.scene.preferencesManager.selectedElevatorSkin)
        addChild(elevator)
        to.connectedElevators.append(elevator)
    }
    
    func addBroken() {
        let elevator = Elevator(type: .broken, base: self, destination: self, size: elevatorSize, skin: manager.scene.preferencesManager.selectedElevatorSkin)
        addChild(elevator)
    }
    
    func addConnector(to: Floor) {
        let elevator = Elevator(type: .connector, base: self, destination: to, size: elevatorSize, skin: manager.scene.preferencesManager.selectedElevatorSkin)
        addChild(elevator)
        to.connectedElevators.append(elevator)
    }
    
    func loadElevator(from model: LevelModel.FloorModel.ElevatorModel, base: Floor, destination: Floor) {
        let elevator = Elevator(model: model, base: base, destination: destination, size: elevatorSize, skin: manager.scene.preferencesManager.selectedElevatorSkin)
        
        elevator.position.x = base.frame.minX + (baseSize.width * model.xPosition)
        self.isPositioned = true
        addChild(elevator)
    }
}

public extension Floor {
    
    func updateElevatorPositions() {
        // Set up debug
        larsonenter(#function)
        // Prepare for deinit of function.
        defer {
            larsonexit()
        }
        
        guard !isPositioned else {
            larsondebug("already isPositioned")
            return
        }
        // Keep a reference to which base elevators have been isPositioned already to add their positions to the blacklisted range for the unisPositioned elevators.
        larsondebug("updating \(baseElevators.count) base elevator's positions...")
        var done = [Elevator]()
        baseElevators.forEach {
            elevator in
            // Width each Elevator reserves of space.
            let delta = (elevatorSize.width) / 2 + (elevatorSize.width / 32)
            
            let blacklisted: [Elevator] = (connectedElevators + done + manager.passovers(on: self))
            
            larsondebug("blacklisting \(blacklisted.count) elevator positions")

            // Range where elevators cannot be due to the floor's connecting Elevators and any other base Elevator that has been isPositioned.
            let blacklist: [ClosedRange<CGFloat>] = blacklisted.map { ($0.position.x - delta) ... ($0.position.x + delta) }
            // Range where Elevators can be placed in.
            let whitelist: ClosedRange<CGFloat> = (-floorSize.width / 2 + delta) ... (floorSize.width / 2 - delta)
            // Utility to calculate distance from range.
            func distance(in range: ClosedRange<CGFloat>, of number: CGFloat) -> CGFloat {
                if range.lowerBound > number {
                    return range.lowerBound - number
                } else if range.upperBound < number {
                    return number - range.upperBound
                } else {
                    return 0
                }
            }
            
            // Generate a random x coordinate in the whitelist range, regenerate if the x is delta away from a blacklisted range.
            larsonenter("searching for x position...")
            var x = CGFloat.random(in: whitelist)
            var attempts = 1
            let maxAttempts = manager?.scene.maxGenerateElevatorFails ?? 1
            repeat {
                attempts += 1
                larsondebug("retry attempt \(attempts)")
                x = CGFloat.random(in: whitelist)
            } while blacklist.contains {
                range in distance(in: range, of: x) < delta
            } && attempts < maxAttempts
            larsondebug("found after \(attempts) attempts")
            larsonexit()
            // Update position
            elevator.position.x = x
            // Move elevator up by half it's height so it's on the ground.
            elevator.position.y = elevatorY
            // Add to done.
            done.append(elevator)
        }
        
        // Flag that this floor is done positioning.
        isPositioned = true
    }
}

public extension Floor {
    override var description: String {
        let tabs = String(repeating: " ", count: (10 - String(number).count))
        let tabs2 = String(repeating: " ", count: (10 - baseElevators.count))
        
        func abbreviate(array: [Elevator]) -> String {
            let characters: [Character] = array.map { elevator -> Character in
                switch elevator.type {
                case .connector:
                    return "c"
                case .broken:
                    return "b"
                case .trap:
                    return "t"
                }
            }
            
            return String(characters)
        }
        
        let base = abbreviate(array: baseElevators)
        let tab3 = String(repeating: " ", count: (10 - connectedElevators.count))
        let connectors = abbreviate(array: connectedElevators)
        let t1 = String(repeating: " ", count: (10 - String(baseElevators.count).count))
        let t2 = String(repeating: " ", count: (10 - String(connectedElevators.count).count))
        
        return "\(number)\(tabs)\(type)\(t1)\(baseElevators.count)\(tabs2)\(base)\(t2)\(connectedElevators.count)\(tab3)\(connectors)"
    }
}

public extension Floor {
    
    static let selected_name = "selected"
    
    func setSelected(_ value: Bool = true) {
        
        self.childNode(withName: Floor.selected_name)?.removeFromParent()
        
        if value {
            let node = SKSpriteNode()
            node.color = UIColor.white.withAlphaComponent(0.1)
            node.size = floorSize
            node.position.y = node.size.height / 2
            node.name = Floor.selected_name
            self.addChild(node)
        }
    }
}
