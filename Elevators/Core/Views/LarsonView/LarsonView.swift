//
//  LarsonView.swift
//  LarsonViewDemo
//
//  Created by Peter Larson on 6/14/19.
//  Copyright © 2019 Peter Larson. All rights reserved.
//

import UIKit

@IBDesignable
final public class LarsonView: UIView {
    
    fileprivate var isInterfaceBuilder: Bool = false
    
    public static var marginFromShadow: CGFloat = 6.0
    public static var marginFromTop: CGFloat = 6.0
    
    public typealias LarsonInteraction = (LarsonView) -> Void
    
    public var onTouch: LarsonInteraction? = nil
    public var endTouch: LarsonInteraction? = nil
    public var isTouched: Bool = false
    
    @IBInspectable public var selectAnimationDuration: Double = 0.125
    @IBInspectable public var highlightBorderWidth: CGFloat = 6.0 {
        didSet {
            self.updateLayers()
        }
    }
    @IBInspectable public var unselectedAlpha: CGFloat = 0.8 {
        didSet {
            self.stateTransform()
        }
    }
    
    @IBInspectable public var cornerRadius: CGFloat = 12.0 {
        didSet {
            self.updateLayers()
        }
    }
    
    @IBInspectable public var shadowHeight: CGFloat = 6.0 {
        didSet {
            self.updateLayers()
        }
    }
    
