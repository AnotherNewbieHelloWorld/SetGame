//
//  SetCardView.swift
//  SetGame
//
//  Created by Apple User on 16.02.2020.
//  Copyright © 2020 Alena Khoroshilova. All rights reserved.
//

import UIKit

@IBDesignable
class SetCardView: UIView {
    
    @IBInspectable
    var faceBackgroundColor: UIColor = UIColor.white { didSet { setNeedsDisplay(); setNeedsLayout()} }
    
    @IBInspectable
    var isSelected: Bool = false { didSet { setNeedsDisplay(); setNeedsLayout()} }
    var isMatched: Bool? { didSet { setNeedsDisplay(); setNeedsLayout() } }

    @IBInspectable
    var isFaceUp: Bool = true {didSet { setNeedsDisplay(); setNeedsLayout()}}
    
    @IBInspectable
    var symbolInt: Int = 1 {
        didSet {
            switch symbolInt {
            case 1: symbol = .squiggle
            case 2: symbol = .oval
            case 3: symbol = .diamond
            default: break
            }
        }
    }
    
    @IBInspectable
    var fillInt: Int = 1 {
        didSet {
            switch fillInt {
            case 1: fill = .empty
            case 2: fill = .stripes
            case 3: fill = .solid
            default: break
            }
        }
    }
    
    @IBInspectable
    var colorInt: Int = 1 {
        didSet {
            switch colorInt {
            case 1: color = Colors.green
            case 2: color = Colors.red
            case 3: color = Colors.purple
            default: break
            }
        }
    }
    
    @IBInspectable
    var count: Int = 1 { didSet { setNeedsDisplay()} }
    
    private var color = Colors.red { didSet { setNeedsDisplay()} }
    private var fill: Fill = Fill.stripes { didSet { setNeedsDisplay()} }
    private var symbol: Symbol = Symbol.squiggle { didSet { setNeedsDisplay()} }
    
    private enum Fill: Int {
        case empty
        case stripes
        case solid
    }
    
    private enum Symbol: Int {
        case diamond
        case squiggle
        case oval
    }
    
