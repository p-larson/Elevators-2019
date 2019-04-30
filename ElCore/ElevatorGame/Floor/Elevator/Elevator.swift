//
//  Elevator.swift
//  Elevators
//
//  Created by Peter Larson on 2/2/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import SpriteKit

public class Elevator: SKSpriteNode {
    
    static let backgroundZPosition: CGFloat = 1.0
    static let doorZPosition: CGFloat = 2.0
    static let ropeZPosition: CGFloat = -1.0
    
    public var isEnabled = true
    public let type: Classification
    public let skin: Skin
    private(set) public weak var destination: Floor!
    private(set) public weak var base: Floor!
    
    public var floor: Floor? {
        return parent as? Floor
    }
    
    public var hasRope: Bool {
        return rope.parent != nil
    }
    
    var pointOfFinalDestination: CGPoint {
        return CGPoint(
            x: 0,
            y: -size.height / 2 + (destination.position.y - base.position.y)
        )
    }
    
    var pointOfLine: CGPoint {
        return CGPoint(
            x: position.x,
            y: position.x + (destination.position.y - base.position.y ) - size.height / 2
        )
    }
    
    public func drawRope() {
        base.addChild(rope)
    }
    
    lazy var rope: SKSpriteNode = {
        let node = SKSpriteNode()
        let height = base.manager?.distance(from: base, to: destination) ?? 0
        node.size = CGSize(width: size.width / 10, height: height)
        node.texture = Graphics.texture(of: size, block: { (context) in
            context.addRect(CGRect(origin: .zero, size: self.size))
            UIColor.black.setFill()
            context.fillPath()
        })
        node.position.x = position.x
        node.position.y = height / 2
        node.zPosition = Elevator.ropeZPosition
        return node
    }()
    
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
    
    private func closingAction(completion: @escaping Block = {}) -> SKAction {
        return SKAction.sequence(
            [
                SKAction.run {
                    self.status = .Closing
                },
                SKAction.animate(with: Array<SKTexture>(skin.frames1), timePerFrame: 1.0 / 24.0),
                SKAction.run {
                    self.status = .Closed
                    completion()
                }
            ]
        )
    }
    
    private func openingAction(completion: @escaping Block = {}) -> SKAction {
        return SKAction.sequence(
            [
                SKAction.run {
                    self.status = .Opening
                },
                SKAction.animate(with: Array<SKTexture>(skin.frames2), timePerFrame: 1.0 / 24.0),
                SKAction.run {
                    self.status = .Open
                    completion()
                }
            ]
        )
    }
    
    public func stopStatusChange() {
        doors.removeAction(forKey: Elevator.doors_closing_move)
        doors.removeAction(forKey: Elevator.doors_opening_move)
    }
    
    public func close(completion: @escaping Block = {}) {
        guard ![Status.Closed, Status.Closing].contains(status) else {
            return
        }
        
        doors.run(closingAction(completion: completion), withKey: Elevator.doors_closing_move)
    }
    
    public func open(completion: @escaping Block = {}) {
        guard ![Status.Open, Status.Opening].contains(status) else {
            return
        }
        
        doors.run(openingAction(completion: completion), withKey: Elevator.doors_opening_move)
    }
    
    
    
    
    init(type: Classification, base: Floor, destination: Floor, size: CGSize, skin: Skin) {
        self.type = type
        self.base = base
        self.destination = destination
        self.skin = skin
        super.init(texture: skin.base, color: .clear, size: size)
        self.zPosition = Elevator.backgroundZPosition
        self.isUserInteractionEnabled = true
        self.addChild(doors)
        
        print(size, doors.size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    public enum Classification {
        case connector
        case trap
        case broken
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        (scene as? ElevatorsGameScene)?.touched(elevator: self)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        (scene as? ElevatorDelegate)?.untouched(elevator: self)
    }
    
    public override var description: String {
        return "\(type) @ \(floor?.number ?? -1) \(base.number) -> \(destination.number)"
    }
    
}

extension Elevator: TextureGraphable {
    static func texture(_ this: Elevator) -> SKTexture {
        
        // TODO: have actual graphics, lol.
        return Graphics.texture(of: this.size, block: { (context) in
            context.addRect(CGRect.init(origin: .zero, size: this.size))
        
            switch this.type {
            case .broken:
                UIColor.gray.setFill()
                break
            case .connector:
                UIColor.blue.setFill()
                break;
            case .trap:
                UIColor.red.setFill()
                break;
            }
            context.fillPath()
            
            ("\(String(describing: this.type).prefix(1)) \(this.destination.number)" as NSString).draw(in: CGRect(origin: .zero, size: this.size), withAttributes: [NSAttributedString.Key.strokeColor : UIColor.white])
            
        })
    }
    
    func updateGraphics() {
        self.texture = Elevator.texture(self)
    }
}
