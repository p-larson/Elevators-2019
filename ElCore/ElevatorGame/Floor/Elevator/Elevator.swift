//
//  Elevator.swift
//  Elevators
//
//  Created by Peter Larson on 2/2/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import SpriteKit

public class Elevator: SKSpriteNode {
    
    public let number: Int
    static let backgroundZPosition: CGFloat = 1.0
    static let doorZPosition: CGFloat = 2.0
    static let ropeZPosition: CGFloat = -1.0
    public var model: ElevatorModel? = nil
    public var isEnabled = true
    public var type: Kind
    public var skin: Skin
    public var destination: Int
    public var base: Int
    
    public var floor: Floor? {
        return parent as? Floor
    }
    
    var baseFloor: Floor? {
        return floor?.manager?.floor(numbered: base)
    }
    
    var destinationFloor: Floor? {
        return floor?.manager?.floor(numbered: destination)
    }
    
    var pointOfFinalDestination: CGPoint {
        
        guard let destinationY = destinationFloor?.position.y, let baseY = baseFloor?.position.y else {
            return CGPoint.zero
        }
        
        return CGPoint(
            x: 0,
            y: -size.height / 2 + (destinationY - baseY)
        )
    }
    
    var pointOfLine: CGPoint {
        
        guard let destinationY = destinationFloor?.position.y, let baseY = baseFloor?.position.y else {
            return CGPoint.zero
        }
        
        return CGPoint(
            x: position.x,
            y: position.x + (destinationY - baseY) - size.height / 2
        )
    }
    
    public static let rope_name = "rope"
    
    public func drawRope(_ needsRedraw: Bool = false) {
        
        if !needsRedraw && floor?.childNode(withName: Elevator.rope_name) != nil {
            return // No need to redraw because the nodes already drawn.
        }
        
        let node = SKSpriteNode()
        let height = self.floor?.manager?.distance(from: base, to: destination) ?? 0
        node.size = CGSize(width: size.width / 10, height: height)
        node.texture = Graphics.texture(of: size, block: { (context) in
            context.addRect(CGRect(origin: .zero, size: self.size))
            UIColor.black.setFill()
            context.fillPath()
        })
        node.position.x = position.x
        node.position.y = height / 2
        node.zPosition = Elevator.ropeZPosition
        floor?.childNode(withName: Elevator.rope_name)?.removeFromParent()
        floor?.addChild(node)
    }
    
    public lazy var doors: SKSpriteNode = {
        let node = SKSpriteNode()
        node.size = self.size
        node.texture = skin.frames1.first
        node.position = CGPoint.zero
        node.zPosition = Elevator.doorZPosition
        return node
    }()
    
    public static let doors_opening_move = "doors_open_move"
    public static let doors_closing_move = "doors_close_move"
    
    public enum Status {
        case Opening
        case Open
        case Closing
        case Closed
    }
    
    public private(set) var status: Status = .Closed
    
    public var isClosing: Bool {
        return doors.action(forKey: Elevator.doors_closing_move) != nil
    }
    
    public var isOpening: Bool {
        return doors.action(forKey: Elevator.doors_opening_move) != nil
    }
    
    private func closingAction(completion: BlockOperation) -> SKAction {
        return SKAction.sequence(
            [
                SKAction.run {
                    self.status = .Closing
                },
                SKAction.animate(with: Array<SKTexture>(skin.frames2), timePerFrame: 1.0 / 72.0),
                SKAction.run {
                    self.status = .Closed
                    completion.start()
                }
            ]
        )
    }
    
    private func openingAction(completion: BlockOperation) -> SKAction {
        return SKAction.sequence(
            [
                SKAction.run {
                    self.status = .Opening
                },
                SKAction.animate(with: Array<SKTexture>(skin.frames1), timePerFrame: 1.0 / 72.0),
                SKAction.run {
                    self.status = .Open
                    completion.start()
                }
            ]
        )
    }
    
    public func stopStatusChange() {
        doors.removeAction(forKey: Elevator.doors_closing_move)
        doors.removeAction(forKey: Elevator.doors_opening_move)
    }
    
    public func close(completion: BlockOperation = BlockOperation()) {
        guard [Status.Closed, Status.Closing].contains(status) == false else {
            return
        }
        
        doors.run(closingAction(completion: completion), withKey: Elevator.doors_closing_move)
    }
    
    public func open(completion: BlockOperation = BlockOperation()) {
        guard [Status.Open, Status.Opening].contains(status) == false else {
            return
        }
        
        doors.run(openingAction(completion: completion), withKey: Elevator.doors_opening_move)
    }
    
    private func setupCommon() {
        self.zPosition = Elevator.backgroundZPosition
        self.addChild(doors)
    }
    
    init(type: Kind, base: Int, destination: Int, size: CGSize, skin: Skin, number: Int) {
        self.type = type
        self.base = base
        self.destination = destination
        self.skin = skin
        self.number = number
        super.init(texture: skin.base, color: .clear, size: size)
        self.setupCommon()
    }
    
    init(model: ElevatorModel, base: Int, destination: Int, size: CGSize, skin: Skin) {
        
        self.type = model.type
        self.number = model.number
        self.base = base
        self.destination = destination
        self.skin = skin
        super.init(texture: skin.base, color: .clear, size: size)
        self.setupCommon()
    }
    
    init?(model: ElevatorModel, size: CGSize, base: Int) {
        self.number = model.number
        self.type = model.type
        self.base = base
        self.destination = base
        self.skin = ShopManager.shared.defaultElevator
        super.init(texture: skin.base, color: .clear, size: size)
        self.setupCommon()
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    public override var description: String {
        return "\(type) @ \(floor?.number ?? -1) \(base) -> \(destination)"
    }
    
}

extension Elevator: TextureGraphable {
    static func texture(_ this: Elevator) -> SKTexture {
        
        // TODO: have actual graphics, lol.
        return Graphics.texture(of: this.size, block: { (context) in
            context.addRect(CGRect.init(origin: .zero, size: this.size))
            
            switch this.type {
            case .Broken:
                UIColor.gray.setFill()
                break
            case .Connector:
                UIColor.blue.setFill()
                break;
            case .Trap:
                UIColor.red.setFill()
                break;
            }
            context.fillPath()
            
            ("\(String(describing: this.type).prefix(1)) \(this.destination)" as NSString).draw(in: CGRect(origin: .zero, size: this.size), withAttributes: [NSAttributedString.Key.strokeColor : UIColor.white])
            
        })
    }
    
    func updateGraphics() {
        self.texture = Elevator.texture(self)
    }
    
    public enum Kind: String, CaseIterable, Encodable, Decodable {
        case Connector, Trap, Broken
        
        public static func load(from: Int) -> Kind {
            if allCases.indices.contains(from) {
                return allCases[from]
            } else {
                return Kind.Connector
            }
        }
    }

}

extension Elevator: Modelable {
    public typealias Model = ElevatorModel
    
    public func modeled() -> ElevatorModel {
        return ElevatorModel(
            xPosition: floor?.percent(from: self) ?? 0.0,
            base: base,
            destination: destination,
            type: type,
            number: number
        )
    }
}
