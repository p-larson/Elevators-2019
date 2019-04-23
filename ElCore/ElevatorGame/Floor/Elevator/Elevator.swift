//
//  Elevator.swift
//  Elevators
//
//  Created by Peter Larson on 2/2/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import SpriteKit

public class Elevator: SKSpriteNode {
    
    public var isEnabled = true
    public let type: Classification
    private(set) public weak var destination: Floor!
    private(set) public weak var base: Floor!
    
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
        larsondebug("drawed rope")
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
        node.zPosition = zPosition - 1
        return node
    }()
    
    init(type: Classification, base: Floor, destination: Floor, size: CGSize) {
        self.type = type
        self.base = base
        self.destination = destination
        super.init(texture: nil, color: .clear, size: size)
        self.updateGraphics()
        self.isUserInteractionEnabled = true
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
        return "\(type) \(base.number) -> \(destination.number)"
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
