//
//  IssueViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/1/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import WebKit
import RxSwift

class IssueViewController: BaseTableViewController, WKNavigationDelegate {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    
    var contentHeight = Variable<CGFloat>(0)
    
    let disposeBag = DisposeBag()
    var viewModel: IssueViewModel! {
        didSet {
            viewModel.fetchData()
            
            viewModel.dataSource.asObservable()
                .skipWhile { $0.count <= 0 }
                .subscribe { _ in
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        
                        self.sizeHeaderToFit(tableView: self.tableView)
                    }
                }
                .addDisposableTo(viewModel.disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "#\(viewModel.issue.number!)"
        tableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        
        configureHeader()
        
        sizeHeaderToFit(tableView: tableView)
        
        contentHeight.asObservable()
            .skip(1)
            .distinctUntilChanged()
            .subscribe { _ in
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                    self.sizeHeaderToFit(tableView: self.tableView)
                }
            }.addDisposableTo(disposeBag)
    }
    
    func configureHeader() {
        
        switch viewModel.issue.state! {
        case .closed:
            statusLabel.text = Octicon.issueclosed.rawValue
            statusLabel.textColor = UIColor(netHex: 0xBD2C00)
        case .open:
            statusLabel.text = Octicon.issueopened.rawValue
            statusLabel.textColor = UIColor(netHex: 0x6CC644)
        }
        
        titleLabel.text = viewModel.issue.title
        
        userAvatar.setAvatar(with: viewModel.issue.user?.avatarURL)
        
        let attrInfo = NSMutableAttributedString(string: "\(viewModel.issue.user!) opened this issue \(viewModel.issue.createdAt!.naturalString)")
        attrInfo.addAttributes([
            NSForegroundColorAttributeName: UIColor(netHex: 0x555555),
            NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)
            ],
                              range: NSRange(location: 0, length: viewModel.issue.user!.login!.characters.count))
        
        infoLabel.attributedText = attrInfo
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : viewModel.dataSource.value.count //viewModel.numberOfRowsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section, indexPath.row) == (0, 0) {
            return contentHeight.value
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WebViewCell", for: indexPath) as! WebViewCell
            cell.webView.loadHTMLString(viewModel.contentHTML, baseURL: Bundle.main.resourceURL)
            cell.webView.navigationDelegate = self
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
            cell.selectionStyle = .none
            cell.entity = viewModel.dataSource.value[indexPath.row]
            
            return cell
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        contentHeight.value = webView.scrollView.contentSize.height
    }
}
