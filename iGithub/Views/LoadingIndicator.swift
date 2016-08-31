//
//  LoadingIndicator.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/31/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class LoadingIndicator: UIView {
    
    var fromColor: UIColor
    var toColor: UIColor
    var lineWidth: CGFloat
    
    let gradations = 7
    
    init(fromColor: UIColor = .whiteColor(), toColor: UIColor = UIColor(netHex: 0x4078C0), lineWidth: CGFloat) {
        self.fromColor = fromColor
        self.toColor = toColor
        self.lineWidth = lineWidth
        
        super.init(frame: CGRectZero)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let circleLayer = CAShapeLayer()
        let arcCenter = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = (bounds.width > bounds.height ? bounds.height : bounds.width) / 2 - lineWidth
        let path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: 0, endAngle: 2 * CGFloat(M_PI), clockwise: true)
        
        circleLayer.path = path.CGPath
        circleLayer.strokeColor = UIColor(netHex: 0x4078C0).CGColor
        circleLayer.fillColor = UIColor.clearColor().CGColor
        circleLayer.lineWidth = lineWidth
        circleLayer.lineCap = kCALineCapRound
        circleLayer.strokeStart = 0.15
        circleLayer.strokeEnd = 0.95
        
        var locations = [Float]()
        let halfStep: Float = 1 / (Float(gradations) + 1)
        for i in 1...gradations / 2 + 1 {
            locations.append((Float(i) * 2 - 1) * halfStep)
        }
        
        let colors = gradientColors(fromColor, toColor: toColor, gradations: gradations)
        for i in 0...1 {
            let gradientLayer = CAGradientLayer()
            
            gradientLayer.startPoint = CGPointMake(0.0, 0.5)
            gradientLayer.endPoint = CGPointMake(1.0, 0.5)
            gradientLayer.frame = CGRectMake(0, bounds.height / 2 * CGFloat(1-i), bounds.width, bounds.height / 2)
            gradientLayer.colors = i == 0 ?
                Array(colors[0...gradations/2]).reverse() :
                Array(colors[gradations/2...gradations - 1])
            gradientLayer.locations = locations
            
            layer.addSublayer(gradientLayer)
        }
        
        layer.mask = circleLayer
        
        startAnimating()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimating() {
        let rotate = CABasicAnimation(keyPath: "transform.rotation")
        rotate.duration = 0.8
        rotate.fromValue = 0
        rotate.toValue = 2 * M_PI
        rotate.repeatCount = HUGE
        layer.addAnimation(rotate, forKey: nil)
    }
    
    func stopAnimating() {
        layer.removeAllAnimations()
    }
    
    func gradientColors(fromColor: UIColor, toColor: UIColor, gradations: Int = 3) -> [CGColor] {
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
            colors.append(color.CGColor)
        }
        
        return colors
    }
    
}
