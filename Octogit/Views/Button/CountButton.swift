//
//  CountButton.swift
//  Octogit
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
        self.titleLabel?.lineBreakMode = .byWordWrapping
        self.titleLabel?.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.lineBreakMode = .byWordWrapping
        self.titleLabel?.textAlignment = .center
    }
    
    func setTitle(_ count: Int?, title: String) {
        
        var countText: String
        if count == nil {
           return
        } else if abbreviative && count != nil && count! > 1000 {
            countText = String(format: "%.1fk", Double(count!) / 1000)
        } else {
            countText = "\(count!)"
        }
        
        let attributedNumber = NSMutableAttributedString(string: "\(countText)\n",
                                                         attributes: [
                                                            NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x4078C0),
                                                            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)])
        
        let attributedTitle = NSAttributedString(string: title,
                                                 attributes: [
                                                    NSAttributedString.Key.foregroundColor: UIColor.gray,
                                                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)])
        
        attributedNumber.append(attributedTitle)
        
        setAttributedTitle(attributedNumber, for: UIControl.State())
    }
    
}
