//
//  OptionPickerView.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/17/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

@objc protocol OptionPickerViewDelegate: UIPickerViewDataSource, UIPickerViewDelegate {
    func doneButtonClicked(_ pickerView: OptionPickerView)
}

class OptionPickerView: UIView {
    
    let pickerView = UIPickerView()
    let toolBar = UIToolbar()
    
    lazy var background: UIView! = {
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hide)))
        return $0
    }(UIView(frame: UIApplication.shared.windows.last!.bounds))
    
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
    
    init(delegate: OptionPickerViewDelegate, optionsCount: Int = 1, index: Int = 0, selectedRow: [Int]? = nil) {
        
        self.delegate = delegate
        pickerView.dataSource = delegate
        pickerView.delegate = delegate
        
        self.selectedRow = selectedRow ?? Array(repeating: 0, count: optionsCount)
        tmpSelectedRow = Array(repeating: nil, count: optionsCount)
        self.index = index
        
        super.init(frame: CGRect.zero)
        
        pickerView.backgroundColor = UIColor(netHex: 0xDADADA)
        configureToolBar()
        addSubviews([pickerView, toolBar])
        
        NSLayoutConstraint.activate([
            toolBar.topAnchor.constraint(equalTo: topAnchor),
            toolBar.bottomAnchor.constraint(equalTo: pickerView.topAnchor),
            toolBar.leftAnchor.constraint(equalTo: leftAnchor),
            toolBar.rightAnchor.constraint(equalTo: rightAnchor),
            pickerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            pickerView.leftAnchor.constraint(equalTo: leftAnchor),
            pickerView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize : CGSize {
        return CGSize(
            width: toolBar.intrinsicContentSize.width,
            height: toolBar.intrinsicContentSize.height + pickerView.intrinsicContentSize.height
        )
    }
    
    func clearRecord() {
        tmpSelectedRow = Array(repeating: nil, count: tmpSelectedRow.count)
    }
    
    // MARK: toolbar

    fileprivate func configureToolBar() {
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneItemClicked))
        let previousItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(previousItemClicked(_:)))
        let nextItem = UIBarButtonItem(image: UIImage(named: "forward"), style: .plain, target: self, action: #selector(nextItemClicked(_:)))
        let fixSpace10 = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        let fixSpace30 = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        fixSpace10.width = 10
        fixSpace30.width = 30
        
        previousItem.isEnabled = index > 0
        nextItem.isEnabled = index < selectedRow.count - 1
        
        if selectedRow.count <= 1 {
            toolBar.setItems([flexibleSpace, doneItem, fixSpace10], animated: false)
        } else {
            toolBar.setItems([fixSpace10, previousItem, fixSpace30, nextItem, flexibleSpace, doneItem, fixSpace10], animated: false)
        }
    }
    
    @objc fileprivate func previousItemClicked(_ item: UIBarButtonItem) {
        index -= 1
    }
    
    @objc fileprivate func nextItemClicked(_ item: UIBarButtonItem) {
        index += 1
    }
    
    @objc fileprivate func doneItemClicked() {
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
        
        UIApplication.shared.windows.last?.addSubview(background)
        
        var pickerFrame = background.frame
        pickerFrame.origin.y = pickerFrame.height
        pickerFrame.size.height = self.intrinsicContentSize.height
        self.frame = pickerFrame
        self.pickerView.selectRow(self.selectedRow[self.index], inComponent: 0, animated: false)
        
        UIApplication.shared.windows.last?.addSubview(self)
        
        UIView.animate(withDuration: 0.2, animations: {
            pickerFrame.origin.y -= pickerFrame.size.height
            self.frame = pickerFrame
        }) 
    }
    
    func hide() {
        guard let _ = self.superview else {
            return
        }
        
        background.removeFromSuperview()
        
        UIView.animate(withDuration: 0.2, animations: {
            var frame = self.frame
            frame.origin.y += self.frame.height
            self.frame = frame
        }, completion: { _ in
            self.clearRecord()
            self.removeFromSuperview()
        }) 
    }
}
