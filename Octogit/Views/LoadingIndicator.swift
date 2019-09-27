//
//  LoadingIndicator.swift
//  Octogit
//
//  Created by Chan Hocheung on 8/31/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class LoadingIndicator: UIView {
    
    fileprivate var fromColor: UIColor
    fileprivate var toColor: UIColor
    fileprivate var lineWidth: CGFloat
    
    fileprivate let circleLayer = CAShapeLayer()
    fileprivate let gradations = 7
    fileprivate var strokeEnd: CGFloat
    
    init(fromColor: UIColor = .white, toColor: UIColor = UIColor(netHex: 0x4078C0), lineWidth: CGFloat = 3, strokeEnd: CGFloat = 0.95) {
        self.fromColor = fromColor
        self.toColor = toColor
        self.lineWidth = lineWidth
        self.strokeEnd = strokeEnd
        
        super.init(frame: CGRect.zero)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let arcCenter = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = (bounds.width > bounds.height ? bounds.height : bounds.width) / 2 - lineWidth
        let path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: CGFloat(-Double.pi / 2), endAngle: 3 * CGFloat(Double.pi / 2), clockwise: true)
        
        circleLayer.path = path.cgPath
        circleLayer.strokeColor = UIColor(netHex: 0x4078C0).cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = lineWidth
        circleLayer.lineCap = CAShapeLayerLineCap.round
        circleLayer.strokeStart = 0.15
        circleLayer.strokeEnd = strokeEnd
        
        var locations = [Float]()
        let halfStep: Float = 1 / (Float(gradations) + 1)
        for i in 1...gradations / 2 + 1 {
            locations.append((Float(i) * 2 - 1) * halfStep)
        }
        
        let colors = gradientColors(fromColor, toColor: toColor, gradations: gradations)
        for i in 0...1 {
            let gradientLayer = CAGradientLayer()
            
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.frame = CGRect(x: bounds.width / 2 * CGFloat(i), y: 0, width: bounds.width / 2, height: bounds.height)
            gradientLayer.colors = i == 0 ?
                Array(colors[gradations/2...gradations - 1]) :
                Array(colors[0...gradations/2]).reversed()
            gradientLayer.locations = locations as [NSNumber]?
            
            layer.addSublayer(gradientLayer)
        }
        
        layer.mask = circleLayer
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetStrokeEnd() {
        circleLayer.strokeEnd = self.strokeEnd
    }
    
    func updateStrokeEnd(_ strokeEnd: CGFloat) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = strokeEnd
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        
        circleLayer.add(animation, forKey: nil)
    }
    
    func startAnimating() {
        let rotate = CABasicAnimation(keyPath: "transform.rotation")
        rotate.duration = 0.8
        rotate.fromValue = 0
        rotate.toValue = 2 * Double.pi
        rotate.repeatCount = HUGE
        rotate.isRemovedOnCompletion = false
        layer.add(rotate, forKey: nil)
    }
    
    func stopAnimating() {
        layer.removeAllAnimations()
    }
    
    func gradientColors(_ fromColor: UIColor, toColor: UIColor, gradations: Int = 3) -> [CGColor] {
        var colors = [CGColor]()
        
        var fromRed: CGFloat = 0
        var fromGreen: CGFloat = 0
        var fromBlue: CGFloat = 0
        
        var toRed: CGFloat = 0
        var toGreen: CGFloat = 0
        var toBlue: CGFloat = 0
        
        fromColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: nil)
        toColor.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: nil)
        
        let redDiff = toRed - fromRed
        let greenDiff = toGreen - fromGreen
        let blueDiff = toBlue - fromBlue
        
        let n = gradations - 1
        for i in 0...n {
            let color = UIColor(red: fromRed + redDiff / CGFloat(n) * CGFloat(i),
                                green: fromGreen + greenDiff / CGFloat(n) * CGFloat(i),
                                blue: fromBlue + blueDiff / CGFloat(n) * CGFloat(i),
                                alpha: 1.0)
            colors.append(color.cgColor)
        }
        
        return colors
    }
    
}
