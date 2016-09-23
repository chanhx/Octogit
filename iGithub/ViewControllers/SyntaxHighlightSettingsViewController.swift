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
    let webViewCell = WebViewCell()
    
    let userDefaults = UserDefaults.standard
    
    let disposeBag = DisposeBag()
    
    lazy var themes: [String] = {
        let path = Bundle.main.path(forResource: "themes", ofType: "plist")
        return NSArray(contentsOfFile: path!) as! [String]
    }()
    
    let sample: String = {
        let path = Bundle.main.path(forResource: "sample", ofType: "")
        return try! String(contentsOfFile: path!, encoding: String.Encoding.utf8)
    }()
    
    var rendering: String {
        return Renderer.render(sample, language: "c", theme: themeLabel.text, showLineNumbers: lineNumbersSwitch.isOn)
    }
    
    lazy var pickerView: OptionPickerView = OptionPickerView(delegate:self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        themeLabel.text = userDefaults.object(forKey: Constants.kTheme) as? String
        lineNumbersSwitch.isOn = userDefaults.bool(forKey: Constants.kLineNumbers)
        
        webViewCell.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 230)
        webViewCell.webView.isOpaque = false
        tableView.tableFooterView = webViewCell
        
        DispatchQueue.global(qos: .default).async {
            self.pickerView.selectedRow[0] = self.themes.index(of: self.themeLabel.text!) ?? 0
        }

        lineNumbersSwitch.rx.value.subscribe { _ in
            self.renderSample()
        }
        .addDisposableTo(disposeBag)
        
        renderSample()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        userDefaults.set(themeLabel.text, forKey: Constants.kTheme)
        userDefaults.set(lineNumbersSwitch.isOn, forKey: Constants.kLineNumbers)
        super.viewDidDisappear(animated)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard (indexPath as NSIndexPath).row == 0 else {
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.pickerView.show()
    }
    
    func renderSample() {
        webViewCell.webView.loadHTMLString(rendering, baseURL: Bundle.main.resourceURL)
    }
}

extension SyntaxHighlightSettingsViewController: OptionPickerViewDelegate {
    
    func doneButtonClicked(_ pickerView: OptionPickerView) {
        themeLabel.text = themes[pickerView.selectedRow[0]]
        
        renderSample()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return themes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return themes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.pickerView.tmpSelectedRow[0] = row
    }
}
