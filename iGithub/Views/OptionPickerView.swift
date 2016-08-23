//
//  OptionPickerView.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/17/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

@objc protocol OptionPickerViewDelegate: UIPickerViewDataSource, UIPickerViewDelegate {
    func doneButtonClicked()
}

class OptionPickerView: UIView {
    
    let pickerView = UIPickerView()
    let toolBar = UIToolbar()
    
    var options: [String?]
    var selectedRow: [Int]
    var tmpSelectedRow: [Int?]
    var index: Int {
        didSet {
            pickerView.reloadAllComponents()
            pickerView.selectRow(tmpSelectedRow[index] ?? selectedRow[index], inComponent: 0, animated: false)
            configureToolBar()
        }
    }
    weak var delegate: OptionPickerViewDelegate?
    
    init(delegate: OptionPickerViewDelegate, optionsCount: Int, index: Int = 0) {
        
        self.delegate = delegate
        pickerView.dataSource = delegate
        pickerView.delegate = delegate
        
        options = Array(count: optionsCount, repeatedValue: nil)
        selectedRow = Array(count: optionsCount, repeatedValue: 0)
        tmpSelectedRow = Array(count: optionsCount, repeatedValue: nil)
        self.index = index
        
        super.init(frame: CGRectZero)
        
        pickerView.backgroundColor = UIColor(netHex: 0xDADADA)
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
    
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(
            toolBar.intrinsicContentSize().width,
            toolBar.intrinsicContentSize().height + pickerView.intrinsicContentSize().height
        )
    }
    
    func clearRecord() {
        options = Array(count: tmpSelectedRow.count, repeatedValue: nil)
        tmpSelectedRow = Array(count: tmpSelectedRow.count, repeatedValue: nil)
    }
    
    // MARK: toolbar

    private func configureToolBar() {
        let doneItem = UIBarButtonItem(barButtonSystemItem: .Done, target: delegate, action: #selector(delegate?.doneButtonClicked))
        let previousItem = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, action: #selector(previousItemClicked(_:)))
        let nextItem = UIBarButtonItem(image: UIImage(named: "forward"), style: .Plain, target: self, action: #selector(nextItemClicked(_:)))
        let fixSpace10 = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        let fixSpace30 = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        fixSpace10.width = 10
        fixSpace30.width = 30
        
        previousItem.enabled = index > 0
        nextItem.enabled = index < options.count - 1
        
        if options.count <= 1 {
            toolBar.setItems([flexibleSpace, doneItem, fixSpace10], animated: false)
        } else {
            toolBar.setItems([fixSpace10, previousItem, fixSpace30, nextItem, flexibleSpace, doneItem, fixSpace10], animated: false)
        }
    }
    
    @objc private func previousItemClicked(item: UIBarButtonItem) {
        index -= 1
    }
    
    @objc private func nextItemClicked(item: UIBarButtonItem) {
        index += 1
    }
}
