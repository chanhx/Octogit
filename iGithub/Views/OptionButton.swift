//
//  OptionButton.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/18/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation

class OptionButton: GradientButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func commonInit() {
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -3, bottom: 0, right: 0)
        titleLabel?.lineBreakMode = .byTruncatingTail
        
        setImage(Octicon.triangleDown.image(color: UIColor(netHex: 0x333333), iconSize: 12, size: CGSize(width: 10, height: 10)), for: .normal)
        
        transform = CGAffineTransform(scaleX: -1, y: 1)
        titleLabel?.transform = CGAffineTransform(scaleX: -1, y: 1)
        imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
    }
    
    var optionTitle = ""
    var choice: String! {
        didSet {
            let attributedTitle = NSMutableAttributedString(string: "\(optionTitle): \(choice!)")
            attributedTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor(netHex: 0x818181),
                                         range: NSRange(location: 0, length: optionTitle.characters.count))
            
            setAttributedTitle(attributedTitle, for: .normal)
            
            let size = sizeThatFits(CGSize(width: 200, height: 27))
            var newFrame = frame
            let width = size.width > 177 ? 177 : size.width
            newFrame.size.width = width
            frame = newFrame
        }
    }
    
    override func draw(_ rect: CGRect) {
        var r = rect
        r.size.width = 177
        
        super.draw(r)
    }
}
