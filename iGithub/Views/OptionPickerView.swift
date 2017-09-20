//
//  OptionPickerView.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/17/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import RxSwift

@objc protocol OptionPickerViewDelegate: UIPickerViewDataSource, UIPickerViewDelegate {
    func doneButtonClicked(_ pickerView: OptionPickerView)
}

class OptionPickerView: UIPickerView {
    
    var selectedRows: [Int]
    var index: Int {
        didSet {
            reloadAllComponents()
            selectRow(tmpSelectedRows[index], inComponent: 0, animated: false)
            configureToolBar()
        }
    }
    
    private lazy var background: UIView! = {
        $0.backgroundColor = UIColor(white: 0.3, alpha: 0.6)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hide)))
        return $0
    }(UIView(frame: UIApplication.shared.windows.last!.bounds))
    
    private var tmpSelectedRows: [Int]
    
    private let disposeBag = DisposeBag()
    private let toolBar = UIToolbar()
    private weak var pickerDelegate: OptionPickerViewDelegate?
    
    init(delegate: OptionPickerViewDelegate, optionsCount: Int = 1, index: Int = 0, selectedRows: [Int]? = nil) {
        
        self.pickerDelegate = delegate
        
        self.selectedRows = selectedRows ?? Array(repeating: 0, count: optionsCount)
        tmpSelectedRows = self.selectedRows
        self.index = index
        
        super.init(frame: CGRect.zero)
        
        dataSource = delegate
        super.delegate = delegate
        
        rx.itemSelected.asObservable().subscribe(onNext: { [unowned self] in
            self.tmpSelectedRows[self.index] = $0.0
        }).addDisposableTo(disposeBag)
        
        clipsToBounds = false
        backgroundColor = UIColor(netHex: 0xDADADA)
        
        toolBar.backgroundColor = UIColor(netHex: 0xf8f8f8)
        configureToolBar()
        addSubview(toolBar)
        
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toolBar.bottomAnchor.constraint(equalTo: topAnchor),
            toolBar.leftAnchor.constraint(equalTo: leftAnchor),
            toolBar.rightAnchor.constraint(equalTo: rightAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clearRecord() {
        tmpSelectedRows = selectedRows
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !self.clipsToBounds && !self.isHidden && self.alpha > 0.0 {
            let subviews = self.subviews.reversed()
            for subview in subviews {
                let subPoint = subview.convert(point, from: self)
                if let result = subview.hitTest(subPoint, with: event) {
                    return result
                }
            }
        }
        
        return nil
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
        nextItem.isEnabled = index < selectedRows.count - 1
        
        if selectedRows.count <= 1 {
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
        selectedRows = tmpSelectedRows
        
        self.hide()
        pickerDelegate?.doneButtonClicked(self)
    }
    
    // MARK: show and hide
    
    @objc func show() {
        if let _ = self.superview {
            return
        }
        
        UIApplication.shared.windows.last?.addSubview(background)
        
        var pickerFrame = background.frame
        pickerFrame.origin.y = pickerFrame.height
        pickerFrame.size.height = intrinsicContentSize.height
        self.frame = pickerFrame
        self.selectRow(self.selectedRows[self.index], inComponent: 0, animated: false)
        
        UIApplication.shared.windows.last?.addSubview(self)
        
        UIView.animate(withDuration: 0.2, animations: {
            pickerFrame.origin.y -= pickerFrame.size.height
            self.frame = pickerFrame
        }) 
    }
    
    @objc func hide() {
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
