//
//  SegmentHeaderView.swift
//  Octogit
//
//  Created by Chan Hocheung on 8/14/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import TTTAttributedLabel

enum TrendingType {
    case repositories
    case users
}

protocol SegmentHeaderViewDelegate: class {
    func headerView(_ view: SegmentHeaderView, didSelectSegmentTitle: TrendingType)
}

class SegmentHeaderView: UIView {
    
    weak var delegate: SegmentHeaderViewDelegate?
    var title: TrendingType = .repositories {
        didSet {
            reposButton.isSelected = title == .repositories
            usersButton.isSelected = title == .users
            
            delegate?.headerView(self, didSelectSegmentTitle: title)
        }
    }
    
    let titleLabel = TTTAttributedLabel(frame: CGRect.zero)
    let reposButton = SegmentButton(type: .custom)
    let usersButton = SegmentButton(type: .custom)
    
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
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.layer.isOpaque = true
        titleLabel.backgroundColor = backgroundColor
        titleLabel.linkAttributes = [NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x4078C0)]
        
        reposButton.setTitle("Repositories", for: UIControl.State())
        reposButton.addTarget(self, action: #selector(SegmentHeaderView.buttonTouched(_:)), for: .touchUpInside)
        usersButton.setTitle("Users", for: UIControl.State())
        usersButton.addTarget(self, action: #selector(SegmentHeaderView.buttonTouched(_:)), for: .touchUpInside)
    }
    
    func layout() {
        let separator = UIView()
        separator.backgroundColor = UIColor(netHex: 0xDDDDDD)
        
        let hStackView = UIStackView(arrangedSubviews: [reposButton, separator, usersButton])
        hStackView.axis = .horizontal
        hStackView.alignment = .fill
        hStackView.distribution = .fill
        
        addSubviews([titleLabel, hStackView])
        
        let margins = layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            separator.widthAnchor.constraint(equalToConstant: 1),
            
            reposButton.widthAnchor.constraint(equalTo: usersButton.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: hStackView.topAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -8),
            
            hStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 1),
            hStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hStackView.heightAnchor.constraint(equalToConstant: 43)
        ])
    }
    
    @objc func buttonTouched(_ button: UIButton) {
        if button.isSelected {return}
        
        title = reposButton.isSelected ? .users : .repositories
    }
    
    class SegmentButton: UIButton {
        fileprivate let topBorder = UIView()
        fileprivate let bottomBorder = UIView()
        
        override var isSelected: Bool {
            didSet {
                topBorder.isHidden = !isSelected
                bottomBorder.isHidden = isSelected
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            adjustsImageWhenHighlighted = false
            titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.medium)
            setTitleColor(UIColor(netHex: 0x4078C0), for: UIControl.State())
            setTitleColor(UIColor(netHex: 0x444444), for: .selected)
            setBackgroundImage(UIImage.imageWithColor(UIColor.white), for: .selected)
            setBackgroundImage(UIImage.imageWithColor(UIColor(netHex: 0xFAFAFA)), for: UIControl.State())
            
            addBorders()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func addBorders() {
            topBorder.isHidden = true
            topBorder.backgroundColor = UIColor(netHex: 0xD26911)
            bottomBorder.backgroundColor = UIColor(netHex: 0xDDDDDD)
            self.addSubviews([topBorder, bottomBorder])
            
            NSLayoutConstraint.activate([
                topBorder.topAnchor.constraint(equalTo: topAnchor),
                topBorder.leadingAnchor.constraint(equalTo: leadingAnchor),
                topBorder.trailingAnchor.constraint(equalTo: trailingAnchor),
                topBorder.heightAnchor.constraint(equalToConstant: 2),
                
                bottomBorder.bottomAnchor.constraint(equalTo: bottomAnchor),
                bottomBorder.leadingAnchor.constraint(equalTo: leadingAnchor),
                bottomBorder.trailingAnchor.constraint(equalTo: trailingAnchor),
                bottomBorder.heightAnchor.constraint(equalToConstant: 1)
            ])
        }
    }
}
