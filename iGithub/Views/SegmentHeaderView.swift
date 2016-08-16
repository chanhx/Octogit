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
            switch title {
            case .Repositories:
                reposButton.selected = true
                usersButton.selected = false
            case .Users:
                usersButton.selected = true
                reposButton.selected = false
            }
            
            delegate?.headerView(self, didSelectSegmentTitle: title)
        }
    }
    
    let reposButton = TrendingButton(type: .Custom)
    let usersButton = TrendingButton(type: .Custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = false
        backgroundColor = UIColor(netHex: 0xFAFAFA)
        
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(14)
        label.attributedText = Octicon.Flame.iconString("Trending For Today in All Languages", iconSize: 16, iconColor: UIColor.redColor())
        
        reposButton.setTitle("Repositories", forState: .Normal)
        reposButton.addTarget(self, action: #selector(SegmentHeaderView.buttonTouched(_:)), forControlEvents: .TouchUpInside)
        usersButton.setTitle("Users", forState: .Normal)
        usersButton.addTarget(self, action: #selector(SegmentHeaderView.buttonTouched(_:)), forControlEvents: .TouchUpInside)
        
        let separator = UIView()
        separator.backgroundColor = UIColor(netHex: 0xDDDDDD)
        separator.widthAnchor.constraintEqualToConstant(1).active = true
        
        let hStackView = UIStackView(arrangedSubviews: [reposButton, separator, usersButton])
        reposButton.widthAnchor.constraintEqualToAnchor(usersButton.widthAnchor).active = true
        hStackView.axis = .Horizontal
        hStackView.alignment = .Fill
        hStackView.distribution = .Fill
        
        hStackView.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
        hStackView.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
        
        label.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
        label.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
        
        addSubviews([label, hStackView])
        
        let margins = layoutMarginsGuide
        
        label.topAnchor.constraintEqualToAnchor(margins.topAnchor, constant: 10).active = true
        label.bottomAnchor.constraintEqualToAnchor(hStackView.topAnchor, constant: -12).active = true
        label.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor, constant: 8).active = true
        label.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor, constant: -8).active = true
        
        hStackView.bottomAnchor.constraintEqualToAnchor(bottomAnchor, constant: 1).active = true
        hStackView.leadingAnchor.constraintEqualToAnchor(leadingAnchor).active = true
        hStackView.trailingAnchor.constraintEqualToAnchor(trailingAnchor).active = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonTouched(button: UIButton) {
        if button.selected {
            return
        }
                
        title = reposButton.selected ? .Users : .Repositories
    }

    class TrendingButton: UIButton {
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
