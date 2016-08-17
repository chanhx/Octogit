//
//  SegmentHeaderView.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/14/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

enum SegmentTitle {
    case Repositories
    case Users
}

protocol SegmentHeaderViewDelegate {
    func headerView(view: SegmentHeaderView, didSelectSegmentTitle: SegmentTitle)
}

class SegmentHeaderView: UIView {
    
    var delegate: SegmentHeaderViewDelegate?
    var title: SegmentTitle = .Repositories {
        didSet {
            reposButton.selected = title == .Repositories
            usersButton.selected = title == .Users
            
            delegate?.headerView(self, didSelectSegmentTitle: title)
        }
    }
    
    let titleLabel = TTTAttributedLabel(frame: CGRectZero)
    let pickerView = UIPickerView()
    let reposButton = SegmentButton(type: .Custom)
    let usersButton = SegmentButton(type: .Custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = false
        backgroundColor = UIColor(netHex: 0xFAFAFA)
        
        configureSubviews()
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubviews() {
        titleLabel.font = UIFont.systemFontOfSize(14)
        titleLabel.linkAttributes = [
            NSForegroundColorAttributeName: UIColor(netHex: 0x4078C0),
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleNone.rawValue
        ]
        titleLabel.attributedText = Octicon.Flame.iconString("Trending For Today in All Languages", iconSize: 16, iconColor: UIColor.redColor())
        titleLabel.addLink(NSURL(string: "Time")!, toText: "Today")
        titleLabel.addLink(NSURL(string: "Language")!, toText: "All Languages")
        
        reposButton.setTitle("Repositories", forState: .Normal)
        reposButton.addTarget(self, action: #selector(SegmentHeaderView.buttonTouched(_:)), forControlEvents: .TouchUpInside)
        usersButton.setTitle("Users", forState: .Normal)
        usersButton.addTarget(self, action: #selector(SegmentHeaderView.buttonTouched(_:)), forControlEvents: .TouchUpInside)
    }
    
    func layout() {
        let separator = UIView()
        separator.backgroundColor = UIColor(netHex: 0xDDDDDD)
        separator.widthAnchor.constraintEqualToConstant(1).active = true
        
        let hStackView = UIStackView(arrangedSubviews: [reposButton, separator, usersButton])
        reposButton.widthAnchor.constraintEqualToAnchor(usersButton.widthAnchor).active = true
        hStackView.axis = .Horizontal
        hStackView.alignment = .Fill
        hStackView.distribution = .Fill
        
        addSubviews([titleLabel, hStackView])
        
        let margins = layoutMarginsGuide
        
        titleLabel.topAnchor.constraintEqualToAnchor(margins.topAnchor, constant: 10).active = true
        titleLabel.bottomAnchor.constraintEqualToAnchor(hStackView.topAnchor, constant: -12).active = true
        titleLabel.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor, constant: 8).active = true
        titleLabel.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor, constant: -8).active = true
        
        hStackView.bottomAnchor.constraintEqualToAnchor(bottomAnchor, constant: 1).active = true
        hStackView.leadingAnchor.constraintEqualToAnchor(leadingAnchor).active = true
        hStackView.trailingAnchor.constraintEqualToAnchor(trailingAnchor).active = true
        hStackView.heightAnchor.constraintEqualToConstant(43).active = true
    }
    
    func buttonTouched(button: UIButton) {
        if button.selected {return}
        
        title = reposButton.selected ? .Users : .Repositories
    }
    
    class SegmentButton: UIButton {
        private let topBorder = UIView()
        private let bottomBorder = UIView()
        
        override var selected: Bool {
            didSet {
                topBorder.hidden = !selected
                bottomBorder.hidden = selected
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            adjustsImageWhenHighlighted = false
            titleLabel?.font = UIFont.systemFontOfSize(17, weight: UIFontWeightMedium)
            setTitleColor(UIColor(netHex: 0x4078C0), forState: .Normal)
            setTitleColor(UIColor(netHex: 0x444444), forState: .Selected)
            setBackgroundImage(UIImage.imageWithColor(UIColor.whiteColor()), forState: .Selected)
            setBackgroundImage(UIImage.imageWithColor(UIColor(netHex: 0xFAFAFA)), forState: .Normal)
            
            addBorders()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func addBorders() {
            topBorder.hidden = true
            topBorder.backgroundColor = UIColor(netHex: 0xD26911)
            bottomBorder.backgroundColor = UIColor(netHex: 0xDDDDDD)
            self.addSubviews([topBorder, bottomBorder])
            
            topBorder.topAnchor.constraintEqualToAnchor(topAnchor).active = true
            topBorder.leadingAnchor.constraintEqualToAnchor(leadingAnchor).active = true
            topBorder.trailingAnchor.constraintEqualToAnchor(trailingAnchor).active = true
            topBorder.heightAnchor.constraintEqualToConstant(2).active = true
            
            bottomBorder.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
            bottomBorder.leadingAnchor.constraintEqualToAnchor(leadingAnchor).active = true
            bottomBorder.trailingAnchor.constraintEqualToAnchor(trailingAnchor).active = true
            bottomBorder.heightAnchor.constraintEqualToConstant(1).active = true
        }
    }
}
