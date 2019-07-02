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
    public let type: Kind
    public let floorSize: CGSize
    public weak var manager: FloorManager? = nil
    public var model: FloorModel? = nil
    public var connectedElevators = [Elevator]()
    private var isPositioned: Bool = false
    public static let baseZPosition: CGFloat = 4.0
    private lazy var label: SKLabelNode = _label()
    private lazy var base: SKSpriteNode = _base()
    
    public func loadElevators(from model: FloorModel) {
        model.baseElevators.forEach { (elevatorModel) in
            self.addChild(Elevator(model: elevatorModel, size: elevatorSize, base: self)!)
        }
    }
    
    public init(number: Int, type: Kind, elevatorSize: CGSize, floorSize: CGSize, manager: FloorManager) {
        self.number = number
        self.type = type
        self.elevatorSize = elevatorSize
        self.floorSize = floorSize
        self.manager = manager
        super.init()
        self.setup()
    }
    
    
    public init(_ model: FloorModel, elevatorSize: CGSize, floorSize: CGSize, manager: FloorManager? = nil) {
        self.number = model.number
        self.type = .Level
        self.elevatorSize = elevatorSize
        self.floorSize = floorSize
        self.model = model
        self.manager = manager
        super.init()
        self.setup()
    }
    
    private func setup() {
        self.addChild(base)
        self.addChild(label)
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
    public enum Kind: String, CaseIterable {
        case Normal, Trap, TrapEnd, Level
        
        public static func load(from: Int) -> Kind {
            if allCases.indices.contains(from) {
                return allCases[from]
            } else {
                return Kind.Normal
            }
        }
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
    
    private var nextNumber: Int {
        return baseElevators.count + 1
    }
    
    @discardableResult
    func addTrap(to: Floor) -> Elevator {
        let elevator = Elevator(type: .Trap, base: self, destination: to, size: elevatorSize, skin: ShopManager.shared.selectedElevatorSkin, number: nextNumber)
        addChild(elevator)
        to.connectedElevators.append(elevator)
        return elevator
    }
    
    @discardableResult
    func addBroken() -> Elevator {
        let elevator = Elevator(type: .Broken, base: self, destination: self, size: elevatorSize, skin: ShopManager.shared.selectedElevatorSkin, number: number)
        addChild(elevator)
        return elevator
    }
    
    @discardableResult
    func addConnector(to: Floor) -> Elevator {
        let elevator = Elevator(type: .Connector, base: self, destination: to, size: elevatorSize, skin: ShopManager.shared.selectedElevatorSkin, number: nextNumber)
        addChild(elevator)
        to.connectedElevators.append(elevator)
        return elevator
    }
    
    @discardableResult
    func loadElevator(from model: ElevatorModel, base: Floor, destination: Floor) -> Elevator {
        let elevator = Elevator(model: model, base: base, destination: destination, size: elevatorSize, skin: ShopManager.shared.selectedElevatorSkin)
        
        elevator.position.x = base.frame.minX + (baseSize.width * model.xPosition)
        self.isPositioned = true
        addChild(elevator)
        return elevator
    }
}

public extension Floor {
    
    func updateElevatorPositions() {
        
        guard !isPositioned else {
            return
        }
        
        if let floorModel = model {
            floorModel.baseElevators.forEach { (elevatorModel) in
                
                let elevator = self.elevator(for: elevatorModel)
                
                elevator?.position.x = self.position(from: elevatorModel.xPosition)
                elevator?.position.y = self.elevatorY
            }
        } else {
            
            // Keep a reference to which base elevators have been isPositioned already to add their positions to the blacklisted range for the unisPositioned elevators.
            var done = [Elevator]()
            baseElevators.forEach {
                elevator in
                // Width each Elevator reserves of space.
                let delta = (elevatorSize.width) / 2 + (elevatorSize.width / 32)
                
                let passovers = manager?.passovers(on: self) ?? []
                
                let blacklisted: [Elevator] = (connectedElevators + done + passovers)
                
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
                var x = CGFloat.random(in: whitelist)
                var attempts = 1
                let maxAttempts = manager?.scene.maxGenerateElevatorFails ?? 1
                repeat {
                    attempts += 1
                    x = CGFloat.random(in: whitelist)
                } while blacklist.contains {
                    range in distance(in: range, of: x) < delta
                    } && attempts < maxAttempts

                // Update position
                elevator.position.x = x
                // Move elevator up by half it's height so it's on the ground.
                elevator.position.y = elevatorY
                // Add to done.
                done.append(elevator)
            }
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
                case .Connector:
                    return "c"
                case .Broken:
                    return "b"
                case .Trap:
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

extension Floor {
    public func position(from percent: CGFloat) -> CGFloat {
        assert(percent >= 0.0 && percent <= 1.0, "Percent is not in range \(percent).")
        
        return base.frame.minX + (baseSize.width * percent)
    }
    
    public func percent(from elevator: Elevator) -> CGFloat {
        guard elevator.parent == self else {
            return 0.0
        }
        
        return (elevator.position.x - base.frame.minX) / baseSize.width
        
    }
}

extension Floor {
    public func elevator(for model: ElevatorModel) -> Elevator? {
        
        let x = position(from: model.xPosition)
        
        return baseElevators.sorted(by: { (elevator1, elevator2) -> Bool in
            return abs(x - elevator1.position.x) < abs(x - elevator2.position.x)
        }).first
    }
}

extension Floor: Modelable {

    public typealias Model = FloorModel
    
    public func modeled() -> FloorModel {
        
        let model = FloorModel(number: number)
        
        baseElevators.forEach { (elevator) in
            model.baseElevators.append(elevator.modeled())
        }
        
        // TODO: Coins
        
        return model
    }
}

public extension Floor {
    
    var container: CGRect {
        return CGRect(origin: position.sub(0, floorSize.height / 2), size: floorSize)
    }
}
