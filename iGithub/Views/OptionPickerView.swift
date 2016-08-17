//
//  OptionPickerView.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/17/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class OptionPickerView: UIView {
    
    let pickerView = UIPickerView()
    let toolBar = UIToolbar()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        pickerView.backgroundColor = UIColor.lightGrayColor()
        configureToolBar()
        addSubviews([pickerView, toolBar])
        
        toolBar.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        toolBar.bottomAnchor.constraintEqualToAnchor(pickerView.topAnchor).active = true
        toolBar.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        toolBar.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
        pickerView.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
        pickerView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        pickerView.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureToolBar() {
        let doneItem = UIBarButtonItem(barButtonSystemItem: .Done, target: nil, action: nil)
        let backItem = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: nil, action: nil)
        let forwardItem = UIBarButtonItem(image: UIImage(named: "forward"), style: .Plain, target: nil, action: nil)
        let fixSpace10 = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        let fixSpace30 = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        fixSpace10.width = 10
        fixSpace30.width = 30
        
        toolBar.setItems([fixSpace10, backItem, fixSpace30, forwardItem, flexibleSpace, doneItem, fixSpace10], animated: false)
    }
    
}
