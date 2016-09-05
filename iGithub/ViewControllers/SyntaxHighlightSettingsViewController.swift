//
//  SyntaxHighlightSettingsViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 9/4/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SyntaxHighlightSettingsViewController: UITableViewController {
    
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var lineNumbersSwitch: UISwitch!
    @IBOutlet weak var webView: UIWebView!
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    let disposeBag = DisposeBag()
    
    lazy var themes: [String] = {
        let path = NSBundle.mainBundle().pathForResource("themes", ofType: "plist")
        return NSArray(contentsOfFile: path!) as! [String]
    }()
    
    let sample: String = {
        let path = NSBundle.mainBundle().pathForResource("sample", ofType: "")
        return try! String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
    }()
    
    var rendering: String {
        get {
            return Renderer.render(sample, language: "c", theme: themeLabel.text, showLineNumbers: lineNumbersSwitch.on)
        }
    }
    
    lazy var pickerView: OptionPickerView = OptionPickerView(delegate:self, optionsCount: 1)
    lazy var background: UIView! = {
        let background = UIView(frame: self.navigationController!.view.window!.bounds)
        background.frame = self.view.bounds
        background.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removePickerView)))
        background.addGestureRecognizer(UIPanGestureRecognizer(target: nil, action: nil))
        return background
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        themeLabel.text = userDefaults.objectForKey(Constants.kTheme) as? String
        lineNumbersSwitch.on = userDefaults.boolForKey(Constants.kLineNumbers)
        webView.scrollView.scrollEnabled = false

        lineNumbersSwitch.rx_value.subscribeNext { _ in
            self.renderSample()
        }
        .addDisposableTo(disposeBag)
        
        renderSample()
    }
    
    override func viewDidDisappear(animated: Bool) {
        userDefaults.setObject(themeLabel.text, forKey: Constants.kTheme)
        userDefaults.setBool(lineNumbersSwitch.on, forKey: Constants.kLineNumbers)
        super.viewDidDisappear(animated)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.row == 0 else {
            return
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        showPickerView()
    }
    
    func renderSample() {
        webView.loadHTMLString(rendering, baseURL: NSBundle.mainBundle().resourceURL)
    }
}

extension SyntaxHighlightSettingsViewController: OptionPickerViewDelegate {
    
    func doneButtonClicked() {
        themeLabel.text = themes[self.pickerView.tmpSelectedRow[0]!]
        removePickerView()
        
        pickerView.clearRecord()
        
        renderSample()
    }
    
    func removePickerView() {
        background.removeFromSuperview()
        
        UIView.animateWithDuration(0.2, animations: {
            var frame = self.pickerView.frame
            frame.origin.y += self.pickerView.frame.height
            self.pickerView.frame = frame
        }) { _ in
            self.pickerView.clearRecord()
            self.pickerView.removeFromSuperview()
        }
    }
    
    func showPickerView() {
        UIApplication.sharedApplication().windows.last?.addSubview(background)
        
        var pickerFrame = view.frame
        pickerFrame.origin.y = view.frame.height
        pickerFrame.size.height = pickerView.intrinsicContentSize().height
        pickerView.frame = pickerFrame
        
        UIApplication.sharedApplication().windows.last?.addSubview(pickerView)
        
        UIView.animateWithDuration(0.2) {
            pickerFrame.origin.y -= pickerFrame.size.height
            self.pickerView.frame = pickerFrame
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return themes.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return themes[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.pickerView.tmpSelectedRow[self.pickerView.index] = row
    }
}