    private let interStripeSpace: CGFloat = 0.001
    private let borderWidth: CGFloat = 6.0
    
    
    // MARK: - Draw
    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        roundedRect.addClip()
        faceBackgroundColor.setFill()
        roundedRect.fill()
        if isFaceUp {
            drawPips()
        } else {
            if let cardBackImage = UIImage(named: "cardback",
                                           in: Bundle(for: self.classForCoder),
                                           compatibleWith: traitCollection) {
                cardBackImage.draw(in: bounds)
            }
        }
    }
    
    private func drawPips() {
        color.setFill()
        color.setStroke()
        
        let size = CGSize(width: faceFrame.width, height: pipHeight)
        let origin = CGPoint(x: faceFrame.minX, y: faceFrame.midY - pipHeight/2)
        let rectPip = CGRect(origin: origin, size: size)
        
        switch count {
        case 1:
            drawShape(in: rectPip)
        case 2:
            let firstRect = rectPip.offsetBy(dx: 0, dy: -(pipHeight + interPipHeight)/2)
            drawShape(in: firstRect)
            let secondRect = firstRect.offsetBy(dx: 0, dy: pipHeight + interPipHeight)
            drawShape(in: secondRect)
        case 3:
            drawShape(in: rectPip)
            let secondRect = rectPip.offsetBy(dx: 0, dy: -(pipHeight + interPipHeight))
            drawShape(in: secondRect)
            let thirdRect = rectPip.offsetBy(dx: 0, dy: pipHeight + interPipHeight)
            drawShape(in: thirdRect)
        default:
            break
        }
    }
    
    private func drawShape(in rect: CGRect) {
        let path: UIBezierPath
        switch symbol {
        case .diamond:
            path = pathForDiamond(in: rect)
        case .oval:
            path = pathForOval(in: rect)
        case .squiggle:
            path = pathForSquiggle(in: rect)
        }
        
        path.lineWidth = 2.0
        path.stroke()
        switch fill {
        case .solid:
            path.fill()
        case .stripes:
            stripeShape(path: path, in: rect)
        default:
            break
        }
    }
    
    func copyCard() -> SetCardView {
        let copy = SetCardView()
        copy.symbolInt =  symbolInt
        copy.fillInt = fillInt
        copy.colorInt = colorInt
        copy.count =  count
        copy.isSelected =  false
       
        copy.isFaceUp = true
        copy.bounds = bounds
        copy.frame = frame
        copy.alpha = 1
        return copy
    }
    
    //      MARK: - Deal a card Animation
    func animateDeal(from deckCenter: CGPoint, delay: TimeInterval) {
        let currentCenter = center
        let currentBounds = bounds
        
        center = deckCenter
        alpha = 1
        bounds = CGRect(x: 0.0, y: 0.0, width: 0.1*bounds.width, height: 0.1*bounds.height)
        isFaceUp = false
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 1,
            delay: delay,
            options: [],
            animations: {
                self.center = currentCenter
                self.bounds = currentBounds
            },
            completion: { position in
                UIView.transition(
                    with: self,
                    duration: 0.3,
                    options: [.transitionFlipFromLeft],
                    animations: { self.isFaceUp = true }
                )
            }
        )
    }
    
    var addDiscardPile: (() -> Void)?
    
    func animateFly(to discardPileCenter: CGPoint, delay: TimeInterval) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 1,
            delay: delay,
            options: [],
            animations: {
                self.center = discardPileCenter
            },
            completion: { position in
                UIView.transition(
                    with: self,
                    duration: 0.75,
                    options: [.transitionFlipFromLeft],
                    animations: {
                        self.isFaceUp = false
                        self.transform = CGAffineTransform.identity.rotated(by: CGFloat.pi/2.0)
                        self.bounds = CGRect(x: 0.0, y: 0.0, width: 0.5*self.bounds.width, height: 0.5*self.bounds.height)
                    },
                    completion: { (finished) in
                        self.addDiscardPile?()
                    }
                )
            }
        )
    }
    
    //      MARK: - Fills
    
    private func stripeShape(path: UIBezierPath, in rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        path.addClip()
        stripeRect(rect)
        context?.restoreGState()
    }
    
    private func stripeRect(_ rect: CGRect) {
        let stripe = UIBezierPath()
        let dashes: [CGFloat] = [1,3]
        stripe.setLineDash(dashes, count: dashes.count, phase: 0)
        
        stripe.lineWidth = bounds.size.height
        stripe.lineCapStyle = .butt
        stripe.move(to: CGPoint(x: bounds.minX, y: bounds.midY))
        stripe.addLine(to: CGPoint(x: bounds.maxX, y: bounds.midY))
        stripe.stroke()
    }
    
    //      MARK: - Shapes
    private func pathForSquiggle(in rect: CGRect) -> UIBezierPath {
        let upperSquiggle = UIBezierPath()
        let sqdx = rect.width * 0.1
        let sqdy = rect.height * 0.2
        upperSquiggle.move(to: CGPoint(x: rect.minX, y: rect.midY))
        
        upperSquiggle.addCurve(
            to: CGPoint(
                x: rect.minX + rect.width * 1/2,
                y: rect.minY + rect.height / 8),
            controlPoint1: CGPoint(
                x: rect.minX,
                y: rect.minY),
            controlPoint2: CGPoint(
                x: rect.minX + rect.width * 1/2 - sqdx,
                y: rect.minY + rect.height / 8 - sqdy))
        
        upperSquiggle.addCurve(
            to: CGPoint(
                x: rect.minX + rect.width * 4/5,
                y: rect.minY + rect.height / 8),
            controlPoint1: CGPoint(
                x: rect.minX + rect.width * 1/2 + sqdx,
                y: rect.minY + rect.height / 8 + sqdy),
            controlPoint2: CGPoint(
                x: rect.minX + rect.width * 4/5 - sqdx,
                y: rect.minY + rect.height / 8 + sqdy))
        
        upperSquiggle.addCurve(
            to:CGPoint(
                x: rect.minX + rect.width,
                y: rect.minY + rect.height / 2),
            controlPoint1: CGPoint(
                x: rect.minX + rect.width * 4/5 + sqdx,
                y: rect.minY + rect.height / 8 - sqdy ),
            controlPoint2: CGPoint(
                x: rect.minX + rect.width,
                y: rect.minY))
        
        let lowerSquiggle = UIBezierPath(cgPath: upperSquiggle.cgPath)
        lowerSquiggle.apply(CGAffineTransform.identity.rotated(by: CGFloat.pi))
        lowerSquiggle.apply(CGAffineTransform.identity.translatedBy(
            x: bounds.width,
            y: bounds.height))
        upperSquiggle.move(to: CGPoint(x: rect.minX, y: rect.midY))
        upperSquiggle.append(lowerSquiggle)
        return upperSquiggle
    }
    
    private func pathForOval(in rect: CGRect) -> UIBezierPath {
        let oval = UIBezierPath()
        let radius = rect.height / 2
        oval.addArc(withCenter:
            CGPoint(x: rect.minX + radius,
                    y: rect.minY + radius),
                    radius: radius,
                    startAngle: CGFloat.pi/2,
                    endAngle: CGFloat.pi*3/2,
                    clockwise: true)
        oval.addLine(to:
            CGPoint(x: rect.maxX - radius,
                    y: rect.minY))
        oval.addArc(withCenter:
            CGPoint(x: rect.maxX - radius,
                    y: rect.maxY - radius),
                    radius: radius,
                    startAngle: CGFloat.pi*3/2,
                    endAngle: CGFloat.pi/2,
                    clockwise: true)
        oval.close()
        return oval
    }
    
    private func pathForDiamond(in rect: CGRect) -> UIBezierPath {
        let diamond = UIBezierPath()
        diamond.move(to: CGPoint(x: rect.minX, y: rect.midY))
        diamond.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        diamond.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        diamond.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        diamond.close()
        return diamond
    }
    
    //      MARK: - Design
    
    private func configureState() {
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        isOpaque = false
        contentMode = .redraw
        
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        
        if isSelected {          // highlight selected card view
            layer.borderColor = Colors.selected
        }
        if let matched = isMatched { // highlight matched 3 cards
            if matched {
                layer.borderColor = Colors.matched
            } else {
                layer.borderColor = Colors.misMatched
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureState()
    }
    
    func hint() {
        layer.borderWidth = borderWidth
        layer.borderColor = Colors.hint
    }

}


//      MARK: Extensions
extension SetCardView {
    private struct SizeRatio {
        static let cornerRadiusToBoundsHeight: CGFloat = 0.05
        static let maxFaceSizeToBoundsSize: CGFloat = 0.75
        static let pipHeightToFaceHeight: CGFloat = 0.25
    }
    
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    
    private struct AspectRatio {
        static let faceFrame: CGFloat = 0.60
    }
    private var maxFaceFrame: CGRect {
        return bounds.zoom(by: SizeRatio.maxFaceSizeToBoundsSize)
    }
    private var faceFrame: CGRect {
        let faceWidth = maxFaceFrame.height * AspectRatio.faceFrame
        return maxFaceFrame.insetBy(dx: (maxFaceFrame.width - faceWidth)/2, dy: 0)
    }
    private var pipHeight: CGFloat {
        return faceFrame.height * SizeRatio.pipHeightToFaceHeight
    }
    private var interPipHeight: CGFloat {
        return (faceFrame.height - (3 * pipHeight)) / 2
    }
    
    private struct Colors {
        static let green = #colorLiteral(red: 0.129181236, green: 0.6996743083, blue: 0.3504030108, alpha: 1)
        static let red = #colorLiteral(red: 0.9316177368, green: 0.2258432508, blue: 0.2543458045, alpha: 1)
        static let purple = #colorLiteral(red: 0.2825651765, green: 0.1798718572, blue: 0.5736023784, alpha: 1)
        
        static let selected = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1).cgColor
        static let hint = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1).cgColor
        static let matched = #colorLiteral(red: 0.1960784314, green: 0.8431372549, blue: 0.2941176471, alpha: 1).cgColor
        static let misMatched = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1).cgColor
    }
}

extension CGRect {
    func zoom(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth)/2, dy: (height - newHeight)/2)
    }
}

extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        CGPoint(x: x+dx, y: y+dy)
    }
}
