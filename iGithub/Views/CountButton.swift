//
//  CountButton.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/28/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class CountButton: UIButton {

    var count: Int!
    var text: String!
    
    var abbreviative = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.lineBreakMode = .ByWordWrapping
        self.titleLabel?.textAlignment = .Center
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.lineBreakMode = .ByWordWrapping
        self.titleLabel?.textAlignment = .Center
    }
    
    func setTitle(count: Int?, title: String) {
        
        var countText: String
        if count == nil {
           countText = ""
        } else if abbreviative && count > 1000 {
            countText = String(format: "%.1gk", Double(count!) / 1000)
        } else {
            countText = "\(count!)"
        }
        
        let attributedNumber = NSMutableAttributedString(string: "\(countText)\n",
                                                         attributes: [
                                                            NSForegroundColorAttributeName: UIColor(netHex: 0x4078C0),
                                                            NSFontAttributeName: UIFont.boldSystemFontOfSize(20)])
        
        let attributedTitle = NSAttributedString(string: title,
                                                 attributes: [
                                                    NSForegroundColorAttributeName: UIColor.grayColor(),
                                                    NSFontAttributeName: UIFont.systemFontOfSize(12)])
        
        attributedNumber.appendAttributedString(attributedTitle)
        
        setAttributedTitle(attributedNumber, forState: .Normal)
    }
    
}
