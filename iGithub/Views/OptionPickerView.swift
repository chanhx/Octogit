//
//  OptionPickerView.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/17/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

@objc protocol OptionPickerViewDelegate: UIPickerViewDataSource, UIPickerViewDelegate {
    func doneButtonClicked(pickerView: OptionPickerView)
}

class OptionPickerView: UIView {
    
    let pickerView = UIPickerView()
    let toolBar = UIToolbar()
    
    lazy var background: UIView! = {
        let background = UIView(frame: UIApplication.sharedApplication().windows.last!.bounds)
        background.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hide)))
        return background
    }()
    
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
    
    init(delegate: OptionPickerViewDelegate, optionsCount: Int = 1, index: Int = 0) {
        
        self.delegate = delegate
        pickerView.dataSource = delegate
        pickerView.delegate = delegate
        
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
        tmpSelectedRow = Array(count: tmpSelectedRow.count, repeatedValue: nil)
    }
    
    // MARK: toolbar

    private func configureToolBar() {
        let doneItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(doneItemClicked))
        let previousItem = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, action: #selector(previousItemClicked(_:)))
        let nextItem = UIBarButtonItem(image: UIImage(named: "forward"), style: .Plain, target: self, action: #selector(nextItemClicked(_:)))
        let fixSpace10 = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        let fixSpace30 = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        fixSpace10.width = 10
        fixSpace30.width = 30
        
        previousItem.enabled = index > 0
        nextItem.enabled = index < selectedRow.count - 1
        
        if selectedRow.count <= 1 {
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
    
    @objc private func doneItemClicked() {
        for i in 0..<selectedRow.count {
            selectedRow[i] = tmpSelectedRow[i] ?? selectedRow[i]
        }
        
        self.hide()
        delegate?.doneButtonClicked(self)
    }
    
    // MARK: show and hide
    
    func show() {
        if let _ = self.superview {
            return
        }
        
        UIApplication.sharedApplication().windows.last?.addSubview(background)
        
        var pickerFrame = background.frame
        pickerFrame.origin.y = pickerFrame.height
        pickerFrame.size.height = self.intrinsicContentSize().height
        self.frame = pickerFrame
        self.pickerView.selectRow(self.selectedRow[self.index], inComponent: 0, animated: false)
        
        UIApplication.sharedApplication().windows.last?.addSubview(self)
        
        UIView.animateWithDuration(0.2) {
            pickerFrame.origin.y -= pickerFrame.size.height
            self.frame = pickerFrame
        }
    }
    
    func hide() {
        guard let _ = self.superview else {
            return
        }
        
        background.removeFromSuperview()
        
        UIView.animateWithDuration(0.2, animations: {
            var frame = self.frame
            frame.origin.y += self.frame.height
            self.frame = frame
        }) { _ in
            self.clearRecord()
            self.removeFromSuperview()
        }
    }
}