    @IBInspectable
    public var image: UIImage = UIImage() {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable
    public var text: String? = nil {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    public var header: String? = nil {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    public var body: String? = nil {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    public typealias LarsonAttributedText = (LarsonView) -> NSAttributedString
    
    public var attributedText: LarsonAttributedText? = nil {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    public enum Style: String {
        case labeled, image, labeledImage
    }
    
    public var style: Style = .labeled {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable
    public var styleAdapter: String {
        get {
            return style.rawValue
        }
        
        set {
            guard let newStyle = Style(rawValue: newValue) else {
                fatalError("Invalid Style set (\(self.styleAdapter))")
            }
            
            self.style = newStyle
        }
    }
    
    @IBInspectable public var fontColor: UIColor? = nil {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    public var font: UIFont = UIFont(name: "Helvetica-Bold", size: 1)! {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    public enum State: String {
        case normal, selected, unselected
    }
    
    public var state: State = .normal
    
    @IBInspectable
    public var stateAdapter: String {
        get {
            return state.rawValue
        }
        
        set {
            guard let newState = State(rawValue: newValue) else {
                fatalError("Invalid State set (\(self.stateAdapter))")
            }
            
            self.state = newState
            self.updateState()
        }
    }
    
    @IBInspectable public var isPressable: Bool = true
    @IBInspectable public var color: UIColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1) {
        didSet {
            self.updateLayers()
        }
    }
    
    public fileprivate(set) var imageView: UIImageView? = nil
    public fileprivate(set) var labelView: UILabel? = nil
    
    public var topConstraint: NSLayoutConstraint? {
        switch style {
        case .labeled:
            return labelStyleConstraints.first
        case .image:
            return imageStyleConstraints.first
        case .labeledImage:
            return labeledImageConstraints.first
        }
    }
    
    fileprivate lazy var labelStyleConstraints: [NSLayoutConstraint] = {
        
        guard let labelView = self.labelView else {
            return []
        }
        
        return [
            NSLayoutConstraint(item: labelView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: LarsonView.marginFromTop),
            NSLayoutConstraint(item: labelView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: self.cornerRadius * -2),
            NSLayoutConstraint(item: labelView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: -LarsonView.marginFromTop-LarsonView.marginFromShadow-self.shadowHeight),
            NSLayoutConstraint(item: labelView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0)
        ]
    }()
    
    fileprivate lazy var labeledImageConstraints: [NSLayoutConstraint] = {
        
        guard let labelView = self.labelView, let imageView = self.imageView else {
            return []
        }
        
        return [
            NSLayoutConstraint(item: labelView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: LarsonView.marginFromTop),
            NSLayoutConstraint(item: labelView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.2, constant: 0.0),
            NSLayoutConstraint(item: labelView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: self.cornerRadius * -2),
            NSLayoutConstraint(item: labelView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: labelView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.8, constant: -self.shadowHeight - LarsonView.marginFromShadow - LarsonView.marginFromTop)
        ]
    }()
    
    fileprivate lazy var imageStyleConstraints: [NSLayoutConstraint] = {
        guard let imageView = self.imageView else {
            return []
        }
        
        return [
            NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: LarsonView.marginFromTop),
            NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -self.shadowHeight - LarsonView.marginFromShadow),
            NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 1.0, constant: 0.0)
        ]
    }()
    
    override public class var layerClass: AnyClass {
        return OverlayLayer.self
    }
    
    fileprivate lazy var stateLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        
        layer.borderWidth = highlightBorderWidth
        layer.path = CGPath(rect: self.frame, transform: nil)
        layer.fillColor = UIColor.clear.cgColor
        layer.cornerRadius = self.cornerRadius
        
        self.layer.addSublayer(layer)
        
        return layer
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    public init() {
        super.init(frame: .zero)
        self.setupView()
    }
}

// Convenience Initializers

extension LarsonView {
    convenience init(image: UIImage, text: String, color: UIColor? = nil) {
        self.init()
        self.image = image
        self.text = text
        self.color = color ?? self.color
        self.style = .labeledImage
        self.setupView()
    }
    
    convenience init(text: String, color: UIColor? = nil, fontColor: UIColor? = nil) {
        self.init()
        self.text = text
        self.fontColor = fontColor
        self.color = color ?? self.color
        self.style = .labeled
        self.setupView()
    }
    
    convenience init(image: UIImage, color: UIColor? = nil) {
        self.init()
        self.image = image
        self.style = .image
        self.color = color ?? self.color
        self.setupView()
    }
}

// Press
public extension LarsonView {
    func animatePress(to value: Bool) {
        (self.layer as? OverlayLayer)?.animate(pressed: value)
    }
}

// Touch
public extension LarsonView {
    
    func canceledTouches(_ touches: Set<UITouch>) -> Bool {
        for touch in touches {
            if frame.contains(touch.location(in: self.superview)) == false {
                return true
            }
        }
        
        return false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if canceledTouches(touches) && isPressable && isTouched {
            self.animatePress(to: false)
            self.isTouched = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isPressable && isTouched == false {
            self.animatePress(to: true)
        }
        
        self.isTouched = true
        
        self.onTouch?.self(self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isPressable && isTouched {
            self.animatePress(to: false)
        }
        
        self.isTouched = false
        
        self.endTouch?.self(self)
    }
}

// Common
public extension LarsonView {
    
    override func prepareForInterfaceBuilder() {
        self.isInterfaceBuilder = true
        super.prepareForInterfaceBuilder()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
    }
    
    func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setupImageView()
        self.setupLabelView()
        self.updateLayers()
        self.updateState()
        self.setNeedsDisplay()
        
        // Debugging constraints
        
        //        labelStyleConstraints.enumerated().forEach { (index, constraint) in
        //            constraint.identifier = "Labeled \(index)"
        //        }
    }
    
    func updateLayers() {
        
        // Set up layers
        
        guard let overlayLayer = layer as? OverlayLayer else {
            return
        }
        
        overlayLayer.masksToBounds = true
        overlayLayer.view = self
        overlayLayer.shadowHeight = self.shadowHeight
        overlayLayer.defaultShadowHeight = self.shadowHeight
        overlayLayer.cornerRadius = self.cornerRadius
        
        self.stateLayer.cornerRadius = self.cornerRadius
        
        // Move label layer in middle
        
        labelView?.layer.zPosition = 1
        labelView?.shadowColor = color.darker()
        
        if fontColor != nil {
            labelView?.shadowOffset = .init(width: 0, height: LarsonView.marginFromShadow / 2)
        }
        
        // Move image layer in middle
        
        imageView?.layer.zPosition = 2
        
        // Move state layer above
        
        stateLayer.zPosition = 3
        stateLayer.frame = layer.bounds
        
        layer.setNeedsDisplay()
    }
}

// Update state
public extension LarsonView {
    
    func setState(to state: State, animated: Bool) {
        
        guard state != self.state else {
            return
        }
        
        self.state = state
        
        guard animated else {
            self.updateState()
            return
        }
        
        UIView.animate(withDuration: selectAnimationDuration, delay: 0.0, options: .curveEaseIn, animations: self.updateState, completion: nil)
        
        guard self.state != .normal else {
            return
        }
        
        let animation = CABasicAnimation(keyPath: "borderColor")
        
        animation.fromValue = state == .selected ? UIColor.clear.cgColor : UIColor.white.cgColor
        animation.toValue = state == .selected ? UIColor.white.cgColor : UIColor.clear.cgColor
        animation.duration = self.selectAnimationDuration
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        self.stateLayer.add(animation, forKey: "borderColor")
    }
    
    private func stateTransform() {
        self.alpha = self.state == LarsonView.State.unselected ? self.unselectedAlpha : 1.0
        
        // For Debugging
//        self.transform = self.state == LarsonView.State.selected ? CGAffineTransform(scaleX: 1.1, y: 1.1) : .identity
    }
    
    private func updateState() {
        self.stateLayer.borderColor = state == .selected ? UIColor.white.cgColor : UIColor.clear.cgColor
        self.stateTransform()
        self.stateLayer.setNeedsDisplay()
    }
}

import os.log

// Label View
public extension LarsonView {
    convenience init(frame: CGRect, label: String) {
        self.init(frame: frame)
    }
    
    func setupLabelView() {
        guard labelView == nil else {
            return
        }
        
        labelView = UILabel()
        
        labelView?.adjustsFontSizeToFitWidth = true
        labelView?.minimumScaleFactor = 0.0
        
        labelView?.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(labelView!)
    }
    
    func updateLabelView() {
        self.setupLabelView()
        
        guard let labelView = labelView else {
            return
        }
        
        guard (layer as? OverlayLayer)?.animating == false else {
            return
        }
        
        labelView.isHidden = style == .image
        
        labelView.baselineAdjustment = .none
        labelView.textAlignment = .center
        labelView.numberOfLines = 0
        labelView.textColor = fontColor ?? color.darker()
        
        self.updateText()
    }
    
    func updateText() {
        guard let labelView = labelView else {
            return
        }
        
        labelView.font = self.font.withSize(labelView.frame.height - LarsonView.marginFromTop - (self.style == .labeled ? LarsonView.marginFromShadow + shadowHeight: 0.0))
        
        if let attributedText = attributedText {
            labelView.text = nil
            labelView.attributedText = attributedText(self)
        } else {
            labelView.text = text
        }
    }
}

// Image View
public extension LarsonView {
    
    fileprivate func setupImageView() {
        
        guard imageView == nil else {
            return
        }
        
        imageView = UIImageView()
        
        imageView?.contentMode = .scaleAspectFit
        
        imageView?.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(imageView!)
    }
    
    func updateImageView() {
        self.setupImageView()
        
        guard let imageView = imageView else {
            self.imageView?.isHidden = true
            return
        }
        
        imageView.isHidden = style == .labeled
        
        imageView.image = self.image
    }
}

// Layout
public extension LarsonView {
    
    override func layoutSubviews() {
        
        guard isInterfaceBuilder == false else {
            super.layoutSubviews()
            return
            
        }
        
        guard let overlayLayer = layer as? OverlayLayer else {
            super.layoutSubviews()
            return
        }
        
        guard overlayLayer.animating == false else {
            super.layoutSubviews()
            return
        }
        
        switch style {
        case .labeled:
            NSLayoutConstraint.deactivate(imageStyleConstraints)
            NSLayoutConstraint.deactivate(labeledImageConstraints)
            NSLayoutConstraint.activate(labelStyleConstraints)
            break
        case .image:
            NSLayoutConstraint.deactivate(labelStyleConstraints)
            NSLayoutConstraint.deactivate(labeledImageConstraints)
            NSLayoutConstraint.activate(imageStyleConstraints)
            break
        case .labeledImage:
            NSLayoutConstraint.deactivate(labelStyleConstraints)
            NSLayoutConstraint.deactivate(imageStyleConstraints)
            NSLayoutConstraint.activate(labeledImageConstraints)
            break
        }
        
        super.layoutSubviews()
        
        self.updateImageView()
        self.updateLabelView()
        self.updateLayers()
    }
}

// LarsonAttributedText
extension LarsonView {
    public static var headedBodyAttributedText: LarsonAttributedText = {
        (larsonview) in
        
        let attributed = NSMutableAttributedString()
        
        func finished() -> NSAttributedString {
            let style = NSMutableParagraphStyle()
            
            style.alignment = .center
            style.lineBreakMode = .byCharWrapping
            
            let range = attributed.mutableString.range(of: attributed.string)
            
            attributed.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: range)
            attributed.addAttribute(NSAttributedString.Key.foregroundColor, value: larsonview.fontColor ?? larsonview.color.darker(), range: range)
            
            return attributed
        }
        
        guard let viewFrame = larsonview.labelView?.frame else {
            return finished()
        }
        
        larsonview.labelView?.numberOfLines = 0
        
        guard let header = larsonview.header else {
            return finished()
        }
        
        attributed.append(NSAttributedString(string: header, attributes: [
            NSAttributedString.Key.font:larsonview.font.withSize(viewFrame.height / 6)]
        ))
        
        guard let body = larsonview.body else {
            return finished()
        }
        
        attributed.append(NSAttributedString(string: "\n"))
        
        attributed.append(NSAttributedString(string: body, attributes:
            [NSAttributedString.Key.font:larsonview.font.withSize(viewFrame.height / 3)]
        ))
        
        return finished()
    }
    
    public static var imageBodyAttributedText: LarsonAttributedText = {
        larsonview in
        
        let attributed = NSMutableAttributedString()
        
        guard let labelView = larsonview.labelView else {
            fatalError("LarsonAttributedText needs a valid label view!")
        }
        
        labelView.lineBreakMode = .byTruncatingTail
        
        let image = larsonview.image
        
        let attachment = NSTextAttachment()
        
        attachment.image = image
        
        attachment.bounds = CGRect(origin: .zero, size: CGSize(width: labelView.frame.size.height / 3 * 2, height: labelView.frame.size.height / 3 * 2))
        
        attributed.append(NSAttributedString(attachment: attachment))
        
        guard let body = larsonview.body else {
            fatalError("LarsonAttributedText needs a valid body string!")
        }
        
        let spacing = labelView.frame.height / 10
        
        attributed.append(NSAttributedString(string: " ", attributes: [NSAttributedString.Key.font : labelView.font.withSize(spacing)]))
        
        
        attributed.append(NSAttributedString(string: body))
        
        let range = attributed.mutableString.range(of: attributed.string)
        
        let style = NSMutableParagraphStyle()
        
        attributed.addAttribute(NSAttributedString.Key.foregroundColor, value: larsonview.fontColor ?? larsonview.color.darker(), range: range)
        
        return attributed
    }
}
