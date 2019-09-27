//
//  SearchBar.swift
//  Octogit
//
//  Created by Chan Hocheung on 21/09/2017.
//  Copyright © 2017 Hocheung. All rights reserved.
//

import UIKit

protocol SearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: SearchBar)
}

class SearchBar: UIView {
    
    private let icon = UITextField()
    private let textField = UITextField()
    
    var delegate: SearchBarDelegate?
    
    var placeholder: String? {
        set {
            textField.attributedPlaceholder = NSAttributedString(string: newValue ?? "",
                                                                 attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        }
        get {
            return textField.placeholder
        }
    }
    var text: String? {
        set {
            textField.text = newValue
        }
        get {
            return textField.text
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var size = UIView.layoutFittingExpandedSize
        size.height = 28
        return size
    }
    
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        return textField.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        return textField.resignFirstResponder()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor(white: 1.0, alpha: 0.6)
        layer.masksToBounds = true
        layer.cornerRadius = 5
        
        configureSubviews()
        setLayout()
    }
    
    private func configureSubviews() {
        icon.isUserInteractionEnabled = false
        icon.textAlignment = .center
        icon.font = UIFont.OcticonOfSize(13)
        icon.textColor = UIColor.gray
        icon.text = Octicon.search.rawValue
        
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.enablesReturnKeyAutomatically = true
        textField.returnKeyType = .search
        textField.delegate = self
        textField.clearButtonMode = .always
        
        addSubviews([icon, textField])
    }
    
    private func setLayout() {
        
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 13),
            icon.heightAnchor.constraint(equalToConstant: 14),

            icon.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            icon.rightAnchor.constraint(equalTo: textField.leftAnchor, constant: -8),
            icon.centerYAnchor.constraint(equalTo: textField.centerYAnchor),

            textField.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            textField.rightAnchor.constraint(equalTo: rightAnchor),
        ])
    }
}

extension SearchBar: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        delegate?.searchBarSearchButtonClicked(self)
        return false
    }
}
