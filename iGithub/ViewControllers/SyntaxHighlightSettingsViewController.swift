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
        return Renderer.render(sample, language: "c", theme: themeLabel.text, showLineNumbers: lineNumbersSwitch.on)
    }
    
    lazy var pickerView: OptionPickerView = OptionPickerView(delegate:self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        themeLabel.text = userDefaults.objectForKey(Constants.kTheme) as? String
        lineNumbersSwitch.on = userDefaults.boolForKey(Constants.kLineNumbers)
        webView.scrollView.scrollEnabled = false
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.pickerView.selectedRow[0] = self.themes.indexOf(self.themeLabel.text!) ?? 0
        }

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
        self.pickerView.show()
    }
    
    func renderSample() {
        webView.loadHTMLString(rendering, baseURL: NSBundle.mainBundle().resourceURL)
    }
}

extension SyntaxHighlightSettingsViewController: OptionPickerViewDelegate {
    
    func doneButtonClicked(pickerView: OptionPickerView) {
        themeLabel.text = themes[pickerView.selectedRow[0]]
        
        renderSample()
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
        self.pickerView.tmpSelectedRow[0] = row
    }
}
